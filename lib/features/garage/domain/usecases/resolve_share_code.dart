import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_share.dart';
import '../repositories/garage_repository.dart';

class ResolveShareCodeParams {
  final String code;

  /// The `?s=` tag the incoming link carried, forwarded so a QR scan that
  /// lands in the app is counted as a scan and not as a plain view.
  final String? source;

  const ResolveShareCodeParams({required this.code, this.source});
}

/// Turns the code from a scanned QR or a tapped share link into the car it
/// points at, so the app can open its own screen for it.
@lazySingleton
class ResolveShareCodeUseCase
    implements UseCase<CarShareResolutionEntity, ResolveShareCodeParams> {
  final GarageRepository repository;

  ResolveShareCodeUseCase(this.repository);

  @override
  Future<Either<Failure, CarShareResolutionEntity>> call(
    ResolveShareCodeParams params,
  ) {
    return repository.resolveShareCode(params.code, source: params.source);
  }
}
