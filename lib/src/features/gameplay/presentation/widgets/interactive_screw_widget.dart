import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';

/// Renders a tactile metallic screw pinned on the puzzle canvas.
///
/// Supports smooth translation animation into the holding tray
/// and provides a generous 48x48dp touch target with accessibility guards.
class InteractiveScrewWidget extends StatefulWidget {
  /// The authoritative state of this screw.
  final ScrewState screw;

  /// Whether this screw is currently unoccluded and accessible to tap.
  final bool isAccessible;

  /// Whether user interaction is currently enabled (not locked by controller).
  final bool isEnabled;

  /// Whether this screw is actively translating into the tray.
  final bool isAnimating;

  /// Target screen coordinates on the canvas for flight animation.
  final Offset? targetOffset;

  /// Travel duration for the flight animation (defaults to 250ms).
  final Duration travelDuration;

  /// Callback invoked when this screw is successfully tapped.
  final ValueChanged<String>? onTap;

  const InteractiveScrewWidget({
    super.key,
    required this.screw,
    required this.isAccessible,
    required this.isEnabled,
    this.isAnimating = false,
    this.targetOffset,
    this.travelDuration = const Duration(milliseconds: 250),
    this.onTap,
  });

  @override
  State<InteractiveScrewWidget> createState() => _InteractiveScrewWidgetState();
}

class _InteractiveScrewWidgetState extends State<InteractiveScrewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _travelController;
  late Animation<double> _travelAnimation;

  @override
  void initState() {
    super.initState();
    _travelController = AnimationController(
      vsync: this,
      duration: widget.travelDuration,
    );
    _travelAnimation = CurvedAnimation(
      parent: _travelController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isAnimating) {
      _travelController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveScrewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.travelDuration != oldWidget.travelDuration) {
      _travelController.duration = widget.travelDuration;
    }
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _travelController.forward(from: 0.0);
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _travelController.reset();
    }
  }

  @override
  void dispose() {
    _travelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If screw has settled into the tray and is not animating,
    // it is visually owned and rendered by HoldingTrayWidget.
    if (widget.screw.isInTray && !widget.isAnimating) {
      return const SizedBox.shrink();
    }

    const touchRadius = 24.0;
    const touchSize = touchRadius * 2.0;

    return Positioned(
      left: widget.screw.x - touchRadius,
      top: widget.screw.y - touchRadius,
      width: touchSize,
      height: touchSize,
      child: AnimatedBuilder(
        animation: _travelAnimation,
        builder: (context, child) {
          final progress = _travelAnimation.value;
          Offset translation = Offset.zero;

          if (widget.isAnimating && widget.targetOffset != null) {
            final startOffset = Offset(widget.screw.x, widget.screw.y);
            final delta = widget.targetOffset! - startOffset;
            translation = delta * progress;
          }

          return Transform.translate(
            offset: translation,
            child: child,
          );
        },
        child: GestureDetector(
          key: ValueKey('screw_touch_target_${widget.screw.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.isEnabled && widget.isAccessible && !widget.isAnimating) {
              widget.onTap?.call(widget.screw.id);
            }
          },
          child: const Center(
            child: ScrewAccent(
              size: 24.0,
              type: ScrewType.slotted,
              material: ScrewMaterial.gold,
            ),
          ),
        ),
      ),
    );
  }
}
