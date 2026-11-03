import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/home/presentation/home_screen.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  group('App Integration Smoke Test', () {
    testWidgets(
        'ScrewEscapeApp mounts HomeScreen and runs cleanly with injected controller',
        (tester) async {
      final repository = InMemoryPreferencesRepository();
      final controller = SettingsController(repository);
      await controller.loadSettings();

      await tester.pumpWidget(ScrewEscapeApp(settingsController: controller));
      await tester.pumpAndSettle();

      // Verify HomeScreen is mounted
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify header, title, and version
      expect(find.text('SCREW'), findsOneWidget);
      expect(find.text('ESCAPE'), findsOneWidget);
      expect(find.text('v${AppConfig.appVersion}'), findsOneWidget);

      // Verify action buttons
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('LEVELS'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });
  });
}

