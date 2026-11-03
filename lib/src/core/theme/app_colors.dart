import 'package:flutter/material.dart';

/// Design system color tokens for Screw Escape.
///
/// Features realistic warm wooden tones, metallic accents, and high-visibility
/// call-to-action colors.
abstract final class AppColors {
  // --- Wood Palette ---
  /// Deep dark oak for app backgrounds and vignettes.
  static const Color woodDark = Color(0xFF2C1810);

  /// Warm teak tone for primary board structures.
  static const Color woodMedium = Color(0xFF4A2E1B);

  /// Light walnut for plank grain highlights.
  static const Color woodLight = Color(0xFF7A5230);

  /// Natural pine / oak surface base color.
  static const Color woodSurface = Color(0xFF8B5A2B);

  /// Deep shadow line between horizontal wooden planks.
  static const Color woodPlankDivider = Color(0xFF1F110B);

  /// Subtle rim vignette shadow on board borders.
  static const Color woodVignette = Color(0x66000000);

  // --- Metallic Palette ---
  /// Brass gold primary metallic tone.
  static const Color metalGold = Color(0xFFD4AF37);

  /// Dark shadow edge for gold hardware bevels.
  static const Color metalGoldDark = Color(0xFFAA820A);

  /// Top highlight for gold hardware bevels.
  static const Color metalGoldLight = Color(0xFFFBE27C);

  /// Brushed silver primary metallic tone.
  static const Color metalSilver = Color(0xFFC0C0C0);

  /// Dark shadow edge for silver hardware bevels.
  static const Color metalSilverDark = Color(0xFF7F8C8D);

  /// Top highlight for silver hardware bevels.
  static const Color metalSilverLight = Color(0xFFE8E8E8);

  /// Recessed dark color for screw slots, grooves, and threads.
  static const Color gunmetal = Color(0xFF2B2D2F);

  /// Soft specular highlight reflection on metal rims.
  static const Color metalHighlight = Color(0x66FFFFFF);

  // --- CTA / Button Palette ---
  /// Emerald green primary Call-To-Action (Play button).
  static const Color playGreen = Color(0xFF2E7D32);

  /// Light emerald highlight for the top bevel of Play button.
  static const Color playGreenLight = Color(0xFF4CAF50);

  /// Dark emerald shadow for the bottom bevel of Play button.
  static const Color playGreenDark = Color(0xFF1B5E20);

  /// Warm amber gold for secondary action buttons.
  static const Color amberGold = Color(0xFFF59E0B);

  /// Light amber highlight for secondary action buttons.
  static const Color amberGoldLight = Color(0xFFFBBF24);

  /// Dark amber shadow for secondary action buttons.
  static const Color amberGoldDark = Color(0xFFD97706);

  // --- Neutral & Typography Palette ---
  /// Bright text for dark wooden surfaces.
  static const Color textLight = Color(0xFFF5F5F5);

  /// Secondary muted text for descriptions and subtitles.
  static const Color textMuted = Color(0xB3FFFFFF);

  /// Dark text for light metallic surfaces.
  static const Color textDark = Color(0xFF1A1A1A);

  /// Gold accent for prominent headers.
  static const Color textGold = Color(0xFFFFD700);

  /// Disabled element fill color.
  static const Color disabledSurface = Color(0xFF55433C);

  /// Disabled element text color.
  static const Color textDisabled = Color(0x66FFFFFF);
}

