import 'package:equatable/equatable.dart';

import '../../../domain/entities/tagged_item.dart';
import '../../utils/tag_error_mapper.dart';

sealed class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => [];
}

/// Nothing fetched yet — also the signal the section uses to know it must
/// trigger the lazy first load.
class TagsInitial extends TagsState {
  const TagsInitial();
}

class TagsLoading extends TagsState {
  const TagsLoading();
}

/// The loaded feed. [nextCursor] being null is the only end-of-feed signal, so
/// [hasMore] never infers "last page" from a short page.
///
/// [removingIds] holds the [TaggedItemEntity.id]s with an untag in flight;
/// [removeError] is a one-shot code the UI shows in a snackbar and then clears.
class TagsLoaded extends TagsState {
  final List<TaggedItemEntity> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final Set<String> removingIds;
  final TagErrorCode? removeError;

  const TagsLoaded({
    required this.items,
    required this.nextCursor,
    this.isLoadingMore = false,
    this.removingIds = const {},
    this.removeError,
  });

  bool get hasMore => nextCursor != null;

  TagsLoaded copyWith({
    List<TaggedItemEntity>? items,
    String? nextCursor,
    bool? isLoadingMore,
    Set<String>? removingIds,
    TagErrorCode? removeError,
    bool clearRemoveError = false,
  }) {
    return TagsLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      removingIds: removingIds ?? this.removingIds,
      removeError: clearRemoveError ? null : (removeError ?? this.removeError),
    );
  }

  @override
  List<Object?> get props =>
      [items, nextCursor, isLoadingMore, removingIds, removeError];
}

class TagsError extends TagsState {
  final TagErrorCode code;
  const TagsError(this.code);

  @override
  List<Object?> get props => [code];
}
