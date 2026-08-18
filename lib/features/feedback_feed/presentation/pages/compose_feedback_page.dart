import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../feedback/presentation/widgets/feedback_top_bar.dart';
import '../bloc/compose/bloc.dart';
import '../bloc/compose/event.dart';
import '../bloc/compose/state.dart';
import '../widgets/compose/feedback_compose_form.dart';
import '../widgets/shared/feedback_feed_views.dart';

/// "Share feedback" — the composer behind the board's "+ NEW" button.
///
/// Pops with `true` once the message is published, so the board knows to pull
/// it in. The close button (and a back gesture) pops with nothing.
class ComposeFeedbackPage extends StatelessWidget {
  const ComposeFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // The post button tracks the keyboard itself, so the scaffold shouldn't
      // also resize the body out from under it.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<ComposeFeedbackBloc, ComposeFeedbackState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status != ComposeFeedbackStatus.success) return;
            context.pop(true);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.feedbackFeedPostSuccess)),
              );
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
                    ComposeFeedbackStatus.loadingTypes =>
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    // Without categories there is nothing to post, so this is
                    // the one hard error on the screen.
                    ComposeFeedbackStatus.typesError => FeedbackFeedErrorView(
                        message: l10n.feedbackFeedErrorGeneric,
                        onRetry: () => context
                            .read<ComposeFeedbackBloc>()
                            .add(const LoadFeedbackTypes()),
                      ),
                    ComposeFeedbackStatus.ready ||
                    ComposeFeedbackStatus.submitting ||
                    ComposeFeedbackStatus.success =>
                      FeedbackComposeForm(state: state),
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
