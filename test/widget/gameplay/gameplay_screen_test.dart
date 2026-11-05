import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/presentation/gameplay_screen.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_controls_bar.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_hud.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_over_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/level_win_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/puzzle_canvas.dart';

void main() {
  group('TASK-002-18: GameplayScreen Widget Tests', () {
    late GameplayController controller;

    setUp(() {
      controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
        hintDuration: const Duration(milliseconds: 50),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('Renders GameHud, PuzzleCanvas, and GameControlsBar in responsive layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      expect(find.byType(GameplayScreen), findsOneWidget);
      expect(find.byType(GameHud), findsOneWidget);
      expect(find.byType(PuzzleCanvas), findsOneWidget);
      expect(find.byType(GameControlsBar), findsOneWidget);
    });

    testWidgets('Tapping Restart on HUD resets game state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // Make a move
      await controller.onScrewTapped('screw_3a');
      expect(controller.gameState.traySlots[0], equals('screw_3a'));
      await tester.pump();

      // Tap Restart
      await tester.tap(find.byKey(const ValueKey('game_hud_restart_button')));
      await tester.pump();

      expect(controller.gameState.traySlots[0], isNull);
      expect(controller.gameState.history, isEmpty);
    });

    testWidgets('Tapping Undo on GameControlsBar restores snapshot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // Make a move
      await controller.onScrewTapped('screw_3a');
      expect(controller.gameState.traySlots[0], equals('screw_3a'));
      await tester.pump();

      // Tap Undo
      await tester.tap(find.byKey(const ValueKey('game_controls_undo_button')));
      await tester.pump();

      expect(controller.gameState.traySlots[0], isNull);
    });

    testWidgets('Tapping Hint triggers golden halo or toast on deadlock', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // In initial state, Hint highlights a screw
      await tester.tap(find.byKey(const ValueKey('game_controls_hint_button')));
      await tester.pump();

      expect(controller.hintedScrewId, isNotNull);

      // Drain hint timer
      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('Deadlock sequence automatically mounts GameOverDialog with Undo Move and Retry actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // Deadlock moves: 1a, 2a, 3a
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_3a');

      // Pump to allow settlement and dialog display
      await tester.pumpAndSettle();

      expect(find.byType(GameOverDialog), findsOneWidget);

      // Tapping "Undo Move" on dialog restores pre-deadlock state and dismisses modal
      await tester.tap(find.byKey(const ValueKey('game_over_undo_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameOverDialog), findsNothing);
      expect(controller.gameState.traySlots[2], isNull);
    });

    testWidgets('Winning sequence automatically mounts LevelWinDialog with Replay action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // Canonical 6-move win: 3a, 3b, 2a, 2b, 1a, 1b
      await controller.onScrewTapped('screw_3a');
      await controller.onScrewTapped('screw_3b');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_2b');
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_1b');

      await tester.pumpAndSettle();

      expect(find.byType(LevelWinDialog), findsOneWidget);

      // Tapping "Replay Level" dismisses dialog and resets
      await tester.tap(find.byKey(const ValueKey('level_win_replay_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LevelWinDialog), findsNothing);
      expect(controller.gameState.traySlots, equals([null, null, null]));
    });

    testWidgets('Deadlock hint toast displays non-blocking SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );

      // Moves 1a and 2a lead to deadlock
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_2a');
      await tester.pump();

      // Tap Hint
      await tester.tap(find.byKey(const ValueKey('game_controls_hint_button')));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No winning path from here. Use Undo or Restart!'), findsOneWidget);
    });
  });
}
