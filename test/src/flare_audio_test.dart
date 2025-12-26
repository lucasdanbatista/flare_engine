import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flare_engine/src/flare_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  group('FlareAudio', () {
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      registerFallbackValue(ReleaseMode.release);
      registerFallbackValue(AssetSource(''));
    });

    test('playSfx plays audio and disposes on complete', () async {
      final streamController = StreamController<void>.broadcast();

      when(
        () => mockAudioPlayer.setReleaseMode(any()),
      ).thenAnswer((_) async {});
      when(() => mockAudioPlayer.play(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});
      when(
        () => mockAudioPlayer.onPlayerComplete,
      ).thenAnswer((_) => streamController.stream);

      FlareAudio().playerFactory = () => mockAudioPlayer;

      await FlareAudio().playSfx('test_sound.wav');

      verify(
        () => mockAudioPlayer.setReleaseMode(ReleaseMode.release),
      ).called(1);
      final captured = verify(
        () => mockAudioPlayer.play(captureAny()),
      ).captured;
      expect(
        captured.last,
        isA<AssetSource>().having((s) => s.path, 'path', 'test_sound.wav'),
      );

      // Simulate completion
      streamController.add(null);
      // Wait for async stream listener
      await Future.delayed(Duration.zero);

      verify(() => mockAudioPlayer.dispose()).called(1);
      await streamController.close();
    });
  });
}
