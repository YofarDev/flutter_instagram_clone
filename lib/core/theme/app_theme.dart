import 'package:flutter/material.dart';

import 'ig_colors.dart';

/// Instagram-exact Material 3 themes (dark + light).
class AppTheme {
  AppTheme._();

  static ThemeData _base(Brightness brightness) {
    final Color background = brightness == Brightness.dark
        ? IgColors.black
        : IgColors.white;
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
        surfaceContainerHighest: IgColors.inputFill(brightness),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerColor: IgColors.divider(brightness),
      dividerTheme: DividerThemeData(
        color: IgColors.divider(brightness),
        thickness: 0.5,
        space: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark
            ? IgColors.black
            : IgColors.appBarLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: Typography.material2021().englishLike
          .merge(Typography.material2021().black)
          .apply(bodyColor: textPrimary, displayColor: textPrimary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? IgColors.elevatedDark
            : IgColors.black,
        contentTextStyle: TextStyle(
          color: IgColors.textPrimary(Brightness.dark),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme => _base(Brightness.dark);
  static ThemeData get lightTheme => _base(Brightness.light);
}
