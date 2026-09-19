import 'dart:async';

import 'package:flutter/widgets.dart';

/// Completes once nothing is covering [route] any more. That is when the
/// transition of the route popped off it has finished, or right away if
/// nothing is covering it.
///
/// The map needs this. `push` hands back its result the moment `pop` is
/// called, while the popped page still covers the map. On iOS, Flutter takes a
/// platform view it isn't drawing out of the view hierarchy, so the Mapbox
/// view is detached from its window at that moment, and a camera animation
/// started then is dropped. The keyboard closing on the popped page also
/// resizes the map during that window. Waiting for the transition to end
/// avoids both.
///
/// [timeout] is a safety net: if the animation is never reported as finished
/// (a route removed without a transition, say), carry on anyway rather than
/// swallow the user's selection.
Future<void> routeUncovered(
  ModalRoute<dynamic>? route, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final covering = route?.secondaryAnimation;
  if (covering == null || covering.status == AnimationStatus.dismissed) return;

  final done = Completer<void>();
  void onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !done.isCompleted) {
      done.complete();
    }
  }

  covering.addStatusListener(onStatus);
  try {
    await done.future.timeout(timeout, onTimeout: () {});
  } finally {
    covering.removeStatusListener(onStatus);
  }
}
