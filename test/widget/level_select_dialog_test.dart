import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/features/home/presentation/widgets/level_select_dialog.dart';

void main() {
  group('LevelSelectDialog Widget Tests', () {
    testWidgets('renders all required elements and messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelSelectDialog(),
          ),
        ),
      );

      expect(find.text('LEVELS'), findsOneWidget);
      expect(find.text('Level selection coming soon!'), findsOneWidget);
      expect(
        find.textContaining('Stages, progression rewards'),
        findsOneWidget,
      );
      expect(find.text('CLOSE'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2));
      expect(find.byTooltip('Close levels'), findsOneWidget);
    });

    testWidgets('tapping CLOSE button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => LevelSelectDialog.show(context),
                child: const Text('Open Levels'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Levels'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsNothing);
    });

    testWidgets('tapping X icon button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => LevelSelectDialog.show(context),
                child: const Text('Open Levels'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Levels'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsOneWidget);

      await tester.tap(find.byTooltip('Close levels'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsNothing);
    });

    testWidgets('tapping outside modal dismisses dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => LevelSelectDialog.show(context),
                child: const Text('Open Levels'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Levels'));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsOneWidget);

      // Tap outside the dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('LEVELS'), findsNothing);
    });
  });
}

