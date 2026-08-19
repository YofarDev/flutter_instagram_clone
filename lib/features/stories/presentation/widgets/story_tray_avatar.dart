import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/ig_colors.dart';
import '../../domain/models/story_tray.dart';

class StoryTrayAvatar extends StatelessWidget {
  const StoryTrayAvatar({
    required this.tray,
    required this.unviewed,
    required this.label,
    this.onTap,
    this.isMine = false,
    super.key,
  });

  final StoryTray tray;
  final bool unviewed;
  final String label;
  final VoidCallback? onTap;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    // IG gradient ring on unseen stories, hairline gray once seen
    final BoxDecoration ring = unviewed
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: IgColors.gradientRing,
              startAngle: -math.pi / 2,
              endAngle: 3 * math.pi / 2,
            ),
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: IgColors.divider(Theme.of(context).brightness),
          );
    final Widget avatar = Container(
      decoration: ring,
      padding: const EdgeInsets.all(2.5),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundImage: tray.avatarUrl != null
            ? NetworkImage(tray.avatarUrl!)
            : null,
        child: tray.avatarUrl == null
            ? Text(
                tray.username.isNotEmpty ? tray.username[0].toUpperCase() : '?',
              )
            : null,
      ),
    );
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: isMine
              ? Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    avatar,
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 9.5,
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : avatar,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
