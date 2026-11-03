import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_colors.dart';

/// Style of the screw drive head.
enum ScrewType {
  /// Cross-head drive (+).
  phillips,

  /// Single straight slot drive (-).
  slotted,
}

/// Metallic finish of the screw accent.
enum ScrewMaterial {
  /// Brushed silver finish.
  silver,

  /// Polished brass gold finish.
  gold,
}

/// A decorative metallic screw head widget rendered strictly using [CustomPainter].
///
/// Features realistic specular highlights, outer drop shadow, beveled rim,
/// and recessed drive groove without any external image files.
class ScrewAccent extends StatelessWidget {
  /// Diameter of the screw head in logical pixels.
  final double size;

  /// The drive groove type (Phillips or slotted).
  final ScrewType type;

  /// The metallic material finish.
  final ScrewMaterial material;

  /// Optional rotation angle in radians for natural variation.
  final double angle;

  const ScrewAccent({
    super.key,
    this.size = 24.0,
    this.type = ScrewType.phillips,
    this.material = ScrewMaterial.silver,
    this.angle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ScrewPainter(
          type: type,
          material: material,
          angle: angle,
        ),
      ),
    );
  }
}

class _ScrewPainter extends CustomPainter {
  final ScrewType type;
  final ScrewMaterial material;
  final double angle;

  _ScrewPainter({
    required this.type,
    required this.material,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Outer drop shadow giving depth off the wooden board
    final shadowPaint = Paint()
      ..color = const Color(0x73000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(center + const Offset(1.0, 1.5), radius * 0.95, shadowPaint);

    // 2. Base metallic rim bevel
    final isGold = material == ScrewMaterial.gold;
    final rimGradient = SweepGradient(
      center: Alignment.center,
      colors: isGold
          ? const [
              AppColors.metalGoldLight,
              AppColors.metalGoldDark,
              AppColors.metalGold,
              AppColors.metalGoldLight,
            ]
          : const [
              AppColors.metalSilverLight,
              AppColors.metalSilverDark,
              AppColors.metalSilver,
              AppColors.metalSilverLight,
            ],
    );

    final rimPaint = Paint()
      ..shader = rimGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    // 3. Inner recessed screw head surface
    final innerRadius = radius * 0.82;
    final headGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: isGold
          ? const [
              AppColors.metalGoldLight,
              AppColors.metalGold,
              AppColors.metalGoldDark,
            ]
          : const [
              AppColors.metalSilverLight,
              AppColors.metalSilver,
              AppColors.metalSilverDark,
            ],
      stops: const [0.0, 0.6, 1.0],
    );

    final headPaint = Paint()
      ..shader = headGradient.createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, headPaint);

    // 4. Subtle specular highlight arc on the top-left rim
    final highlightPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, radius * 0.08);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      highlightPaint,
    );

    // 5. Draw recessed drive groove (Phillips or slotted)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final grooveWidth = innerRadius * 1.25;
    final grooveThickness = math.max(1.8, innerRadius * 0.28);

    final groovePaint = Paint()
      ..color = AppColors.gunmetal
      ..style = PaintingStyle.fill;

    final grooveShadowPaint = Paint()
      ..color = const Color(0x99000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw primary horizontal slot
    final slotRect = Rect.fromCenter(
      center: Offset.zero,
      width: grooveWidth,
      height: grooveThickness,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slotRect, Radius.circular(grooveThickness / 2)),
      groovePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slotRect, Radius.circular(grooveThickness / 2)),
      grooveShadowPaint,
    );

    // If Phillips, draw vertical slot
    if (type == ScrewType.phillips) {
      final crossRect = Rect.fromCenter(
        center: Offset.zero,
        width: grooveThickness,
        height: grooveWidth,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(crossRect, Radius.circular(grooveThickness / 2)),
        groovePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(crossRect, Radius.circular(grooveThickness / 2)),
        grooveShadowPaint,
      );
    }

    // Groove bottom-right engraved highlight line
    final grooveHighlightPaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(-grooveWidth / 2, grooveThickness / 2),
      Offset(grooveWidth / 2, grooveThickness / 2),
      grooveHighlightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScrewPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.material != material ||
        oldDelegate.angle != angle;
  }
}
