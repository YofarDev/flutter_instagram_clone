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
            final double dx =
                _controller.value * bounds.width * 3 - bounds.width;
            final Gradient gradient = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
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
