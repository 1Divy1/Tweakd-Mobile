import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_shortcut.dart';
import '../repositories/forums_repository.dart';

@lazySingleton
class GetForumShortcutsUseCase
    implements UseCase<List<ForumShortcutEntity>, NoParams> {
  final ForumsRepository repository;

  GetForumShortcutsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForumShortcutEntity>>> call(NoParams params) {
    return repository.getShortcuts();
  }
}

class CreateForumShortcutParams {
  final String name;
  final String? brandId;
  final String? modelId;
  final String? topicId;
  final bool notify;

  const CreateForumShortcutParams({
    required this.name,
    this.brandId,
    this.modelId,
    this.topicId,
    this.notify = false,
  });
}

@lazySingleton
class CreateForumShortcutUseCase
    implements UseCase<ForumShortcutEntity, CreateForumShortcutParams> {
  final ForumsRepository repository;

  CreateForumShortcutUseCase(this.repository);

  @override
  Future<Either<Failure, ForumShortcutEntity>> call(
      CreateForumShortcutParams params) {
    return repository.createShortcut(
      name: params.name,
      brandId: params.brandId,
      modelId: params.modelId,
      topicId: params.topicId,
      notify: params.notify,
    );
  }
}

class UpdateForumShortcutParams {
  final String shortcutId;
  final String? name;
  final bool? notify;

  const UpdateForumShortcutParams({
    required this.shortcutId,
    this.name,
    this.notify,
  });
}

/// Partial update of name / notify — the filter itself is immutable.
@lazySingleton
class UpdateForumShortcutUseCase
    implements UseCase<ForumShortcutEntity, UpdateForumShortcutParams> {
  final ForumsRepository repository;

  UpdateForumShortcutUseCase(this.repository);

  @override
  Future<Either<Failure, ForumShortcutEntity>> call(
      UpdateForumShortcutParams params) {
    return repository.updateShortcut(
      params.shortcutId,
      name: params.name,
      notify: params.notify,
    );
  }
}

/// [orderedIds] must contain every shortcut id exactly once, in pinned order.
@lazySingleton
class ReorderForumShortcutsUseCase
    implements UseCase<List<ForumShortcutEntity>, List<String>> {
  final ForumsRepository repository;

  ReorderForumShortcutsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForumShortcutEntity>>> call(
      List<String> orderedIds) {
    return repository.reorderShortcuts(orderedIds);
  }
}

@lazySingleton
class DeleteForumShortcutUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  DeleteForumShortcutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String shortcutId) {
    return repository.deleteShortcut(shortcutId);
  }
}
