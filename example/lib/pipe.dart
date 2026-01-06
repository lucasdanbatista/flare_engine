import 'dart:math' as math;

import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

class Pipe extends StatefulWidget {
  final AxisDirection direction;

  const Pipe({super.key, required this.direction});

  static void reset(GlobalKey key) {
    final state = key.currentState as _PipeState;
    state.reset();
  }

  @override
  State<Pipe> createState() => _PipeState();
}

class _PipeState extends State<Pipe> {
  // Starting position (off-screen right)
  late var _positionX = pipeLevel.initialPositionX;

  void reset() {
    pipeLevel.reset();
    _positionX = pipeLevel.initialPositionX;
  }

  @override
  Widget build(BuildContext context) {
    if (gameState == GameState.running) {
      _positionX -= pipeLevel.speed * context.delta;
      if (_positionX < -60) {
        if (widget.direction == AxisDirection.up) {
          score++;
          pipeLevel.levelFactor -= 0.05;
          FlareAudio().playSfx('audio/point.wav');
        }
        reset();
      }
    }
    return Positioned(
      top: widget.direction == AxisDirection.up
          ? -pipeLevel.initialPositionY
          : null,
      bottom: widget.direction == AxisDirection.up
          ? null
          : -pipeLevel.initialPositionY + 112,
      left: _positionX,
      child: Transform.rotate(
        angle: widget.direction == AxisDirection.up ? -math.pi : 0,
        child: FlareSprite(
          frames: ['assets/pipe-green.png'],
          height: 320,
          width: 52,
        ),
      ),
    );
  }
}
