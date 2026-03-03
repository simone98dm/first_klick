import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
