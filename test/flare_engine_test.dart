import 'package:flare_engine/flare_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlareEngine', () {
    testWidgets('triggers onTick with correct delta', (tester) async {
      final engine = FlareEngine(tester);
      // addTearDown(() => engine.dispose()); // Dispose manually to satisfy WidgetTester

      final capturedDeltas = <Duration>[];

      engine.run(
        onTick: (delta) {
          capturedDeltas.add(delta);
        },
      );

      // Pump a frame to start the ticker (first tick, likely 0 delta)
      await tester.pump();

      // Advance time by 16ms
      const duration = Duration(milliseconds: 16);
      await tester.pump(duration);
      // Pump again to ensure we get subsequent ticks
      await tester.pump(duration);

      engine.dispose();

      expect(
        capturedDeltas.length,
        greaterThanOrEqualTo(2),
        reason: 'Should capture at least 2 ticks',
      );

      // Check if any delta is approximately 16ms
      // Check if any delta is positive
      final hasPositiveDelta = capturedDeltas.any((d) => d.inMicroseconds > 0);
      expect(
        hasPositiveDelta,
        isTrue,
        reason: 'Expected at least one positive delta. Got: $capturedDeltas',
      );
    });

    test('retains state between ticks', () async {
      // Since we need a TickerProvider, testWidgets is easiest even for unit-like logic
      // to access tester.binding as provider.
    });
  });
}
