import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/garage_repository.dart';

class GetCarShareQrParams {
  final String carId;
  const GetCarShareQrParams({required this.carId});
}

/// The car's share URL as a print-ready QR, in SVG.
///
/// Rendered by the backend rather than on device: one renderer means the same
/// code on every phone and a vector file the owner can actually take to a print
/// shop, which no on-device QR widget produces.
@lazySingleton
class GetCarShareQrUseCase implements UseCase<String, GetCarShareQrParams> {
  final GarageRepository repository;

  GetCarShareQrUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetCarShareQrParams params) {
    return repository.getShareQrSvg(params.carId);
  }
}
