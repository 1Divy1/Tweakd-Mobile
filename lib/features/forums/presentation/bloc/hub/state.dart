import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../domain/entities/forum_filter.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../../domain/entities/forum_topic.dart';
import '../../utils/forum_error_mapper.dart';

/// State of one hub page. [baseFilter] is what the page was opened with; the
/// chip row narrows it further via [refinedTopic] without navigating.
/// One-shot signals ([savedTick], [actionErrorTick]) drive snackbars.
class ForumHubState extends Equatable {
  final ForumFilter baseFilter;
  final ForumTopicEntity? refinedTopic;
  final bool isLoading;
  final ForumErrorCode? errorCode;
  final List<CarModelEntity> models;
  final List<ForumTopicEntity> topics;
  final List<ForumThreadEntity> threads;
  final String? nextCursor;
  final bool isThreadsLoading;
  final bool isLoadingMore;
  final ForumThreadSort sort;
  final bool isSavingShortcut;
  final int savedTick;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const ForumHubState({
    this.baseFilter = const ForumFilter(),
    this.refinedTopic,
    this.isLoading = true,
    this.errorCode,
    this.models = const [],
    this.topics = const [],
    this.threads = const [],
    this.nextCursor,
    this.isThreadsLoading = false,
    this.isLoadingMore = false,
    this.sort = ForumThreadSort.hot,
    this.isSavingShortcut = false,
    this.savedTick = 0,
    this.actionError,
    this.actionErrorTick = 0,
  });

  /// What the thread list actually queries: the base filter, narrowed by the
  /// chip selection when the base has no topic of its own.
  ForumFilter get effectiveFilter =>
      baseFilter.topic != null ? baseFilter : baseFilter.withTopic(refinedTopic);

  bool get hasMore => nextCursor != null;

  /// Chips are shown for car hubs only (a topic hub can't refine further).
  bool get showsTopicChips => baseFilter.topic == null;

  ForumHubState copyWith({
    ForumFilter? baseFilter,
    ForumTopicEntity? refinedTopic,
    bool clearRefinedTopic = false,
    bool? isLoading,
    ForumErrorCode? errorCode,
    List<CarModelEntity>? models,
    List<ForumTopicEntity>? topics,
    List<ForumThreadEntity>? threads,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isThreadsLoading,
    bool? isLoadingMore,
    ForumThreadSort? sort,
    bool? isSavingShortcut,
    bool bumpSaved = false,
    ForumErrorCode? actionError,
  }) {
    return ForumHubState(
      baseFilter: baseFilter ?? this.baseFilter,
      refinedTopic:
          clearRefinedTopic ? null : (refinedTopic ?? this.refinedTopic),
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode ?? this.errorCode,
      models: models ?? this.models,
      topics: topics ?? this.topics,
      threads: threads ?? this.threads,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isThreadsLoading: isThreadsLoading ?? this.isThreadsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sort: sort ?? this.sort,
      isSavingShortcut: isSavingShortcut ?? this.isSavingShortcut,
      savedTick: bumpSaved ? savedTick + 1 : savedTick,
      actionError: actionError ?? this.actionError,
      actionErrorTick:
          actionError != null ? actionErrorTick + 1 : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
        baseFilter,
        refinedTopic,
        isLoading,
        errorCode,
        models,
        topics,
        threads,
        nextCursor,
        isThreadsLoading,
        isLoadingMore,
        sort,
        isSavingShortcut,
        savedTick,
        actionError,
        actionErrorTick,
      ];
}
