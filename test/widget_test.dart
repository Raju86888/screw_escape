import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/app.dart';
import 'package:screw_escape/src/core/config/app_config.dart';

void main() {
  testWidgets('ScrewEscapeApp renders app title and version smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ScrewEscapeApp());

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text(AppConfig.appVersion), findsOneWidget);
  });
}
