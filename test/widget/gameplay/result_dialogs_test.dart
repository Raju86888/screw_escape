import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_over_dialog.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/level_win_dialog.dart';

void main() {
  group('TASK-002-17: Result Dialogs Widget Tests', () {
    testWidgets('LevelWinDialog renders victory headline, Replay and Main Menu buttons', (tester) async {
      bool replayTapped = false;
      bool mainMenuTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelWinDialog(
              onReplayPressed: () => replayTapped = true,
              onMainMenuPressed: () => mainMenuTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(WoodSurface), findsOneWidget);
      expect(find.text('LEVEL 1 CLEARED!'), findsOneWidget);
      expect(find.byKey(const ValueKey('level_win_replay_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('level_win_main_menu_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('level_win_replay_button')));
      await tester.pump();
      expect(replayTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('level_win_main_menu_button')));
      await tester.pump();
      expect(mainMenuTapped, isTrue);
    });

    testWidgets('GameOverDialog renders Out of Holes headline, Undo Move, and Retry buttons', (tester) async {
      bool undoTapped = false;
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              onUndoPressed: () => undoTapped = true,
              onRetryPressed: () => retryTapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(WoodSurface), findsOneWidget);
      expect(find.text('OUT OF HOLES!'), findsOneWidget);
      expect(find.text('The holding tray is full.'), findsOneWidget);
      expect(find.byKey(const ValueKey('game_over_undo_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('game_over_retry_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('game_over_undo_button')));
      await tester.pump();
      expect(undoTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('game_over_retry_button')));
      await tester.pump();
      expect(retryTapped, isTrue);
    });
  });
}

