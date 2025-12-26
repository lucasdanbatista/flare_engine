import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class _Number extends StatelessWidget {
  final String asset;

  const _Number({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: FlareSprite(
        frames: ['assets/$asset.png'],
        height: 36,
        ticksPerFrame: 12,
      ),
    );
  }
}

class Score extends StatelessWidget {
  const Score({super.key});

  @override
  Widget build(BuildContext context) {
    final numbers = {
      0: _Number(asset: '0'),
      1: _Number(asset: '1'),
      2: _Number(asset: '2'),
      3: _Number(asset: '3'),
      4: _Number(asset: '4'),
      5: _Number(asset: '5'),
      6: _Number(asset: '6'),
      7: _Number(asset: '7'),
      8: _Number(asset: '8'),
      9: _Number(asset: '9'),
    };

    return Padding(
      padding: EdgeInsets.only(top: 120),
      child: Align(
        alignment: Alignment.topCenter,
        child: Wrap(
          children: score.toString().characters.map((e) {
            switch (e) {
              case '1':
                return numbers[1]!;
              case '2':
                return numbers[2]!;
              case '3':
                return numbers[3]!;
              case '4':
                return numbers[4]!;
              case '5':
                return numbers[5]!;
              case '6':
                return numbers[6]!;
              case '7':
                return numbers[7]!;
              case '8':
                return numbers[8]!;
              case '9':
                return numbers[9]!;
              default:
                return numbers[0]!;
            }
          }).toList(),
        ),
      ),
    );
  }
}
