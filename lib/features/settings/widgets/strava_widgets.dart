import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class StravaConnected extends StatelessWidget {
  const StravaConnected(
      {super.key, required this.name, required this.onDisconnect});
  final String name;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: kSuccess),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Connected', style: AppTextStyles.bodyMedium),
              Text(name, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        TextButton(
          onPressed: onDisconnect,
          child: const Text('Disconnect',
              style: TextStyle(color: kError, fontSize: 13)),
        ),
      ],
    );
  }
}

class StravaDisconnected extends StatelessWidget {
  const StravaDisconnected(
      {super.key, required this.loading, required this.onConnect});
  final bool loading;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return ElevatedButton.icon(
      onPressed: onConnect,
      icon: const Icon(Icons.link_rounded),
      label: const Text('Connect Strava'),
    );
  }
}
