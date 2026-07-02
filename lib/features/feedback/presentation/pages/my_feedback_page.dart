import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../bloc/my_feedback/bloc.dart';
import '../bloc/my_feedback/event.dart';
import '../bloc/my_feedback/state.dart';
import '../utils/feedback_error_mapper.dart';
import '../widgets/my_feedback/my_feedback_empty_view.dart';
import '../widgets/my_feedback/my_feedback_error_view.dart';
import '../widgets/my_feedback/my_feedback_list_view.dart';
import '../widgets/my_feedback/my_feedback_loading_view.dart';

/// The "My feedback" screen: every piece of feedback the current user has sent.
/// Reached from Settings.
class MyFeedbackPage extends StatelessWidget {
  const MyFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(title: l10n.myFeedbackTitle),
            Expanded(
              child: BlocBuilder<MyFeedbackBloc, MyFeedbackState>(
                builder: (context, state) {
                  return switch (state) {
                    MyFeedbackInitial() ||
                    MyFeedbackLoading() =>
                      const MyFeedbackLoadingView(),
                    MyFeedbackError(:final code) => MyFeedbackErrorView(
                        message: feedbackErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<MyFeedbackBloc>()
                            .add(const LoadMyFeedback()),
                      ),
                    MyFeedbackLoaded(:final feedback) when feedback.isEmpty =>
                      const MyFeedbackEmptyView(),
                    MyFeedbackLoaded(:final feedback) =>
                      MyFeedbackListView(feedback: feedback),
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
