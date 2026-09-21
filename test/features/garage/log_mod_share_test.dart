// What happens to a logged mod when the "share to the feed" toggle is on.
//
// The rule worth protecting: the build-log entry is saved first and is never
// undone by the feed. A share that fails costs the post, not the mod.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/features/garage/domain/entities/car_modification.dart';
import 'package:tweakd/features/garage/domain/repositories/garage_repository.dart';
import 'package:tweakd/features/garage/domain/usecases/add_modification.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_modification.dart';
import 'package:tweakd/features/garage/domain/usecases/get_modification_upload_urls.dart';
import 'package:tweakd/features/garage/domain/usecases/get_reference_data.dart';
import 'package:tweakd/features/garage/domain/usecases/patch_modification.dart';
import 'package:tweakd/features/garage/presentation/bloc/add_car/event.dart';
import 'package:tweakd/features/garage/presentation/bloc/log_mod/bloc.dart';
import 'package:tweakd/features/garage/presentation/bloc/log_mod/event.dart';
import 'package:tweakd/features/garage/presentation/bloc/log_mod/state.dart';
import 'package:tweakd/features/posts/domain/entities/post.dart';
import 'package:tweakd/features/posts/domain/entities/post_params.dart';
import 'package:tweakd/features/posts/domain/entities/post_user.dart';
import 'package:tweakd/features/posts/domain/repositories/posts_repository.dart';
import 'package:tweakd/features/posts/domain/usecases/share_modification.dart';

final _mod = CarModificationEntity(
  id: 'm1',
  carId: 'c1',
  categoryId: 'suspension',
  categoryName: 'Suspension',
  title: 'H&R Coilovers',
  installationDate: DateTime.utc(2026, 4, 1),
  createdAt: DateTime.utc(2026, 4, 1),
);

class _FakeGarageRepo implements GarageRepository {
  final List<String> deleted = [];

  @override
  Future<Either<Failure, CarModificationEntity>> addModification(
    String carId,
    ModRequestParams params,
  ) async =>
      Right(_mod);

  @override
  Future<Either<Failure, void>> deleteModification(
      String carId, String modId) async {
    deleted.add(modId);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A posts repository whose share either works or doesn't, as the test asks.
class _FakePostsRepo implements PostsRepository {
  final bool succeeds;
  final List<String> shared = [];

  _FakePostsRepo({this.succeeds = true});

  @override
  Future<Either<Failure, PostEntity>> shareModification(
      ShareModificationParams params) async {
    shared.add(params.modificationId);
    if (!succeeds) return const Left(ServerFailure('feed is down'));
    return Right(PostEntity(
      id: 'p1',
      description: '',
      author: const PostUserEntity(id: 'a1', username: 'author'),
      images: const [],
      taggedPeople: const [],
      taggedCars: const [],
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      savedCount: 0,
      likesCountEnabled: true,
      commentsCountEnabled: true,
      sharesCountEnabled: true,
      savedCountEnabled: true,
      viewerHasLiked: false,
      viewerHasSaved: false,
      createdAt: DateTime.utc(2026, 9, 21),
      updatedAt: DateTime.utc(2026, 9, 21),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

LogModBloc _bloc(_FakeGarageRepo garage, _FakePostsRepo posts) => LogModBloc(
      getModCategories: GetModCategoriesUseCase(garage),
      addModification: AddModificationUseCase(garage),
      deleteModification: DeleteModificationUseCase(garage),
      getModificationUploadUrls: GetModificationUploadUrlsUseCase(garage),
      patchModification: PatchModificationUseCase(garage),
      shareModification: ShareModificationUseCase(posts),
      imageService: ImageService(),
    );

SubmitModification _submit({required bool shareToFeed}) => SubmitModification(
      carId: 'c1',
      input: NewModInput(
        request: ModRequestParams(
          categoryId: 'suspension',
          title: 'H&R Coilovers',
          installationDate: DateTime.utc(2026, 4, 1),
        ),
      ),
      shareToFeed: shareToFeed,
    );

void main() {
  test('with the toggle on, the saved mod is shared to the feed', () async {
    final garage = _FakeGarageRepo();
    final posts = _FakePostsRepo();
    final bloc = _bloc(garage, posts);

    bloc.add(_submit(shareToFeed: true));
    final state = await bloc.stream.firstWhere((s) => s is LogModSuccess)
        as LogModSuccess;

    expect(posts.shared, ['m1']);
    expect(state.shareFailed, isFalse);
    await bloc.close();
  });

  test('with the toggle off, nothing reaches the feed', () async {
    final garage = _FakeGarageRepo();
    final posts = _FakePostsRepo();
    final bloc = _bloc(garage, posts);

    bloc.add(_submit(shareToFeed: false));
    final state = await bloc.stream.firstWhere((s) => s is LogModSuccess)
        as LogModSuccess;

    expect(posts.shared, isEmpty);
    expect(state.shareFailed, isFalse);
    await bloc.close();
  });

  test('a failed share keeps the mod and says so', () async {
    final garage = _FakeGarageRepo();
    final posts = _FakePostsRepo(succeeds: false);
    final bloc = _bloc(garage, posts);

    bloc.add(_submit(shareToFeed: true));
    final state = await bloc.stream.firstWhere((s) => s is LogModSuccess)
        as LogModSuccess;

    // Still a success — the entry is in the build log.
    expect(state.mod.id, 'm1');
    // And it was not rolled back the way a failed photo upload would be.
    expect(garage.deleted, isEmpty);
    expect(state.shareFailed, isTrue);
    await bloc.close();
  });
}
