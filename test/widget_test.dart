import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/core/config/app_config.dart';
import 'package:screw_escape/src/features/settings/data/in_memory_preferences_repository.dart';
import 'package:screw_escape/src/features/settings/domain/settings_controller.dart';

void main() {
  testWidgets('ScrewEscapeApp renders app title and version smoke test',
      (WidgetTester tester) async {
    final controller = SettingsController(InMemoryPreferencesRepository());
    await tester.pumpWidget(ScrewEscapeApp(settingsController: controller));
    await tester.pumpAndSettle();

    expect(find.text('SCREW'), findsOneWidget);
    expect(find.text('ESCAPE'), findsOneWidget);
    expect(find.text('v${AppConfig.appVersion}'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('LEVELS'), findsOneWidget);
  });
}
