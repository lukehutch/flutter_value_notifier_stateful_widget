import 'package:flutter/material.dart';

import './safe_set_state.dart';

/// Class that wraps a [ValueNotifier] and with a [StatefulWidget] to allow
/// for value changes to trigger a build. The type parameter [T] is the type
/// of the value of the [ValueNotifier].
class ValueNotifierStatefulWidget<T> extends StatefulWidget {
  /// The initial value of the [ValueNotifier].
  final T initialValue;

  /// The build function. Only modify the [ValueNotifier] in event handlers,
  /// not in the `builder` function itself.
  final Widget Function(BuildContext context, ValueNotifier<T> valueNotifier)
      builder;

  const ValueNotifierStatefulWidget({
    super.key,
    required this.initialValue,
    required this.builder,
  });

  @override
  State<ValueNotifierStatefulWidget<T>> createState() =>
      _ValueNotifierStatefulWidgetState<T>();
}

class _ValueNotifierStatefulWidgetState<T>
    extends State<ValueNotifierStatefulWidget<T>> {
  late ValueNotifier<T> valueNotifier;

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(widget.initialValue)
      // Call `safeSetState` rather than `setState`, because the widget may no
      // longer be mounted when the value changes. Also, the ValueNotifier's
      // value should not be modified during `build`, but if it is, then
      // safeSetState will schedule a post-frame callback rather than calling
      // `setState` immediately (`setState` cannot be called during `build`).
      ..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, valueNotifier);
}
