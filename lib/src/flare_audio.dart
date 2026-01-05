import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

typedef AudioPlayerFactory = AudioPlayer Function();

/// A simple audio manager for playing sound effects.
class FlareAudio {
  static final FlareAudio _instance = FlareAudio._internal();

  /// Returns the singleton instance of [FlareAudio].
  factory FlareAudio() => _instance;

  FlareAudio._internal();

  //coverage:ignore-start
  AudioPlayerFactory _playerFactory = () => AudioPlayer();
  //coverage:ignore-end

  @visibleForTesting
  set playerFactory(AudioPlayerFactory factory) => _playerFactory = factory;

  /// Plays a sound effect from the given asset [path].
  ///
  /// Example:
  /// ```dart
  /// FlareAudio().playSfx('audio/jump.wav');
  /// ```
  final Map<String, AudioPlayer> _activePlayers = {};

  /// Plays a sound effect from the given asset [path].
  ///
  /// Example:
  /// ```dart
  /// FlareAudio().playSfx('audio/jump.wav');
  /// ```
  Future<void> playSfx(String path) async {
    if (_activePlayers.containsKey(path)) {
      return;
    }

    final player = _playerFactory();
    _activePlayers[path] = player;

    // Ensure we release resources after playing
    await player.setReleaseMode(ReleaseMode.release);

    try {
      await player.play(AssetSource(path));

      // Dispose the player when finished to free up resources
      player.onPlayerComplete.listen((_) {
        _activePlayers.remove(path);
        player.dispose();
      });
    } catch (e) {
      _activePlayers.remove(path);
      player.dispose();
      rethrow;
    }
  }
}
