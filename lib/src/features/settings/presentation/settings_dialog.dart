import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';
import 'package:screw_escape/src/features/settings/presentation/widgets/sound_toggle_row.dart';

/// Modal dialog displaying settings, sound controls, and version information.
///
/// Implements REQ-001-05 and REQ-001-06.
class SettingsDialog extends StatelessWidget {
  /// The settings controller managing state.
  final SettingsController controller;

  const SettingsDialog({
    super.key,
    required this.controller,
  });

  /// Displays the settings dialog as an elevated modal.
  static Future<void> show(
    BuildContext context, {
    required SettingsController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xAA000000),
      builder: (context) => SettingsDialog(controller: controller),
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
                      'SETTINGS',
                      style: AppTextStyles.heading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sound Toggle Row
                    SoundToggleRow(controller: controller),
                    const SizedBox(height: AppSpacing.lg),

                    // Version Information (Single Source of Truth)
                    Text(
                      'Version ${AppConfig.appVersion}',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
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
                  angle: 0.2,
                ),
              ),
              const Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 1.1,
                ),
              ),
              const Positioned(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 2.3,
                ),
              ),
              const Positioned(
                bottom: AppSpacing.xs,
                right: AppSpacing.xs,
                child: ScrewAccent(
                  size: 16.0,
                  material: ScrewMaterial.gold,
                  angle: 0.8,
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
                  tooltip: 'Close settings',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

