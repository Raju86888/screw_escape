import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';

/// Bottom action bar providing Undo and Hint action buttons.
class GameControlsBar extends StatelessWidget {
  /// Whether the Undo action is disabled (e.g. empty history or locked input).
  final bool isUndoDisabled;

  /// Whether the Hint action is disabled (e.g. active animation or locked input).
  final bool isHintDisabled;

  /// Callback executed when tapping the Undo button.
  final VoidCallback? onUndoPressed;

  /// Callback executed when tapping the Hint button.
  final VoidCallback? onHintPressed;

  const GameControlsBar({
    super.key,
    required this.isUndoDisabled,
    required this.isHintDisabled,
    this.onUndoPressed,
    this.onHintPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Undo Button
          Expanded(
            child: _buildActionButton(
              key: const ValueKey('game_controls_undo_button'),
              label: 'UNDO',
              icon: Icons.undo_rounded,
              isEnabled: !isUndoDisabled,
              isGold: false,
              onPressed: isUndoDisabled ? null : onUndoPressed,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 2. Hint Button
          Expanded(
            child: _buildActionButton(
              key: const ValueKey('game_controls_hint_button'),
              label: 'HINT',
              icon: Icons.lightbulb_outline_rounded,
              isEnabled: !isHintDisabled,
              isGold: true,
              onPressed: isHintDisabled ? null : onHintPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Key key,
    required String label,
    required IconData icon,
    required bool isEnabled,
    required bool isGold,
    required VoidCallback? onPressed,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: key,
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEnabled
                      ? (isGold ? const Color(0xFFFDE68A) : AppColors.metalSilverLight)
                      : const Color(0xFF7A6559),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isEnabled
                      ? (isGold
                          ? const [
                              AppColors.amberGoldLight,
                              AppColors.amberGold,
                              AppColors.amberGoldDark,
                            ]
                          : const [
                              AppColors.metalSilverLight,
                              AppColors.metalSilver,
                              AppColors.metalSilverDark,
                            ])
                      : const [
                          Color(0xFF6B584E),
                          Color(0xFF55433A),
                          Color(0xFF3F3028),
                        ],
                ),
                boxShadow: isEnabled
                    ? const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isEnabled
                        ? (isGold ? Colors.white : AppColors.textDark)
                        : AppColors.textDisabled,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: isEnabled
                          ? (isGold ? Colors.white : AppColors.textDark)
                          : AppColors.textDisabled,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
