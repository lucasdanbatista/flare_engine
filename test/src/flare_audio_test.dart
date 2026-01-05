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

    test('playSfx does not play if same sound is already playing', () async {
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

      // First play
      await FlareAudio().playSfx('test_sound.wav');

      // Second play attempt (should be ignored)
      await FlareAudio().playSfx('test_sound.wav');

      // Verify play was called only once
      verify(() => mockAudioPlayer.play(any())).called(1);

      // Finish the sound
      streamController.add(null);
      await Future.delayed(Duration.zero);

      // Now we can play again
      await FlareAudio().playSfx('test_sound.wav');
      verify(
        () => mockAudioPlayer.play(any()),
      ).called(1); // Called one more time

      await streamController.close();
    });

    test('playSfx plays different sounds simultaneously', () async {
      final player1 = MockAudioPlayer();
      final player2 = MockAudioPlayer();
      final streamController1 = StreamController<void>.broadcast();
      final streamController2 = StreamController<void>.broadcast();

      // Setup for player 1
      when(() => player1.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => player1.play(any())).thenAnswer((_) async {});
      when(() => player1.dispose()).thenAnswer((_) async {});
      when(
        () => player1.onPlayerComplete,
      ).thenAnswer((_) => streamController1.stream);

      // Setup for player 2
      when(() => player2.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => player2.play(any())).thenAnswer((_) async {});
      when(() => player2.dispose()).thenAnswer((_) async {});
      when(
        () => player2.onPlayerComplete,
      ).thenAnswer((_) => streamController2.stream);

      var callCount = 0;
      FlareAudio().playerFactory = () {
        callCount++;
        if (callCount == 1) return player1;
        return player2;
      };

      await FlareAudio().playSfx('sound1.wav');
      await FlareAudio().playSfx('sound2.wav');

      verify(
        () => player1.play(
          any(
            that: isA<AssetSource>().having(
              (s) => s.path,
              'path',
              'sound1.wav',
            ),
          ),
        ),
      ).called(1);

      verify(
        () => player2.play(
          any(
            that: isA<AssetSource>().having(
              (s) => s.path,
              'path',
              'sound2.wav',
            ),
          ),
        ),
      ).called(1);

      // Cleanup
      await streamController1.close();
      await streamController2.close();
    });
  });
}
