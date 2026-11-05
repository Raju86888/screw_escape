import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_controls_bar.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/game_hud.dart';

void main() {
  group('TASK-002-16: GameHud and GameControlsBar Widget Tests', () {
    testWidgets('GameHud renders Back button, Level 1 title, and Restart button', (tester) async {
      bool backTapped = false;
      bool restartTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              levelTitle: 'LEVEL 1',
              isInputLocked: false,
              onBackPressed: () => backTapped = true,
              onRestartPressed: () => restartTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('LEVEL 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('game_hud_back_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('game_hud_restart_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('game_hud_back_button')));
      await tester.pump();
      expect(backTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('game_hud_restart_button')));
      await tester.pump();
      expect(restartTapped, isTrue);
    });

    testWidgets('GameHud disables Restart button when isInputLocked is true', (tester) async {
      bool restartTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              levelTitle: 'LEVEL 1',
              isInputLocked: true,
              onBackPressed: () {},
              onRestartPressed: () => restartTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('game_hud_restart_button')));
      await tester.pump();
      expect(restartTapped, isFalse);

      final restartOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const ValueKey('game_hud_restart_button')),
          matching: find.byType(Opacity),
        ),
      );
      expect(restartOpacity.opacity, equals(0.5));
    });

    testWidgets('GameControlsBar renders Undo and Hint buttons and invokes callbacks when enabled', (tester) async {
      bool undoTapped = false;
      bool hintTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsBar(
              isUndoDisabled: false,
              isHintDisabled: false,
              onUndoPressed: () => undoTapped = true,
              onHintPressed: () => hintTapped = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('game_controls_undo_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('game_controls_hint_button')), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
      expect(find.text('HINT'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('game_controls_undo_button')));
      await tester.pump();
      expect(undoTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('game_controls_hint_button')));
      await tester.pump();
      expect(hintTapped, isTrue);
    });

    testWidgets('GameControlsBar disables Undo when isUndoDisabled and Hint when isHintDisabled', (tester) async {
      bool undoTapped = false;
      bool hintTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameControlsBar(
              isUndoDisabled: true,
              isHintDisabled: true,
              onUndoPressed: () => undoTapped = true,
              onHintPressed: () => hintTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('game_controls_undo_button')));
      await tester.pump();
      expect(undoTapped, isFalse);

      await tester.tap(find.byKey(const ValueKey('game_controls_hint_button')));
      await tester.pump();
      expect(hintTapped, isFalse);

      // Verify opacity is dimmed to 0.5
      final undoOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const ValueKey('game_controls_undo_button')),
          matching: find.byType(Opacity),
        ),
      );
      expect(undoOpacity.opacity, equals(0.5));

      final hintOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(const ValueKey('game_controls_hint_button')),
          matching: find.byType(Opacity),
        ),
      );
      expect(hintOpacity.opacity, equals(0.5));
    });
  });
}
