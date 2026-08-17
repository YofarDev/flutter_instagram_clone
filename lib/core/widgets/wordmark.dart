import 'package:flutter/material.dart';

/// Instagram-style script wordmark (Grand Hotel, Billabong-alike).
class Wordmark extends StatelessWidget {
  const Wordmark({this.fontSize = 32, this.color, super.key});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Instagram',
      style: TextStyle(
        fontFamily: 'GrandHotel',
        fontSize: fontSize,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
