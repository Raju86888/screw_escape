import 'package:flutter/material.dart';
import 'package:screw_escape/src/core/theme/app_spacing.dart';

/// A layout container that ensures responsive, safe rendering across Android devices.
///
/// Automatically enforces:
/// - Screen [SafeArea] boundaries to avoid notches and system navigation bars.
/// - Maximum content width constraint to prevent awkward stretching on tablets.
/// - Defensive scrolling to prevent [RenderFlex] overflow on small or narrow screens.
class ResponsiveContainer extends StatelessWidget {
  /// The primary widget content to display inside the container.
  final Widget child;

  /// Maximum allowed content width before centering (defaults to 480dp).
  final double maxWidth;

  /// Internal padding surrounding the child.
  final EdgeInsetsGeometry padding;

  /// Whether vertical scrolling is enabled to prevent screen overflow.
  final bool scrollable;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 480.0,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double minHeight =
              constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;

          final Widget inner = Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          );

          if (!scrollable) {
            return inner;
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: inner,
            ),
          );
        },
      ),
    );
  }
}
