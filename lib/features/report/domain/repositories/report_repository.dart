import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/my_report.dart';
import '../entities/report_reason.dart';
import '../entities/report_target.dart';

abstract class ReportRepository {
  /// The preset reasons applicable to [target]'s kind (post / comment / profile).
  Future<Either<Failure, List<ReportReasonEntity>>> getReasons(
    ReportTarget target,
  );

  /// Submits a report against [target] with the chosen [reasonId].
  Future<Either<Failure, void>> submitReport(
    ReportTarget target,
    String reasonId,
  );

  /// The reports the current user has filed, newest-first.
  Future<Either<Failure, List<MyReportEntity>>> getMyReports();
}
