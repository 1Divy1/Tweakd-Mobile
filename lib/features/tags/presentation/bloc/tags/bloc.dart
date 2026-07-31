import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../domain/entities/tagged_item.dart';
import '../../../domain/usecases/get_my_tags.dart';
import '../../../domain/usecases/get_tags_by_username.dart';
import '../../../domain/usecases/remove_tag.dart';
import '../../utils/tag_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the profile "Tags" tab: a cursor-paginated feed of everything the
/// profile's owner (or one of their cars) was tagged in, across posts, post
/// comments, forum threads and forum replies.
///
/// [_username] is null for the signed-in user's own feed (`/tags/me`) and set
/// for someone else's; it's captured on the first [LoadTags] and reused for
/// refreshes and later pages.
@injectable
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final GetMyTagsUseCase getMyTags;
  final GetTagsByUsernameUseCase getTagsByUsername;
  final RemoveTagUseCase removeTag;

  String? _username;

  TagsBloc({
    required this.getMyTags,
    required this.getTagsByUsername,
    required this.removeTag,
  }) : super(const TagsInitial()) {
    on<LoadTags>(_onLoad);
    on<RefreshTags>(_onRefresh);
    on<LoadMoreTags>(_onLoadMore);
    on<RemoveTagFromItem>(_onRemoveTag);
    on<ClearTagRemoveError>(_onClearRemoveError);
  }

  Future<void> _onLoad(LoadTags event, Emitter<TagsState> emit) async {
    _username = event.username;
    emit(const TagsLoading());
    _emitFirstPage(emit, await _fetch());
  }

  Future<void> _onRefresh(RefreshTags event, Emitter<TagsState> emit) async {
    final current = state;
    final result = await _fetch();
    result.fold(
      (failure) {
        // A failed refresh shouldn't blow away what's already on screen.
        if (current is! TagsLoaded) {
          emit(TagsError(TagErrorMapper.getCode(failure)));
        }
      },
      (page) => emit(TagsLoaded(
        items: _dedup(page.items),
        nextCursor: page.nextCursor,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreTags event, Emitter<TagsState> emit) async {
    final current = state;
    if (current is! TagsLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final result = await _fetch(cursor: current.nextCursor);

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(TagsLoaded(
        items: _dedup([...current.items, ...page.items]),
        nextCursor: page.nextCursor,
        removingIds: current.removingIds,
      )),
    );
  }

  Future<void> _onRemoveTag(
    RemoveTagFromItem event,
    Emitter<TagsState> emit,
  ) async {
    final current = state;
    if (current is! TagsLoaded) return;
    final id = event.item.id;
    if (current.removingIds.contains(id)) return;

    emit(current.copyWith(removingIds: {...current.removingIds, id}));

    final result = await removeTag(RemoveTagParams(
      kind: event.item.kind,
      targetId: event.item.targetId,
    ));

    final latest = state;
    if (latest is! TagsLoaded) return;
    final stillRemoving = {...latest.removingIds}..remove(id);

    result.fold(
      (failure) => emit(latest.copyWith(
        removingIds: stillRemoving,
        removeError: TagErrorMapper.getCode(failure),
      )),
      // 204 confirms the untag, so the row is dropped locally rather than
      // re-fetching the whole feed.
      (_) => emit(latest.copyWith(
        items: [
          for (final i in latest.items)
            if (i.id != id) i,
        ],
        removingIds: stillRemoving,
        clearRemoveError: true,
      )),
    );
  }

  void _onClearRemoveError(
    ClearTagRemoveError event,
    Emitter<TagsState> emit,
  ) {
    final current = state;
    if (current is TagsLoaded && current.removeError != null) {
      emit(current.copyWith(clearRemoveError: true));
    }
  }

  Future<Either<Failure, TaggedItemPageEntity>> _fetch({String? cursor}) {
    final username = _username;
    return username == null
        ? getMyTags(GetMyTagsParams(cursor: cursor))
        : getTagsByUsername(
            GetTagsByUsernameParams(username: username, cursor: cursor),
          );
  }

  void _emitFirstPage(
    Emitter<TagsState> emit,
    Either<Failure, TaggedItemPageEntity> result,
  ) {
    result.fold(
      (failure) => emit(TagsError(TagErrorMapper.getCode(failure))),
      (page) => emit(TagsLoaded(
        items: _dedup(page.items),
        nextCursor: page.nextCursor,
      )),
    );
  }

  /// The backend dedups within a page, but an item can shift across pages
  /// between fetches, so merges are deduped by (kind, target) here too.
  List<TaggedItemEntity> _dedup(List<TaggedItemEntity> items) {
    final seen = <String>{};
    return [
      for (final i in items)
        if (seen.add(i.id)) i,
    ];
  }
}
