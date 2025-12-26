import 'package:flutter/material.dart';

import '../flare_engine.dart';

class FlareAnimation extends StatefulWidget {
  final int maxFrames;
  final int ticksPerFrame;
  final Widget Function(BuildContext context, int currentFrame) builder;

  const FlareAnimation({
    super.key,
    required this.maxFrames,
    required this.ticksPerFrame,
    required this.builder,
  });

  @override
  State<FlareAnimation> createState() => _FlareAnimationState();
}

class _FlareAnimationState extends State<FlareAnimation> {
  var currentFrame = 0;
  var tickCount = 0;

  @override
  void didUpdateWidget(covariant FlareAnimation oldWidget) {
    tickCount++;
    if (tickCount >= widget.ticksPerFrame) {
      tickCount = 0;
      currentFrame++;
      if (currentFrame >= widget.maxFrames) {
        currentFrame = 0;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = FlareFrameNotifier.of(context);
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, child) {
        return widget.builder(context, currentFrame);
      },
    );
  }
}
