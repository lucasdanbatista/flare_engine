import 'dart:ui' as ui;

/// A 2D bitmask used for pixel-perfect collision detection.
class CollisionBitmask {
  /// The width of the mask in pixels.
  final int width;

  /// The height of the mask in pixels.
  final int height;

  final List<bool> _data;

  /// Creates a [CollisionBitmask] with the given [width], [height] and [data].
  ///
  /// The [data] list must have length equal to `width * height`.
  const CollisionBitmask(this.width, this.height, List<bool> data)
    : _data = data,
      assert(
        data.length == width * height,
        'Data length must match width * height',
      );

  /// Creates a [CollisionBitmask] filled with [defaultValue].
  factory CollisionBitmask.filled(
    int width,
    int height, {
    bool defaultValue = false,
  }) {
    return CollisionBitmask(
      width,
      height,
      List<bool>.filled(width * height, defaultValue),
    );
  }

  /// Checks if the pixel at ([x], [y]) is solid (true).
  ///
  /// Returns false if coordinates are out of bounds.
  bool getBit(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return false;
    }
    return _data[y * width + x];
  }

  /// Sets the bit at ([x], [y]) to [value].
  void setBit(int x, int y, {required bool value}) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return;
    }
    _data[y * width + x] = value;
  }

  /// Creates a [CollisionBitmask] from a [ui.Image] based on alpha threshold.
  ///
  /// This is an expensive operation and should be done during loading.
  static Future<CollisionBitmask> fromImage(
    ui.Image image, {
    int alphaThreshold = 0,
  }) async {
    final width = image.width;
    final height = image.height;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final bytes = data!.buffer.asUint8List();
    final maskData = List<bool>.filled(width * height, false);

    for (var i = 0; i < bytes.length; i += 4) {
      final alpha = bytes[i + 3];
      if (alpha > alphaThreshold) {
        maskData[i ~/ 4] = true;
      }
    }

    return CollisionBitmask(width, height, maskData);
  }
}
