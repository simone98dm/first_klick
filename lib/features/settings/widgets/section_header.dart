import 'package:flutter/material.dart';

import '../../../shared/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTextStyles.sectionTitle);
}
