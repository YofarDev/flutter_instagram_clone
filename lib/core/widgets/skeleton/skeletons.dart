// lib/core/widgets/skeleton/skeletons.dart
import 'package:flutter/material.dart';

import 'shimmer.dart';

/// Base gray block used by all skeletons.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width = double.infinity,
    this.height = 16,
    super.key,
  });

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
      child: SingleChildScrollView(
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
      ),
    );
  }
}

/// 3-col grid tile placeholder.
class SkeletonGridTile extends StatelessWidget {
  const SkeletonGridTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: SkeletonBox(height: double.infinity),
    );
  }
}
