import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({required this.icon, required this.count, super.key});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(width: 24, height: 24, child: Icon(icon)),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
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
