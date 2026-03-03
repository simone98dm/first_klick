import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/background/service_messages.dart';
import '../../core/database/app_database.dart';
import '../home/home_provider.dart';

part 'recording_provider.g.dart';

// ── Live stats from the background service ────────────────────────────────

class RunStats {
  const RunStats({
    this.elapsedS = 0,
    this.distanceM = 0,
    this.paceSPerKm = 0,
    this.bpm,
    this.lat,
    this.lng,
    this.activityId,
    this.paused = false,
    this.autoPaused = false,
    this.isRecording = false,
    this.routePoints = const [],
  });

  final int elapsedS;
  final double distanceM;
  final double paceSPerKm;
  final int? bpm;
  final double? lat;
  final double? lng;
  final int? activityId;
  final bool paused;
  /// True when the run was paused automatically because the user stopped moving.
  final bool autoPaused;
  final bool isRecording;
  /// Accumulated GPS positions for the live route polyline.
  final List<LatLng> routePoints;

  // Use a private sentinel so copyWith can explicitly set nullable fields to null.
  static const _keep = Object();

  RunStats copyWith({
    int? elapsedS,
    double? distanceM,
    double? paceSPerKm,
    Object? bpm = _keep,   // pass null to clear, omit to keep
    Object? lat = _keep,
    Object? lng = _keep,
    int? activityId,
    bool? paused,
    bool? autoPaused,
    bool? isRecording,
    List<LatLng>? routePoints,
  }) =>
      RunStats(
        elapsedS: elapsedS ?? this.elapsedS,
        distanceM: distanceM ?? this.distanceM,
        paceSPerKm: paceSPerKm ?? this.paceSPerKm,
        bpm: identical(bpm, _keep) ? this.bpm : bpm as int?,
        lat: identical(lat, _keep) ? this.lat : lat as double?,
        lng: identical(lng, _keep) ? this.lng : lng as double?,
        activityId: activityId ?? this.activityId,
        paused: paused ?? this.paused,
        autoPaused: autoPaused ?? this.autoPaused,
        isRecording: isRecording ?? this.isRecording,
        routePoints: routePoints ?? this.routePoints,
      );
}

@riverpod
class RecordingNotifier extends _$RecordingNotifier {
  StreamSubscription<Map<String, dynamic>?>? _statsSub;
  StreamSubscription<Map<String, dynamic>?>? _stoppedSub;

  @override
  RunStats build() {
    ref.onDispose(_cancelSubs);
    _listenToService();
    return const RunStats();
  }

  // ── Public API ────────────────────────────────────────────────────────

  Future<void> startRun(AppDatabase db, {String? bleDeviceId}) async {
    final now = DateTime.now();
    final hour = now.hour;
    final title = hour < 5
        ? 'Night Run'
        : hour < 12
            ? 'Morning Run'
            : hour < 17
                ? 'Afternoon Run'
                : hour < 21
                    ? 'Evening Run'
                    : 'Night Run';

    // Create activity row
    final id = await db.activitiesDao.insertActivity(
      ActivitiesCompanion(
        startedAt: Value(now),
        title: Value(title),
        status: const Value('recording'),
      ),
    );

    final service = FlutterBackgroundService();
    await service.startService();
    // Small delay so the service entry point is ready
    await Future<void>.delayed(const Duration(milliseconds: 300));

    service.invoke(ServiceMsg.setActivityId, {ServiceMsg.keyActivityId: id});

    if (bleDeviceId != null && bleDeviceId.isNotEmpty) {
      service.invoke(ServiceMsg.setBleDevice, {'device_id': bleDeviceId});
    }

    state = state.copyWith(activityId: id, isRecording: true, paused: false);
  }

  void pause() {
    FlutterBackgroundService().invoke(ServiceMsg.pause);
    state = state.copyWith(paused: true);
  }

  void resumeRun() {
    FlutterBackgroundService().invoke(ServiceMsg.resume);
    state = state.copyWith(paused: false);
  }

  Future<void> stopRun() {
    final service = FlutterBackgroundService();
    final completer = Completer<void>();
    final sub = service.on(ServiceMsg.stopped).listen((_) {
      state = const RunStats(isRecording: false);
      if (!completer.isCompleted) completer.complete();
    });
    service.invoke(ServiceMsg.stop);
    return completer.future
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            // Service did not confirm in time — reset state anyway.
            state = const RunStats(isRecording: false);
          },
        )
        .whenComplete(sub.cancel);
  }

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setStateForTest(RunStats s) => state = s;

  // ── Internal ──────────────────────────────────────────────────────────

  void _listenToService() {
    final service = FlutterBackgroundService();

    _statsSub = service.on(ServiceMsg.stats).listen((data) {
      if (data == null) return;
      final lat = (data[ServiceMsg.keyLat] as num?)?.toDouble();
      final lng = (data[ServiceMsg.keyLng] as num?)?.toDouble();

      // Append a new route point only when the position has actually changed.
      List<LatLng> newPoints = state.routePoints;
      if (lat != null && lng != null) {
        final last = state.routePoints.isNotEmpty ? state.routePoints.last : null;
        if (last == null || last.latitude != lat || last.longitude != lng) {
          newPoints = [...state.routePoints, LatLng(lat, lng)];
        }
      }

      state = state.copyWith(
        isRecording: true,
        activityId: data[ServiceMsg.keyActivityId] as int?,
        elapsedS: data[ServiceMsg.keyElapsedS] as int? ?? state.elapsedS,
        distanceM:
            (data[ServiceMsg.keyDistanceM] as num?)?.toDouble() ?? state.distanceM,
        paceSPerKm:
            (data[ServiceMsg.keyPaceSPerKm] as num?)?.toDouble() ?? state.paceSPerKm,
        bpm: data[ServiceMsg.keyBpm] as int?,
        lat: lat,
        lng: lng,
        paused: data[ServiceMsg.keyPaused] as bool? ?? state.paused,
        autoPaused: data[ServiceMsg.keyAutoPaused] as bool? ?? state.autoPaused,
        routePoints: newPoints,
      );
    });

    _stoppedSub = service.on(ServiceMsg.stopped).listen((_) {
      state = const RunStats(isRecording: false);
      // The background service writes from a separate isolate whose AppDatabase
      // instance does not share Drift's in-process change notifications with the
      // main app. Explicitly invalidate so the home screen re-queries the DB and
      // picks up the newly-completed activity.
      ref.invalidate(activitiesListProvider);
    });
  }

  void _cancelSubs() {
    _statsSub?.cancel();
    _stoppedSub?.cancel();
  }
}

// ── Shared preferences key for persisted BLE device ──────────────────────

@riverpod
Future<String?> savedBleDeviceId(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('ble_device_id');
}
