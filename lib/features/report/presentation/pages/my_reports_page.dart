import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../bloc/my_reports/bloc.dart';
import '../bloc/my_reports/event.dart';
import '../bloc/my_reports/state.dart';
import '../utils/report_error_mapper.dart';
import '../widgets/my_reports/my_reports_empty_view.dart';
import '../widgets/my_reports/my_reports_error_view.dart';
import '../widgets/my_reports/my_reports_list_view.dart';
import '../widgets/my_reports/my_reports_loading_view.dart';

/// The "My reports" screen: every report the current user has filed, with its
/// moderation status. Reached from Settings.
class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(title: l10n.myReportsTitle),
            Expanded(
              child: BlocBuilder<MyReportsBloc, MyReportsState>(
                builder: (context, state) {
                  return switch (state) {
                    MyReportsInitial() ||
                    MyReportsLoading() =>
                      const MyReportsLoadingView(),
                    MyReportsError(:final code) => MyReportsErrorView(
                        message: reportErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<MyReportsBloc>()
                            .add(const LoadMyReports()),
                      ),
                    MyReportsLoaded(:final reports) when reports.isEmpty =>
                      const MyReportsEmptyView(),
                    MyReportsLoaded(:final reports) =>
                      MyReportsListView(reports: reports),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
