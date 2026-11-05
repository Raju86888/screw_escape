import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/gameplay/presentation/gameplay_screen.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late InMemoryPreferencesRepository repository;
    late SettingsController controller;

    setUp(() {
      repository = InMemoryPreferencesRepository();
      controller = SettingsController(repository);
    });

    testWidgets('renders all required elements and version indicator',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      expect(find.text('SCREW'), findsOneWidget);
      expect(find.text('ESCAPE'), findsOneWidget);
      expect(find.text('v${AppConfig.appVersion}'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('LEVELS'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('tapping Settings opens SettingsDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
    });

    testWidgets('tapping Levels opens LevelSelectDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      await tester.tap(find.text('LEVELS'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsNWidgets(2)); // Button + Dialog header
      expect(find.text('Level selection coming soon!'), findsOneWidget);
    });

    testWidgets('tapping Play navigates to GameplayScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(settingsController: controller),
        ),
      );

      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();

      expect(find.byType(GameplayScreen), findsOneWidget);
    });
  });
}

