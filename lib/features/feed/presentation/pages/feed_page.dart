import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../core/shared/widgets/create_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../badges/presentation/bloc/celebration/cubit.dart';
import '../../../forums/presentation/bloc/home/bloc.dart';
import '../../../forums/presentation/bloc/home/event.dart';
import '../../../forums/presentation/widgets/home/forums_home_actions.dart';
import '../../../forums/presentation/widgets/home/forums_home_view.dart';
import '../bloc/feed/bloc.dart';
import '../bloc/feed/event.dart';
import '../bloc/feed/state.dart';
import '../utils/feed_error_mapper.dart';
import '../utils/feed_segment.dart';
import '../widgets/feed_error_view.dart';
import '../widgets/feed_list_view.dart';
import '../widgets/feed_loading_view.dart';
import '../widgets/feed_segment_bar.dart';
import '../widgets/feed_top_bar.dart';

/// The home tab: the post feed and the forums, switched in place by the
/// segmented control under the top bar.
///
/// Both views stay mounted, so a switch keeps each one's scroll position. Each
/// loads the first time it is shown — the route creates both blocs bare — so
/// opening the feed doesn't pay for the forums, and vice versa.
class FeedPage extends StatefulWidget {
  final FeedSegment initialSegment;

  const FeedPage({super.key, this.initialSegment = FeedSegment.feed});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late FeedSegment _segment = widget.initialSegment;
  final _loaded = <FeedSegment>{};

  /// Bumped when the home tab is re-tapped; the visible segment's view
  /// listens and scrolls to the top and refreshes.
  final _feedReselected = ValueNotifier(0);
  final _forumsReselected = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _ensureLoaded(_segment);
  }

  @override
  void dispose() {
    _feedReselected.dispose();
    _forumsReselected.dispose();
    super.dispose();
  }

  void _onReselect() {
    switch (_segment) {
      case FeedSegment.feed:
        _feedReselected.value++;
      case FeedSegment.forums:
        _forumsReselected.value++;
    }
  }

  void _ensureLoaded(FeedSegment segment) {
    if (!_loaded.add(segment)) return;
    switch (segment) {
      case FeedSegment.feed:
        context.read<FeedBloc>().add(const LoadFeed());
      case FeedSegment.forums:
        context.read<ForumsHomeBloc>().add(const LoadForumsHome());
    }
  }

  void _select(FeedSegment segment) {
    if (segment == _segment) return;
    HapticFeedback.selectionClick();
    _ensureLoaded(segment);
    setState(() => _segment = segment);
  }

  /// Pulls in what a composer may just have published. Only for views that
  /// have loaded — the other one fetches fresh when first opened anyway.
  void _onCreateClosed(CreateAction action) {
    switch (action) {
      case CreateAction.post when _loaded.contains(FeedSegment.feed):
        context.read<FeedBloc>().add(const RefreshFeed());
      case CreateAction.thread when _loaded.contains(FeedSegment.forums):
        context.read<ForumsHomeBloc>().add(const RefreshForumsHome());
      default:
        break;
    }
  }

  /// The empty feed's call to action — straight to the post composer.
  Future<void> _createPost() async {
    await context.push(CreateAction.post.route);
    if (mounted) _onCreateClosed(CreateAction.post);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FeedBloc, FeedState>(
          // The initial load is the only state that carries these; hand them
          // to the app-level queue, which the overlay above the router animates.
          listenWhen: (_, state) =>
              state is FeedLoaded && state.pendingBadgeCelebrations.isNotEmpty,
          listener: (context, state) {
            context.read<BadgeCelebrationCubit>().enqueue(
              (state as FeedLoaded).pendingBadgeCelebrations,
            );
          },
        ),
        BlocListener<FeedBloc, FeedState>(
          // The launch refresh failed but the cached posts are still up — say
          // so once, without replacing them with the full-screen error.
          listenWhen: (_, state) =>
              state is FeedLoaded && state.refreshError != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    feedErrorMessage(
                      AppLocalizations.of(context)!,
                      (state as FeedLoaded).refreshError!,
                    ),
                  ),
                ),
              );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const FeedTopBar(),
              FeedSegmentBar(
                active: _segment,
                onChanged: _select,
                trailing: _segment == FeedSegment.forums
                    ? const ForumsHomeActions()
                    : null,
              ),
              Expanded(
                child: IndexedStack(
                  index: _segment.index,
                  children: [
                    // TickerMode pauses the hidden view's animations
                    // (skeleton shimmer, spinners) while it is off-screen.
                    TickerMode(
                      enabled: _segment == FeedSegment.feed,
                      child: BlocBuilder<FeedBloc, FeedState>(
                        builder: (context, state) {
                          return switch (state) {
                            FeedInitial() ||
                            FeedLoading() => const FeedLoadingView(),
                            FeedError(:final code) => FeedErrorView(
                              message: feedErrorMessage(
                                AppLocalizations.of(context)!,
                                code,
                              ),
                              onRetry: () => context.read<FeedBloc>().add(
                                const LoadFeed(),
                              ),
                            ),
                            FeedLoaded() => FeedListView(
                              state: state,
                              onCreatePost: _createPost,
                              reselected: _feedReselected,
                            ),
                          };
                        },
                      ),
                    ),
                    TickerMode(
                      enabled: _segment == FeedSegment.forums,
                      child: ForumsHomeView(reselected: _forumsReselected),
                    ),
                  ],
                ),
              ),
              AppBottomNav(
                activeTab: AppBottomNavTab.feed,
                onCreateClosed: _onCreateClosed,
                onReselect: _onReselect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
