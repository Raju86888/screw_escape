import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/gameplay_placeholder/presentation/gameplay_placeholder_screen.dart';

void main() {
  group('GameplayPlaceholderScreen Widget Tests', () {
    testWidgets('renders headline, descriptive text, and Back button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GameplayPlaceholderScreen(),
        ),
      );

      expect(find.text('Gameplay coming soon'), findsOneWidget);
      expect(
        find.textContaining('under active development'),
        findsOneWidget,
      );
      expect(find.text('BACK'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('tapping Back button pops the route', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GameplayPlaceholderScreen(),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open Placeholder'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open Placeholder'));
      await tester.pumpAndSettle();

      expect(find.text('Gameplay coming soon'), findsOneWidget);
      expect(popped, isFalse);

      // Tap Back button
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Gameplay coming soon'), findsNothing);
      expect(find.text('Open Placeholder'), findsOneWidget);
    });

    testWidgets('system back navigation pops the route cleanly',
        (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GameplayPlaceholderScreen(),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open Placeholder'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Placeholder'));
      await tester.pumpAndSettle();

      expect(find.text('Gameplay coming soon'), findsOneWidget);

      // Simulate system back gesture / pop
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Gameplay coming soon'), findsNothing);
    });
  });
}

