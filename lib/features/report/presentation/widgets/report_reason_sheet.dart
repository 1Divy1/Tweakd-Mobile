import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report_reason.dart';
import '../../domain/entities/report_target.dart';
import '../bloc/report/bloc.dart';
import '../bloc/report/event.dart';
import '../bloc/report/state.dart';
import '../utils/report_error_mapper.dart';

/// Opens the report reason picker for [target] and drives it to completion.
///
/// Resolves to `true` when the report was submitted successfully (so the caller
/// can hide the reported post/comment or redirect away from the profile), and
/// `false` if the user dismissed without a successful report. The success flag
/// is captured the moment the report goes through, so it survives a swipe-down
/// dismiss just as well as tapping the Close button.
Future<bool> showReportSheet(
  BuildContext context, {
  required ReportTarget target,
  required String title,
}) async {
  var reported = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<ReportBloc>(
      create: (_) => getIt<ReportBloc>()..add(LoadReportReasons(target)),
      child: BlocListener<ReportBloc, ReportState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (_, state) {
          if (state.status == ReportStatus.success) reported = true;
        },
        child: _ReportSheet(title: title, target: target),
      ),
    ),
  );
  return reported;
}

class _ReportSheet extends StatelessWidget {
  final String title;
  final ReportTarget target;

  const _ReportSheet({required this.title, required this.target});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                return switch (state.status) {
                  ReportStatus.success => _SuccessView(l10n: l10n),
                  ReportStatus.loadingReasons => _TitledBody(
                      title: title,
                      child: const _LoadingBody(),
                    ),
                  ReportStatus.reasonsError => _TitledBody(
                      title: title,
                      child: _ReasonsErrorBody(
                        l10n: l10n,
                        onRetry: () => context
                            .read<ReportBloc>()
                            .add(LoadReportReasons(target)),
                      ),
                    ),
                  ReportStatus.ready ||
                  ReportStatus.submitting =>
                    _TitledBody(
                      title: title,
                      child: _ReasonsBody(state: state, l10n: l10n),
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TitledBody extends StatelessWidget {
  final String title;
  final Widget child;

  const _TitledBody({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

class _ReasonsErrorBody extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  const _ReasonsErrorBody({required this.l10n, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.reportReasonsLoadError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              l10n.reportRetry,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonsBody extends StatelessWidget {
  final ReportState state;
  final AppLocalizations l10n;

  const _ReasonsBody({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final submitting = state.status == ReportStatus.submitting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: state.reasons.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: AppColors.line),
            itemBuilder: (context, i) {
              final reason = state.reasons[i];
              return _ReasonRow(
                reason: reason,
                selected: reason.id == state.selectedReasonId,
                enabled: !submitting,
                onTap: () => context
                    .read<ReportBloc>()
                    .add(SelectReportReason(reason.id)),
              );
            },
          ),
        ),
        if (state.errorCode != null) ...[
          const SizedBox(height: 14),
          Text(
            reportErrorMessage(l10n, state.errorCode!),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accentHot,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 18),
        _SubmitButton(
          enabled: state.canSubmit,
          submitting: submitting,
          label: l10n.reportSubmit,
          onTap: () =>
              context.read<ReportBloc>().add(const SubmitReportPressed()),
        ),
      ],
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final ReportReasonEntity reason;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ReasonRow({
    required this.reason,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.reason,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.accent : AppColors.muteSoft,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool submitting;
  final String label;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.enabled,
    required this.submitting,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.line,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.muteSoft,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final AppLocalizations l10n;

  const _SuccessView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.reportSuccessTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reportSuccessBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.reportClose,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
