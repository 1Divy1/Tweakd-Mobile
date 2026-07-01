import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_reason.dart';
import '../entities/report_target.dart';
import '../repositories/report_repository.dart';

@lazySingleton
class GetReportReasonsUseCase
    implements UseCase<List<ReportReasonEntity>, ReportTarget> {
  final ReportRepository repository;

  GetReportReasonsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReportReasonEntity>>> call(ReportTarget params) {
    return repository.getReasons(params);
  }
}
