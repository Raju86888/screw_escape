import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/home/presentation/widgets/level_select_dialog.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';
import 'package:screw_escape/src/features/settings/presentation/settings_dialog.dart';

void main() {
  group('Multi-Viewport Responsiveness & Accessibility Tests (TASK-001-17 / AC-09, EC-04, EC-06)', () {
    late InMemoryPreferencesRepository repository;
    late SettingsController controller;

    setUp(() {
      repository = InMemoryPreferencesRepository();
      controller = SettingsController(repository);
    });

    final viewports = <String, Size>{
      'Compact (320x568)': const Size(320, 568),
      'Standard (390x844)': const Size(390, 844),
      'Tall (412x915)': const Size(412, 915),
      'Tablet (800x1280)': const Size(800, 1280),
    };

    for (final entry in viewports.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('HomeScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ScrewEscapeApp(settingsController: controller),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('GameplayPlaceholderScreen renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: GameplayPlaceholderScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(GameplayPlaceholderScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('SettingsDialog renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await controller.loadSettings();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsDialog(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SettingsDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('LevelSelectDialog renders without overflow on $name',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LevelSelectDialog(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LevelSelectDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
        'HomeScreen renders without overflow when Accessibility Text Scaling is 1.5x (EC-06)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.5),
            ),
            child: HomeScreen(settingsController: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
