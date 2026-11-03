import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/metallic_button.dart';

void main() {
  group('MetallicButton Widget', () {
    testWidgets('renders label and invokes callback on tap',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MetallicButton(
                label: 'PLAY',
                icon: Icons.play_arrow,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('PLAY'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byType(MetallicButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('disabled button does not trigger callback when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MetallicButton(
                label: 'DISABLED',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MetallicButton));
      await tester.pump();

      // No exception, button remains disabled
      expect(find.text('DISABLED'), findsOneWidget);
    });

    testWidgets('tap down triggers visual press depression',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MetallicButton(
                label: 'PRESS ME',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(tester.getCenter(find.byType(MetallicButton)));
      await tester.pump(const Duration(milliseconds: 60));

      // After tap down, AnimatedContainer should have translated downward
      final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(animatedContainer.transform, isNotNull);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('displays loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MetallicButton(
                label: 'LOADING',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('LOADING'), findsNothing);
    });
  });
}

