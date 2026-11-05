import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';

/// Top HUD bar displaying the Back navigation button, level header, and Restart action.
class GameHud extends StatelessWidget {
  /// Header title for the current level (e.g. 'LEVEL 1').
  final String levelTitle;

  /// Whether user interaction is currently locked by animation settlement.
  final bool isInputLocked;

  /// Callback executed when tapping the back button.
  final VoidCallback? onBackPressed;

  /// Callback executed when tapping the restart button.
  final VoidCallback? onRestartPressed;

  const GameHud({
    super.key,
    required this.levelTitle,
    this.isInputLocked = false,
    this.onBackPressed,
    this.onRestartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Back button
          _buildCompactButton(
            key: const ValueKey('game_hud_back_button'),
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back to Menu',
            isEnabled: true,
            onPressed: onBackPressed,
          ),

          // 2. Level Header Title
          Text(
            levelTitle,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textGold,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),

          // 3. Restart button
          _buildCompactButton(
            key: const ValueKey('game_hud_restart_button'),
            icon: Icons.refresh_rounded,
            tooltip: 'Restart Level',
            isEnabled: !isInputLocked,
            onPressed: isInputLocked ? null : onRestartPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: key,
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled ? AppColors.metalSilverLight : AppColors.woodMedium,
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isEnabled
                      ? const [
                          AppColors.metalSilverLight,
                          AppColors.metalSilver,
                          AppColors.metalSilverDark,
                        ]
                      : const [
                          Color(0xFF55433A),
                          Color(0xFF3F3028),
                        ],
                ),
                boxShadow: isEnabled
                    ? const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isEnabled ? AppColors.textDark : AppColors.textDisabled,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
