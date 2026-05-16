import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_status_option.dart';
import '../entities/reference_data.dart';
import '../repositories/garage_repository.dart';

@lazySingleton
class GetBrandsUseCase implements UseCase<List<CarBrandEntity>, NoParams> {
  final GarageRepository repository;
  GetBrandsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarBrandEntity>>> call(NoParams _) =>
      repository.getBrands();
}

class GetModelsByBrandParams {
  final String brandId;
  const GetModelsByBrandParams({required this.brandId});
}

@lazySingleton
class GetModelsByBrandUseCase
    implements UseCase<List<CarModelEntity>, GetModelsByBrandParams> {
  final GarageRepository repository;
  GetModelsByBrandUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarModelEntity>>> call(
          GetModelsByBrandParams params) =>
      repository.getModelsByBrand(params.brandId);
}

@lazySingleton
class GetDrivetrainsUseCase
    implements UseCase<List<CarDrivetrainEntity>, NoParams> {
  final GarageRepository repository;
  GetDrivetrainsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarDrivetrainEntity>>> call(NoParams _) =>
      repository.getDrivetrains();
}

@lazySingleton
class GetColorsUseCase implements UseCase<List<CarColorEntity>, NoParams> {
  final GarageRepository repository;
  GetColorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarColorEntity>>> call(NoParams _) =>
      repository.getColors();
}

@lazySingleton
class GetDistanceUnitsUseCase
    implements UseCase<List<CarDistanceUnitEntity>, NoParams> {
  final GarageRepository repository;
  GetDistanceUnitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarDistanceUnitEntity>>> call(NoParams _) =>
      repository.getDistanceUnits();
}

@lazySingleton
class GetStatusOptionsUseCase
    implements UseCase<List<CarStatusOptionEntity>, NoParams> {
  final GarageRepository repository;
  GetStatusOptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarStatusOptionEntity>>> call(NoParams _) =>
      repository.getStatusOptions();
}

@lazySingleton
class GetModCategoriesUseCase
    implements UseCase<List<CarModCategoryEntity>, NoParams> {
  final GarageRepository repository;
  GetModCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarModCategoryEntity>>> call(NoParams _) =>
      repository.getModCategories();
}
