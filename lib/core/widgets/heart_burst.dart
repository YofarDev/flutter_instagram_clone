import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'ig_icon.dart';
import 'ig_icons.dart';

/// Fires the IG double-tap heart: scale pop, slight rotation, fade-out.
/// Shared by feed post cards and reels — put one inside a Stack and call
/// [HeartBurstController.fire] from the double-tap handler.
class HeartBurstController {
  _HeartBurstState? _state;

  void fire() => _state?.fire();

  void _attach(_HeartBurstState state) => _state = state;

  void _detach(_HeartBurstState state) {
    if (identical(_state, state)) _state = null;
  }
}

class HeartBurst extends StatefulWidget {
  const HeartBurst({required this.controller, this.size = 96, super.key});

  final HeartBurstController controller;
  final double size;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    _controller.addStatusListener((AnimationStatus status) {
      // value resets so the idle widget collapses to nothing
      if (status == AnimationStatus.completed) _controller.value = 0;
    });
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _controller.dispose();
    super.dispose();
  }

  void fire() {
    if (mounted) _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // the burst is pure eye candy over a gesture surface — never hit-testable,
    // or it swallows the very double-taps that trigger it
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          if (!_controller.isAnimating && _controller.value == 0) {
            return const SizedBox.shrink();
          }
          final double t = _controller.value;
          // 0-0.35 grow with overshoot, 0.35-0.5 settle, 0.5-1 fade out
          final double scale = t < 0.35
              ? Curves.easeOutBack.transform(t / 0.35) * 1.2
              : t < 0.5
              ? lerpDouble(1.2, 1.0, (t - 0.35) / 0.15)!
              : lerpDouble(1.0, 0.9, (t - 0.5) / 0.5)!;
          final double opacity = t < 0.5 ? 1.0 : 1.0 - (t - 0.5) / 0.5;
          final double rotation = t < 0.5
              ? lerpDouble(-0.25, 0.1, t / 0.5)!
              : 0.1;
          return Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: IgIcon(
          IgIcons.heartFilled,
          size: widget.size,
          color: Colors.white,
        ),
      ),
    );
  }
}
