import 'dart:math';

abstract interface class LevelGenerator {
  double get levelFactor;

  set levelFactor(double value);

  void reset();
}

class PipeLevelGenerator implements LevelGenerator {
  @override
  double levelFactor;

  PipeLevelGenerator(this.levelFactor);

  late var initialPositionY = _generatePositionY();

  final initialPositionX = 600.0;

  double get speed {
    return max(400, 200 * (levelFactor * 0.5));
  }

  double _generatePositionY() => max(150, Random().nextInt(300).toDouble());

  @override
  void reset() {
    initialPositionY = _generatePositionY();
  }
}
