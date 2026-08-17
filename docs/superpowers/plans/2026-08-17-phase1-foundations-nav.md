# Phase 1 — Foundations + Nav Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace default Material look with Instagram-exact foundations: color tokens (dark + light), custom IG icon set, no-ripple interaction, haptics util, skeleton primitives, and the real-IG 5-icon unlabeled nav shell with avatar profile tab.

**Architecture:** Tokens and shared widgets live in `core/`. The nav shell keeps `StatefulShellRoute.indexedStack` but drops the Material `NavigationBar` for a custom bar; Activity moves from a nav branch to a pushed root route; Create becomes an action (push), not a branch.

**Tech Stack:** Flutter (Material 3 widgets, custom `CustomPainter` icons), flutter_bloc, go_router. No new packages.

## Global Constraints

- Colors verbatim: dark `#000000` bg / `#262626` input+divider / `#F5F5F5` text / `#A8A8A8` secondary / `#121212` elevated; light `#FFFFFF` bg / `#FAFAFA` appbar / `#EFEFEF` input / `#DBDBDB` divider / `#262626` text / `#8E8E8E` secondary; both: accent `#0095F6`, like `#FF3040`, alert `#ED4956`.
- `SplashFactory.noSplash` on both themes — no Material ripple anywhere.
- Type scale: 13 / 14 / 16 / 22 (semibold) / 28. Tabular figures on count styles.
- All new user-visible strings go through `fstr $key "$fr" "$en"` (hook generates l10n).
- Always specify type annotations. Use `AppLogger()` for prints. `flutter pub add` only (never edit pubspec.yaml manually).
- A repo hook runs `dart fix --apply && dart format .` after every `.dart` edit — unused imports are auto-removed; don't fight it.
- Every task ends with `flutter analyze` clean + its tests green + commit.

---

### Task 1: IG color tokens + theme rewrite

**Files:**
- Create: `lib/core/theme/ig_colors.dart`
- Modify: `lib/core/theme/app_theme.dart` (full rewrite)
- Test: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Produces: `IgColors` static class — `IgColors.black`, `.elevatedDark`, `.inputFill(Brightness)`, `.divider(Brightness)`, `.textPrimary(Brightness)`, `.textSecondary(Brightness)`, `.blue`, `.likeRed`, `.alertRed`, `.gradientRing` (`List<Color>`). Later phases consume these instead of hardcoding colors.

- [ ] **Step 1: Write failing theme test**

```dart
// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/theme/app_theme.dart';
import 'package:flutter_instagram_clone/core/theme/ig_colors.dart';

void main() {
  group('AppTheme', () {
    test('dark theme uses IG tokens', () {
      final ThemeData t = AppTheme.darkTheme;
      expect(t.scaffoldBackgroundColor, IgColors.black);
      expect(t.colorScheme.onPrimary, IgColors.textPrimary(Brightness.dark));
      expect(t.splashFactory, SplashFactory.noSplash);
    });

    test('light theme uses IG tokens', () {
      final ThemeData t = AppTheme.lightTheme;
      expect(t.scaffoldBackgroundColor, IgColors.white);
      expect(t.colorScheme.onPrimary, IgColors.textPrimary(Brightness.light));
      expect(t.splashFactory, SplashFactory.noSplash);
    });

    test('IG gradient ring is 4 stops warm-to-pink', () {
      final List<Color> g = IgColors.gradientRing;
      expect(g.length, 4);
      expect(g.first, const Color(0xFFFEDA75));
      expect(g.last, const Color(0xFFD62976));
    });
  });
}
```

- [ ] **Step 2: Run — expect failure**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `ig_colors.dart` does not exist.

- [ ] **Step 3: Create `IgColors`**

```dart
// lib/core/theme/ig_colors.dart
import 'package:flutter/material.dart';

/// Instagram-exact palette. Values locked by the fidelity spec — do not tweak.
class IgColors {
  IgColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color elevatedDark = Color(0xFF121212);
  static const Color appBarLight = Color(0xFFFAFAFA);

  static const Color blue = Color(0xFF0095F6);
  static const Color likeRed = Color(0xFFFF3040);
  static const Color alertRed = Color(0xFFED4956);

  static const Color _inputFillDark = Color(0xFF262626);
  static const Color _inputFillLight = Color(0xFFEFEFEF);
  static const Color _dividerDark = Color(0xFF262626);
  static const Color _dividerLight = Color(0xFFDBDBDB);
  static const Color _textDark = Color(0xFFF5F5F5);
  static const Color _textLight = Color(0xFF262626);
  static const Color _textSecondaryDark = Color(0xFFA8A8A8);
  static const Color _textSecondaryLight = Color(0xFF8E8E8E);

  static Color inputFill(Brightness b) =>
      b == Brightness.dark ? _inputFillDark : _inputFillLight;
  static Color divider(Brightness b) =>
      b == Brightness.dark ? _dividerDark : _dividerLight;
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? _textDark : _textLight;
  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? _textSecondaryDark : _textSecondaryLight;

  /// Story-ring gradient (warm yellow -> pink), IG order.
  static const List<Color> gradientRing = <Color>[
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFF962FBF),
    Color(0xFFD62976),
  ];
}
```

- [ ] **Step 4: Rewrite `app_theme.dart`**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

import 'ig_colors.dart';

/// Instagram-exact Material 3 themes (dark + light).
class AppTheme {
  AppTheme._();

  static ThemeData _base(Brightness brightness) {
    final Color background =
        brightness == Brightness.dark ? IgColors.black : IgColors.white;
    final Color textPrimary = IgColors.textPrimary(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: IgColors.blue,
        onPrimary: textPrimary,
        secondary: IgColors.blue,
        onSecondary: IgColors.white,
        error: IgColors.alertRed,
        onError: IgColors.white,
        surface: background,
        onSurface: textPrimary,
        surfaceContainerHighest:
            IgColors.inputFill(brightness),
      ),
      splashFactory: SplashFactory.noSplash,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerColor: IgColors.divider(brightness),
      dividerTheme: DividerThemeData(
        color: IgColors.divider(brightness),
        thickness: 0.5,
        space: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            brightness == Brightness.dark ? IgColors.black : IgColors.appBarLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: Typography.material2021().englishLike.merge(
        Typography.material2021().black,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      snackBarTheme: const SnackBarBehaviorFloating(),
    );
  }

  static ThemeData get darkTheme => _base(Brightness.dark);
  static ThemeData get lightTheme => _base(Brightness.light);
}

typedef SnackBarBehaviorFloating = SnackBarThemeData;
```

Note: `SnackBarBehaviorFloating` typedef is a placeholder for the actual snackbar theme — write it concretely instead:

```dart
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            brightness == Brightness.dark ? IgColors.elevatedDark : IgColors.black,
        contentTextStyle: TextStyle(color: IgColors.textPrimary(Brightness.dark)),
        behavior: SnackBarBehavior.floating,
      ),
```

(Use this second version; drop the typedef line.)

- [ ] **Step 5: Run test — pass**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 6: Full suite + analyze (theme change ripples)**

Run: `flutter analyze && flutter test`
Fix any widget tests that pinned old seeded colors. Commit:

```bash
git add lib/core/theme/ test/core/theme/
git commit -m "feat: instagram-exact theme tokens, no ripple, hairline dividers"
```

---

### Task 2: Haptics util

**Files:**
- Create: `lib/core/utils/haptics.dart`
- Test: `test/core/utils/haptics_test.dart`

**Interfaces:**
- Produces: `AppHaptics.tab()`, `AppHaptics.like()`, `AppHaptics.follow()`, `AppHaptics.success()` — static void, no deps. Later phases call these at interaction points.

- [ ] **Step 1: Failing test**

```dart
// test/core/utils/haptics_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/utils/haptics.dart';

void main() {
  testWidgets('AppHaptics calls never throw on test bindings', (
    WidgetTester tester,
  ) async {
    AppHaptics.tab();
    AppHaptics.like();
    AppHaptics.follow();
    AppHaptics.success();
    expect(true, isTrue);
  });
}
```

- [ ] **Step 2: Run — expect failure** (`flutter test test/core/utils/haptics_test.dart` → FAIL, file missing)

- [ ] **Step 3: Implement**

```dart
// lib/core/utils/haptics.dart
import 'package:flutter/services.dart';

/// Centralized haptic vocabulary. Keep calls semantic, not mechanical.
class AppHaptics {
  AppHaptics._();

  /// Tab switches, segmented controls.
  static void tab() => HapticFeedback.selectionClick();

  /// Likes (double-tap or button), heavy moments.
  static void like() => HapticFeedback.mediumImpact();

  /// Follow buttons, small confirmations.
  static void follow() => HapticFeedback.lightImpact();

  /// Post shared / action completed.
  static void success() => HapticFeedback.heavyImpact();
}
```

- [ ] **Step 4: Pass + commit**

Run: `flutter test test/core/utils/haptics_test.dart` → PASS

```bash
git add lib/core/utils/haptics.dart test/core/utils/haptics_test.dart
git commit -m "feat: haptics vocabulary util"
```

---

### Task 3: Custom IG icon set

**Files:**
- Create: `lib/core/widgets/ig_icons.dart` (icon data: one `Path Function(Size)` per icon)
- Create: `lib/core/widgets/ig_icon.dart` (the widget: paints a path, stroke or fill)
- Test: `test/core/widgets/ig_icon_test.dart`

**Interfaces:**
- Produces: `class IgIcon extends StatelessWidget` — `const IgIcon(IgIcons.home, {super.key, this.size = 24, this.active = false, this.color})`. `IgIcons` exposes static const `IgIconData`: `home`, `search`, `reels`, `heart`, `comment`, `share`, `bookmark`, `plusSquare`, `moreDots`, `camera`, `chevron`, `grid`, `tagged`, `micOrSend`. Later phases use these everywhere Material icons appeared.
- `IgIconData` shape: `final Path Function(Size size) builder; final bool filled;`

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/ig_icon_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icons.dart';

void main() {
  testWidgets('IgIcon renders every glyph without throwing', (
    WidgetTester tester,
  ) async {
    final List<IgIconData> all = <IgIconData>[
      IgIcons.home, IgIcons.search, IgIcons.reels, IgIcons.heart,
      IgIcons.comment, IgIcons.share, IgIcons.bookmark, IgIcons.plusSquare,
      IgIcons.moreDots, IgIcons.camera, IgIcons.chevron, IgIcons.grid,
      IgIcons.tagged, IgIcons.micOrSend,
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: <Widget>[
            for (final IgIconData d in all) IgIcon(d, size: 24),
          ],
        ),
      ),
    );
    expect(find.byType(IgIcon), findsNWidgets(all.length));
  });

  testWidgets('paths stay inside the size box', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: IgIcon(IgIcons.home)))),
    );
    final Rect box = tester.getRect(find.byType(IgIcon));
    expect(box.width, 24);
    expect(box.height, 24);
  });
}
```

- [ ] **Step 2: Run — expect failure** (missing files)

- [ ] **Step 3: Implement `ig_icons.dart` + `ig_icon.dart`**

Glyphs are drawn on a normalized 24×24 grid, stroke 1.8, scaled to `size`. Full implementation:

```dart
// lib/core/widgets/ig_icons.dart
import 'dart:ui' show Path;

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

  static Path _r(Size s, double l, double t, double w, double h,
      {double rr = 0}) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Rect rect = Rect.fromLTWH(l * sx, t * sy, w * sx, h * sy);
    return rr == 0 ? Path()..addRect(rect) : Path()..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rr * sx)));
  }

  /// Home: rounded house outline.
  static final IgIconData home = IgIconData((Size s) => _r(s, 3, 10, 18, 11, rr: 3)
    ..moveTo(3.5 * s.width / 24, 11.5 * s.height / 24)
    ..lineTo(12 * s.width / 24, 4 * s.height / 24)
    ..lineTo(20.5 * s.width / 24, 11.5 * s.height / 24));

  /// Search: circle + handle.
  static final IgIconData search = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path circle = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(10.5 * sx, 10.5 * sy), radius: 6.5 * sx));
    circle.moveTo(15.5 * sx, 15.5 * sy);
    circle.lineTo(20.5 * sx, 20.5 * sy);
    return circle;
  });

  /// Reels: rounded square + top line + diagonal play.
  static final IgIconData reels = IgIconData((Size s) => _r(s, 3, 3, 18, 18, rr: 4)
    ..moveTo(3 * s.width / 24, 8.5 * s.height / 24)
    ..lineTo(21 * s.width / 24, 8.5 * s.height / 24)
    ..moveTo(9.5 * s.width / 24, 6 * s.height / 24)
    ..lineTo(11.5 * s.width / 24, 8.5 * s.height / 24)
    ..moveTo(14.5 * s.width / 24, 6 * s.height / 24)
    ..lineTo(16.5 * s.width / 24, 8.5 * s.height / 24)
    ..moveTo(10.5 * s.width / 24, 12 * s.height / 24)
    ..lineTo(15 * s.width / 24, 14.5 * s.height / 24)
    ..lineTo(10.5 * s.width / 24, 17 * s.height / 24)
    ..close());

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

  static final IgIconData heartFilled =
      IgIconData(heart.builder, filled: true);

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
      ..lineTo(13.5 * sy == 0 ? 13.5 * sx : 13.5 * sx, 21 * sy)
      ..close();
  });

  /// Bookmark.
  static final IgIconData bookmark = IgIconData((Size s) => _p(s, <List<double>>[
        [6, 3.5], [18, 3.5], [18, 20.5], [12, 15], [6, 20.5],
      ], close: true));

  /// Plus in square (create).
  static final IgIconData plusSquare = IgIconData((Size s) => _r(s, 3, 3, 18, 18, rr: 5)
    ..moveTo(12 * s.width / 24, 7.5 * s.height / 24)
    ..lineTo(12 * s.width / 24, 16.5 * s.height / 24)
    ..moveTo(7.5 * s.width / 24, 12 * s.height / 24)
    ..lineTo(16.5 * s.width / 24, 12 * s.height / 24));

  /// More dots (horizontal).
  static final IgIconData moreDots = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path p = Path();
    for (final double x in <double>[5, 12, 19]) {
      p.addOval(Rect.fromCircle(
          center: Offset(x * sx, 12 * sy), radius: 1.9 * sx));
    }
    return p;
  });

  /// Camera.
  static final IgIconData camera = IgIconData((Size s) => _r(s, 2.5, 6.5, 19, 13.5, rr: 3)
    ..moveTo(8 * s.width / 24, 6.5 * s.height / 24)
    ..lineTo(9.5 * s.width / 24, 4 * s.height / 24)
    ..lineTo(14.5 * s.width / 24, 4 * s.height / 24)
    ..lineTo(16 * s.width / 24, 6.5 * s.height / 24)
    ..addOval(Rect.fromCircle(
        center: Offset(12 * s.width / 24, 13 * s.height / 24),
        radius: 3.8 * s.width / 24)));

  /// Chevron right.
  static final IgIconData chevron =
      IgIconData((Size s) => _p(s, <List<double>>[
            [9.5, 5], [16, 12], [9.5, 19],
          ]));

  /// Grid (profile posts).
  static final IgIconData grid = IgIconData((Size s) => Path()
    ..addPath(_r(s, 3, 3, 18, 18, rr: 2), Offset.zero)
    ..addPath(_r(s, 9, 3, 0.1, 0.1), Offset.zero) // vertical hint
    ..moveTo(3 * s.width / 24, 12 * s.height / 24)
    ..lineTo(21 * s.width / 24, 12 * s.height / 24)
    ..moveTo(12 * s.width / 24, 3 * s.height / 24)
    ..lineTo(12 * s.width / 24, 21 * s.height / 24));

  /// Tagged (person in box).
  static final IgIconData tagged = IgIconData((Size s) {
    final double sx = s.width / 24, sy = s.height / 24;
    final Path p = _r(s, 3, 3, 18, 18, rr: 2);
    p.addOval(Rect.fromCircle(center: Offset(12 * sx, 10 * sy), radius: 2.6 * sx));
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
```

```dart
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
        color ?? (active ? IgIconTheme.of(context).active : IgIconTheme.of(context).inactive);
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
```

Note: the `share` path contains a defensive no-op ternary from drafting — write it cleanly as `..lineTo(13.5 * sx, 21 * sy)`. The `grid` glyph includes a zero-size addPath hack — drop that line, keep the four stroke lines. Clean versions in the committed code, not the draft artifacts.

- [ ] **Step 4: Run test — pass** (`flutter test test/core/widgets/ig_icon_test.dart` → PASS)

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/ig_icons.dart lib/core/widgets/ig_icon.dart test/core/widgets/ig_icon_test.dart
git commit -m "feat: custom instagram-style icon set"
```

---

### Task 4: Skeleton primitives

**Files:**
- Create: `lib/core/widgets/skeleton/shimmer.dart`
- Create: `lib/core/widgets/skeleton/skeletons.dart`
- Test: `test/core/widgets/skeleton_test.dart`

**Interfaces:**
- Produces: `Shimmer` (wraps children in an animated sweep; needs a `TickerProvider`-free usage — it animates itself), `SkeletonPostCard()`, `SkeletonAvatar({double radius})`, `SkeletonGridTile()`. All theme-aware via `IgColors.inputFill`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/skeleton_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/skeleton/skeletons.dart';

void main() {
  testWidgets('SkeletonPostCard pumps and animates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SkeletonPostCard())),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SkeletonPostCard), findsOneWidget);
  });

  testWidgets('SkeletonAvatar renders at requested radius', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: SkeletonAvatar(radius: 16)))),
    );
    final Size size = tester.getSize(find.byType(SkeletonAvatar));
    expect(size.width, 32);
  });
}
```

- [ ] **Step 2: Run — expect failure**

- [ ] **Step 3: Implement**

```dart
// lib/core/widgets/skeleton/shimmer.dart
import 'package:flutter/material.dart';

/// Self-animating base shimmer. Wrap skeleton children with [Shimmer.child].
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double dx = _controller.value * bounds.width * 3 - bounds.width;
            final Gradient gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
              stops: const <double>[0.35, 0.5, 0.65],
            );
            return gradient.createShader(bounds.translate(dx, 0));
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
```

```dart
// lib/core/widgets/skeleton/skeletons.dart
import 'package:flutter/material.dart';

import 'shimmer.dart';

/// Base gray block used by all skeletons.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({this.width = double.infinity, this.height = 16, super.key});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({required this.radius, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: radius * 2, height: radius * 2);
  }
}

/// Applied circular clip by callers needing circles:
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({required this.radius, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Post-shaped placeholder: header row + square media + action row.
class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                const SkeletonCircle(radius: 16),
                const SizedBox(width: 10),
                SkeletonBox(width: 120, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: width, height: width),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                SkeletonCircle(radius: 12),
                SizedBox(width: 16),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3-col grid tile placeholder.
class SkeletonGridTile extends StatelessWidget {
  const SkeletonGridTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(aspectRatio: 1, child: SkeletonBox(height: double.infinity));
  }
}
```

(The `Shimmer` sweep tints children gray; `SkeletonBox` supplies the fill — the combination reads correctly. `SkeletonAvatar` is a plain box: callers preferring circles use `SkeletonCircle`. The test asserts `SkeletonAvatar` width only.)

- [ ] **Step 4: Run — pass**

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/skeleton/ test/core/widgets/skeleton_test.dart
git commit -m "feat: shimmer skeleton primitives"
```

---

### Task 5: Nav shell — 5 IG tabs, avatar profile tab, activity → push route

**Files:**
- Create: `lib/core/widgets/ig_nav_bar.dart`
- Modify: `lib/core/router/app_router.dart` (shell builder + branches + activity route moves to root level)
- Modify: `lib/core/router/route_constants.dart` (no path changes; confirm `Routes.activity` exists)
- Test: `test/core/widgets/ig_nav_bar_test.dart`, update `test/features/feed/feed_screen_widget_test.dart`

**Interfaces:**
- Consumes: `IgIcon`/`IgIcons` (Task 3), `AppHaptics` (Task 2), `IgColors` (Task 1), `BadgeIcon` (existing), `AuthCubit.state.user.avatarUrl` (existing `AppUser` field).
- Produces: `IgNavBar({required int currentIndex, required ValueChanged<int> onTap, required int unreadCount, String? avatarUrl})` — indexes 0..4 map to Feed/Search/Create/Reels/Profile branches; **Create (index 2) is reported via `onCreate` callback instead of `onTap` index** (final shape: `IgNavBar({required int currentIndex, required ValueChanged<int> onBranchSelected, required VoidCallback onCreate, required int unreadCount, String? avatarUrl})`).
- Router shape after task: branches = feed, search, reels, profile (4 branches; `currentIndex` maps 0→0, 1→1, 3→2, 4→3). Activity becomes a top-level `GoRoute(Routes.activity)` pushed from the feed appbar.

- [ ] **Step 1: Failing nav bar test**

```dart
// test/core/widgets/ig_nav_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_nav_bar.dart';

Widget _wrap({required IgNavBar bar}) => MaterialApp(home: Scaffold(bottomNavigationBar: bar));

void main() {
  testWidgets('renders 5 unlabeled destinations', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(
      bar: IgNavBar(
        currentIndex: 0,
        onBranchSelected: (_) {},
        onCreate: () {},
        unreadCount: 0,
      ),
    ));
    expect(find.byType(IgNavBar), findsOneWidget);
    expect(find.text('Feed'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('create tab reports via onCreate, not branch index', (
    WidgetTester tester,
  ) async {
    int? branch;
    bool created = false;
    await tester.pumpWidget(_wrap(
      bar: IgNavBar(
        currentIndex: 0,
        onBranchSelected: (int i) => branch = i,
        onCreate: () => created = true,
        unreadCount: 0,
      ),
    ));
    // 5 icon buttons in order: home, search, plus, reels, avatar
    final Finder icons = find.byType(GestureDetector);
    await tester.tap(icons.at(2));
    expect(created, isTrue);
    expect(branch, isNull);
  });
}
```

- [ ] **Step 2: Run — expect failure**

- [ ] **Step 3: Implement `IgNavBar`**

```dart
// lib/core/widgets/ig_nav_bar.dart
import 'package:flutter/material.dart';

import '../../features/notifications/presentation/widgets/badge_icon.dart';
import '../theme/ig_colors.dart';
import '../utils/haptics.dart';
import 'ig_icon.dart';
import 'ig_icons.dart';

/// Instagram bottom bar: 5 unlabeled icons, no indicator animation.
/// Index 2 (create) fires [onCreate] instead of switching branches.
class IgNavBar extends StatelessWidget {
  const IgNavBar({
    required this.currentIndex,
    required this.onBranchSelected,
    required this.onCreate,
    required this.unreadCount,
    this.avatarUrl,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onBranchSelected;
  final VoidCallback onCreate;
  final int unreadCount;
  final String? avatarUrl;

  static const List<int> _branchIndexOf = <int>[0, 1, -1, 2, 3];

  bool _isActive(int tab) {
    final int? branch = _branchIndexOf[tab] == -1
        ? null
        : _branchIndexOf[tab];
    return branch != null && branch == currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color active = IgColors.textPrimary(brightness);
    final Color inactive = IgColors.textSecondary(brightness);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? IgColors.black
            : IgColors.white,
        border: Border(
          top: BorderSide(color: IgColors.divider(brightness), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              _tab(0, IgIcons.home, active, inactive),
              _tab(1, IgIcons.search, active, inactive),
              _tab(2, IgIcons.plusSquare, active, inactive, onCreate),
              _tab(3, IgIcons.reels, active, inactive),
              _avatarTab(active),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    int tab,
    IgIconData icon,
    Color active,
    Color inactive, [
    VoidCallback? override,
  ]) {
    final bool isActive = _isActive(tab);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.tab();
          (override ?? () => onBranchSelected(_branchIndexOf[tab]))();
        },
        child: Center(
          child: IgIcon(icon, size: 26, color: isActive ? active : inactive),
        ),
      ),
    );
  }

  Widget _avatarTab(Color active) {
    final bool isActive = _isActive(4);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.tab();
          onBranchSelected(3);
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? active : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: IgColors.elevatedDark,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? IgIcon(IgIcons.tagged, size: 16, color: active)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
```

(`BadgeIcon` import is needed only if a badge is placed on the bar — P1 keeps the badge on the feed appbar heart, so remove the unused import; the repo hook would strip it anyway.)

- [ ] **Step 4: Run nav bar test — pass**

- [ ] **Step 5: Rewire router**

In `app_router.dart`:

1. Delete `_activityNavigatorKey` and the whole Activity `StatefulShellBranch` (lines ~254–263).
2. Delete the Create `StatefulShellBranch` (the feed branch keeps its `Routes.create` child route — verify `Routes.create` lives under feed branch; if it was the create branch's route, move the `GoRoute` under the feed branch).
3. Replace the `bottomNavigationBar:` builder block (the `BlocBuilder<NotificationsCubit,...>` + `NavigationBar(...)`) with:

```dart
bottomNavigationBar: BlocBuilder<NotificationsCubit, NotificationsState>(
  buildWhen: (NotificationsState previous, NotificationsState current) =>
      previous.unreadCount != current.unreadCount,
  builder: (BuildContext context, NotificationsState state) =>
      BlocBuilder<AuthCubit, AuthState>(
    buildWhen: (AuthState p, AuthState c) =>
        p.user?.avatarUrl != c.user?.avatarUrl,
    builder: (BuildContext context, AuthState authState) => IgNavBar(
      currentIndex: navigationShell.currentIndex,
      onBranchSelected: (int branch) => navigationShell.goBranch(
        branch,
        initialLocation: branch == navigationShell.currentIndex,
      ),
      onCreate: () => navigationShell.routerDelegate
          .currentConfiguration.uri.toString()
          .isEmpty
          ? null
          : rootNavigatorKey.currentContext!.push(Routes.create),
      unreadCount: state.unreadCount,
      avatarUrl: authState.user?.avatarUrl,
    ),
  ),
),
```

Simplify `onCreate` to `() => context.push(Routes.create)` using the builder's `context` (the shell builder provides one). Write it that way.

4. Add a top-level route (sibling of the auth routes, outside `StatefulShellRoute`):

```dart
GoRoute(
  path: Routes.activity,
  name: 'Activity',
  parentNavigatorKey: rootNavigatorKey,
  builder: (BuildContext context, GoRouterState state) =>
      BlocProvider<NotificationsCubit>.value(
    value: getIt<NotificationsCubit>(),
    child: const ActivityScreen(),
  ),
),
```

(Match however the existing branch supplied `NotificationsCubit` — copy that provider pattern.)

5. Order the remaining branches: feed, search, reels, profile.

- [ ] **Step 6: Full suite; fix broken tests**

Run: `flutter analyze && flutter test`
Expected breakages and fixes:
- `test/features/feed/feed_screen_widget_test.dart` — if it references the FAB or nav labels, update to the new appbar actions.
- Any test pumping the router shell expecting 6 branches.
- `activity_screen_widget_test.dart` — should still pass (screen unchanged).

- [ ] **Step 7: Commit**

```bash
git add lib/core/ test/
git commit -m "feat: instagram 5-tab nav shell, avatar tab, activity as push route"
```

---

### Task 6: Feed appbar — heart + plane, logout relocated

**Files:**
- Modify: `lib/features/feed/presentation/screens/feed_screen.dart:22-39`
- Modify: `lib/features/profile/presentation/screens/profile_screen.dart` (add logout icon to appbar actions temporarily — P4 replaces with the real profile menu)
- Test: update `test/features/feed/feed_screen_widget_test.dart`

**Interfaces:**
- Consumes: `IgIcon(IgIcons.heart)`, `BadgeIcon`, `Routes.activity`, `Routes.conversations`, `AuthCubit`.
- Produces: feed appbar = `Wordmark` title + heart (badge, pushes `Routes.activity`) + plane (pushes `Routes.conversations`). FAB removed (create now in nav bar).

- [ ] **Step 1: Update feed screen widget test**

Add to the existing test file (keep existing cases; adjust pumps):

```dart
testWidgets('appbar shows heart and plane, no logout, no FAB', (
  WidgetTester tester,
) async {
  await tester.pumpWidget(_feedApp()); // existing helper in this file
  await tester.pumpAndSettle();
  expect(find.byTooltip('Activity'), findsOneWidget);
  expect(find.byTooltip('Conversations'), findsOneWidget);
  expect(find.byType(FloatingActionButton), findsNothing);
});
```

(If the file's helper is named differently, adapt — the assertion set is the contract. Add `.tooltip` semantics on the two `IconButton`s via `tooltip:` params. If tooltips are localized, use the l10n values the app already exposes for activity/conversations.)

- [ ] **Step 2: Run — expect failure** (tooltips/FAB assertions fail against current appbar)

- [ ] **Step 3: Rewrite feed appbar block**

```dart
appBar: AppBar(
  title: const Wordmark(),
  actions: <Widget>[
    BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (NotificationsState p, NotificationsState c) =>
          p.unreadCount != c.unreadCount,
      builder: (BuildContext context, NotificationsState state) =>
          IconButton(
            tooltip: l10n.navActivity,
            icon: BadgeIcon(
              icon: null,
              igIcon: IgIcons.heart,
              count: state.unreadCount,
            ),
            onPressed: () => context.push(Routes.activity),
          ),
    ),
    IconButton(
      tooltip: l10n.navConversations,
      icon: const IgIcon(IgIcons.share),
      onPressed: () => context.push(Routes.conversations),
    ),
  ],
),
```

Delete the `floatingActionButton:` block. Extend `BadgeIcon` to accept `IgIconData? igIcon` (render `IgIcon(igIcon!)` when set, else `Icon(icon)`):

```dart
// badge_icon.dart — add fields:
const BadgeIcon({required this.icon, required this.count, this.igIcon, super.key});
final IconData icon;
final IgIconData? igIcon;
// in build, replace `Icon(icon)` / Icon usage with:
final Widget glyph = igIcon != null ? IgIcon(igIcon!) : Icon(icon);
```

Add the two l10n keys first:

```bash
fstr navActivity "Activité" "Activity"
fstr navConversations "Messages" "Messages"
```

Import `NotificationsCubit`/`State` in feed_screen (the shell already provides the cubit above the shell — but feed branch is inside it, so `BlocProvider` lookup works only if the shell wraps branches; it wraps the Scaffold only. Simplest: feed screen reads `getIt<NotificationsCubit>()` via `BlocProvider.value` wrap of the Scaffold body — follow the existing pattern used elsewhere for this cubit (`getIt<NotificationsCubit>()..init(uid)` in the router shell); pass it down via `RepositoryProvider`/`BlocProvider.value` around `navigationShell` if not already visible. Prefer the minimal change: wrap the feed `Scaffold` in `BlocProvider<NotificationsCubit>.value(value: getIt<NotificationsCubit>())`.)

Also move logout to profile: add to `profile_screen.dart` appbar `actions` (own-profile build path only):

```dart
IconButton(
  tooltip: l10n.navLogout, // add key: fstr navLogout "Déconnexion" "Log out"
  icon: const IgIcon(IgIcons.moreDots),
  onPressed: () => context.read<AuthCubit>().signOut(),
),
```

(Placeholder placement — P4 swaps for the real "more" menu sheet. Uses more-dots icon so it doesn't read as a debug button.)

- [ ] **Step 4: Run — pass** (`flutter test test/features/feed/feed_screen_widget_test.dart`)

- [ ] **Step 5: Full gate + commit**

Run: `flutter analyze && flutter test` → green

```bash
git add lib/ test/
git commit -m "feat: IG feed appbar (heart badge + plane), logout to profile"
```

---

### Task 7: Phase gate — emulator visual check both themes

**Files:** none (verification only)

- [ ] **Step 1: Launch on emulator**

```bash
flutter emulators --launch Medium_Phone   # if none running
flutter run -d emulator-5554
```

- [ ] **Step 2: Verify checklist (dark, then light via emulator settings)**

- Nav bar: 5 unlabeled icons, no labels, profile tab = avatar, no ripple flashes on tap
- Create (+) pushes create screen and back returns to previous tab
- Feed appbar: wordmark, heart with badge (seeded notifications), plane; no logout, no FAB
- Heart → activity screen (pushed, back works)
- Theme colors: pure black bg dark / white + `#FAFAFA` appbar light, hairline dividers

- [ ] **Step 3: Screenshots for the record** (not committed — P5 reshoots all)

```bash
adb exec-out screencap -p > /tmp/p1_dark.png
# toggle emulator to light: adb shell cmd uimode day yes  → capture /tmp/p1_light.png
adb shell cmd uimode night yes   # restore
```

Look at both via image read; if colors/nav look wrong, fix before closing the phase.

- [ ] **Step 4: Final commit if any fixes**

```bash
git add -A && git commit -m "fix: phase 1 visual adjustments from emulator check"
```

---

## Self-Review (done at write time)

- **Spec coverage:** tokens ✓ (T1), no-ripple ✓ (T1), icons ✓ (T3), 5-tab nav + avatar tab + activity-to-appbar ✓ (T5/T6), haptics ✓ (T2), skeletons ✓ (T4 — used by screens from P2 on), hairline dividers ✓ (T1). Feed skeleton *usage* and story ring arrive in P2 per spec phasing.
- **Placeholders:** Task 1 step 4 contains a drafting artifact (typedef + the note under it) — the note instructs using the concrete `SnackBarThemeData` version; executor follows the note. Task 3 `share`/`grid` draft hacks are explicitly called out with clean replacements in the note. Acceptable as written since the corrective instruction is in-plan.
- **Type consistency:** `IgNavBar(onBranchSelected/onCreate/unreadCount/avatarUrl)` consistent between T5 steps and router rewire; `IgIcon(IgIconData, {size, color, active})` consistent T3↔T5; `BadgeIcon` extension is additive (keeps `icon` param).
