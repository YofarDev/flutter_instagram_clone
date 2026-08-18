import 'package:flutter/material.dart';

import '../../../../core/theme/ig_colors.dart';
import '../../../../core/widgets/ig_icon.dart';
import '../../../../core/widgets/ig_icons.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({required this.igIcon, required this.count, super.key});

  final IgIconData igIcon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final Widget glyph = IgIcon(
      igIcon,
      color:
          IconTheme.of(context).color ??
          Theme.of(context).colorScheme.onSurface,
    );
    if (count <= 0) return glyph;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(width: 24, height: 24, child: glyph),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: IgColors.alertRed,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 9,
                  color: IgColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
