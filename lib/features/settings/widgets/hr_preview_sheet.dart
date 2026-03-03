import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ble/ble_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class HrPreviewSheet extends ConsumerStatefulWidget {
  const HrPreviewSheet(
      {super.key, required this.deviceId, required this.deviceName});
  final String deviceId;
  final String deviceName;

  @override
  ConsumerState<HrPreviewSheet> createState() => _HrPreviewSheetState();
}

class _HrPreviewSheetState extends ConsumerState<HrPreviewSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    lowerBound: 0.85,
    upperBound: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _pulse.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulse.reverse();
      if (s == AnimationStatus.dismissed) {
        final bpm = ref.read(bleNotifierProvider).bpm;
        if (bpm != null) _pulse.forward();
      }
    });
    // Connect if not already connected.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ble = ref.read(bleNotifierProvider);
      if (ble.status != BleStatus.connected) {
        ref
            .read(bleNotifierProvider.notifier)
            .connectToDevice(widget.deviceId, widget.deviceName);
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = ref.watch(bleNotifierProvider);

    // Drive the pulse animation from BPM changes.
    if (ble.bpm != null && !_pulse.isAnimating) _pulse.forward();
    if (ble.bpm == null && _pulse.isAnimating) _pulse.stop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Device name + status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(widget.deviceName,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _StatusChip(status: ble.status),
                const SizedBox(height: 36),
              ],
            ),
          ),

          // Heart icon + BPM (full width)
          ScaleTransition(
            scale: _pulse,
            child: Icon(
              Icons.favorite_rounded,
              color: ble.bpm != null ? kError : kTextDisabled,
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ble.bpm != null ? '${ble.bpm}' : '--',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              color: kTextPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text('BPM', style: AppTextStyles.metricLabel),
          const SizedBox(height: 32),

          if (ble.status == BleStatus.connecting ||
              ble.status == BleStatus.disconnected) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                ble.status == BleStatus.connecting
                    ? 'Connecting to device…'
                    : 'Reconnecting…',
                style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BleStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BleStatus.connected => ('Connected', kSuccess),
      BleStatus.connecting => ('Connecting…', kWarning),
      BleStatus.scanning => ('Scanning…', kWarning),
      BleStatus.disconnected => ('Disconnected', kTextDisabled),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
