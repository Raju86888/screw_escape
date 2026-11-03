import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';

/// Modal dialog displaying level selection placeholder information.
///
/// Implements REQ-001-07 and AC-07.
class LevelSelectDialog extends StatelessWidget {
  const LevelSelectDialog({super.key});

  /// Displays the level selection modal dialog.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xAA000000),
      builder: (context) => const LevelSelectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: const [
              BoxShadow(
                color: Color(0xCC000000),
                offset: Offset(0, 10),
                blurRadius: 20.0,
              ),
            ],
          ),
          child: Stack(
            children: [
              WoodSurface(
                showPlanks: false,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.woodLight,
                  width: 2.5,
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Title
                    const Text(
                      'LEVELS',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Placeholder Level Preview Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLevelBadge('1', isLocked: false),
                        const SizedBox(width: AppSpacing.md),
                        _buildLevelBadge('2', isLocked: true),
                        const SizedBox(width: AppSpacing.md),
                        _buildLevelBadge('3', isLocked: true),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Descriptive Info Text
                    const Text(
                      'Level selection coming soon!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Stages, progression rewards, and difficulty tiers will unlock here in future updates.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Close Action Button
                    MetallicButton(
                      label: 'CLOSE',
                      variant: MetallicButtonVariant.silver,
                      height: 44.0,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Decorative Corner Screws
              const Positioned(
                top: AppSpacing.xs,
                left: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 0.5,
                ),
              ),
              const Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 1.8,
                ),
              ),
              const Positioned(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 0.1,
                ),
              ),
              const Positioned(
                bottom: AppSpacing.xs,
                right: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 2.7,
                ),
              ),

              // Close 'X' icon button at top right
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                  tooltip: 'Close levels',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(String number, {required bool isLocked}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isLocked ? AppColors.disabledSurface : AppColors.woodDark,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isLocked ? AppColors.woodMedium : AppColors.metalGold,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isLocked
            ? const Icon(
                Icons.lock_rounded,
                size: 22,
                color: AppColors.textDisabled,
              )
            : Text(
                number,
                style: AppTextStyles.buttonLabelSm.copyWith(
                  color: AppColors.metalGoldLight,
                ),
              ),
      ),
    );
  }
}

