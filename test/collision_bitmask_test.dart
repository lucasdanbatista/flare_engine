import 'dart:ui' as ui;

import 'package:flare_engine/src/collision_bitmask.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> createTestImage({
  required int width,
  required int height,
  ui.Color color = const ui.Color(0x00000000), // Default transparent
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = color;
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );
  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}

void main() {
  group('CollisionBitmask', () {
    test('creates filled bitmask correctly', () {
      final mask = CollisionBitmask.filled(2, 2, defaultValue: true);
      expect(mask.width, 2);
      expect(mask.height, 2);
      expect(mask.getBit(0, 0), true);
      expect(mask.getBit(1, 1), true);
    });

    test('getBit returns false for out of bounds', () {
      final mask = CollisionBitmask.filled(2, 2, defaultValue: true);
      expect(mask.getBit(-1, 0), false);
      expect(mask.getBit(0, -1), false);
      expect(mask.getBit(2, 0), false);
      expect(mask.getBit(0, 2), false);
    });

    test('manual creation works', () {
      // 2x2 checkerboard
      // T F
      // F T
      final mask = CollisionBitmask(2, 2, [true, false, false, true]);
      expect(mask.getBit(0, 0), true);
      expect(mask.getBit(1, 0), false);
      expect(mask.getBit(0, 1), false);
      expect(mask.getBit(1, 1), true);
    });

    test('setBit updates the bit correctly', () {
      final mask = CollisionBitmask.filled(2, 2);
      expect(mask.getBit(0, 0), false);

      mask.setBit(0, 0, value: true);
      expect(mask.getBit(0, 0), true);
    });

    test('setBit handles out of bounds safely', () {
      final mask = CollisionBitmask.filled(2, 2);
      // specific error checking isn't implemented, just ensuring no crash
      mask.setBit(-1, 0, value: true);
      mask.setBit(0, -1, value: true);
      mask.setBit(2, 0, value: true);
      mask.setBit(0, 2, value: true);

      // Verify nothing changed
      expect(mask.getBit(0, 0), false);
      expect(mask.getBit(1, 0), false);
      expect(mask.getBit(0, 1), false);
      expect(mask.getBit(1, 1), false);
    });

    testWidgets('fromImage creates bitmask from image', (tester) async {
      await tester.runAsync(() async {
        // Create a 2x2 transparent image
        final image = await createTestImage(width: 2, height: 2);
        final mask = await CollisionBitmask.fromImage(image);
        expect(mask.width, 2);
        expect(mask.height, 2);
        expect(mask.getBit(0, 0), false);
      });
    });

    testWidgets('fromImage creates bitmask with opaque pixels', (tester) async {
      await tester.runAsync(() async {
        // Create a 2x2 opaque image (red)
        final image = await createTestImage(
          width: 2,
          height: 2,
          color: const ui.Color(0xFFFF0000), // Opaque Red
        );
        final mask = await CollisionBitmask.fromImage(image);
        expect(mask.width, 2);
        expect(mask.height, 2);
        // Alpha should be 255, so it should be solid
        expect(mask.getBit(0, 0), true);
        expect(mask.getBit(1, 1), true);
      });
    });
  });
}
