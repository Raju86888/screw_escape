import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/home/presentation/widgets/level_select_dialog.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';
import 'package:screw_escape/src/features/settings/presentation/settings_dialog.dart';

void main() {
  group('Navigation Regression Tests (TASK-001-16 / REQ-001-03, REQ-001-04, EC-05, AC-03, AC-04)', () {
    late InMemoryPreferencesRepository repository;
    late SettingsController controller;

    setUp(() {
      repository = InMemoryPreferencesRepository();
      controller = SettingsController(repository);
    });

    testWidgets(
        'rapid double-tap on PLAY only pushes a single GameplayPlaceholderScreen',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      // Perform rapid double-tap on PLAY
      await tester.tap(find.text('PLAY'));
      await tester.tap(find.text('PLAY'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Exactly one gameplay screen exists
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);

      // Tapping BACK once returns cleanly to HomeScreen
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      expect(find.byType(GameplayPlaceholderScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
        'can navigate to Gameplay and back repeatedly without lockout',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      // First navigation cycle
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsNothing);

      // Second navigation cycle (confirms debounce reset)
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsNothing);
    });

    testWidgets(
        'Android system back gesture from GameplayPlaceholder pops cleanly to HomeScreen',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);

      // Trigger system back pop
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.byType(GameplayPlaceholderScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Confirm Play button still works after system back pop
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);
    });

    testWidgets(
        'Settings modal and Level Select dialog can be sequentially opened and dismissed without route collisions',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      // Open and dismiss Settings
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsNothing);

      // Open and dismiss Levels
      await tester.tap(find.text('LEVELS'));
      await tester.pumpAndSettle();
      expect(find.byType(LevelSelectDialog), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.byType(LevelSelectDialog), findsNothing);

      // Immediately navigate to Play
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);
    });
  });
}
