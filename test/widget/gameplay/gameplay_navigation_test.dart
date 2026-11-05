import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay/presentation/gameplay_screen.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  group('TASK-002-19: Gameplay Navigation Tests', () {
    late SettingsController controller;

    setUp(() {
      controller = SettingsController(InMemoryPreferencesRepository());
    });

    testWidgets('Tapping PLAY on HomeScreen pushes GameplayScreen (replacing placeholder)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      // Verify HomeScreen is active
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(GameplayScreen), findsNothing);

      // Tap PLAY
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();

      // GameplayScreen is mounted, placeholder is NOT mounted
      expect(find.byType(GameplayScreen), findsOneWidget);
      expect(find.byType(GameplayPlaceholderScreen), findsNothing);

      // Tapping Back in GameHud pops back to HomeScreen
      await tester.tap(find.byKey(const ValueKey('game_hud_back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameplayScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Rapid double-tap on PLAY only pushes a single GameplayScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      // Double tap PLAY rapidly
      await tester.tap(find.text('PLAY'));
      await tester.tap(find.text('PLAY'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Only 1 GameplayScreen on stack
      expect(find.byType(GameplayScreen), findsOneWidget);

      // Single back pop returns to HomeScreen
      await tester.tap(find.byKey(const ValueKey('game_hud_back_button')));
      await tester.pumpAndSettle();

      expect(find.byType(GameplayScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
