import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';

/// Stylized game title plaque featuring embossed typography and decorative screw accents.
///
/// Implements REQ-001-03 and AC-02.
class GameTitle extends StatelessWidget {
  const GameTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.woodMedium,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.woodLight,
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 8),
            blurRadius: 16.0,
          ),
          BoxShadow(
            color: Color(0x33FFFFFF),
            offset: Offset(0, -1),
            blurRadius: 0.0,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Four Corner Decorative Screw Accents
          const Positioned(
            top: -AppSpacing.xs,
            left: -AppSpacing.xs,
            child: ScrewAccent(
              size: 20.0,
              material: ScrewMaterial.gold,
              angle: 0.3,
            ),
          ),
          const Positioned(
            top: -AppSpacing.xs,
            right: -AppSpacing.xs,
            child: ScrewAccent(
              size: 20.0,
              material: ScrewMaterial.gold,
              angle: 1.4,
            ),
          ),
          const Positioned(
            bottom: -AppSpacing.xs,
            left: -AppSpacing.xs,
            child: ScrewAccent(
              size: 20.0,
              material: ScrewMaterial.gold,
              angle: 2.5,
            ),
          ),
          const Positioned(
            bottom: -AppSpacing.xs,
            right: -AppSpacing.xs,
            child: ScrewAccent(
              size: 20.0,
              material: ScrewMaterial.gold,
              angle: 0.9,
            ),
          ),

          // Embossed Game Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SCREW',
                    style: AppTextStyles.gameTitle.copyWith(
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'ESCAPE',
                    style: AppTextStyles.gameTitle.copyWith(
                      color: AppColors.metalGoldLight,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

