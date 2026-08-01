import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presence_service.dart';

/// Supabase Realtime Presence implementation of [PresenceService].
///
/// The channel is private, so joining and tracking are both checked against
/// the `presence:online` policies on `realtime.messages`
/// (see `supabase/migrations/20260801000000_realtime_authorization.sql`).
///
/// The viewer's own id is used as the presence key, so `presenceState()` keys
/// map straight to user ids with no payload digging. The tracked payload is
/// deliberately tiny — presence is for slow-changing state; anything chatty
/// belongs on Broadcast.
@LazySingleton(as: PresenceService)
class SupabasePresenceService implements PresenceService {
  final SupabaseClient supabaseClient;

  static const _topic = 'presence:online';

  final _updates = StreamController<UserPresence>.broadcast();

  RealtimeChannel? _channel;
  Set<String> _online = {};

  /// Rejoin backoff for a refused/timed-out subscription.
  Timer? _retryTimer;
  int _retryAttempt = 0;

  SupabasePresenceService(this.supabaseClient);

  @override
  Stream<UserPresence> get updates => _updates.stream;

  @override
  Set<String> get onlineUserIds => Set.unmodifiable(_online);

  @override
  void connect() {
    if (_channel != null) return;
    unawaited(_open());
  }

  Future<void> _open() async {
    if (_channel != null) return;
    final myId = supabaseClient.auth.currentUser?.id;
    if (myId == null) return;

    // The join payload snapshots `socket.accessToken`, which starts out as the
    // publishable key. Joining with it makes Realtime evaluate the policies as
    // `anon`, and this channel's are `to authenticated` — so the token has to
    // be on the socket before subscribing, not merely soon after.
    if (!await _applyAuth()) return;
    if (_channel != null) return;

    final channel = supabaseClient.channel(
      _topic,
      // Keying by user id collapses a user's multiple devices into one entry.
      opts: RealtimeChannelConfig(key: myId, private: true),
    );
    _channel = channel;

    // Sync carries the full state; join/leave are deltas of it. Recomputing
    // from the full state on every event keeps one code path and can't drift.
    channel
        .onPresenceSync((_) => _syncFrom(channel))
        .onPresenceJoin((_) => _syncFrom(channel))
        .onPresenceLeave((_) => _syncFrom(channel));

    channel.subscribe((status, error) async {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          _retryAttempt = 0;
          await channel.track({'online_at': DateTime.now().toIso8601String()});
        case RealtimeSubscribeStatus.channelError:
        case RealtimeSubscribeStatus.timedOut:
          debugPrint('📡 presence $status: $error');
          _scheduleRetry();
        case RealtimeSubscribeStatus.closed:
          break;
      }
    });
  }

  /// Puts the signed-in user's JWT on the realtime socket. False when there is
  /// no session yet — `main.dart` calls [connect] again once one exists.
  Future<bool> _applyAuth() async {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token == null) return false;
    try {
      await supabaseClient.realtime.setAuth(token);
      return true;
    } catch (e) {
      debugPrint('📡 presence auth failed: $e');
      return false;
    }
  }

  /// Rebuilds the subscription with whatever token is current by then, so a
  /// join refused because the JWT had just expired recovers on its own.
  void _scheduleRetry() {
    if (_retryTimer != null) return;
    final delay = Duration(seconds: 1 << (_retryAttempt.clamp(0, 5)));
    _retryAttempt++;
    _retryTimer = Timer(delay, () async {
      _retryTimer = null;
      final stale = _channel;
      _channel = null;
      if (stale != null) await supabaseClient.removeChannel(stale);
      await _open();
    });
  }

  @override
  Future<void> disconnect() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    final channel = _channel;
    _channel = null;
    if (channel == null) return;

    // Emit the offline flips ourselves: once the channel is gone no further
    // presence events arrive, and stale online dots would stick.
    final wasOnline = _online;
    _online = {};
    for (final userId in wasOnline) {
      _updates.add(UserPresence(userId: userId, online: false));
    }

    try {
      await channel.untrack();
    } catch (_) {
      // Already gone — removing the channel below is what actually matters.
    }
    await supabaseClient.removeChannel(channel);
  }

  /// Diffs the channel's presence state against the last one and emits only
  /// the users whose online state actually changed.
  void _syncFrom(RealtimeChannel channel) {
    final next = {
      for (final state in channel.presenceState())
        if (state.presences.isNotEmpty) state.key,
    };

    for (final userId in next.difference(_online)) {
      _updates.add(UserPresence(userId: userId, online: true));
    }
    for (final userId in _online.difference(next)) {
      _updates.add(UserPresence(userId: userId, online: false));
    }
    _online = next;
  }
}
