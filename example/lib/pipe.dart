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
  final _initialPositionX = 600.0;
  var _initialPositionY = math.min(math.Random().nextInt(300), 75).toDouble();

  // Starting position (off-screen right)
  late var _positionX = _initialPositionX;

  // Horizontal speed (pixels/s)
  final _speed = 200.0;

  void reset() {
    _positionX = _initialPositionX;
    _initialPositionY = math.min(math.Random().nextInt(300), 75).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (gameState == GameState.running) {
      // Move pipe to the left
      _positionX -= _speed * context.delta;

      if (_positionX.round() == 100) {
        if (widget.direction == AxisDirection.up) {
          score++;
          FlareAudio().playSfx('audio/point.wav');
        }
      }

      // Reset position when pipe goes off-screen left
      if (_positionX < -100) {
        reset();
      }
    }
    return Positioned(
      top: widget.direction == AxisDirection.up ? -_initialPositionY : null,
      bottom: widget.direction == AxisDirection.up ? null : -_initialPositionY,
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
