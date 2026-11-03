import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';

/// Design system typographic hierarchy for Screw Escape.
abstract final class AppTextStyles {
  /// Embossed, high-impact header used for the main game title.
  static const TextStyle gameTitle = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.0,
    color: AppColors.textGold,
    shadows: [
      Shadow(
        offset: Offset(0, 3),
        blurRadius: 4.0,
        color: Colors.black87,
      ),
      Shadow(
        offset: Offset(0, -1),
        blurRadius: 1.0,
        color: AppColors.metalGoldLight,
      ),
    ],
  );

  /// Heavy, tactile label used on primary and secondary buttons.
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 3.0,
        color: Colors.black54,
      ),
    ],
  );

  /// Smaller button label for compact or secondary buttons.
  static const TextStyle buttonLabelSm = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 2.0,
        color: Colors.black54,
      ),
    ],
  );

  /// Section heading style for dialogs and modals.
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppColors.textLight,
  );

  /// Subheading style for cards, rows, and list items.
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textLight,
  );

  /// Standard readable body text for descriptions and instructions.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
  );

  /// Subtle caption style for versions, metadata, and status hints.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white60,
  );
}

