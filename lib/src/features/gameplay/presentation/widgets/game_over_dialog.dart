import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';

/// Modal dialog displayed when player runs out of holding tray slots (deadlock).
class GameOverDialog extends StatelessWidget {
  /// Callback executed when the player taps "Undo Move".
  final VoidCallback? onUndoPressed;

  /// Callback executed when the player taps "Retry Level".
  final VoidCallback? onRetryPressed;

  const GameOverDialog({
    super.key,
    this.onUndoPressed,
    this.onRetryPressed,
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
            // 1. Deadlock Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFE57373),
                    Color(0xFFC62828),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66C62828),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 2. Headline
            Text(
              'OUT OF HOLES!',
              style: AppTextStyles.heading.copyWith(
                color: const Color(0xFFFF8A80),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Subtitle
            Text(
              'The holding tray is full.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Action: Undo Move
            MetallicButton(
              key: const ValueKey('game_over_undo_button'),
              label: 'Undo Move',
              icon: Icons.undo_rounded,
              variant: MetallicButtonVariant.gold,
              onPressed: onUndoPressed,
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. Action: Retry Level
            MetallicButton(
              key: const ValueKey('game_over_retry_button'),
              label: 'Retry Level',
              icon: Icons.refresh_rounded,
              variant: MetallicButtonVariant.silver,
              onPressed: onRetryPressed,
            ),
          ],
        ),
      ),
    );
  }
}

