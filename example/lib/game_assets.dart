import 'dart:async';
import 'dart:ui' as ui;

import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/services.dart';

class GameAssets {
  static final instance = GameAssets._();

  GameAssets._();

  CollisionBitmask? _pipeMask;
  CollisionBitmask? _grassMask;
  CollisionBitmask? _playerMask;

  CollisionBitmask get pipeMask => _pipeMask!;

  CollisionBitmask get grassMask => _grassMask!;

  CollisionBitmask get playerMask => _playerMask!;

  Future<void> load() async {
    _pipeMask = await _loadMask('assets/pipe-green.png');
    _grassMask = await _loadMask('assets/base.png');
    // Using one of the player frames for the mask.
    // Ideally we might want an average or specific hit-box representation,
    // but the midflap frame is a reasonable approximation for now.
    _playerMask = await _loadMask('assets/yellowbird-midflap.png');
  }

  Future<CollisionBitmask> _loadMask(String assetPath) async {
    final image = await _loadImage(assetPath);
    return CollisionBitmask.fromImage(image);
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, (img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
