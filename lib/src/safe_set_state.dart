import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
