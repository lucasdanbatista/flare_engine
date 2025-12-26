import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

class Grass extends StatelessWidget {
  const Grass({super.key});

  @override
  Widget build(BuildContext context) {
    return FlareAnimation(
      maxFrames: 2,
      ticksPerFrame: 12,
      builder: (context, currentFrame) => Positioned(
        left: gameState == GameState.running
            ? currentFrame == 0
                  ? 0
                  : 12
            : 0,
        bottom: 0,
        child: FlareSprite(
          frames: ['assets/base.png'],
          height: 96,
          width: MediaQuery.of(context).size.width,
          ticksPerFrame: 12,
        ),
      ),
    );
  }
}
