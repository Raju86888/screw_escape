import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/wood_surface.dart';

void main() {
  group('WoodSurface Widget', () {
    testWidgets('renders background and displays child content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WoodSurface(
              padding: EdgeInsets.all(16.0),
              child: Text('Test Wood Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Wood Child'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with border radius and elevation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WoodSurface(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              elevation: 8.0,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final woodSurface = tester.widget<WoodSurface>(find.byType(WoodSurface));
      expect(woodSurface.elevation, equals(8.0));
      expect(woodSurface.borderRadius, equals(const BorderRadius.all(Radius.circular(12.0))));
    });
  });
}

