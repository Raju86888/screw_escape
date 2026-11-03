import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';
import 'package:screw_escape/src/core/theme/app_text_styles.dart';

/// Visual style variant of the [MetallicButton].
enum MetallicButtonVariant {
  /// Emerald green primary Call-to-Action (Play button).
  primaryGreen,

  /// Amber / brass gold secondary action button.
  gold,

  /// Brushed silver neutral action button.
  silver,
}

/// A tactile, physical 3D beveled button widget.
///
/// Features realistic top-light highlight, bottom shadow bevels,
/// authentic press translation (<16ms tactile reaction), and full accessibility semantics.
class MetallicButton extends StatefulWidget {
  /// Text label displayed on the button.
  final String label;

  /// Callback executed when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// The visual color and gradient variant.
  final MetallicButtonVariant variant;

  /// Explicit width. If null, expands to fill available width.
  final double? width;

  /// Height of the button (defaults to 56.0dp for easy touch targets).
  final double height;

  /// Whether an inline loading indicator is active.
  final bool isLoading;

  const MetallicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = MetallicButtonVariant.primaryGreen,
    this.width,
    this.height = 56.0,
    this.isLoading = false,
  });

  @override
  State<MetallicButton> createState() => _MetallicButtonState();
}

class _MetallicButtonState extends State<MetallicButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(widget.variant, _isEnabled);

    // Visual depression values
    final double translationY = _isPressed ? 3.0 : 0.0;
    final double shadowDepth = _isPressed ? 1.0 : 4.0;

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0.0, translationY, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000),
                offset: Offset(0, shadowDepth),
                blurRadius: shadowDepth * 1.5,
              ),
            ],
            border: Border.all(
              color: colors.borderColor,
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors.gradientColors,
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: colors.textColor,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: AppTextStyles.buttonLabel.copyWith(
                        color: colors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors(MetallicButtonVariant variant, bool isEnabled) {
    if (!isEnabled) {
      return _ButtonColors(
        gradientColors: const [
          Color(0xFF6B584E),
          Color(0xFF55433A),
          Color(0xFF3F3028),
        ],
        borderColor: const Color(0xFF7A6559),
        textColor: AppColors.textDisabled,
      );
    }

    switch (variant) {
      case MetallicButtonVariant.primaryGreen:
        return _ButtonColors(
          gradientColors: const [
            AppColors.playGreenLight,
            AppColors.playGreen,
            AppColors.playGreenDark,
          ],
          borderColor: const Color(0xFF81C784),
          textColor: Colors.white,
        );
      case MetallicButtonVariant.gold:
        return _ButtonColors(
          gradientColors: const [
            AppColors.amberGoldLight,
            AppColors.amberGold,
            AppColors.amberGoldDark,
          ],
          borderColor: const Color(0xFFFDE68A),
          textColor: Colors.white,
        );
      case MetallicButtonVariant.silver:
        return _ButtonColors(
          gradientColors: const [
            AppColors.metalSilverLight,
            AppColors.metalSilver,
            AppColors.metalSilverDark,
          ],
          borderColor: Colors.white70,
          textColor: AppColors.textDark,
        );
    }
  }
}

class _ButtonColors {
  final List<Color> gradientColors;
  final Color borderColor;
  final Color textColor;

  _ButtonColors({
    required this.gradientColors,
    required this.borderColor,
    required this.textColor,
  });
}
