import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';

/// A tactile wooden board container rendered natively using gradients and [CustomPainter].
///
/// Features realistic vertical grain gradients, horizontal plank seams,
/// and edge vignette shading without using any bitmap images.
class WoodSurface extends StatelessWidget {
  /// The optional widget displayed inside the wooden surface.
  final Widget? child;

  /// Empty space to surround the wooden surface.
  final EdgeInsetsGeometry? margin;

  /// Empty space to inscribe inside the wooden surface.
  final EdgeInsetsGeometry? padding;

  /// The border radius for the surface corners.
  final BorderRadius? borderRadius;

  /// Whether horizontal plank seams are rendered across the surface.
  final bool showPlanks;

  /// Drop shadow elevation for card/dialog surfaces.
  final double elevation;

  /// Custom border decoration around the surface.
  final BoxBorder? border;

  const WoodSurface({
    super.key,
    this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showPlanks = true,
    this.elevation = 0.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.zero;

    Widget surface = ClipRRect(
      borderRadius: effectiveRadius,
      child: CustomPaint(
        painter: _WoodGrainPainter(showPlanks: showPlanks),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (border != null) {
      surface = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          border: border,
        ),
        child: surface,
      );
    }

    if (elevation > 0) {
      surface = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0x8C000000),
              blurRadius: elevation * 2.5,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: surface,
      );
    } else if (margin != null) {
      surface = Padding(
        padding: margin!,
        child: surface,
      );
    }

    return surface;
  }
}

class _WoodGrainPainter extends CustomPainter {
  final bool showPlanks;

  _WoodGrainPainter({required this.showPlanks});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Base vertical multi-stop wood grain gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        AppColors.woodDark,
        AppColors.woodMedium,
        AppColors.woodLight,
        AppColors.woodSurface,
        AppColors.woodMedium,
        AppColors.woodDark,
      ],
      stops: const [0.0, 0.22, 0.48, 0.65, 0.85, 1.0],
    );

    final basePaint = Paint()..shader = baseGradient.createShader(rect);
    canvas.drawRect(rect, basePaint);

    // 2. Fine horizontal plank dividers
    if (showPlanks && size.height > 80) {
      // Calculate plank height dynamically to fit nicely
      const desiredPlankHeight = 110.0;
      final plankCount = (size.height / desiredPlankHeight).round().clamp(2, 20);
      final actualPlankHeight = size.height / plankCount;

      final dividerShadowPaint = Paint()
        ..color = AppColors.woodPlankDivider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final dividerHighlightPaint = Paint()
        ..color = const Color(0x14FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int i = 1; i < plankCount; i++) {
        final y = i * actualPlankHeight;
        // Deep shadow groove
        canvas.drawLine(Offset(0, y), Offset(size.width, y), dividerShadowPaint);
        // Subtle light catch on the lower edge of the groove
        canvas.drawLine(
            Offset(0, y + 1.2), Offset(size.width, y + 1.2), dividerHighlightPaint);
      }
    }

    // 3. Subtle edge vignette shading for realistic depth
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.transparent,
          AppColors.woodVignette,
        ],
        stops: const [0.65, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _WoodGrainPainter oldDelegate) {
    return oldDelegate.showPlanks != showPlanks;
  }
}
