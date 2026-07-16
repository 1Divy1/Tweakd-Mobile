import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dm_socket_service.dart';

/// STOMP-over-WebSocket implementation of [DmSocketService].
///
/// Connects to `${API_BASE_URL}/ws` (http → ws, https → wss) and subscribes
/// to the user destination `/user/queue/dms`. The Supabase JWT is sent in
/// the connect headers — never in the URL, so it can't leak into server
/// access logs — and is re-read from the current session before every
/// (re)connect attempt, so reconnections after a token refresh keep working.
@LazySingleton(as: DmSocketService)
class StompDmSocketService implements DmSocketService {
  final SupabaseClient supabaseClient;

  final _events = StreamController<DmSocketEvent>.broadcast();

  /// Mutated in [_beforeConnect]; StompConfig holds these by reference, so
  /// updates apply to every subsequent (re)connect attempt.
  final Map<String, String> _stompHeaders = {};
  final Map<String, dynamic> _wsHeaders = {};

  StompClient? _client;

  StompDmSocketService(this.supabaseClient);

  @override
  Stream<DmSocketEvent> get events => _events.stream;

  @override
  void connect() {
    if (_client?.isActive ?? false) return;
    if (supabaseClient.auth.currentSession == null) return;

    final host = dotenv.env['API_BASE_URL'] ?? '';
    if (host.isEmpty) return;

    _client = StompClient(
      config: StompConfig(
        url: '${host.replaceFirst('http', 'ws')}/ws',
        stompConnectHeaders: _stompHeaders,
        webSocketConnectHeaders: _wsHeaders,
        beforeConnect: _beforeConnect,
        onConnect: _onConnect,
        reconnectDelay: const Duration(seconds: 5),
        onWebSocketError: (error) => debugPrint('🔌 DM socket error: $error'),
        onStompError: (frame) =>
            debugPrint('🔌 DM socket STOMP error: ${frame.body}'),
      ),
    );
    _client!.activate();
  }

  @override
  Future<void> disconnect() async {
    final client = _client;
    _client = null;
    client?.deactivate();
  }

  Future<void> _beforeConnect() async {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token == null) return;
    _stompHeaders['Authorization'] = 'Bearer $token';
    _wsHeaders['Authorization'] = 'Bearer $token';
  }

  void _onConnect(StompFrame frame) {
    _client?.subscribe(
      destination: '/user/queue/dms',
      callback: _onFrame,
    );
  }

  @override
  void sendTyping({required String conversationId, required bool isTyping}) {
    final client = _client;
    if (client == null || !client.connected) return;
    client.send(
      destination: '/app/dms/typing',
      body: jsonEncode({
        'conversation_id': conversationId,
        'typing': isTyping,
      }),
    );
  }

  void _onFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) return;

    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return;
      final event = _decode(json);
      if (event != null) _events.add(event);
    } on FormatException {
      // Malformed frame — drop it rather than tearing the stream down.
    }
  }

  /// Decodes one sparse `/user/queue/dms` envelope. Every field is
  /// type-checked before use — the payload is untrusted input — and events
  /// with missing/mistyped required fields (or unknown types) are dropped.
  DmSocketEvent? _decode(Map<String, dynamic> json) {
    final conversationId = json['conversation_id'];
    final userId = json['user_id'];

    switch (json['type']) {
      case 'presence':
        final online = json['online'];
        if (userId is! String || online is! bool) return null;
        final lastSeenRaw = json['last_seen_at'];
        return DmPresenceEvent(
          userId: userId,
          online: online,
          lastSeenAt: lastSeenRaw is String
              ? DateTime.tryParse(lastSeenRaw)?.toLocal()
              : null,
        );
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
        // Unknown event type — ignore for forward compatibility.
        return null;
    }
  }
}
