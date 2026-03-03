import 'dart:async';
import 'dart:io';

import 'package:first_klick/shared/app_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/logging_service.dart';

part 'ble_service.g.dart';

enum BleStatus { disconnected, scanning, connecting, connected }

class BleState {
  const BleState({
    this.status = BleStatus.disconnected,
    this.bpm,
    this.deviceName,
    this.deviceId,
  });

  final BleStatus status;
  final int? bpm;
  final String? deviceName;
  final String? deviceId;

  BleState copyWith({
    BleStatus? status,
    int? bpm,
    String? deviceName,
    String? deviceId,
  }) =>
      BleState(
        status: status ?? this.status,
        bpm: bpm ?? this.bpm,
        deviceName: deviceName ?? this.deviceName,
        deviceId: deviceId ?? this.deviceId,
      );
}

@riverpod
class BleNotifier extends _$BleNotifier {
  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _charSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  Timer? _reconnectTimer;
  String? _targetDeviceId;

  @override
  BleState build() => const BleState();

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> connectToDevice(String deviceId, String deviceName) async {
    try {
      LoggingService.info('Connecting to BLE device: $deviceId ($deviceName)');
      _targetDeviceId = deviceId;
      await _cancelExisting();
      state = state.copyWith(
        status: BleStatus.connecting,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      await _connect(deviceId, deviceName);
    } catch (e, stackTrace) {
      LoggingService.error('Failed to initiate BLE connection', e, stackTrace);
      state = state.copyWith(status: BleStatus.disconnected);
    }
  }

  Future<void> disconnect() async {
    try {
      LoggingService.info('Disconnecting BLE device');
      _targetDeviceId = null;
      _reconnectTimer?.cancel();
      await _cancelExisting();
      state = const BleState();
      LoggingService.info('BLE device disconnected successfully');
    } catch (e, stackTrace) {
      LoggingService.error('Error disconnecting BLE device', e, stackTrace);
      // Still reset state even if cleanup failed
      state = const BleState();
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _connect(String deviceId, String deviceName) async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        LoggingService.debug('Android Bluetooth turned on');
      }

      _device = BluetoothDevice.fromId(deviceId);

      _connSub = _device!.connectionState.listen((s) {
        try {
          if (s == BluetoothConnectionState.disconnected) {
            LoggingService.warning('BLE device disconnected: $deviceId');
            state = state.copyWith(status: BleStatus.disconnected, bpm: null);
            _scheduleReconnect();
          } else if (s == BluetoothConnectionState.connected) {
            LoggingService.info('BLE device connected: $deviceId');
            state = state.copyWith(status: BleStatus.connected);
          }
        } catch (e, stackTrace) {
          LoggingService.error(
              'Error handling BLE connection state change', e, stackTrace);
        }
      });

      await _device!
          .connect(autoConnect: false, timeout: const Duration(seconds: 10));
      LoggingService.info('BLE device connected successfully');
      await _subscribeToHr();
    } catch (e, stackTrace) {
      LoggingService.error('Failed to connect to BLE device', e, stackTrace);
      state = state.copyWith(status: BleStatus.disconnected);
      _scheduleReconnect();
    }
  }

  Future<void> _subscribeToHr() async {
    try {
      if (_device == null) {
        LoggingService.warning('Cannot subscribe to HR: device is null');
        return;
      }
      LoggingService.debug('Subscribing to heart rate service...');
      final services = await _device!.discoverServices();
      for (final s in services) {
        if (s.uuid.str128.toLowerCase() == kHeartRateServiceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid.str128.toLowerCase() == kHeartRateMeasurementUuid) {
              await c.setNotifyValue(true);
              _charSub = c.lastValueStream.listen(_onHrData);
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

  void _onHrData(List<int> data) {
    try {
      if (data.isEmpty) return;
      // GATT HR measurement: flags byte at index 0.
      // Bit 0 = 0 → HR value is uint8 at index 1; = 1 → uint16 at index 1–2.
      final flags = data[0];
      final isUint16 = (flags & 0x01) != 0;
      final bpm = isUint16 ? (data[2] << 8) | data[1] : data[1];
      LoggingService.debug('Received BPM: $bpm');
      state = state.copyWith(bpm: bpm);
    } catch (e, stackTrace) {
      LoggingService.error('Error processing heart rate data', e, stackTrace);
    }
  }

  void _scheduleReconnect() {
    try {
      if (_targetDeviceId == null) return;
      LoggingService.debug('Scheduling BLE reconnect...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        try {
          if (_targetDeviceId != null) {
            LoggingService.info('Attempting BLE reconnect...');
            _connect(_targetDeviceId!, state.deviceName ?? '');
          }
        } catch (e, stackTrace) {
          LoggingService.error(
              'BLE reconnect failed, scheduling next attempt', e, stackTrace);
          _scheduleReconnect();
        }
      });
    } catch (e, stackTrace) {
      LoggingService.error('Error scheduling BLE reconnect', e, stackTrace);
    }
  }

  Future<void> _cancelExisting() async {
    try {
      _reconnectTimer?.cancel();
      await _charSub?.cancel();
      await _connSub?.cancel();
      try {
        await _device?.disconnect();
      } catch (disconnectError, disconnectStackTrace) {
        LoggingService.warning('Error disconnecting device during cleanup',
            disconnectError, disconnectStackTrace);
        // Don't rethrow, continue cleanup
      }
      _device = null;
      _charSub = null;
      _connSub = null;
    } catch (e, stackTrace) {
      LoggingService.error('Error during BLE cleanup', e, stackTrace);
      // Reset references even if cleanup failed
      _device = null;
      _charSub = null;
      _connSub = null;
    }
  }
}

/// Thin provider that exposes just the current BPM value.
@riverpod
int? currentBpm(Ref ref) => ref.watch(bleNotifierProvider).bpm;
