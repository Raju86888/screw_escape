import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/wooden_board_state.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/wooden_board_widget.dart';

void main() {
  group('TASK-002-12: WoodenBoardWidget Tests', () {
    testWidgets('Renders pinned board at designated shape with WoodSurface', (tester) async {
      final board = WoodenBoardState(
        id: 'board_2',
        left: 40,
        top: 210,
        width: 280,
        height: 50,
        attachedScrewIds: {'screw_2a', 'screw_2b'},
        zIndex: 1,
        status: BoardStatus.pinned,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WoodenBoardWidget(board: board),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WoodenBoardWidget), findsOneWidget);
      expect(find.byType(WoodSurface), findsOneWidget);

      final size = tester.getSize(find.byType(WoodSurface));
      expect(size.width, equals(280.0));
      expect(size.height, equals(50.0));
    });

    testWidgets('Animates vertical translation (+600dp) and +8 deg tilt when falling over 400ms', (tester) async {
      final board = WoodenBoardState(
        id: 'board_3',
        left: 145,
        top: 140,
        width: 70,
        height: 260,
        attachedScrewIds: {},
        zIndex: 2,
        status: BoardStatus.falling,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WoodenBoardWidget(
                  board: board,
                  fallDuration: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),
      );

      // Frame 0: At initial position
      final transformFinder = find.descendant(
        of: find.byType(WoodenBoardWidget),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      // Initial transform at 0ms
      var transformWidget = tester.widget<Transform>(transformFinder.first);
      expect(transformWidget.transform.getTranslation().y, equals(0.0));

      // Advance 200ms (halfway with easeInQuad curve)
      await tester.pump(const Duration(milliseconds: 200));
      transformWidget = tester.widget<Transform>(transformFinder.first);
      final midY = transformWidget.transform.getTranslation().y;
      expect(midY, greaterThan(0.0));
      expect(midY, lessThan(600.0));

      // Advance to 400ms (end)
      await tester.pump(const Duration(milliseconds: 200));
      transformWidget = tester.widget<Transform>(transformFinder.first);
      final finalY = transformWidget.transform.getTranslation().y;
      expect(finalY, closeTo(600.0, 0.1));

      // Verify rotation (+8 degrees in radians = 8 * pi / 180 = ~0.1396 rad)
      final rotateWidget = tester.widget<Transform>(transformFinder.at(1));
      final expectedAngle = 8.0 * math.pi / 180.0;
      expect(rotateWidget.transform.storage[0], closeTo(math.cos(expectedAngle), 0.05));
    });

    testWidgets('Renders nothing or SizedBox.shrink when board status is cleared', (tester) async {
      final board = WoodenBoardState(
        id: 'board_1',
        left: 40,
        top: 310,
        width: 280,
        height: 50,
        attachedScrewIds: {},
        zIndex: 0,
        status: BoardStatus.cleared,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WoodenBoardWidget(board: board),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WoodSurface), findsNothing);
    });
  });
}
