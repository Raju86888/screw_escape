import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';

void main() {
  group('Theme Tokens', () {
    test('AppColors defines wood, metallic, and CTA semantic colors', () {
      expect(AppColors.woodDark.toARGB32(), equals(0xFF2C1810));
      expect(AppColors.woodMedium.toARGB32(), equals(0xFF4A2E1B));
      expect(AppColors.woodLight.toARGB32(), equals(0xFF7A5230));
      expect(AppColors.woodSurface.toARGB32(), equals(0xFF8B5A2B));

      expect(AppColors.metalGold.toARGB32(), equals(0xFFD4AF37));
      expect(AppColors.metalSilver.toARGB32(), equals(0xFFC0C0C0));
      expect(AppColors.gunmetal.toARGB32(), equals(0xFF2B2D2F));

      expect(AppColors.playGreen.toARGB32(), equals(0xFF2E7D32));
      expect(AppColors.amberGold.toARGB32(), equals(0xFFF59E0B));
    });

    test('AppSpacing defines progressive layout scales and radiuses', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));
      expect(AppSpacing.xl, equals(32.0));
      expect(AppSpacing.xxl, equals(48.0));

      expect(AppSpacing.radiusSm, equals(4.0));
      expect(AppSpacing.radiusMd, equals(12.0));
      expect(AppSpacing.radiusLg, equals(20.0));
    });

    test('AppTextStyles provides complete typography hierarchy', () {
      expect(AppTextStyles.gameTitle.fontSize, equals(38));
      expect(AppTextStyles.buttonLabel.fontSize, equals(20));
      expect(AppTextStyles.buttonLabelSm.fontSize, equals(16));
      expect(AppTextStyles.heading.fontSize, equals(22));
      expect(AppTextStyles.subheading.fontSize, equals(18));
      expect(AppTextStyles.body.fontSize, equals(14));
      expect(AppTextStyles.caption.fontSize, equals(12));
    });
  });
}
