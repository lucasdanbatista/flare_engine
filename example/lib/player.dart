import 'dart:math' as math;

import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  static void reset(GlobalKey key) {
    final state = key.currentState as _PlayerState;
    state.reset();
  }

  static void fly(GlobalKey key) {
    final state = key.currentState as _PlayerState;
    state.fly();
  }

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  var _position = 490.0;
  var _velocity = 0.0;
  var _rotation = 0.0; // Current rotation in radians

  // Flappy Bird-style physics constants
  final _gravity = 1200.0; // Gravity acceleration (pixels/s²)
  final _flapStrength = -1200.0; // Upward velocity on flap (pixels/s)
  final _terminalVelocity = 600.0; // Max falling speed (pixels/s)
  final _drag = 0.98; // Air resistance (velocity multiplier per frame)

  // Rotation constants
  final _flapRotation =
      -30.0 * math.pi / 180; // -30 degrees in radians (tilt up)
  final _maxDownRotation =
      90.0 * math.pi / 180; // 90 degrees in radians (nose dive)
  final _rotationSpeed = 3.0; // How fast rotation changes

  void fly() {
    if (gameState != GameState.running) return;
    _velocity = _flapStrength;
    _rotation = _flapRotation; // Tilt up on flap
    Haptics.vibrate(HapticsType.heavy);
    FlareAudio().playSfx('audio/wing.wav');
  }

  void reset() {
    _position = 300.0;
    _velocity = 0.0;
    _rotation = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dt =
        FlareFrameNotifier.of(context).delta.inMicroseconds /
        Duration.microsecondsPerSecond;

    if (gameState == GameState.running) {
      // Apply gravity
      _velocity += _gravity * dt;

      // Apply air resistance (drag)
      _velocity *= _drag;

      // Clamp to terminal velocity
      _velocity = _velocity.clamp(-_terminalVelocity, _terminalVelocity);

      // Update position
      _position += _velocity * dt;

      // Update rotation based on velocity (falling = rotate down)
      if (_velocity > 0) {
        // Falling: gradually rotate towards nose-down
        _rotation += _rotationSpeed * dt;
        _rotation = _rotation.clamp(_flapRotation, _maxDownRotation);
      }

      if (_position < -40) {
        _position = -40;
      }
    }

    return Positioned(
      top: _position,
      left: 100,
      child: Transform.rotate(
        angle: _rotation,
        child: FlareSprite(
          frames: gameState == GameState.over
              ? ['assets/yellowbird-downflap.png']
              : [
                  'assets/yellowbird-downflap.png',
                  'assets/yellowbird-midflap.png',
                  'assets/yellowbird-upflap.png',
                ],
          width: 32,
          height: 24,
          ticksPerFrame: 8,
        ),
      ),
    );
  }
}
