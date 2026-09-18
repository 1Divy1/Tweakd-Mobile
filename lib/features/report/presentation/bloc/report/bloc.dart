import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/report_target.dart';
import '../../../domain/usecases/get_report_reasons.dart';
import '../../../domain/usecases/submit_report.dart';
import '../../utils/report_error_mapper.dart';
import 'event.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

/// Backs the report bottom sheet for a single target (post, comment or profile):
/// loads the preset reasons, tracks the single selected reason, and submits.
@injectable
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetReportReasonsUseCase getReasons;
  final SubmitReportUseCase submitReport;

  late ReportTarget _target;
  final AnalyticsService analytics;

  ReportBloc({
    required this.getReasons,
    required this.submitReport,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const ReportState()) {
    on<LoadReportReasons>(_onLoad);
    on<SelectReportReason>(_onSelect);
    on<SubmitReportPressed>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadReportReasons event,
    Emitter<ReportState> emit,
  ) async {
    _target = event.target;
    emit(const ReportState(status: ReportStatus.loadingReasons));

    final result = await getReasons(_target);
    result.fold(
      (_) => emit(state.copyWith(status: ReportStatus.reasonsError)),
      (reasons) => emit(state.copyWith(
        status: ReportStatus.ready,
        reasons: reasons,
      )),
    );
  }

  void _onSelect(SelectReportReason event, Emitter<ReportState> emit) {
    if (state.status == ReportStatus.submitting) return;
    emit(state.copyWith(
      selectedReasonId: event.reasonId,
      clearError: true,
    ));
  }

  Future<void> _onSubmit(
    SubmitReportPressed event,
    Emitter<ReportState> emit,
  ) async {
    final reasonId = state.selectedReasonId;
    if (reasonId == null || state.status == ReportStatus.submitting) return;

    emit(state.copyWith(status: ReportStatus.submitting, clearError: true));

    final result = await submitReport(
      SubmitReportParams(target: _target, reasonId: reasonId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: ReportStatus.ready,
        errorCode: ReportErrorMapper.getCode(failure),
      )),
      (_) {
        analytics.track(AnalyticsEvents.contentReported, {
          'target_type': switch (_target) {
            PostReportTarget() => 'post',
            CommentReportTarget() => 'comment',
            ProfileReportTarget() => 'profile',
            ForumThreadReportTarget() => 'forum_thread',
            ForumReplyReportTarget() => 'forum_reply',
          },
          'reason': reasonId,
        });
        emit(state.copyWith(status: ReportStatus.success));
      },
    );
  }
}
