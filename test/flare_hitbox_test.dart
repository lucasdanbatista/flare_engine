import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlareHitbox Pixel Perfect', () {
    testWidgets('Collision detected only when solid pixels overlap', (
      tester,
    ) async {
      bool collisionDetected = false;
      final targetKey = GlobalKey();

      // Create two 2x2 masks
      // Child Mask:
      // T F
      // F F
      final childMask = CollisionBitmask(2, 2, [true, false, false, false]);

      // Target Mask:
      // F F
      // F T
      // If we align them exactly, (0,0) overlaps (0,0).
      // Child(0,0)=True overlaps Target(0,0)=False -> No Collision
      // But if we offset them...

      // Let's make it simpler.
      // Child: Solid at (0,0)
      // Target: Solid at (0,0)
      final targetMask = CollisionBitmask(2, 2, [true, false, false, false]);

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              // Target at (0,0)
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(width: 2, height: 2, key: targetKey),
              ),
              // Child at (0,0) - Overlap at (0,0) where both are true
              FlareHitbox(
                targetKey: targetKey,
                mask: childMask,
                targetMask: targetMask,
                onCollision: () => collisionDetected = true,
                child: const SizedBox(width: 2, height: 2),
              ),
            ],
          ),
        ),
      );

      // Trigger frame callback
      await tester.pump();
      await tester.pump(Duration.zero); // Post frame callback

      expect(collisionDetected, true);
    });

    testWidgets('No collision when solid pixels do not overlap', (
      tester,
    ) async {
      bool collisionDetected = false;
      final targetKey = GlobalKey();

      // Child Mask: Top-Left only
      final childMask = CollisionBitmask(2, 2, [true, false, false, false]);

      // Target Mask: Bottom-Right only
      final targetMask = CollisionBitmask(2, 2, [false, false, false, true]);

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              // Target at (0,0)
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(width: 2, height: 2, key: targetKey),
              ),
              // Child at (0,0) - AABB overlaps fully, but pixels don't
              FlareHitbox(
                targetKey: targetKey,
                mask: childMask,
                targetMask: targetMask,
                onCollision: () => collisionDetected = true,
                child: const SizedBox(width: 2, height: 2),
              ),
            ],
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration.zero);

      expect(collisionDetected, false);
    });

    testWidgets('Collision detected with offset', (tester) async {
      bool collisionDetected = false;
      final targetKey = GlobalKey();

      // Child: 3x3, center is solid
      // F F F
      // F T F
      // F F F
      final childMask = CollisionBitmask(3, 3, [
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
      ]);

      // Target: 3x3, center is solid
      final targetMask = CollisionBitmask(3, 3, [
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              // Target at (0,0)
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(width: 3, height: 3, key: targetKey),
              ),
              // Child at (1,1)
              // Child's center (1,1) in its local coords will be at global (2,2)
              // Target's center (1,1) in its local coords is at global (1,1)
              // No overlap of solid pixels expected if we shift by 1?
              // Wait.
              // Target is at 0,0. Target center solid is at global 1,1.
              // Child is at 1,0. Child center (1,1) is at global 2,1.
              // Let's simply test "No Collision" with offset first.
              Positioned(
                top: 1,
                left: 0,
                child: FlareHitbox(
                  targetKey: targetKey,
                  mask: childMask,
                  targetMask: targetMask,
                  onCollision: () => collisionDetected = true,
                  child: const SizedBox(width: 3, height: 3),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration.zero);
      expect(collisionDetected, false, reason: "Centers should not overlap");
    });

    group('Directional Collision', () {
      // 3x3 Cross Mask
      // F T F
      // T T T
      // F T F
      final crossMask = CollisionBitmask(3, 3, [
        false,
        true,
        false,
        true,
        true,
        true,
        false,
        true,
        false,
      ]);

      testWidgets('Detects collision from LEFT', (tester) async {
        bool collision = false;
        final targetKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: SizedBox(key: targetKey, width: 3, height: 3),
                ),
                // Approaches from Left. Target is at x=10.
                // Child at x=8.
                // Child X range: 8..11. Target X range: 10..13.
                // Intersection: 10..11.
                // Child local X at overlap: 10-8 = 2 (Rightmost pixel).
                // Target local X at overlap: 10-10 = 0 (Leftmost pixel).
                // CrossMask right col: F T F (middle is solid)
                // CrossMask left col: F T F (middle is solid)
                // They should collide at y=11 (Local 1).
                Positioned(
                  left: 8,
                  top: 10,
                  child: FlareHitbox(
                    targetKey: targetKey,
                    mask: crossMask,
                    targetMask: crossMask,
                    onCollision: () => collision = true,
                    child: SizedBox(width: 3, height: 3),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pump(Duration.zero); // Post frame
        expect(collision, true, reason: "Should collide from Left");
      });

      testWidgets('Detects collision from RIGHT', (tester) async {
        bool collision = false;
        final targetKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: SizedBox(key: targetKey, width: 3, height: 3),
                ),
                // Approaches from Right. Child at x=12.
                // Child X range: 12..15. Target X range: 10..13.
                // Intersection: 12..13.
                // Child local X at overlap: 12-12 = 0.
                // Target local X at overlap: 12-10 = 2.
                // Both Left and Right cols of CrossMask are solid at middle row.
                Positioned(
                  left: 12,
                  top: 10,
                  child: FlareHitbox(
                    targetKey: targetKey,
                    mask: crossMask,
                    targetMask: crossMask,
                    onCollision: () => collision = true,
                    child: SizedBox(width: 3, height: 3),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pump(Duration.zero);
        expect(collision, true, reason: "Should collide from Right");
      });

      testWidgets('Detects collision from TOP', (tester) async {
        bool collision = false;
        final targetKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: SizedBox(key: targetKey, width: 3, height: 3),
                ),
                // Approaches from Top. Child at y=8.
                // Child Y range: 8..11. Target Y range: 10..13.
                // Intersection Y: 10..11.
                // Child Local Y: 10-8 = 2 (Bottom Row).
                // Target Local Y: 10-10 = 0 (Top Row).
                // CrossMask Bottom Row: F T F.
                // CrossMask Top Row: F T F.
                // Both solid at middle x (Local 1).
                Positioned(
                  left: 10,
                  top: 8,
                  child: FlareHitbox(
                    targetKey: targetKey,
                    mask: crossMask,
                    targetMask: crossMask,
                    onCollision: () => collision = true,
                    child: SizedBox(width: 3, height: 3),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pump(Duration.zero);
        expect(collision, true, reason: "Should collide from Top");
      });

      testWidgets('Detects collision from BOTTOM', (tester) async {
        bool collision = false;
        final targetKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: SizedBox(key: targetKey, width: 3, height: 3),
                ),
                // Child at y=12.
                // Child Y range: 12..15. Target Y range: 10..13.
                // Intersection Y: 12..13.
                // Child Local Y: 0. Target Local Y: 2.
                Positioned(
                  left: 10,
                  top: 12,
                  child: FlareHitbox(
                    targetKey: targetKey,
                    mask: crossMask,
                    targetMask: crossMask,
                    onCollision: () => collision = true,
                    child: SizedBox(width: 3, height: 3),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pump(Duration.zero);
        expect(collision, true, reason: "Should collide from Bottom");
      });
    });

    group('Rotation Collision', () {
      testWidgets(
        'Detects collision with 180 degree rotation (Should be FALSE if rotation respected)',
        (tester) async {
          bool collision = false;
          final targetKey = GlobalKey();

          // 4x4 Two Halves
          // Top Half: Solid
          // Bottom Half: Empty
          // T T T T
          // T T T T
          // F F F F
          // F F F F
          final topSolidMask = CollisionBitmask(4, 4, [
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ]);

          await tester.pumpWidget(
            MaterialApp(
              home: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: SizedBox(key: targetKey, width: 4, height: 4),
                  ),
                  // Child at (0,0).
                  // Both Child and Target use the TopSolidMask.
                  // Child is ROTATED 180 degrees.
                  // So physically, Child has solid pixels on BOTTOM.
                  // Target has solid pixels on TOP.
                  // They occupy the same 4x4 square.
                  // Overlap is full 4x4.
                  // Pixels check:
                  // Target(x,y) is solid for y < 2.
                  // Child(x,y) (physically) is solid for y >= 2.
                  // NO overlap of solid pixels should occur.
                  Positioned(
                    left: 0,
                    top: 0,
                    child: FlareHitbox(
                      targetKey: targetKey,
                      mask: topSolidMask,
                      targetMask: topSolidMask,
                      onCollision: () => collision = true,
                      child: Transform.rotate(
                        angle: 3.14159, // 180 degrees
                        child: SizedBox(width: 4, height: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          await tester.pump(Duration.zero);
          // Current implementation ignores rotation, checks local (x,y) against mask directly.
          // It sees mask(0,0) as True for both.
          // So it will be TRUE (Collision).
          // Correct implementation should be FALSE.
          expect(
            collision,
            false,
            reason: "Masks should not overlap when rotated 180",
          );
        },
      );
    });
  });
}
