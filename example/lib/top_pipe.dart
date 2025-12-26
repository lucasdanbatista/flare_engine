import 'dart:math' as math;

import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

const _initialPositionX = 600.0;
var _positionX = _initialPositionX; // Starting position (off-screen right)
const _speed = 200.0; // Horizontal speed (pixels/s)

class TopPipe extends StatelessWidget {
  const TopPipe({super.key});

  static void reset() {
    _positionX = _initialPositionX;
  }

  @override
  Widget build(BuildContext context) {
    if (gameState == GameState.running) {
      final dt =
          FlareFrameNotifier.of(context).delta.inMicroseconds /
          Duration.microsecondsPerSecond;

      // Move pipe to the left
      _positionX -= _speed * dt;

      // Reset position when pipe goes off-screen left
      if (_positionX < -100) {
        reset();
      }
    }
    return Positioned(
      top: -100,
      left: _positionX,
      child: Transform.rotate(
        angle: -math.pi,
        child: FlareSprite(
          frames: ['assets/pipe-green.png'],
          height: 320,
          width: 52,
          ticksPerFrame: 12,
        ),
      ),
    );
  }
}
