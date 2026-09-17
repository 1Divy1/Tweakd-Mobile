import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/usecases/get_inbox.dart';
import '../../../domain/usecases/message_actions.dart';
import '../../../domain/usecases/watch_inbox.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the messages inbox: cursor-paged load, pull-to-refresh,
/// client-side search, hide ("delete chat"), plus live Supabase Realtime
/// new-message broadcasts (row preview / ordering / unread badge). The bloc's
/// subscription is what holds the live connection open while the inbox is on
/// screen.
@injectable
class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final GetInboxUseCase getInbox;
  final HideConversationUseCase hideConversation;
  final WatchInboxMessagesUseCase watchInboxMessages;

  StreamSubscription<InboxLiveEvent>? _liveSubscription;

  InboxBloc({
    required this.getInbox,
    required this.hideConversation,
    required this.watchInboxMessages,
  }) : super(const InboxInitial()) {
    on<LoadInbox>(_onLoad);
    on<RefreshInbox>(_onRefresh);
    on<LoadMoreInbox>(_onLoadMore);
    on<InboxSearchChanged>(_onSearchChanged);
    on<HideInboxConversation>(_onHide);
    on<InboxMessageReceived>(_onMessageReceived);

    _liveSubscription = watchInboxMessages().listen((event) {
      switch (event) {
        case InboxMessageEvent():
          add(InboxMessageReceived(event));
        case InboxLiveConnected():
          // Pings sent while the connection was down are gone. Before the
          // first load lands there is nothing to catch up — LoadInbox is
          // already fetching.
          if (state is InboxLoaded) add(const RefreshInbox());
      }
    });
  }

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadInbox event, Emitter<InboxState> emit) async {
    emit(const InboxLoading());
    final result = await getInbox(null);
    result.fold(
      (failure) => emit(InboxError(MessagesErrorMapper.getCode(failure))),
      (inbox) => emit(InboxLoaded(inbox: inbox)),
    );
  }

  Future<void> _onRefresh(RefreshInbox event, Emitter<InboxState> emit) async {
    try {
      final result = await getInbox(null);
      result.fold(
        (_) {}, // keep the current list on a failed refresh
        (inbox) {
          final current = state;
          emit(current is InboxLoaded
              ? current.copyWith(inbox: inbox, isLoadingMore: false)
              : InboxLoaded(inbox: inbox));
        },
      );
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreInbox event,
    Emitter<InboxState> emit,
  ) async {
    final current = state;
    if (current is! InboxLoaded ||
        current.isLoadingMore ||
        current.inbox.nextCursor == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final result = await getInbox(current.inbox.nextCursor);

    final latest = state;
    if (latest is! InboxLoaded) return;
    result.fold(
      (_) => emit(latest.copyWith(isLoadingMore: false)),
      (page) {
        final knownIds = {for (final c in latest.inbox.conversations) c.id};
        final appended = [
          ...latest.inbox.conversations,
          for (final conversation in page.conversations)
            if (!knownIds.contains(conversation.id)) conversation,
        ];
        emit(latest.copyWith(
          inbox: InboxEntity(
            requestsCount: latest.inbox.requestsCount,
            requestsPreviewNames: latest.inbox.requestsPreviewNames,
            conversations: appended,
            nextCursor: page.nextCursor,
          ),
          isLoadingMore: false,
        ));
      },
    );
  }

  void _onSearchChanged(InboxSearchChanged event, Emitter<InboxState> emit) {
    final current = state;
    if (current is InboxLoaded) emit(current.copyWith(query: event.query));
  }

  Future<void> _onHide(
    HideInboxConversation event,
    Emitter<InboxState> emit,
  ) async {
    final current = state;
    if (current is! InboxLoaded) return;

    final result = await hideConversation(event.conversationId);
    final latest = state;
    if (latest is! InboxLoaded) return;
    result.fold(
      (_) {}, // row stays on failure — nothing was hidden server-side
      (_) {
        final remaining = [
          for (final conversation in latest.inbox.conversations)
            if (conversation.id != event.conversationId) conversation,
        ];
        emit(latest.copyWith(
          inbox: latest.inbox.copyWith(conversations: remaining),
        ));
      },
    );
  }

  void _onMessageReceived(
    InboxMessageReceived event,
    Emitter<InboxState> emit,
  ) {
    final current = state;
    if (current is! InboxLoaded) return;
    final ping = event.event;

    final index = current.inbox.conversations
        .indexWhere((conversation) => conversation.id == ping.conversationId);
    if (index < 0) {
      // Brand-new (or hidden) conversation — refetch page 1 quietly.
      add(const RefreshInbox());
      return;
    }

    final row = current.inbox.conversations[index];
    final updated = ConversationEntity(
      id: row.id,
      user: row.user,
      preview: ping.message.isDeleted ? '' : (ping.message.text ?? ''),
      previewKind: ping.message.isDeleted
          ? ConversationPreviewKind.deleted
          : ConversationPreviewKind.text,
      isLastMessageMine: ping.message.isMine,
      lastMessageAt: ping.message.sentAt,
      unreadCount: ping.message.isMine ? row.unreadCount : row.unreadCount + 1,
      lastMessageSeen: false,
    );

    // Most recent activity floats to the top.
    final conversations = [
      updated,
      for (var i = 0; i < current.inbox.conversations.length; i++)
        if (i != index) current.inbox.conversations[i],
    ];
    emit(current.copyWith(
      inbox: current.inbox.copyWith(conversations: conversations),
    ));
  }
}
