import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/dm_models.dart';

/// DM REST contract (base /api/v1, snake_case, JWT via interceptor).
/// Presence lives in PresenceDataSource; live events in DmSocketService.
abstract class MessagesDataSource {
  Future<DmConversationsPageModel> getConversations({String? cursor});
  Future<DmMessagesPageModel> getMessages(
    String conversationId, {
    String? cursor,
  });
  Future<DmMessageModel> sendMessage({
    required String recipientId,
    required String content,
  });
  Future<void> deleteMessage(String messageId);
  Future<void> hideConversation(String conversationId);
  Future<void> markRead(String conversationId);

  /// Compose-sheet user search — reuses the profile search endpoint; there
  /// is no DM-specific suggestions endpoint.
  Future<List<DmPeerModel>> searchUsers(String query);
}

@LazySingleton(as: MessagesDataSource)
class MessagesApiDataSource implements MessagesDataSource {
  final AbstractHTTP http;

  MessagesApiDataSource(this.http);

  @override
  Future<DmConversationsPageModel> getConversations({String? cursor}) async {
    final data = await http.get(
      '/dms/conversations',
      queryParameters: {'cursor': ?cursor},
    );
    return DmConversationsPageModel.fromJson(data as Map<String, dynamic>);
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

  @override
  Future<DmMessageModel> sendMessage({
    required String recipientId,
    required String content,
  }) async {
    final data = await http.post(
      '/dms/messages',
      body: {
        'recipient_id': recipientId,
        'content': content,
      },
    );
    return DmMessageModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMessage(String messageId) =>
      http.delete('/dms/messages/$messageId');

  @override
  Future<void> hideConversation(String conversationId) =>
      http.post('/dms/conversations/$conversationId/hide');

  @override
  Future<void> markRead(String conversationId) =>
      http.post('/dms/conversations/$conversationId/read');

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
