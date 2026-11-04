import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/widgets/screw_accent.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/holding_tray_widget.dart';

void main() {
  group('TASK-002-11: HoldingTrayWidget Tests', () {
    testWidgets('Renders 3 horizontal sockets, all vacant when slots are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoldingTrayWidget(
                traySlots: [null, null, null],
                ejectingScrewIds: [],
              ),
            ),
          ),
        ),
      );

      // Verify 3 socket containers are present
      expect(find.byKey(const ValueKey('tray_socket_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('tray_socket_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('tray_socket_2')), findsOneWidget);

      // No screws docked
      expect(find.byType(ScrewAccent), findsNothing);
    });

    testWidgets('Renders docked gold ScrewAccent when slots are occupied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoldingTrayWidget(
                traySlots: ['screw_3a', null, 'screw_2a'],
                ejectingScrewIds: [],
              ),
            ),
          ),
        ),
      );

      // Verify docked screws in slot 0 and slot 2
      expect(find.byKey(const ValueKey('docked_screw_screw_3a')), findsOneWidget);
      expect(find.byKey(const ValueKey('docked_screw_screw_2a')), findsOneWidget);
      expect(find.byType(ScrewAccent), findsNWidgets(2));

      // Verify properties of docked screw (gold slotted)
      final screwWidget = tester.widget<ScrewAccent>(
        find.byKey(const ValueKey('docked_screw_screw_3a')),
      );
      expect(screwWidget.material, equals(ScrewMaterial.gold));
      expect(screwWidget.type, equals(ScrewType.slotted));
    });

    testWidgets('Ejecting screws animate scale and fade out over 150ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoldingTrayWidget(
                traySlots: ['screw_3a', 'screw_3b', null],
                ejectingScrewIds: ['screw_3a', 'screw_3b'],
                ejectionDuration: Duration(milliseconds: 150),
              ),
            ),
          ),
        ),
      );

      // Initially at frame 0, scale and opacity are 1.0
      final scaleFinder = find.descendant(
        of: find.byType(HoldingTrayWidget),
        matching: find.byType(ScaleTransition),
      );
      final fadeFinder = find.descendant(
        of: find.byType(HoldingTrayWidget),
        matching: find.byType(FadeTransition),
      );
      expect(scaleFinder, findsNWidgets(2));
      expect(fadeFinder, findsNWidgets(2));

      final initialScale = tester.widget<ScaleTransition>(scaleFinder.first);
      expect(initialScale.scale.value, equals(1.0));

      final initialFade = tester.widget<FadeTransition>(fadeFinder.first);
      expect(initialFade.opacity.value, equals(1.0));

      // Advance 75ms (halfway)
      await tester.pump(const Duration(milliseconds: 75));
      final midScale = tester.widget<ScaleTransition>(scaleFinder.first);
      expect(midScale.scale.value, lessThan(1.0));
      expect(midScale.scale.value, greaterThan(0.0));

      // Advance to 150ms (complete)
      await tester.pump(const Duration(milliseconds: 75));
      final finalScale = tester.widget<ScaleTransition>(scaleFinder.first);
      expect(finalScale.scale.value, equals(0.0));
      final finalFade = tester.widget<FadeTransition>(fadeFinder.first);
      expect(finalFade.opacity.value, equals(0.0));
    });
  });
}

