import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'contest_realtime_service.dart';

/// Supabase Realtime Broadcast implementation of [ContestRealtimeService].
///
/// One private channel per event, `event:<id>:contests`, read-only for the
/// app: the `realtime.messages` policy lets any signed-in user read a topic
/// belonging to an approved event and lets nobody but the backend publish.
///
/// Same auth rule as `SupabaseDmRealtimeService`: the socket's access token
/// must be the user's JWT **before** the join, otherwise Realtime evaluates
/// the policy as `anon` and refuses. A refused or timed-out join is retried
/// with backoff; while a channel is down [isLive] is false and the bloc polls.
@LazySingleton(as: ContestRealtimeService)
class SupabaseContestRealtimeService implements ContestRealtimeService {
  final SupabaseClient supabaseClient;

  final _boards = StreamController<Map<String, dynamic>>.broadcast();
  final _status = StreamController<Map<String, dynamic>>.broadcast();

  final Map<String, _EventChannel> _channels = {};

  SupabaseContestRealtimeService(this.supabaseClient);

  @override
  Stream<Map<String, dynamic>> get boards => _boards.stream;

  @override
  Stream<Map<String, dynamic>> get statusChanges => _status.stream;

  @override
  bool isLive(String eventId) => _channels[eventId]?.live ?? false;

  @override
  Future<void> subscribe(String eventId) async {
    final existing = _channels[eventId];
    if (existing != null) {
      existing.refs++;
      return;
    }
    final entry = _EventChannel();
    _channels[eventId] = entry;
    await _join(eventId, entry);
  }

  @override
  Future<void> unsubscribe(String eventId) async {
    final entry = _channels[eventId];
    if (entry == null) return;
    entry.refs--;
    if (entry.refs > 0) return;
    _channels.remove(eventId);
    await _teardown(entry);
  }

  @override
  Future<void> disconnect() async {
    final entries = _channels.values.toList();
    _channels.clear();
    for (final entry in entries) {
      await _teardown(entry);
    }
  }

  Future<void> _join(String eventId, _EventChannel entry) async {
    // Must precede the join: the join payload snapshots `socket.accessToken`.
    if (!await _applyAuth()) {
      entry.live = false;
      _scheduleRetry(eventId, entry);
      return;
    }
    // Torn down while we were awaiting the token.
    if (_channels[eventId] != entry) return;

    final channel = supabaseClient.channel(
      'event:$eventId:contests',
      opts: const RealtimeChannelConfig(private: true),
    );
    channel
      ..onBroadcast(
        event: 'board',
        callback: (payload) => _boards.add(Map<String, dynamic>.from(payload)),
      )
      ..onBroadcast(
        event: 'status',
        callback: (payload) => _status.add(Map<String, dynamic>.from(payload)),
      );
    entry.channel = channel;

    channel.subscribe((status, error) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          entry.live = true;
          entry.retryAttempt = 0;
        case RealtimeSubscribeStatus.channelError:
        case RealtimeSubscribeStatus.timedOut:
          debugPrint('📡 contest realtime (event:$eventId) $status: $error');
          entry.live = false;
          _scheduleRetry(eventId, entry);
        case RealtimeSubscribeStatus.closed:
          entry.live = false;
      }
    });
  }

  Future<bool> _applyAuth() async {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token == null) return false;
    try {
      await supabaseClient.realtime.setAuth(token);
      return true;
    } catch (e) {
      debugPrint('📡 contest realtime auth failed: $e');
      return false;
    }
  }

  /// Tears the failed channel down and rejoins with whatever token is current
  /// by then — a join refused because the JWT had just expired succeeds once
  /// supabase_flutter has refreshed it.
  void _scheduleRetry(String eventId, _EventChannel entry) {
    if (entry.retryTimer != null) return;
    final delay = Duration(seconds: 1 << entry.retryAttempt.clamp(0, 5));
    entry.retryAttempt++;
    entry.retryTimer = Timer(delay, () async {
      entry.retryTimer = null;
      // Unsubscribed meanwhile: nothing to rejoin.
      if (_channels[eventId] != entry) return;
      final stale = entry.channel;
      entry.channel = null;
      if (stale != null) await supabaseClient.removeChannel(stale);
      await _join(eventId, entry);
    });
  }

  Future<void> _teardown(_EventChannel entry) async {
    entry.retryTimer?.cancel();
    entry.retryTimer = null;
    entry.live = false;
    final channel = entry.channel;
    entry.channel = null;
    if (channel != null) await supabaseClient.removeChannel(channel);
  }
}

class _EventChannel {
  RealtimeChannel? channel;
  int refs = 1;
  bool live = false;
  Timer? retryTimer;
  int retryAttempt = 0;
}
