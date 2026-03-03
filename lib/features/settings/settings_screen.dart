import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ble/ble_service.dart';
import '../../core/strava/strava_auth.dart';
import '../../core/strava/token_storage.dart';
import '../../shared/theme/app_colors.dart';
import 'widgets/ble_scan_modal.dart';
import 'widgets/card.dart';
import 'widgets/device_widgets.dart';
import 'widgets/hr_preview_sheet.dart';
import 'widgets/section_header.dart';
import 'widgets/strava_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _stravaConnected = false;
  String? _athleteName;
  String? _pairedDeviceId;
  String? _pairedDeviceName;
  bool _stravaLoading = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final connected = await TokenStorage.isConnected();
    final name = await TokenStorage.getAthleteName();
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('ble_device_id');
    final deviceName = prefs.getString('ble_device_name');
    if (mounted) {
      setState(() {
        _stravaConnected = connected;
        _athleteName = name;
        _pairedDeviceId = deviceId;
        _pairedDeviceName = deviceName;
      });
    }
  }

  Future<void> _connectStrava() async {
    setState(() => _stravaLoading = true);
    try {
      await StravaAuth.authenticate();
      await _loadState();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _stravaLoading = false);
    }
  }

  Future<void> _disconnectStrava() async {
    await StravaAuth.disconnect();
    await _loadState();
  }

  Future<void> _pairDevice(BluetoothDevice device, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ble_device_id', device.remoteId.str);
    await prefs.setString('ble_device_name', name);
    await ref.read(bleNotifierProvider.notifier).connectToDevice(
          device.remoteId.str,
          name,
        );
    setState(() {
      _pairedDeviceId = device.remoteId.str;
      _pairedDeviceName = name;
    });
  }

  void _showHrPreview() {
    final id = _pairedDeviceId;
    final name = _pairedDeviceName;
    if (id == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        width: double.infinity,
        child: HrPreviewSheet(
          deviceId: id,
          deviceName: name ?? id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Strava section ─────────────────────────────────────────
          SectionHeader(label: 'STRAVA'),
          const SizedBox(height: 8),
          SettingsCard(
            child: _stravaConnected
                ? StravaConnected(
                    name: _athleteName ?? 'Athlete',
                    onDisconnect: _disconnectStrava,
                  )
                : StravaDisconnected(
                    loading: _stravaLoading,
                    onConnect: _connectStrava,
                  ),
          ),
          const SizedBox(height: 24),

          // ── BLE section ────────────────────────────────────────────
          SectionHeader(label: 'HEART RATE MONITOR'),
          const SizedBox(height: 8),
          SettingsCard(
            child: _pairedDeviceId != null
                ? DevicePaired(
                    deviceId: _pairedDeviceId!,
                    name: _pairedDeviceName ?? _pairedDeviceId!,
                    onTest: _showHrPreview,
                    onForget: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('ble_device_id');
                      await prefs.remove('ble_device_name');
                      await ref.read(bleNotifierProvider.notifier).disconnect();
                      setState(() {
                        _pairedDeviceId = null;
                        _pairedDeviceName = null;
                      });
                    },
                  )
                : ScanButton(
                    onScan: () async {
                      final device =
                          await showModalBottomSheet<(BluetoothDevice, String)>(
                        context: context,
                        backgroundColor: kSurface,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const BleScanModal(),
                      );
                      if (device != null) {
                        await _pairDevice(device.$1, device.$2);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
