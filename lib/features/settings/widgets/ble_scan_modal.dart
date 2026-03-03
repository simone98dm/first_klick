import 'dart:async';
import 'dart:io';

import 'package:first_klick/shared/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Guesses a human-readable device type from scan advertisement data and
/// device name. Returns a record of (displayName, deviceType).
({String displayName, String deviceType}) _guessDeviceInfo(ScanResult r) {
  final displayName = r.device.platformName.isNotEmpty
      ? r.device.platformName
      : (r.advertisementData.advName.isNotEmpty
          ? r.advertisementData.advName
          : r.device.remoteId.str);

  final lower = displayName.toLowerCase();
  final advertisedServices = r.advertisementData.serviceUuids
      .map((u) => u.str128.toLowerCase())
      .toSet();

  String deviceType;
  if (advertisedServices.contains(kHeartRateServiceUuid)) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('polar') ||
      lower.contains(' h10') ||
      lower.contains(' h9') ||
      lower.contains(' h7')) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('wahoo') || lower.contains('tickr')) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('garmin') || lower.contains('hrm')) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('suunto')) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('scosche') || lower.contains('rhythm')) {
    deviceType = 'Heart Rate Monitor';
  } else if (lower.contains('watch') ||
      lower.contains('band') ||
      lower.contains('fitbit') ||
      lower.contains('amazfit')) {
    deviceType = 'Smart Watch / Band';
  } else {
    deviceType = 'BLE Device';
  }

  return (displayName: displayName, deviceType: deviceType);
}

/// Returns icon + color for a given RSSI value.
({IconData icon, Color color, String label}) _signalInfo(int rssi) {
  if (rssi >= -60) {
    return (
      icon: Icons.signal_cellular_alt_rounded,
      color: kSuccess,
      label: 'Strong'
    );
  } else if (rssi >= -75) {
    return (
      icon: Icons.signal_cellular_alt_2_bar_rounded,
      color: kWarning,
      label: 'Good'
    );
  } else {
    return (
      icon: Icons.signal_cellular_alt_1_bar_rounded,
      color: kError,
      label: 'Weak'
    );
  }
}

class BleScanModal extends StatefulWidget {
  const BleScanModal({super.key});

  @override
  State<BleScanModal> createState() => _BleScanModalState();
}

class _BleScanModalState extends State<BleScanModal> {
  final _devices = <ScanResult>[];
  bool _scanning = false;
  StreamSubscription<List<ScanResult>>? _scanSub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_scanning) return;

    await _scanSub?.cancel();
    _scanSub = null;

    setState(() {
      _devices.clear();
      _scanning = true;
    });

    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {}
    }

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        for (final r in results) {
          final idx = _devices
              .indexWhere((d) => d.device.remoteId == r.device.remoteId);
          if (idx >= 0) {
            // Update RSSI with the freshest reading.
            _devices[idx] = r;
          } else {
            _devices.add(r);
          }
        }
        // Keep the strongest signal at the top.
        _devices.sort((a, b) => b.rssi.compareTo(a.rssi));
      });
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );

    if (mounted) setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Scan for HR Monitors',
                    style: AppTextStyles.bodyLarge),
                const Spacer(),
                if (_scanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _startScan,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_devices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    _scanning
                        ? 'Searching for devices…'
                        : 'No devices found. Try again.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final r = _devices[index];
                    final info = _guessDeviceInfo(r);
                    final sig = _signalInfo(r.rssi);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      leading: Icon(
                        info.deviceType == 'Heart Rate Monitor'
                            ? Icons.favorite_rounded
                            : info.deviceType == 'Smart Watch / Band'
                                ? Icons.watch_rounded
                                : Icons.bluetooth_rounded,
                        color: kAccent,
                      ),
                      title: Text(
                        info.displayName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      subtitle: Text(
                        info.deviceType,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: kTextSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(sig.icon, color: sig.color, size: 18),
                          Text(
                            '${r.rssi} dBm',
                            style: TextStyle(
                                fontSize: 10,
                                color: sig.color,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.of(context).pop(
                        (r.device, info.displayName),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
