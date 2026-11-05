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
  group('TASK-002-20: Responsive Gameplay & Accessibility Verification', () {
    final viewports = <String, Size>{
      'Narrow phone (320x640)': const Size(320, 640),
      'Standard phone (360x800)': const Size(360, 800),
      'Large phone (412x915)': const Size(412, 915),
      'Small tablet (800x1280)': const Size(800, 1280),
      'Large tablet (1200x1600)': const Size(1200, 1600),
    };

    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('GameplayScreen renders with zero overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = GameplayController();

        await tester.pumpWidget(
          MaterialApp(
            home: GameplayScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GameplayScreen), findsOneWidget);
        expect(find.byType(GameHud), findsOneWidget);
        expect(find.byType(PuzzleCanvas), findsOneWidget);
        expect(find.byType(GameControlsBar), findsOneWidget);

        // Verify no RenderFlex overflow exceptions occurred
        expect(tester.takeException(), isNull);

        controller.dispose();
      });

      testWidgets('LevelWinDialog renders cleanly without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: LevelWinDialog(
                  onReplayPressed: () {},
                  onMainMenuPressed: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LevelWinDialog), findsOneWidget);
        expect(find.text('LEVEL 1 CLEARED!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('GameOverDialog renders cleanly without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: GameOverDialog(
                  onUndoPressed: () {},
                  onRetryPressed: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GameOverDialog), findsOneWidget);
        expect(find.text('OUT OF HOLES!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Touch target interaction functions accurately on narrow phone (320x640)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Level 1 top board (board_3) has screw_3a at logical (180, 170)
      final canvasFinder = find.byType(PuzzleCanvas);
      final canvasTopLeft = tester.getTopLeft(canvasFinder);
      final canvasSize = tester.getSize(canvasFinder);

      const logicalW = 360.0;
      const logicalH = 500.0;
      final scale = (canvasSize.width / logicalW < canvasSize.height / logicalH)
          ? canvasSize.width / logicalW
          : canvasSize.height / logicalH;
      final dx = (canvasSize.width - logicalW * scale) / 2;
      final dy = (canvasSize.height - logicalH * scale) / 2;

      final screenX = canvasTopLeft.dx + dx + (180.0 * scale);
      final screenY = canvasTopLeft.dy + dy + (170.0 * scale);

      await tester.tapAt(Offset(screenX, screenY));
      await tester.pump();

      expect(controller.isInputLocked, isTrue);

      await tester.pumpAndSettle();
      expect(controller.gameState.screws['screw_3a']!.isInTray, isTrue);

      controller.dispose();
    });

    testWidgets('Touch target interaction functions accurately on small tablet (800x1280)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final canvasFinder = find.byType(PuzzleCanvas);
      final canvasTopLeft = tester.getTopLeft(canvasFinder);
      final canvasSize = tester.getSize(canvasFinder);

      const logicalW = 360.0;
      const logicalH = 500.0;
      final scale = (canvasSize.width / logicalW < canvasSize.height / logicalH)
          ? canvasSize.width / logicalW
          : canvasSize.height / logicalH;
      final dx = (canvasSize.width - logicalW * scale) / 2;
      final dy = (canvasSize.height - logicalH * scale) / 2;

      final screenX = canvasTopLeft.dx + dx + (180.0 * scale);
      final screenY = canvasTopLeft.dy + dy + (170.0 * scale);

      await tester.tapAt(Offset(screenX, screenY));
      await tester.pump();

      expect(controller.isInputLocked, isTrue);

      await tester.pumpAndSettle();
      expect(controller.gameState.screws['screw_3a']!.isInTray, isTrue);

      controller.dispose();
    });

    testWidgets('GameplayScreen renders without overflow under 1.5x accessibility text scaling',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.5),
            ),
            child: GameplayScreen(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameplayScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      controller.dispose();
    });

    testWidgets('HUD action buttons meet minimum 48x48dp touch target standard',
        (tester) async {
      final controller = GameplayController();

      await tester.pumpWidget(
        MaterialApp(
          home: GameplayScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byTooltip('Back to Menu');
      final restartButton = find.byTooltip('Restart Level');
      final undoButton = find.byKey(const ValueKey('game_controls_undo_button'));
      final hintButton = find.byKey(const ValueKey('game_controls_hint_button'));

      expect(tester.getSize(backButton).width, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(backButton).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(restartButton).width, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(restartButton).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(undoButton).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(hintButton).height, greaterThanOrEqualTo(48.0));

      controller.dispose();
    });
  });
}
