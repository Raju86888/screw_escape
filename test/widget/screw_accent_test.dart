import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';

void main() {
  group('ScrewAccent Widget', () {
    testWidgets('renders silver phillips screw at custom size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrewAccent(
                size: 32.0,
                type: ScrewType.phillips,
                material: ScrewMaterial.silver,
              ),
            ),
          ),
        ),
      );

      final customPaintFinder = find.byType(CustomPaint);
      expect(customPaintFinder, findsWidgets);

      final screwWidget = tester.widget<ScrewAccent>(find.byType(ScrewAccent));
      expect(screwWidget.size, equals(32.0));
      expect(screwWidget.type, equals(ScrewType.phillips));
      expect(screwWidget.material, equals(ScrewMaterial.silver));
    });

    testWidgets('renders gold slotted screw with rotation angle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrewAccent(
                size: 20.0,
                type: ScrewType.slotted,
                material: ScrewMaterial.gold,
                angle: 0.75,
              ),
            ),
          ),
        ),
      );

      final screwWidget = tester.widget<ScrewAccent>(find.byType(ScrewAccent));
      expect(screwWidget.size, equals(20.0));
      expect(screwWidget.type, equals(ScrewType.slotted));
      expect(screwWidget.material, equals(ScrewMaterial.gold));
      expect(screwWidget.angle, equals(0.75));
    });
  });
}

