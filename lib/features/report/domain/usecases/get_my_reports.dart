import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_report.dart';
import '../repositories/report_repository.dart';

@lazySingleton
class GetMyReportsUseCase implements UseCase<List<MyReportEntity>, NoParams> {
  final ReportRepository repository;

  GetMyReportsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MyReportEntity>>> call(NoParams params) {
    return repository.getMyReports();
  }
}
