import 'dart:math';

import 'package:example/main.dart';
import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.black,
      child: Text(
        'fps: ${(1 / max(context.delta, 0.00000001)).round()}\n'
        'pipe_level_factor: ${pipeLevel.levelFactor.toStringAsFixed(1)}',
        style: TextStyle(color: Color(0xFF00FF00)),
      ),
    );
  }
}
