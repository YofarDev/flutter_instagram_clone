// lib/core/widgets/ig_icon.dart
import 'package:flutter/material.dart';

import 'ig_icons.dart';

/// Paints an [IgIconData] glyph. Stroke glyphs use IG's ~1.8 weight,
/// scaled with size; `filled` glyphs paint solid.
class IgIcon extends StatelessWidget {
  const IgIcon(
    this.data, {
    super.key,
    this.size = 24,
    this.color,
    this.active = false,
  });

  final IgIconData data;
  final double size;
  final Color? color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color resolved =
        color ??
        (active
            ? IgIconTheme.of(context).active
            : IgIconTheme.of(context).inactive);
    return CustomPaint(
      size: Size.square(size),
      painter: _IgIconPainter(data, resolved),
    );
  }
}

class _IgIconPainter extends CustomPainter {
  const _IgIconPainter(this.data, this.color);

  final IgIconData data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = data.builder(size);
    final Paint paint = Paint()
      ..color = color
      ..style = data.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8 * (size.width / 24)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IgIconPainter old) =>
      old.data != data || old.color != color;
}

/// Resolves active/inactive icon colors from the theme (P2+ screens use this).
class IgIconTheme extends InheritedWidget {
  const IgIconTheme({
    required this.active,
    required this.inactive,
    required super.child,
    super.key,
  });

  final Color active;
  final Color inactive;

  static IgIconTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IgIconTheme>()!;

  @override
  bool updateShouldNotify(IgIconTheme old) =>
      old.active != active || old.inactive != inactive;
}
