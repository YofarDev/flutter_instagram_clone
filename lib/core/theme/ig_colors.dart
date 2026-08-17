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
