import 'package:flare_engine/src/collision_bitmask.dart';
import 'package:flutter/material.dart';

/// A widget that detects collisions between a [child] widget and a target
/// identified by a [GlobalKey].
///
/// The [FlareHitbox] wraps a [child] widget and monitors its position relative to
/// a target widget identified by [targetKey]. When the bounding boxes of both
/// widgets overlap, the [onCollision] callback is invoked.
///
/// Both the [child] and target must be rendered in the same coordinate space
/// (typically within the same [Stack]) for collision detection to work correctly.
///
/// If [mask] and [targetMask] are provided, a pixel-perfect collision check
/// is performed using the masks. Otherwise, a simple bounding box (AABB) check
/// is used.
///
/// Example usage:
/// ```dart
/// final playerKey = GlobalKey();
///
/// // In your build method:
/// Player(key: playerKey),
/// FlareHitbox(
///   targetKey: playerKey,
///   child: Pipe(direction: AxisDirection.up),
///   onCollision: () => gameState = GameState.over,
/// )
/// ```
class FlareHitbox extends StatefulWidget {
  /// Creates a hitbox widget that detects collisions.
  ///
  /// The [child] is the widget whose bounds are monitored for collision.
  /// The [targetKey] is the GlobalKey of the widget to check collision against.
  /// The [onCollision] callback is invoked when bounds overlap.
  const FlareHitbox({
    super.key,
    required this.child,
    required this.targetKey,
    required this.onCollision,
    this.mask,
    this.targetMask,
  });

  /// The widget that has collision physics (e.g., a pipe or obstacle).
  final Widget child;

  /// The GlobalKey of the widget to check collision against (e.g., the player).
  final GlobalKey targetKey;

  /// Optional bitmask for the [child] widget for pixel-perfect collision.
  final CollisionBitmask? mask;

  /// Optional bitmask for the [targetKey] widget for pixel-perfect collision.
  final CollisionBitmask? targetMask;

  /// Callback invoked when a collision is detected.
  ///
  /// This is called once per frame while the collision is active.
  final VoidCallback onCollision;

  @override
  State<FlareHitbox> createState() => _FlareHitboxState();
}

class _FlareHitboxState extends State<FlareHitbox> {
  final _childKey = GlobalKey();

  /// Gets the bounding rectangle of a widget in global coordinates.
  /// Handles rotation and scaling by transforming all 4 corners.
  RenderBox? _getDeepestRenderBox(GlobalKey key) {
    var renderObject = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return null;

    // Drill down to find the leaf RenderBox (handling Transforms, etc.)
    // We want the object that actually draws the content (and defines the coord system for the mask)
    while (true) {
      RenderBox? nextChild;
      int childCount = 0;

      renderObject!.visitChildren((child) {
        childCount++;
        if (child is RenderBox) {
          nextChild = child;
        }
      });

      if (childCount == 1 && nextChild != null) {
        renderObject = nextChild;
      } else {
        break;
      }
    }
    return renderObject;
  }

  /// Gets the bounding rectangle of a widget in global coordinates.
  /// Handles rotation and scaling by transforming all 4 corners.
  Rect? _getBounds(GlobalKey key) {
    final renderObject = _getDeepestRenderBox(key);
    if (renderObject is RenderBox && renderObject.hasSize) {
      final size = renderObject.size;
      final corners = [
        Offset.zero,
        Offset(size.width, 0),
        Offset(0, size.height),
        Offset(size.width, size.height),
      ];

      final globalCorners = corners
          .map((c) => renderObject.localToGlobal(c))
          .toList();

      var minX = double.infinity;
      var minY = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;

      for (var point in globalCorners) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }

      return Rect.fromLTRB(minX, minY, maxX, maxY);
    }
    return null;
  }

  /// Checks if the child and target bounds overlap.
  bool _checkCollision() {
    final childRenderObject = _getDeepestRenderBox(_childKey);
    final targetRenderObject = _getDeepestRenderBox(widget.targetKey);

    if (childRenderObject == null ||
        targetRenderObject == null ||
        !childRenderObject.hasSize ||
        !targetRenderObject.hasSize) {
      return false;
    }

    final childBounds = _getBounds(_childKey);
    final targetBounds = _getBounds(widget.targetKey);

    if (childBounds == null || targetBounds == null) {
      return false;
    }

    // AABB Check (Early Out)
    final intersection = childBounds.intersect(targetBounds);
    if (intersection.width <= 0 || intersection.height <= 0) {
      return false;
    }

    // If masks are not provided, we are done (AABB collision confirmed)
    if (widget.mask == null || widget.targetMask == null) {
      return true;
    }

    // Pixel-Perfect Check (Bitmap Collision)
    // We iterate over the intersection rectangle
    final startX = intersection.left.floor();
    final endX = intersection.right.ceil();
    final startY = intersection.top.floor();
    final endY = intersection.bottom.ceil();

    for (var x = startX; x < endX; x++) {
      for (var y = startY; y < endY; y++) {
        // Convert global coordinate (x, y) to local bitmask coordinates RECOGNIZING rotation/scale
        final globalPoint = Offset(x.toDouble(), y.toDouble());

        final localPoint1 = childRenderObject.globalToLocal(globalPoint);
        final localPoint2 = targetRenderObject.globalToLocal(globalPoint);

        final localX1 = localPoint1.dx.floor();
        final localY1 = localPoint1.dy.floor();

        final localX2 = localPoint2.dx.floor();
        final localY2 = localPoint2.dy.floor();

        // Check if both masks have a solid pixel at this location
        final isSolid1 = widget.mask!.getBit(localX1, localY1);
        final isSolid2 = widget.targetMask!.getBit(localX2, localY2);

        if (isSolid1 && isSolid2) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Schedule collision check after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checkCollision()) {
        widget.onCollision();
      }
    });

    return KeyedSubtree(key: _childKey, child: widget.child);
  }
}
