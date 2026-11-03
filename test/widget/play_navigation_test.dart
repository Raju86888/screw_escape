import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  group('Play Navigation & Debounce Guard Tests', () {
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

      // Tapping BACK once should return cleanly to HomeScreen
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
  });
}
