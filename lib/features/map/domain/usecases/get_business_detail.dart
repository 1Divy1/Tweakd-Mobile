import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_detail_entity.dart';
import '../repositories/map_repository.dart';

class GetBusinessDetailParams {
  final String id;
  final CancelToken? cancelToken;

  const GetBusinessDetailParams({required this.id, this.cancelToken});
}

@lazySingleton
class GetBusinessDetailUseCase
    implements UseCase<BusinessDetailEntity, GetBusinessDetailParams> {
  final MapRepository repository;

  GetBusinessDetailUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessDetailEntity>> call(
    GetBusinessDetailParams params,
  ) {
    return repository.getBusinessDetail(
      params.id,
      cancelToken: params.cancelToken,
    );
  }
}
