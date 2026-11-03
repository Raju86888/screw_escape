import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/responsive_container.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';

/// Placeholder screen displayed when navigating to gameplay.
///
/// Implements REQ-001-04, AC-04, and EC-05.
/// Provides a visible Back button and supports system back gestures.
class GameplayPlaceholderScreen extends StatelessWidget {
  const GameplayPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.woodDark,
        body: WoodSurface(
          showPlanks: true,
          child: ResponsiveContainer(
            maxWidth: 480.0,
            scrollable: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar / Back navigation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MetallicButton(
                      label: 'BACK',
                      icon: Icons.arrow_back_rounded,
                      variant: MetallicButtonVariant.silver,
                      width: 110.0,
                      height: 42.0,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Tactical Game Board Area Placeholder
                Expanded(
                  flex: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.woodMedium,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: AppColors.woodLight,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x99000000),
                          offset: Offset(0, 8),
                          blurRadius: 16.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Four Corner Decorative Screw Accents
                        const Positioned(
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: ScrewAccent(
                            size: 20.0,
                            material: ScrewMaterial.silver,
                            angle: 0.4,
                          ),
                        ),
                        const Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: ScrewAccent(
                            size: 20.0,
                            material: ScrewMaterial.silver,
                            angle: 1.2,
                          ),
                        ),
                        const Positioned(
                          bottom: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: ScrewAccent(
                            size: 20.0,
                            material: ScrewMaterial.silver,
                            angle: 2.1,
                          ),
                        ),
                        const Positioned(
                          bottom: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: ScrewAccent(
                            size: 20.0,
                            material: ScrewMaterial.silver,
                            angle: 0.9,
                          ),
                        ),

                        // Center content inside tactical board
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xxl,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.woodDark,
                                  border: Border.all(
                                    color: AppColors.metalGold,
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x66000000),
                                      offset: Offset(0, 4),
                                      blurRadius: 8.0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.extension_rounded,
                                  size: 44,
                                  color: AppColors.metalGold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const Text(
                                'Gameplay coming soon',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                'Tactical screw puzzle mechanics and puzzle levels are currently under active development.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

