// lib/core/widgets/ig_icons.dart
import 'dart:ui' show Offset, Path, Radius, Rect, RRect, Size;

class IgIconData {
  const IgIconData(this.builder, {this.filled = false});
  final Path Function(Size size) builder;
  final bool filled;
}

/// Hand-drawn Instagram-style glyphs on a 24x24 grid.
class IgIcons {
  IgIcons._();

  static Path _p(Size s, List<List<double>> pts, {bool close = false}) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path p = Path();
    p.moveTo(pts.first[0] * sx, pts.first[1] * sy);
    for (int i = 1; i < pts.length; i++) {
      p.lineTo(pts[i][0] * sx, pts[i][1] * sy);
    }
    if (close) p.close();
    return p;
  }

  static Path _r(
    Size s,
    double l,
    double t,
    double w,
    double h, {
    double rr = 0,
  }) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Rect rect = Rect.fromLTWH(l * sx, t * sy, w * sx, h * sy);
    final Path path = Path();
    if (rr == 0) {
      path.addRect(rect);
    } else {
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(rr * sx)));
    }
    return path;
  }

  /// Home: rounded house outline.
  static final IgIconData home = IgIconData(
    (Size s) => _r(s, 3, 10, 18, 11, rr: 3)
      ..moveTo(3.5 * s.width / 24, 11.5 * s.height / 24)
      ..lineTo(12 * s.width / 24, 4 * s.height / 24)
      ..lineTo(20.5 * s.width / 24, 11.5 * s.height / 24),
  );

  /// Search: circle + handle.
  static final IgIconData search = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path circle = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(10.5 * sx, 10.5 * sy), radius: 6.5 * sx),
      );
    circle.moveTo(15.5 * sx, 15.5 * sy);
    circle.lineTo(20.5 * sx, 20.5 * sy);
    return circle;
  });

  /// Reels: rounded square + top line + diagonal play.
  static final IgIconData reels = IgIconData(
    (Size s) => _r(s, 3, 3, 18, 18, rr: 4)
      ..moveTo(3 * s.width / 24, 8.5 * s.height / 24)
      ..lineTo(21 * s.width / 24, 8.5 * s.height / 24)
      ..moveTo(9.5 * s.width / 24, 6 * s.height / 24)
      ..lineTo(11.5 * s.width / 24, 8.5 * s.height / 24)
      ..moveTo(14.5 * s.width / 24, 6 * s.height / 24)
      ..lineTo(16.5 * s.width / 24, 8.5 * s.height / 24)
      ..moveTo(10.5 * s.width / 24, 12 * s.height / 24)
      ..lineTo(15 * s.width / 24, 14.5 * s.height / 24)
      ..lineTo(10.5 * s.width / 24, 17 * s.height / 24)
      ..close(),
  );

  /// Heart outline.
  static final IgIconData heart = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    return Path()
      ..moveTo(12 * sx, 20.5 * sy)
      ..cubicTo(4 * sx, 15 * sy, 2.5 * sx, 8.5 * sy, 6.5 * sx, 5.5 * sy)
      ..cubicTo(9 * sx, 3.5 * sy, 11.3 * sx, 5 * sy, 12 * sx, 7 * sy)
      ..cubicTo(12.7 * sx, 5 * sy, 15 * sx, 3.5 * sy, 17.5 * sx, 5.5 * sy)
      ..cubicTo(21.5 * sx, 8.5 * sy, 20 * sx, 15 * sy, 12 * sx, 20.5 * sy);
  });

  static final IgIconData heartFilled = IgIconData(heart.builder, filled: true);

  /// Comment bubble.
  static final IgIconData comment = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    return Path()
      ..moveTo(12 * sx, 3.5 * sy)
      ..cubicTo(18 * sx, 3.5 * sy, 21 * sx, 7 * sy, 21 * sx, 11 * sy)
      ..cubicTo(21 * sx, 15 * sy, 18 * sx, 18 * sy, 12 * sx, 18 * sy)
      ..lineTo(8 * sx, 20.5 * sy)
      ..lineTo(8.8 * sx, 17 * sy)
      ..cubicTo(5 * sx, 15.8 * sy, 3 * sx, 14 * sy, 3 * sx, 11 * sy)
      ..cubicTo(3 * sx, 7 * sy, 6 * sx, 3.5 * sy, 12 * sx, 3.5 * sy)
      ..close();
  });

  /// Paper plane.
  static final IgIconData share = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    return Path()
      ..moveTo(21.5 * sx, 3 * sy)
      ..lineTo(2.5 * sx, 10.5 * sy)
      ..lineTo(10 * sx, 13.5 * sy)
      ..lineTo(21.5 * sx, 3 * sy)
      ..close()
      ..moveTo(21.5 * sx, 3 * sy)
      ..lineTo(10 * sx, 13.5 * sy)
      ..lineTo(13.5 * sx, 21 * sy)
      ..close();
  });

  /// Bookmark.
  static final IgIconData bookmark = IgIconData(
    (Size s) => _p(s, <List<double>>[
      <double>[6, 3.5],
      <double>[18, 3.5],
      <double>[18, 20.5],
      <double>[12, 15],
      <double>[6, 20.5],
    ], close: true),
  );

  static final IgIconData bookmarkFilled = IgIconData(
    bookmark.builder,
    filled: true,
  );

  /// Plus in square (create).
  static final IgIconData plusSquare = IgIconData(
    (Size s) => _r(s, 3, 3, 18, 18, rr: 5)
      ..moveTo(12 * s.width / 24, 7.5 * s.height / 24)
      ..lineTo(12 * s.width / 24, 16.5 * s.height / 24)
      ..moveTo(7.5 * s.width / 24, 12 * s.height / 24)
      ..lineTo(16.5 * s.width / 24, 12 * s.height / 24),
  );

  /// More dots (horizontal).
  static final IgIconData moreDots = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path p = Path();
    for (final double x in <double>[5, 12, 19]) {
      p.addOval(
        Rect.fromCircle(center: Offset(x * sx, 12 * sy), radius: 1.9 * sx),
      );
    }
    return p;
  });

  /// Camera.
  static final IgIconData camera = IgIconData(
    (Size s) => _r(s, 2.5, 6.5, 19, 13.5, rr: 3)
      ..moveTo(8 * s.width / 24, 6.5 * s.height / 24)
      ..lineTo(9.5 * s.width / 24, 4 * s.height / 24)
      ..lineTo(14.5 * s.width / 24, 4 * s.height / 24)
      ..lineTo(16 * s.width / 24, 6.5 * s.height / 24)
      ..addOval(
        Rect.fromCircle(
          center: Offset(12 * s.width / 24, 13 * s.height / 24),
          radius: 3.8 * s.width / 24,
        ),
      ),
  );

  /// Chevron right.
  static final IgIconData chevron = IgIconData(
    (Size s) => _p(s, <List<double>>[
      <double>[9.5, 5],
      <double>[16, 12],
      <double>[9.5, 19],
    ]),
  );

  /// Grid (profile posts).
  static final IgIconData grid = IgIconData(
    (Size s) => Path()
      ..addPath(_r(s, 3, 3, 18, 18, rr: 2), Offset.zero)
      ..moveTo(3 * s.width / 24, 12 * s.height / 24)
      ..lineTo(21 * s.width / 24, 12 * s.height / 24)
      ..moveTo(12 * s.width / 24, 3 * s.height / 24)
      ..lineTo(12 * s.width / 24, 21 * s.height / 24),
  );

  /// Tagged (person in box).
  static final IgIconData tagged = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path p = _r(s, 3, 3, 18, 18, rr: 2);
    p.addOval(
      Rect.fromCircle(center: Offset(12 * sx, 10 * sy), radius: 2.6 * sx),
    );
    p.moveTo(7 * sx, 17.5 * sy);
    p.cubicTo(8 * sx, 14.2 * sy, 16 * sx, 14.2 * sy, 17 * sx, 17.5 * sy);
    return p;
  });

  /// Send arrow (chat input).
  static final IgIconData micOrSend = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    return Path()
      ..moveTo(4 * sx, 12 * sy)
      ..lineTo(20 * sx, 4.5 * sy)
      ..lineTo(14.5 * sx, 20 * sy)
      ..lineTo(11.8 * sx, 13.8 * sy)
      ..close();
  }, filled: true);
}
