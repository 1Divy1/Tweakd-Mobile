import 'package:http/http.dart' as net;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/network/abstract_http.dart';
import '../models/dm_models.dart';

/// DM data contract. Reads and admin actions are Spring REST (base /api/v1,
/// snake_case, JWT via interceptor); **sending** goes straight to Supabase via
/// the `dm_send_message` RPC. Live events live in DmRealtimeService.
abstract class MessagesDataSource {
  Future<DmConversationsPageModel> getConversations({String? cursor});

  /// One conversation by id. Used when a chat is opened without its peer
  /// travelling alongside — a push notification tap, where the payload names
  /// the conversation but carries no avatar.
  Future<DmConversationModel> getConversation(String conversationId);

  Future<DmMessagesPageModel> getMessages(
    String conversationId, {
    String? cursor,
  });

  /// Writes the message through Supabase. [taggedCars] are echoed back on the
  /// returned model so the sender's bubble (and the broadcast the caller sends
  /// to the peer) carry cover images the database cannot produce — only the
  /// ids reach the RPC.
  Future<DmMessageModel> sendMessage({
    required String recipientId,
    required String content,
    List<DmTaggedCarModel> taggedCars,
  });
  Future<void> deleteMessage(String messageId);
  Future<void> hideConversation(String conversationId);

  /// Marks the conversation read and returns the resulting watermark, which
  /// the caller broadcasts to the peer so their "Seen" ticks update.
  Future<String?> markRead(String conversationId);

  /// Total unread messages across all conversations — drives the app-level
  /// DMs badge.
  Future<int> getUnreadCount();

  /// Compose-sheet user search — reuses the profile search endpoint; there
  /// is no DM-specific suggestions endpoint.
  Future<List<DmPeerModel>> searchUsers(String query);
}

@LazySingleton(as: MessagesDataSource)
class MessagesApiDataSource implements MessagesDataSource {
  final AbstractHTTP http;
  final SupabaseClient supabaseClient;

  MessagesApiDataSource(this.http, this.supabaseClient);

  @override
  Future<DmConversationsPageModel> getConversations({String? cursor}) async {
    final data = await http.get(
      '/dms/conversations',
      queryParameters: {'cursor': ?cursor},
    );
    return DmConversationsPageModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<DmConversationModel> getConversation(String conversationId) async {
    final data = await http.get('/dms/conversations/$conversationId');
    return DmConversationModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<DmMessagesPageModel> getMessages(
    String conversationId, {
    String? cursor,
  }) async {
    final data = await http.get(
      '/dms/conversations/$conversationId/messages',
      queryParameters: {'cursor': ?cursor},
    );
    return DmMessagesPageModel.fromJson(data as Map<String, dynamic>);
  }

  /// `dm_send_message` is SECURITY DEFINER and does the whole send atomically
  /// (conversation upsert, message insert, car tags, unread counter). It
  /// returns the message in the same shape as the REST payload, minus
  /// `tagged_cars` — cover-image URLs are built from R2 keys by Spring and
  /// cannot come out of the database, so the cars the caller passed in are
  /// stitched back on here.
  @override
  Future<DmMessageModel> sendMessage({
    required String recipientId,
    required String content,
    List<DmTaggedCarModel> taggedCars = const [],
  }) async {
    final data = await _runRpc(
      'dm_send_message',
      {
        'p_recipient_id': recipientId,
        'p_content': content,
        'p_tagged_car_ids': [for (final car in taggedCars) car.id],
      },
    );
    return DmMessageModel.fromJson(data).withTaggedCars(taggedCars);
  }

  /// Supabase throws its own exception types; per the error pipeline they must
  /// never leak past the data layer.
  Future<Map<String, dynamic>> _runRpc(
    String function,
    Map<String, dynamic> params,
  ) async {
    try {
      final data = await supabaseClient.rpc(function, params: params);
      if (data is! Map<String, dynamic>) {
        throw ServerException('Unexpected response from $function.');
      }
      return data;
    } on PostgrestException catch (e) {
      // The RPC raises with SQLSTATE 28000 for a missing session and 22xxx for
      // validation; anything else is a genuine server-side failure.
      if (e.code == '28000') {
        throw UnauthenticatedException(e.message);
      }
      if (e.code != null && e.code!.startsWith('22')) {
        throw ApiException(statusCode: 400, errorCode: e.code, message: e.message);
      }
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw UnauthenticatedException(e.message);
    } on net.ClientException {
      // package:http surfaces connectivity failures this way (it wraps
      // SocketException), so this is the Supabase-side equivalent of the
      // DioException → NetworkException mapping in DioHttpClient.
      throw NetworkException();
    }
  }

  @override
  Future<void> deleteMessage(String messageId) =>
      http.delete('/dms/messages/$messageId');

  @override
  Future<void> hideConversation(String conversationId) =>
      http.post('/dms/conversations/$conversationId/hide');

  @override
  Future<String?> markRead(String conversationId) async {
    final data = await http.post('/dms/conversations/$conversationId/read');
    if (data is! Map<String, dynamic>) return null;
    return data['last_read_message_id'] as String?;
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await http.get('/dms/unread-count');
    return (data as Map<String, dynamic>)['unread'] as int? ?? 0;
  }

  @override
  Future<List<DmPeerModel>> searchUsers(String query) async {
    final data = await http.get(
      '/profile/search',
      queryParameters: {'q': query},
    );
    return [
      for (final item in data as List? ?? const [])
        if (item is Map<String, dynamic>) DmPeerModel.fromJson(item),
    ];
  }
}
