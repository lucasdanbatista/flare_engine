import 'package:flare_engine/flare_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlareAnimation', () {
    testWidgets('advances frame after ticksPerFrame updates', (tester) async {
      final notifier = FlareFrameNotifier();
      int? reportedFrame;

      Widget buildWidget() {
        return FlareFrameNotifierProvider(
          frameNotifier: notifier,
          child: FlareAnimation(
            maxFrames: 3,
            ticksPerFrame: 2,
            builder: (context, frame) {
              reportedFrame = frame;
              return Container();
            },
          ),
        );
      }

      // Initial build
      await tester.pumpWidget(buildWidget());
      expect(reportedFrame, 0, reason: 'Initial frame should be 0');

      // Update 1: tickCount -> 1. 1 < 2. Frame stays 0.
      await tester.pumpWidget(buildWidget());
      expect(reportedFrame, 0, reason: 'After 1 tick, frame should still be 0');

      // Update 2: tickCount -> 2. 2 >= 2. tickCount resetting to 0. Frame -> 1.
      await tester.pumpWidget(buildWidget());
      expect(
        reportedFrame,
        1,
        reason: 'After 2 ticks, frame should advance to 1',
      );

      // Update 3: tickCount -> 1. Frame stays 1.
      await tester.pumpWidget(buildWidget());
      expect(
        reportedFrame,
        1,
        reason: 'After 3 ticks, frame should still be 1',
      );

      // Update 4: tickCount -> 2. Frame -> 2.
      await tester.pumpWidget(buildWidget());
      expect(
        reportedFrame,
        2,
        reason: 'After 4 ticks, frame should advance to 2',
      );

      // Update 5: tickCount -> 1. Frame stays 2.
      await tester.pumpWidget(buildWidget());
      expect(
        reportedFrame,
        2,
        reason: 'After 5 ticks, frame should still be 2',
      );

      // Update 6: tickCount -> 2. Frame -> 3 -> wraps to 0.
      await tester.pumpWidget(buildWidget());
      expect(reportedFrame, 0, reason: 'After 6 ticks, frame should wrap to 0');
    });
  });
}
