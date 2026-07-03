import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:car_social_media_app/features/garage/domain/usecases/get_reference_data.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/forum_shortcuts.dart';
import '../../../domain/usecases/get_forum_threads.dart';
import '../../../domain/usecases/get_forum_topics.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives one hub page: threads with sort + cursor paging, in-page topic
/// refinement, the models row for brand hubs, and saving the filter as a
/// shortcut.
@injectable
class ForumHubBloc extends Bloc<ForumHubEvent, ForumHubState> {
  final GetForumThreadsUseCase getThreads;
  final GetForumTopicsUseCase getTopics;
  final GetModelsByBrandUseCase getModelsByBrand;
  final CreateForumShortcutUseCase createShortcut;

  ForumHubBloc({
    required this.getThreads,
    required this.getTopics,
    required this.getModelsByBrand,
    required this.createShortcut,
  }) : super(const ForumHubState()) {
    on<LoadForumHub>(_onLoad);
    on<ChangeForumHubSort>(_onChangeSort);
    on<SelectForumHubTopic>(_onSelectTopic);
    on<LoadMoreForumHub>(_onLoadMore);
    on<SaveForumShortcut>(_onSaveShortcut);
  }

  Future<void> _onLoad(LoadForumHub event, Emitter<ForumHubState> emit) async {
    emit(ForumHubState(baseFilter: event.filter, isLoading: true));

    final filter = event.filter;
    final threadsFuture =
        getThreads(GetForumThreadsParams(filter: filter, sort: state.sort));
    // Models only matter on a brand hub (no model picked yet); topics feed the
    // refine chips of any car hub.
    final wantsModels = filter.brand != null && filter.model == null;
    final modelsFuture = wantsModels
        ? getModelsByBrand(GetModelsByBrandParams(brandId: filter.brand!.id))
        : null;
    final topicsFuture = filter.topic == null ? getTopics(NoParams()) : null;

    final threadsResult = await threadsFuture;
    final modelsResult = await modelsFuture;
    final topicsResult = await topicsFuture;

    ForumErrorCode? fatal;
    threadsResult.fold((f) => fatal = ForumErrorMapper.getCode(f), (_) {});
    if (fatal != null) {
      emit(state.copyWith(isLoading: false, errorCode: fatal));
      return;
    }

    emit(state.copyWith(
      isLoading: false,
      threads: threadsResult.fold((_) => const [], (p) => p.items),
      nextCursor: threadsResult.fold((_) => null, (p) => p.nextCursor),
      models: modelsResult?.fold((_) => const [], (m) => m) ?? const [],
      topics: topicsResult?.fold(
            (_) => const [],
            (groups) => [for (final g in groups) ...g.topics]
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
          ) ??
          const [],
    ));
  }

  Future<void> _onChangeSort(
    ChangeForumHubSort event,
    Emitter<ForumHubState> emit,
  ) async {
    if (event.sort == state.sort) return;
    emit(state.copyWith(sort: event.sort, isThreadsLoading: true));
    await _reloadThreads(emit);
  }

  Future<void> _onSelectTopic(
    SelectForumHubTopic event,
    Emitter<ForumHubState> emit,
  ) async {
    if (event.topic?.id == state.refinedTopic?.id) return;
    emit(state.copyWith(
      refinedTopic: event.topic,
      clearRefinedTopic: event.topic == null,
      isThreadsLoading: true,
    ));
    await _reloadThreads(emit);
  }

  Future<void> _reloadThreads(Emitter<ForumHubState> emit) async {
    final result = await getThreads(GetForumThreadsParams(
      filter: state.effectiveFilter,
      sort: state.sort,
    ));
    result.fold(
      (f) => emit(state.copyWith(
        isThreadsLoading: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (page) => emit(state.copyWith(
        isThreadsLoading: false,
        threads: page.items,
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreForumHub event,
    Emitter<ForumHubState> emit,
  ) async {
    if (state.isLoadingMore || state.isThreadsLoading || !state.hasMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));

    final result = await getThreads(GetForumThreadsParams(
      filter: state.effectiveFilter,
      sort: state.sort,
      cursor: state.nextCursor,
    ));
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) {
        final seen = state.threads.map((t) => t.id).toSet();
        final fresh = page.items.where((t) => seen.add(t.id));
        emit(state.copyWith(
          isLoadingMore: false,
          threads: [...state.threads, ...fresh],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ));
      },
    );
  }

  Future<void> _onSaveShortcut(
    SaveForumShortcut event,
    Emitter<ForumHubState> emit,
  ) async {
    if (state.isSavingShortcut) return;
    emit(state.copyWith(isSavingShortcut: true));

    final filter = state.effectiveFilter;
    final result = await createShortcut(CreateForumShortcutParams(
      name: event.name,
      // The backend derives the brand from the model, so send the brand only
      // for brand-level (model-less) filters.
      modelId: filter.model?.id,
      brandId: filter.model == null ? filter.brand?.id : null,
      topicId: filter.topic?.id,
      notify: event.notify,
    ));
    result.fold(
      (f) => emit(state.copyWith(
        isSavingShortcut: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (_) => emit(state.copyWith(isSavingShortcut: false, bumpSaved: true)),
    );
  }
}
