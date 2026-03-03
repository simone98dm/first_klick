import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:first_klick/shared/app_constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../database/app_database.dart';
import '../gps/haversine.dart';
import '../gps/gps_service.dart';
import '../../shared/logging_service.dart';
import 'service_messages.dart';

// ── Initialisation (called once from main.dart) ───────────────────────────

Future<void> initBackgroundService() async {
  try {
    LoggingService.info('Initializing background service...');
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'first_klick_run',
        initialNotificationTitle: 'First Klick',
        initialNotificationContent: 'Preparing…',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        onForeground: _onStart,
        onBackground: _onIosBackground,
        autoStart: false,
      ),
    );
    LoggingService.info('Background service initialized successfully');
  } catch (e, stackTrace) {
    LoggingService.fatal(
        'Failed to initialize background service', e, stackTrace);
    rethrow;
  }
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async => true;

// ── Service entry point ───────────────────────────────────────────────────

const _kNotifId = 888;
const _kNotifTitle = 'First Klick — Recording';

// Auto-pause thresholds
const double _kAutoPauseSpeedMs = 0.5;  // m/s ≈ 1.8 km/h
const double _kAutoResumeSpeedMs = 1.0; // m/s ≈ 3.6 km/h (hysteresis gap)
const int _kSlowReadingsToAutoPause = 2; // consecutive slow readings before pausing

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  LoggingService.info('Background service starting...');
  final db = AppDatabase();
  LoggingService.debug('Database initialized in background service');

  // Initialise local notifications for iOS so we can update the persistent
  // notification content from this background isolate.
  if (Platform.isIOS) {
    const initSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await FlutterLocalNotificationsPlugin().initialize(initSettings);
    LoggingService.debug('flutter_local_notifications initialised on iOS');
  }

  // State
  int? activityId;
  double cumulativeDistanceM = 0;
  Position? prevPosition;
  int? latestBpm;
  DateTime? startTime;
  int pausedAccumulatedS = 0;
  bool paused = false;
  bool autoPaused = false;      // true when paused by the speed detector
  int slowReadingsCount = 0;    // consecutive GPS readings below auto-pause threshold
  String? bleDeviceId;

  // BLE state
  BluetoothDevice? bleDevice;
  StreamSubscription<List<int>>? hrSub;
  StreamSubscription<BluetoothConnectionState>? connSub;
  Timer? bleReconnectTimer;

  // ── Helper: update foreground notification ────────────────────────────
  void updateNotification(String content) {
    if (content.isEmpty) return;
    try {
      if (service is AndroidServiceInstance) {
        // Android: update the required foreground-service notification in place.
        service.setForegroundNotificationInfo(
          title: _kNotifTitle,
          content: content,
        );
      } else if (Platform.isIOS) {
        // iOS: re-post a local notification with the same ID so it updates
        // in the notification centre without showing a new banner.
        FlutterLocalNotificationsPlugin().show(
          _kNotifId,
          _kNotifTitle,
          content,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: false,
              presentBadge: false,
              presentSound: false,
              interruptionLevel: InterruptionLevel.passive,
            ),
          ),
        );
      }
      LoggingService.debug('Updated notification: $content');
    } catch (e, stackTrace) {
      LoggingService.error(
          'Failed to update foreground notification', e, stackTrace);
    }
  }

  // ── BLE helpers ───────────────────────────────────────────────────────
  Future<void> subscribeHr(BluetoothDevice dev) async {
    try {
      LoggingService.debug('Subscribing to heart rate service...');
      final services = await dev.discoverServices();
      for (final s in services) {
        if (s.uuid.str128.toLowerCase() == kHeartRateServiceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid.str128.toLowerCase() == kHeartRateMeasurementUuid) {
              await c.setNotifyValue(true);
              hrSub = c.lastValueStream.listen((data) {
                try {
                  if (data.isEmpty) return;
                  final flags = data[0];
                  final isUint16 = (flags & 0x01) != 0;
                  latestBpm = isUint16 ? (data[2] << 8) | data[1] : data[1];
                  LoggingService.debug('Received BPM: $latestBpm');
                } catch (e, stackTrace) {
                  LoggingService.error(
                      'Error processing heart rate data', e, stackTrace);
                }
              });
              LoggingService.info(
                  'Successfully subscribed to heart rate service');
              return;
            }
          }
        }
      }
      LoggingService.warning('Heart rate service not found on device');
    } catch (e, stackTrace) {
      LoggingService.error(
          'Failed to subscribe to heart rate service', e, stackTrace);
    }
  }

  void scheduleBleReconnect() {
    try {
      LoggingService.debug('Scheduling BLE reconnect...');
      bleReconnectTimer?.cancel();
      bleReconnectTimer = Timer(const Duration(seconds: 5), () async {
        try {
          if (bleDeviceId == null) return;
          LoggingService.info('Attempting BLE reconnect...');
          await bleDevice?.connect(timeout: const Duration(seconds: 10));
          await subscribeHr(bleDevice!);
          LoggingService.info('BLE reconnect successful');
        } catch (e, stackTrace) {
          LoggingService.error(
              'BLE reconnect failed, scheduling next attempt', e, stackTrace);
          scheduleBleReconnect();
        }
      });
    } catch (e, stackTrace) {
      LoggingService.error('Error scheduling BLE reconnect', e, stackTrace);
    }
  }

  Future<void> connectBle(String deviceId) async {
    try {
      LoggingService.info('Connecting to BLE device: $deviceId');
      bleDevice = BluetoothDevice.fromId(deviceId);
      connSub = bleDevice!.connectionState.listen((s) {
        try {
          if (s == BluetoothConnectionState.disconnected) {
            LoggingService.warning('BLE device disconnected');
            latestBpm = null;
            scheduleBleReconnect();
          }
        } catch (e, stackTrace) {
          LoggingService.error(
              'Error handling BLE connection state change', e, stackTrace);
        }
      });
      await bleDevice!
          .connect(autoConnect: false, timeout: const Duration(seconds: 10));
      await subscribeHr(bleDevice!);
      LoggingService.info('BLE device connected successfully');
    } catch (e, stackTrace) {
      LoggingService.error('Failed to connect to BLE device', e, stackTrace);
      scheduleBleReconnect();
    }
  }

  // ── GPS stream ────────────────────────────────────────────────────────
  final locationSettings = Platform.isAndroid
      ? GpsService.androidBackgroundSettings
      : GpsService.appleBackgroundSettings;

  final gpsSub = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).handleError((Object error) {
    LoggingService.error('GPS stream error', error);
    // kCLErrorDomain 1 = kCLErrorLocationUnknown (transient — no fix yet).
    // Swallow and keep the stream alive; the next position event arrives
    // automatically when the device regains a GPS fix.
  }).listen((pos) async {
    try {
      if (activityId == null) return;

      // ── Auto-pause / auto-resume based on GPS speed ───────────────────
      if (!paused) {
        if (pos.speed < _kAutoPauseSpeedMs) {
          slowReadingsCount++;
          if (slowReadingsCount >= _kSlowReadingsToAutoPause) {
            if (startTime != null) {
              pausedAccumulatedS +=
                  DateTime.now().difference(startTime!).inSeconds;
              startTime = null;
            }
            paused = true;
            autoPaused = true;
            slowReadingsCount = 0;
            LoggingService.info(
                'Auto-paused (speed ${pos.speed.toStringAsFixed(2)} m/s)');
          }
        } else {
          slowReadingsCount = 0;
        }
      } else if (autoPaused && pos.speed >= _kAutoResumeSpeedMs) {
        paused = false;
        autoPaused = false;
        startTime = DateTime.now();
        LoggingService.info(
            'Auto-resumed (speed ${pos.speed.toStringAsFixed(2)} m/s)');
      }

      if (paused) return; // don't accumulate distance or write a point while paused

      double distFromPrev = 0;
      if (prevPosition != null) {
        distFromPrev = haversineDistance(
          lat1: prevPosition!.latitude,
          lon1: prevPosition!.longitude,
          lat2: pos.latitude,
          lon2: pos.longitude,
        );
      }
      cumulativeDistanceM += distFromPrev;
      prevPosition = pos;

      try {
        await db.dataPointsDao.insertPoint(DataPointsCompanion(
          activityId: Value(activityId!),
          recordedAt: Value(DateTime.now()),
          lat: Value(pos.latitude),
          lng: Value(pos.longitude),
          altitudeM: Value(pos.altitude),
          accuracyM: Value(pos.accuracy),
          distanceFromPrevM: Value(distFromPrev),
          cumulativeDistanceM: Value(cumulativeDistanceM),
          speedMs: Value(pos.speed),
          bpm: Value(latestBpm),
        ));
        LoggingService.debug(
            'Data point inserted: lat=${pos.latitude}, lng=${pos.longitude}, dist=$cumulativeDistanceM');
      } catch (e, stackTrace) {
        LoggingService.error(
            'Failed to insert data point to database', e, stackTrace);
        // Keep the stream alive even if a single write fails.
      }
    } catch (e, stackTrace) {
      LoggingService.error('Error processing GPS position', e, stackTrace);
    }
  });

  // ── Stats broadcast (every second) ───────────────────────────────────
  Timer.periodic(const Duration(seconds: 1), (_) {
    try {
      if (activityId == null) return;
      final now = DateTime.now();
      int elapsedS = pausedAccumulatedS;
      if (startTime != null && !paused) {
        elapsedS += now.difference(startTime!).inSeconds;
      }

      final paceSecPerKm = (cumulativeDistanceM > 10)
          ? (elapsedS / (cumulativeDistanceM / 1000))
          : 0.0;

      final notifText = _formatStats(
        elapsedS: elapsedS,
        distanceM: cumulativeDistanceM,
        paceSecPerKm: paceSecPerKm,
        bpm: latestBpm,
      );
      updateNotification(notifText);

      service.invoke(ServiceMsg.stats, {
        ServiceMsg.keyActivityId: activityId,
        ServiceMsg.keyElapsedS: elapsedS,
        ServiceMsg.keyDistanceM: cumulativeDistanceM,
        ServiceMsg.keyPaceSPerKm: paceSecPerKm,
        ServiceMsg.keyBpm: latestBpm,
        ServiceMsg.keyLat: prevPosition?.latitude,
        ServiceMsg.keyLng: prevPosition?.longitude,
        ServiceMsg.keyPaused: paused,
        ServiceMsg.keyAutoPaused: autoPaused,
      });
    } catch (e, stackTrace) {
      LoggingService.error('Error broadcasting stats', e, stackTrace);
    }
  });

  // ── Listen to UI commands ─────────────────────────────────────────────
  service.on(ServiceMsg.setActivityId).listen((data) {
    try {
      LoggingService.info(
          'Setting activity ID: ${data?[ServiceMsg.keyActivityId]}');
      activityId = data?[ServiceMsg.keyActivityId] as int?;
      startTime = DateTime.now();
      cumulativeDistanceM = 0;
      prevPosition = null;
    } catch (e, stackTrace) {
      LoggingService.error('Error setting activity ID', e, stackTrace);
    }
  });

  service.on(ServiceMsg.setBleDevice).listen((data) async {
    try {
      final id = data?['device_id'] as String?;
      if (id != null) {
        LoggingService.info('Setting BLE device: $id');
        bleDeviceId = id;
        await connectBle(id);
      }
    } catch (e, stackTrace) {
      LoggingService.error('Error setting BLE device', e, stackTrace);
    }
  });

  service.on(ServiceMsg.pause).listen((_) {
    try {
      LoggingService.info('Pausing activity (manual)');
      if (startTime != null) {
        pausedAccumulatedS += DateTime.now().difference(startTime!).inSeconds;
      }
      startTime = null;
      paused = true;
      autoPaused = false;    // manual pause — disable auto-resume
      slowReadingsCount = 0; // reset so detector doesn't immediately fire on resume
    } catch (e, stackTrace) {
      LoggingService.error('Error pausing activity', e, stackTrace);
    }
  });

  service.on(ServiceMsg.resume).listen((_) {
    try {
      LoggingService.info('Resuming activity (manual)');
      paused = false;
      autoPaused = false;
      slowReadingsCount = 0;
      startTime = DateTime.now();
    } catch (e, stackTrace) {
      LoggingService.error('Error resuming activity', e, stackTrace);
    }
  });

  service.on(ServiceMsg.stop).listen((_) async {
    try {
      if (activityId == null) return;
      LoggingService.info('Stopping activity: $activityId');

      // Compute and write summary
      final now = DateTime.now();
      int totalS = pausedAccumulatedS;
      if (startTime != null && !paused) {
        totalS += now.difference(startTime!).inSeconds;
      }

      final points = await db.dataPointsDao.getForActivity(activityId!);
      double? avgBpm;
      int? maxBpm;
      double elevGain = 0;

      if (points.isNotEmpty) {
        final bpmVals = points.map((p) => p.bpm).whereType<int>().toList();
        if (bpmVals.isNotEmpty) {
          avgBpm = bpmVals.reduce((a, b) => a + b) / bpmVals.length;
          maxBpm = bpmVals.reduce((a, b) => a > b ? a : b);
        }

        double? prevAlt;
        for (final p in points) {
          if (p.altitudeM != null && prevAlt != null) {
            final diff = p.altitudeM! - prevAlt;
            if (diff > 0) elevGain += diff;
          }
          prevAlt = p.altitudeM;
        }
      }

      final paceSecPerKm = (cumulativeDistanceM > 10 && totalS > 0)
          ? (totalS / (cumulativeDistanceM / 1000))
          : null;

      final activity = await db.activitiesDao.findById(activityId!);
      if (activity != null) {
        await db.activitiesDao.updateById(
          activityId!,
          ActivitiesCompanion(
            id: Value(activity.id),
            startedAt: Value(activity.startedAt),
            endedAt: Value(now),
            status: const Value('completed'),
            totalDistanceM: Value(cumulativeDistanceM),
            totalDurationS: Value(totalS),
            avgBpm: Value(avgBpm),
            maxBpm: Value(maxBpm),
            avgPaceSPerKm: Value(paceSecPerKm),
            elevationGainM: Value(elevGain),
          ),
        );
      }

      service
          .invoke(ServiceMsg.stopped, {ServiceMsg.keyActivityId: activityId});

      // Clean up
      await hrSub?.cancel();
      await connSub?.cancel();
      bleReconnectTimer?.cancel();
      await bleDevice?.disconnect();
      await gpsSub.cancel();
      await db.close();
      // Remove the iOS persistent notification now that the run is over.
      if (Platform.isIOS) {
        await FlutterLocalNotificationsPlugin().cancel(_kNotifId);
      }
      service.stopSelf();
      LoggingService.info('Activity stopped and cleaned up successfully');
    } catch (e, stackTrace) {
      LoggingService.error('Error stopping activity', e, stackTrace);
      // Still try to clean up even if there was an error
      try {
        await hrSub?.cancel();
        await connSub?.cancel();
        bleReconnectTimer?.cancel();
        await bleDevice?.disconnect();
        await gpsSub.cancel();
        await db.close();
        if (Platform.isIOS) {
          await FlutterLocalNotificationsPlugin().cancel(_kNotifId);
        }
        service.stopSelf();
      } catch (cleanupError, cleanupStackTrace) {
        LoggingService.error('Error during cleanup after stop failure',
            cleanupError, cleanupStackTrace);
      }
    }
  });
}

String _formatStats({
  required int elapsedS,
  required double distanceM,
  required double paceSecPerKm,
  required int? bpm,
}) {
  final h = elapsedS ~/ 3600;
  final m = (elapsedS % 3600) ~/ 60;
  final s = elapsedS % 60;
  final time = h > 0
      ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
      : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

  final km = (distanceM / 1000).toStringAsFixed(2);
  String pace = '--:--';
  if (paceSecPerKm > 0) {
    final pm = paceSecPerKm ~/ 60;
    final ps = (paceSecPerKm % 60).round();
    pace = '$pm:${ps.toString().padLeft(2, '0')} /km';
  }
  final bpmStr = bpm != null ? ' · $bpm bpm' : '';
  return '$time · ${km}km · $pace$bpmStr';
}
