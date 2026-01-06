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

  late var _previousLevelFactor = levelFactor;

  var _speed = 300.0;

  double get speed {
    if (_previousLevelFactor != levelFactor) {
      _previousLevelFactor = levelFactor;
      _speed += 10;
    }
    return min(_speed, 1000);
  }

  double _generatePositionY() => max(150, Random().nextInt(300).toDouble());


  @override
  void reset() {
    initialPositionY = _generatePositionY();
  }
}
