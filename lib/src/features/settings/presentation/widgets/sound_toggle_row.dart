import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

/// An interactive toggle row for the sound preference setting.
///
/// Implements REQ-001-05 and REQ-001-06.
/// Features a loading guard: the switch is disabled while `!controller.isLoaded`.
class SoundToggleRow extends StatelessWidget {
  /// The settings controller managing sound state and persistence.
  final SettingsController controller;

  const SoundToggleRow({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final bool isLoaded = controller.isLoaded;
        final bool soundEnabled = controller.soundEnabled;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: const Color(0x33000000),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: const Color(0x22FFFFFF),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Sound Status Icon
              Icon(
                soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 28,
                color: isLoaded
                    ? (soundEnabled ? AppColors.metalGold : AppColors.textMuted)
                    : AppColors.textDisabled,
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sound Effects',
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      !isLoaded
                          ? 'Loading settings...'
                          : (soundEnabled ? 'Enabled' : 'Disabled'),
                      style: AppTextStyles.caption.copyWith(
                        color: !isLoaded
                            ? AppColors.textDisabled
                            : (soundEnabled
                                ? AppColors.metalGoldLight
                                : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              // Sound switch toggle with loading guard
              Semantics(
                label: 'Sound Effects toggle',
                value: soundEnabled ? 'On' : 'Off',
                child: Switch(
                  value: soundEnabled,
                  onChanged: isLoaded
                      ? (value) => controller.setSoundEnabled(value)
                      : null,
                  activeThumbColor: AppColors.metalGoldLight,
                  activeTrackColor: AppColors.playGreen,
                  inactiveThumbColor: AppColors.metalSilverDark,
                  inactiveTrackColor: AppColors.woodDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
