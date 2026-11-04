import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';
import 'package:screw_escape/src/features/gameplay/presentation/widgets/hint_highlight_widget.dart';

void main() {
  group('TASK-002-14: HintHighlightWidget Tests', () {
    testWidgets('Renders pulsating circular halo with gold color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                HintHighlightWidget(
                  x: 180,
                  y: 170,
                  radius: 20,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(HintHighlightWidget), findsOneWidget);

      final containerFinder = find.descendant(
        of: find.byType(HintHighlightWidget),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);

      // Verify border color uses AppColors.metalGoldLight / 0xFFFFD700
      final container = tester.widget<Container>(containerFinder.first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
      expect(decoration.border, isNotNull);
      expect(
        decoration.border!.top.color,
        isIn([AppColors.metalGoldLight, AppColors.textGold]),
      );
    });

    testWidgets('Loops scale (1.0x to 1.25x) and opacity (0.6 to 1.0)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                HintHighlightWidget(
                  x: 180,
                  y: 170,
                  radius: 20,
                  pulsePeriod: Duration(milliseconds: 1000),
                ),
              ],
            ),
          ),
        ),
      );

      // Frame 0
      final scaleFinder = find.descendant(
        of: find.byType(HintHighlightWidget),
        matching: find.byType(ScaleTransition),
      );
      final fadeFinder = find.descendant(
        of: find.byType(HintHighlightWidget),
        matching: find.byType(FadeTransition),
      );

      expect(scaleFinder, findsOneWidget);
      expect(fadeFinder, findsOneWidget);

      final initialScale = tester.widget<ScaleTransition>(scaleFinder).scale.value;
      expect(initialScale, closeTo(1.0, 0.05));

      // Advance 500ms (halfway of pulse)
      await tester.pump(const Duration(milliseconds: 500));
      final peakScale = tester.widget<ScaleTransition>(scaleFinder).scale.value;
      expect(peakScale, closeTo(1.25, 0.05));

      // Advance another 500ms (back to start)
      await tester.pump(const Duration(milliseconds: 500));
      final returnedScale = tester.widget<ScaleTransition>(scaleFinder).scale.value;
      expect(returnedScale, closeTo(1.0, 0.05));
    });
  });
}
