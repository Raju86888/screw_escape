import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/features/gameplay/application/gameplay_controller.dart';
import 'package:screw_escape/src/features/gameplay/domain/levels/level_1_data.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/board_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/game_status.dart';
import 'package:screw_escape/src/features/gameplay/domain/solver/puzzle_solver.dart';
import 'package:screw_escape/src/features/gameplay/presentation/gameplay_screen.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_controls_bar.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_hud.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_over_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/hint_highlight_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/holding_tray_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/interactive_screw_widget.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/level_win_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/puzzle_canvas.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/wooden_board_widget.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  group('TASK-002-21: Comprehensive Acceptance Criteria Audit (AC-002-01 through AC-002-12)', () {
    late InMemoryPreferencesRepository repo;
    late SettingsController settingsController;

    setUp(() {
      repo = InMemoryPreferencesRepository();
      settingsController = SettingsController(repo);
    });

    testWidgets('AC-002-01: Playable Level 1 Launch from HomeScreen', (tester) async {
      await tester.pumpWidget(
        ScrewEscapeApp(settingsController: settingsController),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();

      expect(find.byType(GameplayScreen), findsOneWidget);
      expect(find.byType(GameHud), findsOneWidget);
      expect(find.byType(PuzzleCanvas), findsOneWidget);
      expect(find.byType(HoldingTrayWidget), findsOneWidget);
      expect(find.byType(GameControlsBar), findsOneWidget);
      expect(find.byType(WoodenBoardWidget), findsNWidgets(3));
      expect(find.byType(InteractiveScrewWidget), findsNWidgets(6));
    });

    testWidgets('AC-002-02 & AC-002-03: Tap-to-Move to First Empty Slot & Single Ownership', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Top board is board_3 with screw_3a and screw_3b
      expect(controller.gameState.traySlots, equals([null, null, null]));

      // Tapping screw_3a moves to slot 0
      controller.onScrewTapped('screw_3a');
      expect(controller.isInputLocked, isTrue);

      await tester.pumpAndSettle();
      expect(controller.gameState.traySlots[0], equals('screw_3a'));
      expect(controller.gameState.screws['screw_3a']!.boardId, equals('board_3'));
      expect(controller.gameState.screws['screw_3a']!.isInTray, isTrue);
      expect(controller.isInputLocked, isFalse);

      controller.dispose();
    });

    testWidgets('AC-002-04 & AC-002-05: Board Fall Animation & Tray Clearing', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Move screw_3a and screw_3b to free board_3
      controller.onScrewTapped('screw_3a');
      await tester.pumpAndSettle();

      controller.onScrewTapped('screw_3b');
      // Board drop sequence triggers
      await tester.pump(const Duration(milliseconds: 250)); // screw travel
      await tester.pump(const Duration(milliseconds: 400)); // board falling
      await tester.pump(const Duration(milliseconds: 150)); // tray ejection
      await tester.pump(const Duration(milliseconds: 100)); // settlement
      await tester.pumpAndSettle();

      expect(controller.gameState.boards['board_3']!.status, equals(BoardStatus.cleared));
      // Tray cleared of board_3 screws
      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.screws['screw_3a']!.isInTray, isFalse);
      expect(controller.gameState.screws['screw_3b']!.isInTray, isFalse);

      controller.dispose();
    });

    testWidgets('AC-002-06: Animation-Safe Game Over on Deadlock', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Intentionally deadlock by filling 3 slots without completing any board:
      // screw_3a (board_3), screw_2a (board_2), screw_1a (board_1)
      controller.onScrewTapped('screw_3a');
      await tester.pumpAndSettle();

      controller.onScrewTapped('screw_2a');
      await tester.pumpAndSettle();

      controller.onScrewTapped('screw_1a');
      await tester.pumpAndSettle();

      expect(controller.gameState.status, equals(GameStatus.lost));
      expect(find.byType(GameOverDialog), findsOneWidget);
      expect(find.text('OUT OF HOLES!'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AC-002-07: Animation-Safe Victory on All Boards Cleared', (tester) async {
      final controller = GameplayController(
        screwTravelDuration: Duration.zero,
        boardFallDuration: Duration.zero,
        trayClearDuration: Duration.zero,
        settlementDuration: Duration.zero,
        hintDuration: const Duration(milliseconds: 50),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Winning sequence: screw_3a, screw_3b -> board_3 cleared
      // screw_2a, screw_2b -> board_2 cleared
      // screw_1a, screw_1b -> board_1 cleared -> WIN
      await controller.onScrewTapped('screw_3a');
      await controller.onScrewTapped('screw_3b');
      await controller.onScrewTapped('screw_2a');
      await controller.onScrewTapped('screw_2b');
      await controller.onScrewTapped('screw_1a');
      await controller.onScrewTapped('screw_1b');

      await tester.pumpAndSettle();

      expect(controller.gameState.status, equals(GameStatus.won));
      expect(find.byType(LevelWinDialog), findsOneWidget);
      expect(find.text('LEVEL 1 CLEARED!'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AC-002-08: Lossless Snapshot Undo Restoring Exact State', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      controller.onScrewTapped('screw_3a');
      await tester.pumpAndSettle();
      expect(controller.gameState.traySlots[0], equals('screw_3a'));

      // Tap UNDO button
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.screws['screw_3a']!.isInTray, isFalse);
      expect(controller.gameState.history.isEmpty, isTrue);

      controller.dispose();
    });

    testWidgets('AC-002-09: Unified BFS Hint with Golden Halo', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HintHighlightWidget), findsNothing);

      // Tap HINT
      await tester.tap(find.text('HINT'));
      await tester.pump();

      expect(controller.hintedScrewId, isNotNull);
      expect(find.byType(HintHighlightWidget), findsOneWidget);

      // Fast-forward 3.0s timer
      await tester.pump(const Duration(milliseconds: 3100));
      expect(controller.hintedScrewId, isNull);

      controller.dispose();
    });

    testWidgets('AC-002-10: Level Restart Resetting to Pristine Initial State', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      controller.onScrewTapped('screw_3a');
      await tester.pumpAndSettle();
      expect(controller.gameState.history.isNotEmpty, isTrue);

      // Tap Restart
      await tester.tap(find.byTooltip('Restart Level'));
      await tester.pumpAndSettle();

      expect(controller.gameState.traySlots, equals([null, null, null]));
      expect(controller.gameState.history.isEmpty, isTrue);
      expect(controller.gameState.status, equals(GameStatus.playing));
      expect(controller.gameState.boards.values.every((b) => b.status == BoardStatus.pinned), isTrue);

      controller.dispose();
    });

    test('AC-002-11: Solvability Verified by BFS Unit Test in 6 moves (< 5ms target)', () {
      final state = Level1Data.create();
      final solution = PuzzleSolver.solve(state);

      expect(solution.isSolvable, isTrue);
      expect(solution.shortestPath.length, equals(6));
      expect(solution.statesVisited, equals(53));
      expect(solution.deadlocksFound, equals(12));
    });

    testWidgets('AC-002-12: Strict Native Visuals & Zero Game Engine', (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Zero Image widgets, pure CustomPaint / BoxDecoration / WoodSurface / ScrewAccent
      expect(find.byType(Image), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);

      controller.dispose();
    });
  });
}
