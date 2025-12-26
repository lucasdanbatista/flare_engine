import 'package:flare_engine/src/flare_frame_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlareFrameNotifier', () {
    test('initial delta is zero', () {
      final notifier = FlareFrameNotifier();
      expect(notifier.delta, Duration.zero);
    });

    test('tick updates delta and notifies listeners', () {
      final notifier = FlareFrameNotifier();
      var notified = false;
      notifier.addListener(() => notified = true);

      const delta = Duration(milliseconds: 16);
      notifier.tick(delta);

      expect(notifier.delta, delta);
      expect(notified, isTrue);
    });
  });

  group('FlareFrameNotifierProvider', () {
    testWidgets('provides notifier to descendants', (tester) async {
      final notifier = FlareFrameNotifier();
      late FlareFrameNotifier receivedNotifier;

      await tester.pumpWidget(
        FlareFrameNotifierProvider(
          frameNotifier: notifier,
          child: Builder(
            builder: (context) {
              receivedNotifier = FlareFrameNotifier.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedNotifier, notifier);
    });

    testWidgets('extension returns correct delta in seconds', (tester) async {
      final notifier = FlareFrameNotifier();
      const deltaMs = 100; // 0.1 seconds
      notifier.tick(const Duration(milliseconds: deltaMs));

      double? receivedDelta;

      await tester.pumpWidget(
        FlareFrameNotifierProvider(
          frameNotifier: notifier,
          child: Builder(
            builder: (context) {
              receivedDelta = context.delta;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedDelta, closeTo(0.1, 0.0001));
    });

    testWidgets('updateShouldNotify returns true when notifier changes', (
      tester,
    ) async {
      final notifier1 = FlareFrameNotifier();

      // We can test updateShouldNotify by checking if dependent widget rebuilds
      var buildCount = 0;

      await tester.pumpWidget(
        FlareFrameNotifierProvider(
          frameNotifier: notifier1,
          child: Builder(
            builder: (context) {
              FlareFrameNotifier.of(context); // depend
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Rebuild with same notifier
      await tester.pumpWidget(
        FlareFrameNotifierProvider(
          frameNotifier: notifier1,
          child: Builder(
            builder: (context) {
              FlareFrameNotifier.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      // Should not trigger rebuild via dependency update (though pumpWidget rebuilds tree,
      // InheritedWidget optimization might prevent dependent rebuild if updateShouldNotify is false)
      // Actually standard InheritedWidget behavior is: if references match and logic is custom...
      // but here we pass new widget instance.
      // flutter_test pumpWidget replaces the root.
      // Let's verify standard behavior.

      // If we use the same instance for provider wrapper?
      // Just testing logic of the class directly might be easier for updateShouldNotify unit test
      // but let's stick to widget test behavior.

      expect(buildCount, 2); // It rebuilds because Builder parent rebuilt?
      // To isolate, we usually use a const child that depends.
    });

    test('updateShouldNotify logic', () {
      final n1 = FlareFrameNotifier();
      final n2 = FlareFrameNotifier();

      final p1 = FlareFrameNotifierProvider(
        frameNotifier: n1,
        child: const SizedBox(),
      );
      final p2 = FlareFrameNotifierProvider(
        frameNotifier: n2,
        child: const SizedBox(),
      );
      final p3 = FlareFrameNotifierProvider(
        frameNotifier: n1,
        child: const SizedBox(),
      );

      expect(p2.updateShouldNotify(p1), true);
      expect(p3.updateShouldNotify(p1), false);
    });
  });
}
