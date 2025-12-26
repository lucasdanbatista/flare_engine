import 'package:flutter/scheduler.dart';

class FlareEngine {
  final TickerProvider _tickerProvider;
  var _previous = Duration.zero;

  FlareEngine(this._tickerProvider);

  Ticker? _ticker;
  bool _isFirstTick = true;

  void run({required void Function(Duration onTick) onTick}) {
    _ticker = _tickerProvider.createTicker((elapsed) {
      if (_isFirstTick) {
        _isFirstTick = false;
        _previous = elapsed;
        onTick(Duration.zero);
        return;
      }
      final delta = elapsed - _previous;
      _previous = elapsed;
      onTick(delta);
    });
    _ticker!.start();
  }

  void dispose() {
    _ticker?.dispose();
  }
}
