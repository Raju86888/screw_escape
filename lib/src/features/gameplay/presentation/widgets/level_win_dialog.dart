import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';

/// Modal dialog displayed when the player clears all wooden boards on the level.
class LevelWinDialog extends StatelessWidget {
  /// Callback executed when the player taps "Replay Level".
  final VoidCallback? onReplayPressed;

  /// Callback executed when the player taps "Main Menu".
  final VoidCallback? onMainMenuPressed;

  const LevelWinDialog({
    super.key,
    this.onReplayPressed,
    this.onMainMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: WoodSurface(
        borderRadius: BorderRadius.circular(24),
        elevation: 8,
        border: Border.all(
          color: AppColors.woodMedium,
          width: 3,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Trophy / Celebration Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.metalGoldLight,
                    AppColors.metalGoldDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66FFD700),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 2. Headline
            Text(
              'LEVEL 1 CLEARED!',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textGold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Subtitle
            Text(
              'All boards successfully removed!',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Action: Replay Level
            MetallicButton(
              key: const ValueKey('level_win_replay_button'),
              label: 'Replay Level',
              icon: Icons.refresh_rounded,
              variant: MetallicButtonVariant.gold,
              onPressed: onReplayPressed,
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. Action: Main Menu
            MetallicButton(
              key: const ValueKey('level_win_main_menu_button'),
              label: 'Main Menu',
              icon: Icons.home_rounded,
              variant: MetallicButtonVariant.silver,
              onPressed: onMainMenuPressed,
            ),
          ],
        ),
      ),
    );
  }
}
