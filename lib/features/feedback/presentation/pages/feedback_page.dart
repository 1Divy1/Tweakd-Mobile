import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/feedback/bloc.dart';
import '../bloc/feedback/event.dart';
import '../bloc/feedback/state.dart';
import '../widgets/feedback_error_view.dart';
import '../widgets/feedback_form.dart';
import '../widgets/feedback_loading_view.dart';
import '../widgets/feedback_top_bar.dart';

/// The "Send feedback" screen, reached from Settings. Loads the type + feature
/// pickers, then lets the user file a bug / feature request / general note.
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<FeedbackBloc, FeedbackState>(
          listenWhen: (a, b) => a.status != b.status,
          listener: (context, state) {
            if (state.status == FeedbackStatus.success) {
              // Feedback is on its way — leave the screen and confirm on the
              // page the user returns to.
              context.pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.feedbackSuccess)));
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                FeedbackTopBar(
                  brand: l10n.appTitle,
                  onClose: () => context.pop(),
                ),
                Expanded(
                  child: switch (state.status) {
                    FeedbackStatus.loadingOptions =>
                      const FeedbackLoadingView(),
                    FeedbackStatus.optionsError => FeedbackErrorView(
                        onRetry: () => context
                            .read<FeedbackBloc>()
                            .add(const LoadFeedbackOptions()),
                      ),
                    FeedbackStatus.ready ||
                    FeedbackStatus.submitting ||
                    FeedbackStatus.success =>
                      FeedbackForm(state: state),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
