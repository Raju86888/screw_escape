import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/holding_tray_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/hint_highlight_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/interactive_screw_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/wooden_board_widget.dart';

/// Responsive puzzle canvas hosting layered wooden boards, holding tray, and screws.
///
/// Automatically scales a normalized 360x500dp logical playfield to fit
/// any Android screen viewport while performing inverse touch mapping and
/// top-down z-index hit testing.
class PuzzleCanvas extends StatelessWidget {
  /// The authoritative gameplay controller driving state and animations.
  final GameplayController controller;

  /// Logical width of the game board.
  static const double logicalWidth = 360.0;

  /// Logical height of the game board.
  static const double logicalHeight = 500.0;

  /// Tray socket target coordinates in logical canvas space.
  static const List<Offset> traySocketCenters = [
    Offset(98.0, 36.0),
    Offset(180.0, 36.0),
    Offset(262.0, 36.0),
  ];

  const PuzzleCanvas({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(
              constraints.maxWidth / logicalWidth,
              constraints.maxHeight / logicalHeight,
            );
            final renderedWidth = logicalWidth * scale;
            final renderedHeight = logicalHeight * scale;
            final dx = (constraints.maxWidth - renderedWidth) / 2.0;
            final dy = (constraints.maxHeight - renderedHeight) / 2.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => _handleTap(details.localPosition, dx, dy, scale),
              child: Stack(
                children: [
                  Positioned(
                    left: dx,
                    top: dy,
                    width: renderedWidth,
                    height: renderedHeight,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: logicalWidth,
                        height: logicalHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Holding Tray at the top
                            Positioned(
                              left: 70,
                              top: 4,
                              child: HoldingTrayWidget(
                                traySlots: controller.gameState.traySlots,
                                ejectingScrewIds: controller.ejectingScrewIds,
                                ejectionDuration: controller.trayClearDuration,
                              ),
                            ),

                            // 2. Layered Wooden Boards (ordered bottom to top by zIndex)
                            ..._buildBoards(),

                            // 3. Interactive Screws
                            ..._buildScrews(),

                            // 4. Active Hint Golden Halo Highlight
                            if (controller.hintedScrewId != null &&
                                controller.gameState.screws.containsKey(controller.hintedScrewId))
                              _buildHintHalo(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildBoards() {
    final boards = controller.gameState.boards.values.toList()
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return boards.map((board) {
      return WoodenBoardWidget(
        key: ValueKey('board_widget_${board.id}'),
        board: board,
        fallDuration: controller.boardFallDuration,
      );
    }).toList();
  }

  List<Widget> _buildScrews() {
    final targetSlot = controller.gameState.traySlots.indexOf(null);
    final targetOffset = targetSlot != -1 ? traySocketCenters[targetSlot] : null;

    return controller.gameState.screws.values.map((screw) {
      final isAccessible = controller.gameState.isScrewAccessible(screw.id);
      final isAnimating = controller.animatingScrewId == screw.id;

      return InteractiveScrewWidget(
        key: ValueKey('interactive_screw_${screw.id}'),
        screw: screw,
        isAccessible: isAccessible,
        isEnabled: !controller.isInputLocked,
        isAnimating: isAnimating,
        targetOffset: targetOffset,
        travelDuration: controller.screwTravelDuration,
        onTap: (id) => controller.onScrewTapped(id),
      );
    }).toList();
  }

  Widget _buildHintHalo() {
    final screw = controller.gameState.screws[controller.hintedScrewId!]!;
    return HintHighlightWidget(
      key: ValueKey('hint_halo_${screw.id}'),
      x: screw.x,
      y: screw.y,
      radius: 22.0,
    );
  }

  void _handleTap(Offset localPosition, double dx, double dy, double scale) {
    if (scale <= 0) return;

    // 1. Inverse touch coordinate mapping
    final logicalX = (localPosition.dx - dx) / scale;
    final logicalY = (localPosition.dy - dy) / scale;

    // 2. Discard if touch is outside logical bounds
    if (logicalX < 0 ||
        logicalX > logicalWidth ||
        logicalY < 0 ||
        logicalY > logicalHeight) {
      return;
    }

    final touchPoint = Offset(logicalX, logicalY);

    // 3. Find candidate screws within 24dp touch radius
    const touchRadius = 24.0;
    final candidates = controller.gameState.screws.values
        .where((s) => !s.isInTray && (Offset(s.x, s.y) - touchPoint).distance <= touchRadius)
        .toList();

    if (candidates.isEmpty) return;

    // 4. Sort candidates descending by owning board zIndex (topmost board first)
    candidates.sort((a, b) {
      final zA = controller.gameState.boards[a.boardId]!.zIndex;
      final zB = controller.gameState.boards[b.boardId]!.zIndex;
      return zB.compareTo(zA);
    });

    final topCandidate = candidates.first;

    // 5. If topmost candidate is accessible and input is not locked, invoke move
    if (controller.gameState.isScrewAccessible(topCandidate.id) &&
        !controller.isInputLocked) {
      controller.onScrewTapped(topCandidate.id);
    }
  }
}

