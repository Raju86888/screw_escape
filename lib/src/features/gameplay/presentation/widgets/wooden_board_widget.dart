import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';

/// Renders an individual layered wooden board plank.
///
/// Animates a natural gravity drop (Y translation + 600dp and +8° tilt)
/// when the board is freed from its securing screws.
class WoodenBoardWidget extends StatefulWidget {
  /// The authoritative state of this board.
  final WoodenBoardState board;

  /// Duration of the gravity drop animation (defaults to 400ms).
  final Duration fallDuration;

  const WoodenBoardWidget({
    super.key,
    required this.board,
    this.fallDuration = const Duration(milliseconds: 400),
  });

  @override
  State<WoodenBoardWidget> createState() => _WoodenBoardWidgetState();
}

class _WoodenBoardWidgetState extends State<WoodenBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fallController;
  late Animation<double> _fallAnimation;

  @override
  void initState() {
    super.initState();
    _fallController = AnimationController(
      vsync: this,
      duration: widget.fallDuration,
    );
    _fallAnimation = CurvedAnimation(
      parent: _fallController,
      curve: Curves.easeInQuad,
    );

    if (widget.board.status == BoardStatus.falling) {
      _fallController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WoodenBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fallDuration != oldWidget.fallDuration) {
      _fallController.duration = widget.fallDuration;
    }
    if (widget.board.status == BoardStatus.falling &&
        oldWidget.board.status != BoardStatus.falling) {
      _fallController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _fallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.board.status == BoardStatus.cleared) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.board.left,
      top: widget.board.top,
      width: widget.board.width,
      height: widget.board.height,
      child: AnimatedBuilder(
        animation: _fallAnimation,
        builder: (context, child) {
          final progress = _fallAnimation.value;
          final dy = progress * 600.0;
          final angle = progress * (8.0 * math.pi / 180.0);

          return Transform.translate(
            offset: Offset(0.0, dy),
            child: Transform.rotate(
              angle: angle,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: WoodSurface(
          borderRadius: BorderRadius.circular(12),
          elevation: (widget.board.zIndex + 1) * 3.0,
          border: Border.all(
            color: AppColors.woodPlankDivider,
            width: 1.5,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
