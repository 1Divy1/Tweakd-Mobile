import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Cold-start timing markers, measured from the top of `main()`.
///
/// Each [mark] prints `⏱ startup +<ms> <label>` and drops an instant event on
/// the DevTools timeline, so a `flutter run --profile` session shows where the
/// launch spends its time. Compiled out of release builds.
///
/// Everything before `main()` — process start, engine and Dart VM boot — is
/// not covered; the OS-level launch-to-first-frame figure (`Displayed` in
/// Android's logcat) is the one that includes it.
abstract final class StartupTrace {
  static final Stopwatch _clock = Stopwatch();
  static final Set<String> _once = {};

  /// Starts the clock. Call first thing in `main()`.
  static void begin() => _clock.start();

  static void mark(String label) {
    if (kReleaseMode || !_clock.isRunning) return;
    developer.Timeline.instantSync('startup: $label');
    debugPrint('⏱ startup +${_clock.elapsedMilliseconds}ms $label');
  }

  /// [mark], but only the first time [label] is seen — for points reached on
  /// every rebuild or every feed load, where only the launch one matters.
  static void markOnce(String label) {
    if (_once.add(label)) mark(label);
  }
}
