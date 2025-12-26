import 'dart:convert';

import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'test';
  }

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final ByteData? data = const StandardMessageCodec().encodeMessage(
        <String, dynamic>{},
      );
      return data!;
    }
    // Return 1x1 transparent PNG
    final bytes = base64.decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
    );
    return ByteData.view(bytes.buffer);
  }
}

void main() {
  group('FlareSprite', () {
    test('throws assertion error if frames are empty', () {
      expect(() => FlareSprite(frames: []), throwsAssertionError);
    });

    testWidgets('builds FlareAnimation and Image with correct properties', (
      tester,
    ) async {
      final frames = ['assets/frame1.png', 'assets/frame2.png'];
      final notifier = FlareFrameNotifier();

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: FlareFrameNotifierProvider(
            frameNotifier: notifier,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FlareSprite(
                frames: frames,
                width: 100,
                height: 200,
                scale: 2.0,
                ticksPerFrame: 5,
              ),
            ),
          ),
        ),
      );

      // Verify FlareAnimation is present
      final animationFinder = find.byType(FlareAnimation);
      expect(animationFinder, findsOneWidget);
      final animation = tester.widget<FlareAnimation>(animationFinder);
      expect(animation.maxFrames, frames.length);
      expect(animation.ticksPerFrame, 5);

      // Verify Image is present
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      expect(image.width, 100);
      expect(image.height, 200);
      expect(image.fit, BoxFit.fill);
      expect(image.filterQuality, FilterQuality.none);

      final imageProvider = image.image as AssetImage;
      expect(imageProvider.assetName, frames[0]);

      // Verify Transform.scale
      // Find Transform that is direct child of FlareAnimation's builder essentially
      final transformFinder = find.descendant(
        of: find.byType(FlareSprite),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsOneWidget);
      final scaleTransform = tester.widget<Transform>(transformFinder);

      expect(scaleTransform.transform.getMaxScaleOnAxis(), closeTo(2.0, 0.001));
    });

    testWidgets('defaults are correct', (tester) async {
      final frames = ['assets/frame1.png'];
      final notifier = FlareFrameNotifier();

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: FlareFrameNotifierProvider(
            frameNotifier: notifier,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FlareSprite(frames: frames),
            ),
          ),
        ),
      );

      final animation = tester.widget<FlareAnimation>(
        find.byType(FlareAnimation),
      );
      expect(animation.ticksPerFrame, 0);

      final transformFinder = find.descendant(
        of: find.byType(FlareSprite),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsOneWidget);
      final scaleTransform = tester.widget<Transform>(transformFinder);

      expect(
        scaleTransform.transform.getMaxScaleOnAxis(),
        closeTo(1.5, 0.001),
      ); // Default scale
    });
  });
}
