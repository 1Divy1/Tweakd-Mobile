// Sharing a mod that was logged earlier, from the build log's share row.
//
// Two rules matter here: only the owner is offered it, and a mod that is
// already in the feed links to its post instead of posting again.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/garage/domain/entities/car.dart';
import 'package:tweakd/features/garage/domain/entities/car_modification.dart';
import 'package:tweakd/features/garage/domain/entities/car_status_option.dart';
import 'package:tweakd/features/garage/domain/repositories/garage_repository.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_car.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_gallery_images.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_modification.dart';
import 'package:tweakd/features/garage/domain/usecases/get_car.dart';
import 'package:tweakd/features/garage/presentation/bloc/car_detail/bloc.dart';
import 'package:tweakd/features/garage/presentation/bloc/car_detail/event.dart';
import 'package:tweakd/features/garage/presentation/bloc/car_detail/state.dart';
import 'package:tweakd/features/posts/domain/entities/post.dart';
import 'package:tweakd/features/posts/domain/entities/post_params.dart';
import 'package:tweakd/features/posts/domain/entities/post_user.dart';
import 'package:tweakd/features/posts/domain/repositories/posts_repository.dart';
import 'package:tweakd/features/posts/domain/usecases/share_modification.dart';

const _carId = 'c1';
const _unsharedMod = 'm1';
const _sharedMod = 'm2';

CarModificationEntity _mod(String id, {String? sharedPostId}) =>
    CarModificationEntity(
      id: id,
      carId: _carId,
      categoryId: 'suspension',
      categoryName: 'Suspension',
      title: 'H&R Coilovers',
      installationDate: DateTime.utc(2026, 4, 1),
      createdAt: DateTime.utc(2026, 4, 1),
      sharedPostId: sharedPostId,
    );

CarEntity _car() => CarEntity(
      id: _carId,
      garageId: 'g1',
      brandId: 'b1',
      brandName: 'BMW',
      modelId: 'mo1',
      modelName: 'M3',
      drivetrainId: 'awd',
      drivetrainName: 'AWD',
      colorId: 'black',
      colorName: 'Black',
      colorCode: '#111111',
      mileageUnitId: 'km',
      mileageUnitName: 'km',
      year: 2023,
      horsepower: 510,
      torque: 650,
      weight: 1800,
      engineDisplacement: 3.0,
      fuelTypeId: 'petrol',
      fuelTypeName: 'Petrol',
      status: const CarStatusOptionEntity(id: 'daily', type: 'Daily Driver'),
      createdAt: DateTime.utc(2026, 1, 1),
      modifications: [
        _mod(_unsharedMod),
        _mod(_sharedMod, sharedPostId: 'p-existing'),
      ],
    );

class _FakeGarageRepo implements GarageRepository {
  @override
  Future<Either<Failure, CarEntity>> getCar(String carId) async =>
      Right(_car());

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

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
      id: 'p-new',
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

CarDetailBloc _bloc(_FakePostsRepo posts) {
  final garage = _FakeGarageRepo();
  return CarDetailBloc(
    getCarUseCase: GetCarUseCase(garage),
    deleteCarUseCase: DeleteCarUseCase(garage),
    deleteGalleryImagesUseCase: DeleteGalleryImagesUseCase(garage),
    deleteModificationUseCase: DeleteModificationUseCase(garage),
    shareModificationUseCase: ShareModificationUseCase(posts),
  );
}

Future<CarDetailLoaded> _loaded(CarDetailBloc bloc) async {
  bloc.add(const LoadCar(_carId));
  return await bloc.stream.firstWhere((s) => s is CarDetailLoaded)
      as CarDetailLoaded;
}

void main() {
  test('sharing a logged mod posts it and marks the row shared', () async {
    final posts = _FakePostsRepo();
    final bloc = _bloc(posts);
    await _loaded(bloc);

    bloc.add(const ShareModificationFromDetail(_unsharedMod));
    final done = await bloc.stream.firstWhere(
      (s) => s is CarDetailLoaded && s.sharingModId == null,
    ) as CarDetailLoaded;

    expect(posts.shared, [_unsharedMod]);
    // The row flips from the post the backend handed back — no re-fetch.
    final mod = done.car.modifications.firstWhere((m) => m.id == _unsharedMod);
    expect(mod.sharedPostId, 'p-new');
    expect(mod.isSharedToFeed, isTrue);
    await bloc.close();
  });

  test('a mod already in the feed is never posted twice', () async {
    final posts = _FakePostsRepo();
    final bloc = _bloc(posts);
    final loaded = await _loaded(bloc);

    bloc.add(const ShareModificationFromDetail(_sharedMod));
    await Future<void>.delayed(Duration.zero);

    // Its row is a link to the post, so there is nothing to send.
    expect(posts.shared, isEmpty);
    expect(loaded.car.modifications
        .firstWhere((m) => m.id == _sharedMod).sharedPostId, 'p-existing');
    await bloc.close();
  });

  test('a failed share reports itself and leaves the row unshared', () async {
    final posts = _FakePostsRepo(succeeds: false);
    final bloc = _bloc(posts);
    await _loaded(bloc);

    bloc.add(const ShareModificationFromDetail(_unsharedMod));
    final failed = await bloc.stream.firstWhere(
      (s) => s is CarDetailLoaded && s.shareFailedModId != null,
    ) as CarDetailLoaded;

    expect(failed.shareFailedModId, _unsharedMod);
    // Nothing is claimed that did not happen.
    expect(
      failed.car.modifications
          .firstWhere((m) => m.id == _unsharedMod)
          .sharedPostId,
      isNull,
    );
    await bloc.close();
  });
}
