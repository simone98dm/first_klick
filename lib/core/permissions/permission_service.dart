import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Handles requesting all runtime permissions the app needs.
///
/// Ordering is intentional:
///   1. Notifications   — non-critical; shown first while the user is attentive.
///   2. Location (when in use) — critical; must be granted before "always".
///   3. Location (always)      — critical for background recording; must follow (2).
///   4. Bluetooth              — non-critical; only needed for heart rate monitors.
class PermissionService {
  PermissionService._();

  /// Request every permission the app may need.
  ///
  /// Dialogs are shown in the right order so the OS accepts each request.
  /// Returns [true] if the minimum permissions for recording a run are granted
  /// (location when in use + location always).
  static Future<bool> requestAll() async {
    // ── 1. Notifications ─────────────────────────────────────────────────
    // Android 13+ requires POST_NOTIFICATIONS; iOS shows the standard alert.
    await Permission.notification.request();

    // ── 2. Location when in use ──────────────────────────────────────────
    // Critical — without this the app cannot record GPS data.
    final locStatus = await Permission.locationWhenInUse.request();
    if (!locStatus.isGranted) {
      // User denied foreground location; background will be denied too.
      return false;
    }

    // ── 3. Background location ───────────────────────────────────────────
    // Must be requested *after* foreground location is granted.
    // On Android the OS enforces this; on iOS it upgrades the authorisation.
    final bgStatus = await Permission.locationAlways.request();

    // ── 4. Bluetooth ─────────────────────────────────────────────────────
    // Android 12+ splits into BLUETOOTH_SCAN + BLUETOOTH_CONNECT.
    // iOS uses a single NSBluetoothAlwaysUsageDescription.
    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    } else {
      await Permission.bluetooth.request();
    }

    return bgStatus.isGranted;
  }

  /// Quick check: is the minimum location permission for recording granted?
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Quick check: is background location granted?
  static Future<bool> hasBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  /// Opens the app's system settings page so the user can grant a denied
  /// permission manually.
  static Future<void> openSettings() => openAppSettings();
}
