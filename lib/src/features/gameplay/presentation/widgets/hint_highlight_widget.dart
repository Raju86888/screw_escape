import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';

/// Renders a pulsating golden halo highlighting the suggested screw move.
///
/// Looping scale and opacity animations guide the player's eye
/// without obstructing touches or mutating game state.
class HintHighlightWidget extends StatefulWidget {
  /// Center X coordinate on the puzzle canvas.
  final double x;

  /// Center Y coordinate on the puzzle canvas.
  final double y;

  /// Radius of the circular highlight in dp.
  final double radius;

  /// Full cycle period of the pulse animation (defaults to 1000ms).
  final Duration pulsePeriod;

  const HintHighlightWidget({
    super.key,
    required this.x,
    required this.y,
    this.radius = 20.0,
    this.pulsePeriod = const Duration(milliseconds: 1000),
  });

  @override
  State<HintHighlightWidget> createState() => _HintHighlightWidgetState();
}

class _HintHighlightWidgetState extends State<HintHighlightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.pulsePeriod.inMilliseconds ~/ 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2.0;

    return Positioned(
      left: widget.x - widget.radius,
      top: widget.y - widget.radius,
      width: size,
      height: size,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.metalGoldLight,
                  width: 3.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99FFD700),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
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
