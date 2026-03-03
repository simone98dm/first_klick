import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Hero metric (e.g. elapsed time "42:15")
  static const TextStyle heroNumber = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w200,
    color: kTextPrimary,
    letterSpacing: -2,
    height: 1,
  );

  /// Large metric (BPM, pace, distance)
  static const TextStyle metricLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: kTextPrimary,
    letterSpacing: -1,
    height: 1,
  );

  /// Metric label under the number
  static const TextStyle metricLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: kTextSecondary,
    letterSpacing: 1.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: kTextSecondary,
    letterSpacing: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: kTextPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kTextPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: kTextSecondary,
  );

  static const TextStyle accentLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: kTextPrimary,
    letterSpacing: 0.5,
  );
}
