import 'package:flutter/widgets.dart';

extension FlareFrameNotifierBuildContextExtension on BuildContext {
  double get delta {
    final delta =
        dependOnInheritedWidgetOfExactType<FlareFrameNotifierProvider>()!
            .frameNotifier
            .delta;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }
}

class FlareFrameNotifier extends ChangeNotifier {
  var _delta = Duration.zero;

  Duration get delta => _delta;

  static FlareFrameNotifier of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<FlareFrameNotifierProvider>()
        ?.frameNotifier;
    assert(result != null, 'No FlareFrameNotifier found in context');
    return result!;
  }

  void tick(Duration delta) {
    _delta = delta;
    notifyListeners();
  }
}

class FlareFrameNotifierProvider extends InheritedWidget {
  final FlareFrameNotifier frameNotifier;

  const FlareFrameNotifierProvider({
    super.key,
    required this.frameNotifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(FlareFrameNotifierProvider old) =>
      frameNotifier != old.frameNotifier;
}
