import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return FlareSprite(
      frames: ['assets/background-day.png'],
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      ticksPerFrame: 0,
    );
  }
}
