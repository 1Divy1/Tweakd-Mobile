import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// One "slow down" message for the user.
class RateLimitNotice extends Equatable {
  /// How long to wait, or null when the backend didn't say.
  final Duration? retryAfter;

  const RateLimitNotice({this.retryAfter});

  @override
  List<Object?> get props => [retryAfter];
}

/// The app-wide funnel for rate-limit hits.
///
/// Every `429` is reported here by `RateLimitInterceptor`; `RateLimitBanner`
/// listens to [notices] and tells the user. The notifier decides *whether* a
/// hit is worth a message:
///
/// * A burst of refused requests (a screen firing several calls at once)
///   collapses into one notice instead of one per request.
/// * A limit only background work can hit (see [_backgroundLimits]) is never
///   shown — the user didn't do anything to cause it.
@lazySingleton
class RateLimitNotifier {
  /// Limits that only background work consumes. `devices` is push-token
  /// registration, which runs on app start and sign-in without the user
  /// asking for anything; telling them to slow down would make no sense.
  static const _backgroundLimits = {'devices'};

  /// Hits closer together than this are treated as the same burst.
  static const _burstWindow = Duration(seconds: 3);

  /// Slack for comparing two waits. `Retry-After` is rounded up to whole
  /// seconds, so parallel requests refused by the same limit can differ by one.
  static const _waitTolerance = Duration(seconds: 2);

  final DateTime Function() _now;
  final _controller = StreamController<RateLimitNotice>.broadcast();

  DateTime? _lastShownAt;
  DateTime? _lastWaitEndsAt;

  RateLimitNotifier() : _now = DateTime.now;

  @visibleForTesting
  RateLimitNotifier.withClock(this._now);

  Stream<RateLimitNotice> get notices => _controller.stream;

  void report({Duration? retryAfter, String? limit}) {
    if (limit != null && _backgroundLimits.contains(limit)) return;

    final now = _now();
    final waitEndsAt = now.add(retryAfter ?? Duration.zero);

    final lastShownAt = _lastShownAt;
    final lastWaitEndsAt = _lastWaitEndsAt;
    if (lastShownAt != null &&
        lastWaitEndsAt != null &&
        now.difference(lastShownAt) < _burstWindow &&
        // A materially longer wait inside the burst (e.g. the general limit
        // then the posting limit) is still news, so it replaces the message.
        !waitEndsAt.isAfter(lastWaitEndsAt.add(_waitTolerance))) {
      return;
    }

    _lastShownAt = now;
    _lastWaitEndsAt = waitEndsAt;
    _controller.add(RateLimitNotice(retryAfter: retryAfter));
  }
}
