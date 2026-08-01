import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dm_realtime_service.dart';

/// Supabase Realtime Broadcast implementation of [DmRealtimeService].
///
/// Topics are private, so every join and publish is checked against the RLS
/// policies on `realtime.messages`
/// (see `supabase/migrations/20260801000000_realtime_authorization.sql`):
///
/// * `user:<my_id>` — subscribed for the whole session, **read**. Nobody else
///   can listen on it, and it is the only channel this client joins.
/// * `user:<peer_id>` — never joined. Realtime refuses a join outright when
///   the read policy denies it, and by design a peer's topic is unreadable, so
///   a "write-only join" is not a thing. Outbound events are published over
///   Realtime's HTTP broadcast endpoint instead, which needs no membership.
///   Only the receive path needs a socket, and that one is the viewer's own
///   topic.
///
/// The socket's access token is applied here rather than left to
/// supabase_flutter: it seeds `RealtimeClient.accessToken` with the **publishable
/// key**, and only replaces it when an auth event happens to fire before the
/// first join. Joining with the publishable key makes Realtime evaluate the RLS
/// policies as `anon`, so every `to authenticated` policy denies and the join
/// comes back as "You do not have permissions to read from this Channel topic".
@LazySingleton(as: DmRealtimeService)
class SupabaseDmRealtimeService implements DmRealtimeService {
  final SupabaseClient supabaseClient;

  final _events = StreamController<DmRealtimeEvent>.broadcast();

  /// The viewer's own inbound topic.
  RealtimeChannel? _selfChannel;

  /// Outbound topics, keyed by peer id. These are never subscribed — they only
  /// exist so `sendBroadcastMessage` has a channel to build the HTTP request
  /// from. Cached so a chat's typing signals don't rebuild one per keystroke.
  final Map<String, RealtimeChannel> _peerChannels = {};

  /// Rejoin backoff for a refused/timed-out subscription.
  Timer? _retryTimer;
  int _retryAttempt = 0;

  SupabaseDmRealtimeService(this.supabaseClient);

  String? get _myId => supabaseClient.auth.currentUser?.id;

  @override
  Stream<DmRealtimeEvent> get events => _events.stream;

  // ------------------------------------------------------------- lifecycle

  @override
  void connect() {
    if (_selfChannel != null) return;
    unawaited(_open());
  }

  Future<void> _open() async {
    if (_selfChannel != null) return;
    final myId = _myId;
    if (myId == null) return;

    // Must happen before the join: the join payload snapshots
    // `socket.accessToken` and the server caches the policies it derives from
    // it for the life of the connection.
    if (!await _applyAuth()) return;
    if (_selfChannel != null) return;

    final channel = supabaseClient.channel(
      'user:$myId',
      opts: const RealtimeChannelConfig(private: true),
    );

    for (final event in _inboundEvents) {
      channel.onBroadcast(
        event: event,
        callback: (payload) => _onBroadcast(event, payload),
      );
    }

    _selfChannel = channel;
    channel.subscribe((status, error) {
      switch (status) {
        case RealtimeSubscribeStatus.subscribed:
          _retryAttempt = 0;
        case RealtimeSubscribeStatus.channelError:
        case RealtimeSubscribeStatus.timedOut:
          debugPrint('📡 DM realtime (user:$myId) $status: $error');
          _scheduleRetry();
        case RealtimeSubscribeStatus.closed:
          break;
      }
    });
  }

  /// Puts the signed-in user's JWT on the realtime socket. Returns false when
  /// there is no session to authenticate with, in which case joining would be
  /// pointless — the sign-in listener in `main.dart` calls [connect] again.
  Future<bool> _applyAuth() async {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token == null) return false;
    try {
      await supabaseClient.realtime.setAuth(token);
      return true;
    } catch (e) {
      debugPrint('📡 DM realtime auth failed: $e');
      return false;
    }
  }

  /// Tears the failed subscription down and tries again with whatever token is
  /// current by then — a join refused because the JWT had just expired
  /// succeeds on the next attempt, once supabase_flutter has refreshed it.
  void _scheduleRetry() {
    if (_retryTimer != null) return;
    final delay = Duration(seconds: 1 << (_retryAttempt.clamp(0, 5)));
    _retryAttempt++;
    _retryTimer = Timer(delay, () async {
      _retryTimer = null;
      final stale = _selfChannel;
      _selfChannel = null;
      if (stale != null) await supabaseClient.removeChannel(stale);
      await _open();
    });
  }

  @override
  Future<void> disconnect() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    final channels = [
      ?_selfChannel,
      ..._peerChannels.values,
    ];
    _selfChannel = null;
    _peerChannels.clear();
    for (final channel in channels) {
      await supabaseClient.removeChannel(channel);
    }
  }

  // -------------------------------------------------------------- outbound

  @override
  void broadcastMessageCreated({
    required String peerId,
    required String conversationId,
    required Map<String, dynamic> message,
  }) =>
      _publish(
        peerId: peerId,
        event: 'message.created',
        payload: {
          'conversation_id': conversationId,
          'message': message,
        },
        toSelfToo: true,
      );

  @override
  void broadcastMessageDeleted({
    required String peerId,
    required String conversationId,
    required String messageId,
  }) =>
      _publish(
        peerId: peerId,
        event: 'message.deleted',
        payload: {
          'conversation_id': conversationId,
          'message_id': messageId,
        },
        toSelfToo: true,
      );

  @override
  void broadcastConversationRead({
    required String peerId,
    required String conversationId,
    String? lastReadMessageId,
  }) {
    final myId = _myId;
    if (myId == null) return;
    _publish(
      peerId: peerId,
      event: 'conversation.read',
      payload: {
        'conversation_id': conversationId,
        'user_id': myId,
        'last_read_message_id': ?lastReadMessageId,
      },
    );
  }

  @override
  void sendTyping({
    required String peerId,
    required String conversationId,
    required bool isTyping,
  }) {
    final myId = _myId;
    if (myId == null) return;
    _publish(
      peerId: peerId,
      event: 'typing',
      payload: {
        'conversation_id': conversationId,
        'user_id': myId,
        'typing': isTyping,
      },
    );
  }

  /// Fire-and-forget publish to the peer's topic, optionally mirrored onto the
  /// viewer's own topic so their other devices update too. Failures are logged
  /// and swallowed: the write already succeeded, and the peer picks the change
  /// up on their next load.
  void _publish({
    required String peerId,
    required String event,
    required Map<String, dynamic> payload,
    bool toSelfToo = false,
  }) =>
      unawaited(_publishNow(
        peerId: peerId,
        event: event,
        payload: payload,
        toSelfToo: toSelfToo,
      ));

  Future<void> _publishNow({
    required String peerId,
    required String event,
    required Map<String, dynamic> payload,
    required bool toSelfToo,
  }) async {
    // The peer topic is delivered over HTTP, which authenticates with the same
    // `socket.accessToken` the socket uses — so it needs the viewer's JWT just
    // as much as a join does, and a send can happen before [connect] has run.
    if (!await _applyAuth()) return;
    await _send(_peerChannel(peerId), event, payload, peerId);
    final self = _selfChannel;
    if (toSelfToo && self != null) await _send(self, event, payload, null);
  }

  Future<void> _send(
    RealtimeChannel channel,
    String event,
    Map<String, dynamic> payload,
    String? peerIdToEvictOnError,
  ) async {
    try {
      // The payload map is mutated by the client (it stamps `type` and
      // `event`), so hand over a copy — callers reuse theirs for the mirror.
      final response = await channel.sendBroadcastMessage(
        event: event,
        payload: Map<String, dynamic>.from(payload),
      );
      // A rejected push (RLS, or an HTTP error on the unjoined peer topic)
      // comes back as a status, not an exception.
      if (response == ChannelResponse.ok) return;
      debugPrint('📡 DM realtime publish "$event" -> $response');
    } catch (e) {
      debugPrint('📡 DM realtime publish "$event" failed: $e');
    }
    // Drop the channel so the next publish rebuilds it rather than pushing
    // into a dead one for the rest of the session.
    if (peerIdToEvictOnError != null) {
      final stale = _peerChannels.remove(peerIdToEvictOnError);
      if (stale != null) unawaited(supabaseClient.removeChannel(stale));
    }
  }

  /// How many outbound peer topics to keep around. Only the open chat ever
  /// publishes, so one would do — a few spare slots just avoid rebuilding
  /// while the user flicks between recent chats. `channel()` always appends a
  /// new instance to the client's channel list, so an unbounded map would grow
  /// it by one entry per chat opened.
  static const _maxPeerChannels = 3;

  /// Outbound channel for [peerId]. Deliberately **not** subscribed: the read
  /// policy denies this topic to anyone but its owner, and Realtime rejects a
  /// join it cannot grant read on. Leaving it unjoined makes
  /// `sendBroadcastMessage` deliver over Realtime's HTTP endpoint, which
  /// authorizes the publish against the INSERT policy on its own.
  RealtimeChannel _peerChannel(String peerId) {
    final existing = _peerChannels.remove(peerId);
    if (existing != null) {
      // Re-insert so the most recently used entry is last.
      return _peerChannels[peerId] = existing;
    }

    while (_peerChannels.length >= _maxPeerChannels) {
      final oldest = _peerChannels.remove(_peerChannels.keys.first);
      if (oldest != null) unawaited(supabaseClient.removeChannel(oldest));
    }

    final channel = supabaseClient.channel(
      'user:$peerId',
      opts: const RealtimeChannelConfig(private: true),
    );
    _peerChannels[peerId] = channel;
    return channel;
  }

  // --------------------------------------------------------------- inbound

  static const _inboundEvents = [
    'message.created',
    'message.deleted',
    'conversation.read',
    'typing',
  ];

  void _onBroadcast(String event, Map<String, dynamic> raw) {
    // Broadcast payloads arrive either flat or wrapped in a `payload` key
    // depending on the server version — accept both rather than betting on one.
    final nested = raw['payload'];
    final json = nested is Map<String, dynamic> ? nested : raw;

    final decoded = _decode(event, json);
    if (decoded != null) _events.add(decoded);
  }

  /// Every field is type-checked before use — a payload is untrusted input,
  /// and one malformed broadcast must never tear down the stream.
  DmRealtimeEvent? _decode(String event, Map<String, dynamic> json) {
    final conversationId = json['conversation_id'];
    final userId = json['user_id'];

    switch (event) {
      case 'message.created':
        final message = json['message'];
        if (conversationId is! String || message is! Map<String, dynamic>) {
          return null;
        }
        return DmMessageCreatedEvent(
          conversationId: conversationId,
          message: message,
        );
      case 'message.deleted':
        final messageId = json['message_id'];
        if (conversationId is! String || messageId is! String) return null;
        return DmMessageDeletedEvent(
          conversationId: conversationId,
          messageId: messageId,
        );
      case 'conversation.read':
        if (conversationId is! String || userId is! String) return null;
        final lastRead = json['last_read_message_id'];
        return DmConversationReadEvent(
          conversationId: conversationId,
          userId: userId,
          lastReadMessageId: lastRead is String ? lastRead : null,
        );
      case 'typing':
        final typing = json['typing'];
        if (conversationId is! String ||
            userId is! String ||
            typing is! bool) {
          return null;
        }
        return DmTypingEvent(
          conversationId: conversationId,
          userId: userId,
          isTyping: typing,
        );
      default:
        return null;
    }
  }
}
