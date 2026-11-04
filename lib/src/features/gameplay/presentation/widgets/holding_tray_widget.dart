import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';

/// Renders the 3-slot holding tray at the top of the gameplay canvas.
///
/// Features recessed metallic sockets that display docked gold screws
/// and an ejection animation (scale down and fade out) when a board clears.
class HoldingTrayWidget extends StatefulWidget {
  /// The 3-slot array of screw IDs (or null if vacant).
  final List<String?> traySlots;

  /// IDs of screws currently playing the ejection animation.
  final List<String> ejectingScrewIds;

  /// Duration of the ejection animation (defaults to 150ms).
  final Duration ejectionDuration;

  const HoldingTrayWidget({
    super.key,
    required this.traySlots,
    this.ejectingScrewIds = const [],
    this.ejectionDuration = const Duration(milliseconds: 150),
  });

  @override
  State<HoldingTrayWidget> createState() => _HoldingTrayWidgetState();
}

class _HoldingTrayWidgetState extends State<HoldingTrayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ejectController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _ejectController = AnimationController(
      vsync: this,
      duration: widget.ejectionDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ejectController, curve: Curves.easeInQuad),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ejectController, curve: Curves.easeInQuad),
    );

    if (widget.ejectingScrewIds.isNotEmpty) {
      _ejectController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant HoldingTrayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ejectionDuration != oldWidget.ejectionDuration) {
      _ejectController.duration = widget.ejectionDuration;
    }
    if (widget.ejectingScrewIds.isNotEmpty &&
        oldWidget.ejectingScrewIds.isEmpty) {
      _ejectController.forward(from: 0.0);
    } else if (widget.ejectingScrewIds.isEmpty &&
        oldWidget.ejectingScrewIds.isNotEmpty) {
      _ejectController.reset();
    }
  }

  @override
  void dispose() {
    _ejectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.woodDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.woodMedium,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          final screwId = index < widget.traySlots.length ? widget.traySlots[index] : null;
          final isEjecting = screwId != null && widget.ejectingScrewIds.contains(screwId);

          return _buildSocket(index, screwId, isEjecting);
        }),
      ),
    );
  }

  Widget _buildSocket(int index, String? screwId, bool isEjecting) {
    return Container(
      key: ValueKey('tray_socket_$index'),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gunmetal,
        border: Border.all(
          color: const Color(0x40FFFFFF),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Center(
        child: screwId == null
            ? const SizedBox.shrink()
            : isEjecting
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ScrewAccent(
                        key: ValueKey('docked_screw_$screwId'),
                        size: 32,
                        type: ScrewType.slotted,
                        material: ScrewMaterial.gold,
                      ),
                    ),
                  )
                : ScrewAccent(
                    key: ValueKey('docked_screw_$screwId'),
                    size: 32,
                    type: ScrewType.slotted,
                    material: ScrewMaterial.gold,
                  ),
      ),
    );
  }
}

