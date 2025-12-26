import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Wrap(
        children: [
          if (gameState == GameState.idle) _Start(),
          if (gameState == GameState.over) _GameOver(),
        ],
      ),
    );
  }
}

class _Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlareSprite(
      frames: ['assets/message.png'],
      height: 267,
      width: 184,
      ticksPerFrame: 1,
    );
  }
}

class _GameOver extends StatelessWidget {
  const _GameOver();

  @override
  Widget build(BuildContext context) {
    return FlareSprite(
      frames: ['assets/gameover.png'],
      height: 42,
      width: 192,
      ticksPerFrame: 1,
    );
  }
}
