import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class DevicePaired extends StatelessWidget {
  const DevicePaired({
    super.key,
    required this.deviceId,
    required this.name,
    required this.onTest,
    required this.onForget,
  });

  final String deviceId;
  final String name;
  final VoidCallback onTest;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTest,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          const Icon(Icons.bluetooth_connected_rounded, color: kAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  'Tap to test live HR',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: kTextDisabled, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onForget,
            child: const Text('Forget',
                style: TextStyle(color: kTextSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class ScanButton extends StatelessWidget {
  const ScanButton({super.key, required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onScan,
      icon: const Icon(Icons.search_rounded),
      label: const Text('Scan for HR Monitor'),
    );
  }
}
