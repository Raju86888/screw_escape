import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';
import 'package:screw_escape/src/features/settings/presentation/settings_dialog.dart';
import 'package:screw_escape/src/features/settings/presentation/widgets/sound_toggle_row.dart';

void main() {
  group('SettingsDialog & SoundToggleRow Widget Tests', () {
    late InMemoryPreferencesRepository repository;
    late SettingsController controller;

    setUp(() {
      repository = InMemoryPreferencesRepository();
      controller = SettingsController(repository);
    });

    testWidgets('renders all required elements and exact version string',
        (tester) async {
      await controller.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDialog(controller: controller),
          ),
        ),
      );

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Version ${AppConfig.appVersion}'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byTooltip('Close settings'), findsOneWidget);
    });

    testWidgets('switch is disabled when controller is not loaded',
        (tester) async {
      // Note: loadSettings has not been called, so isLoaded == false
      expect(controller.isLoaded, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SoundToggleRow(controller: controller),
          ),
        ),
      );

      expect(find.text('Loading settings...'), findsOneWidget);
      final Switch switchWidget = tester.widget(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('toggling switch updates controller and repository',
        (tester) async {
      await controller.loadSettings();
      expect(controller.soundEnabled, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDialog(controller: controller),
          ),
        ),
      );

      expect(find.text('Enabled'), findsOneWidget);

      // Tap the switch to toggle from true to false
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(controller.soundEnabled, isFalse);
      expect(find.text('Disabled'), findsOneWidget);
      expect(await repository.getBool(AppConfig.soundPrefKey), isFalse);

      // Tap again to toggle back to true
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(controller.soundEnabled, isTrue);
      expect(find.text('Enabled'), findsOneWidget);
      expect(await repository.getBool(AppConfig.soundPrefKey), isTrue);
    });

    testWidgets('tapping CLOSE button dismisses dialog', (tester) async {
      await controller.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => SettingsDialog.show(
                  context,
                  controller: controller,
                ),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsNothing);
    });

    testWidgets('tapping X icon button dismisses dialog', (tester) async {
      await controller.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => SettingsDialog.show(
                  context,
                  controller: controller,
                ),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);

      await tester.tap(find.byTooltip('Close settings'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsNothing);
    });

    testWidgets('tapping outside modal dismisses dialog', (tester) async {
      await controller.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => SettingsDialog.show(
                  context,
                  controller: controller,
                ),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);

      // Tap on top left barrier area outside modal
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsNothing);
    });
  });
}

