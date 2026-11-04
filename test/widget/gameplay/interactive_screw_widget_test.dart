import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/features/gameplay/domain/models/screw_state.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/interactive_screw_widget.dart';

void main() {
  group('TASK-002-13: InteractiveScrewWidget Tests', () {
    testWidgets('Renders gold slotted ScrewAccent with 48x48dp minimum touch target', (tester) async {
      final screw = ScrewState(
        id: 'screw_3a',
        boardId: 'board_3',
        x: 180,
        y: 170,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                InteractiveScrewWidget(
                  screw: screw,
                  isAccessible: true,
                  isEnabled: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveScrewWidget), findsOneWidget);
      expect(find.byType(ScrewAccent), findsOneWidget);

      final screwAccent = tester.widget<ScrewAccent>(find.byType(ScrewAccent));
      expect(screwAccent.material, equals(ScrewMaterial.gold));
      expect(screwAccent.type, equals(ScrewType.slotted));

      // Verify touch target size is at least 48x48
      final touchTargetSize = tester.getSize(find.byKey(const ValueKey('screw_touch_target_screw_3a')));
      expect(touchTargetSize.width, greaterThanOrEqualTo(48.0));
      expect(touchTargetSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Tapping accessible enabled screw invokes onTap callback with screw ID', (tester) async {
      final screw = ScrewState(
        id: 'screw_3a',
        boardId: 'board_3',
        x: 180,
        y: 170,
      );
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                InteractiveScrewWidget(
                  screw: screw,
                  isAccessible: true,
                  isEnabled: true,
                  onTap: (id) => tappedId = id,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('screw_touch_target_screw_3a')));
      await tester.pump();

      expect(tappedId, equals('screw_3a'));
    });

    testWidgets('Tapping disabled or inaccessible screw does not invoke onTap callback', (tester) async {
      final screw = ScrewState(
        id: 'screw_2b',
        boardId: 'board_2',
        x: 180,
        y: 235,
      );
      String? tappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                InteractiveScrewWidget(
                  screw: screw,
                  isAccessible: false,
                  isEnabled: false,
                  onTap: (id) => tappedId = id,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('screw_touch_target_screw_2b')));
      await tester.pump();

      expect(tappedId, isNull);
    });

    testWidgets('Translates towards target offset over 250ms when animating', (tester) async {
      final screw = ScrewState(
        id: 'screw_3a',
        boardId: 'board_3',
        x: 180,
        y: 170,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                InteractiveScrewWidget(
                  screw: screw,
                  isAccessible: true,
                  isEnabled: false,
                  isAnimating: true,
                  targetOffset: const Offset(110, 40),
                  travelDuration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      );

      final transformFinder = find.descendant(
        of: find.byType(InteractiveScrewWidget),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      // Frame 0: origin offset (0, 0) relative to start
      var transform = tester.widget<Transform>(transformFinder.first);
      expect(transform.transform.getTranslation().x, equals(0.0));
      expect(transform.transform.getTranslation().y, equals(0.0));

      // Advance 125ms (halfway)
      await tester.pump(const Duration(milliseconds: 125));
      transform = tester.widget<Transform>(transformFinder.first);
      final midX = transform.transform.getTranslation().x;
      final midY = transform.transform.getTranslation().y;
      expect(midX, isNot(equals(0.0)));
      expect(midY, isNot(equals(0.0)));

      // Advance to 250ms (end)
      await tester.pump(const Duration(milliseconds: 125));
      transform = tester.widget<Transform>(transformFinder.first);
      final finalX = transform.transform.getTranslation().x;
      final finalY = transform.transform.getTranslation().y;
      // targetOffset (110, 40) - start (180, 170) = (-70, -130)
      expect(finalX, closeTo(110.0 - 180.0, 0.1));
      expect(finalY, closeTo(40.0 - 170.0, 0.1));
    });
  });
}
