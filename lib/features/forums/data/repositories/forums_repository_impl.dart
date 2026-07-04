import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/forum_filter.dart';
import '../../domain/entities/forum_pages.dart';
import '../../domain/entities/forum_reply.dart';
import '../../domain/entities/forum_shortcut.dart';
import '../../domain/entities/forum_suggestion.dart';
import '../../domain/entities/forum_thread.dart';
import '../../domain/entities/forum_topic.dart';
import '../../domain/failures/forum_failures.dart';
import '../../domain/repositories/forums_repository.dart';
import '../datasources/forums_api_data_source.dart';

@LazySingleton(as: ForumsRepository)
class ForumsRepositoryImpl implements ForumsRepository {
  final ForumsApiDataSource dataSource;

  ForumsRepositoryImpl(this.dataSource);

  /// Shared exception → failure mapping for every forums call. The backend's
  /// interesting statuses: 400 validation, 403 not-owner, 404 missing,
  /// 409 locked thread / deleted target.
  Future<Either<Failure, T>> _run<T>(
    String op,
    Future<T> Function() body,
  ) async {
    try {
      return Right(await body());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ConflictException catch (e) {
      return Left(ForumConflictFailure(e.message));
    } on ApiException catch (e) {
      return Left(switch (e.statusCode) {
        404 => const ForumNotFoundFailure(),
        403 => const ForumForbiddenFailure(),
        400 => ForumValidationFailure(e.message),
        _ => ServerFailure(e.message),
      });
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('forums $op error: $e');
      return Left(UnknownFailure('Forums request failed: $op.'));
    }
  }

  @override
  Future<Either<Failure, List<ForumTopicGroupEntity>>> getTopics() =>
      _run('getTopics', () async {
        final groups = await dataSource.getTopics();
        return groups.map((g) => g.toEntity()).toList();
      });

  @override
  Future<Either<Failure, ForumThreadPageEntity>> getThreads({
    ForumFilter? filter,
    required ForumThreadSort sort,
    String? cursor,
    int? size,
  }) =>
      _run('getThreads', () async {
        final page = await dataSource.getThreads(
          filter: filter,
          sort: sort,
          cursor: cursor,
          size: size,
        );
        return page.toEntity();
      });

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> getThread(
          String threadId) =>
      _run('getThread',
          () async => (await dataSource.getThread(threadId)).toEntity());

  @override
  Future<Either<Failure, ForumReplyPageEntity>> getThreadReplies(
    String threadId, {
    ForumReplySort sort = ForumReplySort.oldest,
    String? cursor,
    int? size,
  }) =>
      _run('getThreadReplies', () async {
        final page = await dataSource.getThreadReplies(
          threadId,
          sort: sort,
          cursor: cursor,
          size: size,
        );
        return page.toEntity();
      });

  @override
  Future<Either<Failure, ForumReplyPageEntity>> getReplyChildren(
    String postId, {
    ForumReplySort sort = ForumReplySort.oldest,
    String? cursor,
    int? size,
  }) =>
      _run('getReplyChildren', () async {
        final page = await dataSource.getReplyChildren(
          postId,
          sort: sort,
          cursor: cursor,
          size: size,
        );
        return page.toEntity();
      });

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> createThread({
    required String title,
    String? content,
    String? modelId,
    String? brandId,
    List<String> topicIds = const [],
  }) =>
      _run('createThread', () async {
        final model = await dataSource.createThread(
          title: title,
          content: content,
          modelId: modelId,
          brandId: brandId,
          topicIds: topicIds,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> editThread(
    String threadId, {
    required String content,
  }) =>
      _run(
          'editThread',
          () async =>
              (await dataSource.editThread(threadId, content: content))
                  .toEntity());

  @override
  Future<Either<Failure, void>> deleteThread(String threadId) =>
      _run('deleteThread', () => dataSource.deleteThread(threadId));

  @override
  Future<Either<Failure, ForumReplyEntity>> createReply(
    String threadId, {
    required String content,
    String? parentPostId,
  }) =>
      _run('createReply', () async {
        final model = await dataSource.createReply(
          threadId,
          content: content,
          parentPostId: parentPostId,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, ForumReplyEntity>> editReply(
    String postId, {
    required String content,
  }) =>
      _run(
          'editReply',
          () async => (await dataSource.editReply(postId, content: content))
              .toEntity());

  @override
  Future<Either<Failure, void>> deleteReply(String postId) =>
      _run('deleteReply', () => dataSource.deleteReply(postId));

  @override
  Future<Either<Failure, void>> likeThread(String threadId) =>
      _run('likeThread', () => dataSource.likeThread(threadId));

  @override
  Future<Either<Failure, void>> unlikeThread(String threadId) =>
      _run('unlikeThread', () => dataSource.unlikeThread(threadId));

  @override
  Future<Either<Failure, void>> likeReply(String postId) =>
      _run('likeReply', () => dataSource.likeReply(postId));

  @override
  Future<Either<Failure, void>> unlikeReply(String postId) =>
      _run('unlikeReply', () => dataSource.unlikeReply(postId));

  @override
  Future<Either<Failure, List<ForumShortcutEntity>>> getShortcuts() =>
      _run('getShortcuts', () async {
        final models = await dataSource.getShortcuts();
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Either<Failure, ForumShortcutEntity>> createShortcut({
    required String name,
    String? brandId,
    String? modelId,
    String? topicId,
    bool notify = false,
  }) =>
      _run('createShortcut', () async {
        final model = await dataSource.createShortcut(
          name: name,
          brandId: brandId,
          modelId: modelId,
          topicId: topicId,
          notify: notify,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, ForumShortcutEntity>> updateShortcut(
    String shortcutId, {
    String? name,
    bool? notify,
  }) =>
      _run('updateShortcut', () async {
        final model = await dataSource.updateShortcut(
          shortcutId,
          name: name,
          notify: notify,
        );
        return model.toEntity();
      });

  @override
  Future<Either<Failure, List<ForumShortcutEntity>>> reorderShortcuts(
          List<String> orderedIds) =>
      _run('reorderShortcuts', () async {
        final models = await dataSource.reorderShortcuts(orderedIds);
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Either<Failure, void>> deleteShortcut(String shortcutId) =>
      _run('deleteShortcut', () => dataSource.deleteShortcut(shortcutId));

  @override
  Future<Either<Failure, void>> saveThread(String threadId) =>
      _run('saveThread', () => dataSource.saveThread(threadId));

  @override
  Future<Either<Failure, void>> unsaveThread(String threadId) =>
      _run('unsaveThread', () => dataSource.unsaveThread(threadId));

  @override
  Future<Either<Failure, ForumThreadPageEntity>> getSavedThreads({
    String? cursor,
    int? size,
  }) =>
      _run('getSavedThreads', () async {
        final page =
            await dataSource.getSavedThreads(cursor: cursor, size: size);
        return page.toEntity();
      });

  @override
  Future<Either<Failure, List<ForumSuggestionEntity>>> getSuggestions({
    int? limit,
  }) =>
      _run('getSuggestions', () async {
        final models = await dataSource.getSuggestions(limit: limit);
        return models.map((m) => m.toEntity()).toList();
      });
}
