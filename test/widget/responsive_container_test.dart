import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/responsive_container.dart';

void main() {
  group('ResponsiveContainer Widget', () {
    testWidgets('renders child content inside SafeArea',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('Safe Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Safe Child Content'), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('constrains content width on large screen viewports',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              maxWidth: 400.0,
              child: SizedBox(
                width: 600.0,
                child: Text('Constrained Content'),
              ),
            ),
          ),
        ),
      );

      final constrainedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox &&
            widget.constraints.maxWidth == 400.0,
      );
      expect(constrainedBoxFinder, findsOneWidget);
    });

    testWidgets('prevents overflow on ultra-small viewports via scrollability',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Column(
                children: List.generate(
                  15,
                  (index) => Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('Item $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

