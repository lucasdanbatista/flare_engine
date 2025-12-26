import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/widgets.dart';

class FlareSprite extends StatelessWidget {
  const FlareSprite({
    super.key,
    required this.frames,
    this.width,
    this.height,
    this.ticksPerFrame = 0,
    this.scale = 1.5,
  }) : assert(frames.length > 0);

  final double scale;
  final List<String> frames;
  final double? width;
  final double? height;
  final int ticksPerFrame;

  @override
  Widget build(BuildContext context) {
    return FlareAnimation(
      maxFrames: frames.length,
      ticksPerFrame: ticksPerFrame,
      builder: (context, currentFrame) => Transform.scale(
        scale: scale,
        child: Image.asset(
          currentFrame < frames.length ? frames[currentFrame] : frames[0],
          width: width,
          height: height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}
