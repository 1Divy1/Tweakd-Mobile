import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation.dart';
import '../../utils/messages_error_mapper.dart';

sealed class InboxState extends Equatable {
  const InboxState();

  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {
  const InboxInitial();
}

class InboxLoading extends InboxState {
  const InboxLoading();
}

class InboxLoaded extends InboxState {
  final InboxEntity inbox;
  final String query;
  final bool isLoadingMore;

  const InboxLoaded({
    required this.inbox,
    this.query = '',
    this.isLoadingMore = false,
  });

  /// Conversations matching the search field (username or preview text).
  List<ConversationEntity> get filteredConversations {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return inbox.conversations;
    return inbox.conversations
        .where((c) =>
            c.user.username.toLowerCase().contains(needle) ||
            c.preview.toLowerCase().contains(needle))
        .toList();
  }

  bool get isSearching => query.trim().isNotEmpty;

  InboxLoaded copyWith({
    InboxEntity? inbox,
    String? query,
    bool? isLoadingMore,
  }) =>
      InboxLoaded(
        inbox: inbox ?? this.inbox,
        query: query ?? this.query,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [inbox, query, isLoadingMore];
}

class InboxError extends InboxState {
  final MessagesErrorCode code;
  const InboxError(this.code);

  @override
  List<Object?> get props => [code];
}
