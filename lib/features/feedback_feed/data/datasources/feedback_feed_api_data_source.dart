import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/network/abstract_http.dart';
import '../models/feedback_feed_models.dart';

/// Talks to the feedback-board module under the shared API base
/// (`$API_BASE_URL/api/v1`). The JWT is attached by `AuthInterceptor`.
@lazySingleton
class FeedbackFeedApiDataSource {
  static const _basePath = '/feedback-feed';

  final AbstractHTTP http;

  FeedbackFeedApiDataSource(this.http);

  /// GET /feedback-feed/types — categories for the compose screen.
  Future<List<FeedbackOptionModel>> getTypes() async {
    final data = await http.get('$_basePath/types');
    return _parseOptions(data);
  }

  /// GET /feedback-feed/statuses — roadmap stages, in order.
  Future<List<FeedbackOptionModel>> getStatuses() async {
    final data = await http.get('$_basePath/statuses');
    return _parseOptions(data);
  }

  /// GET /feedback-feed — the main board, excluding completed messages.
  Future<FeedbackMessagePageModel> getFeed({
    required String sort,
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      _basePath,
      queryParameters: {
        'sort': sort,
        'cursor': ?cursor,
        'size': size,
      },
    );
    return _parsePage(data);
  }

  /// GET /feedback-feed/completed — shipped requests, newest first.
  Future<FeedbackMessagePageModel> getCompleted({
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '$_basePath/completed',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return _parsePage(data);
  }

  /// GET /feedback-feed/{id}
  Future<FeedbackMessageModel> getMessage(String messageId) async {
    final data = await http.get('$_basePath/$messageId');
    return _parseMessage(data);
  }

  /// POST /feedback-feed — publishes a message (201).
  ///
  /// The response body is deliberately **not** parsed. The contract documents a
  /// `FeedbackMessageDto` here, but nothing consumes it — the board refetches
  /// after a successful post — and insisting on it would turn a 201 with an
  /// empty body into a spurious "failed to post" for the user.
  Future<void> createMessage({
    required String typeId,
    required String message,
  }) async {
    await http.post(
      _basePath,
      body: {'type': typeId, 'message': message},
    );
  }

  /// DELETE /feedback-feed/{id} — hard delete (204), 409 once the status has
  /// moved past `sent`.
  Future<void> deleteMessage(String messageId) async {
    await http.delete('$_basePath/$messageId');
  }

  /// POST /feedback-feed/{id}/vote — `value` is 1 or -1.
  Future<FeedbackMessageModel> vote({
    required String messageId,
    required int value,
  }) async {
    final data = await http.post(
      '$_basePath/$messageId/vote',
      body: {'value': value},
    );
    return _parseMessage(data);
  }

  /// DELETE /feedback-feed/{id}/vote — idempotent withdrawal.
  Future<FeedbackMessageModel> withdrawVote(String messageId) async {
    final data = await http.delete('$_basePath/$messageId/vote');
    return _parseMessage(data);
  }

  List<FeedbackOptionModel> _parseOptions(dynamic data) {
    if (data is! List) {
      throw ServerException('Unexpected feedback options response.');
    }
    return data
        .whereType<Map>()
        .map((e) => FeedbackOptionModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  FeedbackMessagePageModel _parsePage(dynamic data) {
    if (data is! Map) {
      throw ServerException('Unexpected feedback feed response.');
    }
    return FeedbackMessagePageModel.fromJson(data.cast<String, dynamic>());
  }

  FeedbackMessageModel _parseMessage(dynamic data) {
    if (data is! Map) {
      throw ServerException('Unexpected feedback message response.');
    }
    return FeedbackMessageModel.fromJson(data.cast<String, dynamic>());
  }
}
