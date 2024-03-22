# `ValueNotifierStatefulWidget` for Flutter

This Flutter package provides an extremely simple state management system for Flutter, particularly for use with widgets whose state may change in reaction to an event handler like `onTap`.

`ValueNotifierStatefulWidget` is more or less a merger of the classes `ValueNotifier` and `ValueListenableBuilder` into one class, which manages the lifecycle of the `ValueNotifier` for you.

`ValueNotifierStatefulWidget` allows you to avoid having to create a new `StatefulWidget` class every time you need to have the display of the widget respond to a simple state change.

## Usage

```dart
ValueNotifierStatefulWidget<bool>(
  initialValue: false,
  builder: (context, loadingValueNotifier) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.blue.shade200,
        disabledForegroundColor: Colors.white,
      ),
      // Button icon: when loading, show a spinner, otherwise show a
      // checkbox icon
      icon: loadingValueNotifier.value
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Icon(
              Icons.check,
              color: Colors.white,
            ),
      // Button text
      label: const Text(
        'Submit',
        style: TextStyle(fontSize: 15),
      ),
      // Disable the button when loading
      onPressed: loadingValueNotifier.value
          ? null
          : () async {
              try {
                // Set loading state to true
                loadingValueNotifier.value = true;
                // Call asynchronous function
                await doSomethingAsynchronously();
              } finally {
                // Set loading state to false (done inside a finally
                // block in case the async function throws an error)
                loadingValueNotifier.value = false;
              }
            },
    );
  },
);
```

This library also exposes `safeSetState` as an extension on `State`, which allows you to call `setState` anytime, including after awaiting an async function in a handler callback, without running into problems with the widget no longer being mounted. `safeSetState` is called when the `ValueNotifier`'s value changes, which is important for making state updates in asynchronous functions, as shown above.

```dart
extension SafeUpdateState on State {
  void safeSetState(void Function() updaterFunction) {
    void callSetState() {
      // Can only call setState if mounted
      if (mounted) {
        // ignore: invalid_use_of_protected_member
        setState(updaterFunction);
      }
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // Currently building, can't call setState -- add post-frame callback
      SchedulerBinding.instance.addPostFrameCallback((_) => callSetState());
    } else {
      callSetState();
    }
  }
}
```
