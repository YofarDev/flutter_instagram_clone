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
      expect(t.splashFactory, NoSplash.splashFactory);
    });

    test('light theme uses IG tokens', () {
      final ThemeData t = AppTheme.lightTheme;
      expect(t.scaffoldBackgroundColor, IgColors.white);
      expect(t.colorScheme.onPrimary, IgColors.textPrimary(Brightness.light));
      expect(t.splashFactory, NoSplash.splashFactory);
    });

    test('IG gradient ring is 4 stops warm-to-pink', () {
      final List<Color> g = IgColors.gradientRing;
      expect(g.length, 4);
      expect(g.first, const Color(0xFFFEDA75));
      expect(g.last, const Color(0xFFD62976));
    });
  });
}
