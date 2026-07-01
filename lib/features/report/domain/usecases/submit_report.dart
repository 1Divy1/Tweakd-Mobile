import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_target.dart';
import '../repositories/report_repository.dart';

class SubmitReportParams {
  final ReportTarget target;
  final String reasonId;
  const SubmitReportParams({required this.target, required this.reasonId});
}

@lazySingleton
class SubmitReportUseCase implements UseCase<void, SubmitReportParams> {
  final ReportRepository repository;

  SubmitReportUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitReportParams params) {
    return repository.submitReport(params.target, params.reasonId);
  }
}
