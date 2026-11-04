import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/holding_tray_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/interactive_screw_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/puzzle_canvas.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/wooden_board_widget.dart';

void main() {
  group('TASK-002-15: PuzzleCanvas Responsive Coordinate Mapping & Hit-Testing Tests', () {
    late GameplayController controller;

    setUp(() {
      controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('Renders within 360x500dp logical canvas with holding tray and boards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 720,
                height: 1000,
                child: PuzzleCanvas(controller: controller),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PuzzleCanvas), findsOneWidget);
      expect(find.byType(HoldingTrayWidget), findsOneWidget);
      expect(find.byType(WoodenBoardWidget), findsNWidgets(3));
      expect(find.byType(InteractiveScrewWidget), findsNWidgets(6));
    });

    testWidgets('Inverse touch coordinate transform correctly maps scaled screen touch to logical screw', (tester) async {
      tester.view.physicalSize = const Size(720, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 720,
                height: 1000,
                child: PuzzleCanvas(controller: controller),
              ),
            ),
          ),
        ),
      );

      // Tap screen position (360, 340)
      final canvasOrigin = tester.getTopLeft(find.byType(PuzzleCanvas));
      await tester.tapAt(canvasOrigin + const Offset(360, 340));
      await tester.pump();

      // screw_3a must have been moved to tray slot 0
      expect(controller.gameState.traySlots[0], equals('screw_3a'));
    });

    testWidgets('Tapping covered screw (screw_2b occluded by board_3) absorbs touch without move', (tester) async {
      tester.view.physicalSize = const Size(360, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 500,
                child: PuzzleCanvas(controller: controller),
              ),
            ),
          ),
        ),
      );

      // Tap directly on screw_2b position (180, 235)
      final canvasOrigin = tester.getTopLeft(find.byType(PuzzleCanvas));
      await tester.tapAt(canvasOrigin + const Offset(180, 235));
      await tester.pump();

      // Tray should remain empty, screw_2b not moved
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.screws['screw_2b']!.isInTray, isFalse);
    });

    testWidgets('Tapping outside canvas bounds is completely discarded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 1200,
              child: PuzzleCanvas(controller: controller),
            ),
          ),
        ),
      );

      // Tap way outside the centered 360x500 box (e.g. top-left corner (10, 10))
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(controller.gameState.traySlots, equals([null, null, null]));
    });
  });
}
