import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message_user.dart';
import '../../../domain/entities/presence.dart';
import '../../../domain/usecases/get_inbox.dart';
import '../../../domain/usecases/message_actions.dart';
import '../../../domain/usecases/presence.dart';
import '../../../domain/usecases/watch_inbox.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the messages inbox: cursor-paged load, pull-to-refresh,
/// client-side search, hide ("delete chat"), plus live socket updates —
/// presence flips (online dots + ACTIVE NOW strip) and new-message pings
/// (row preview / ordering / unread badge).
@injectable
class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final GetInboxUseCase getInbox;
  final HideConversationUseCase hideConversation;
  final WatchPresenceUseCase watchPresence;
  final WatchInboxMessagesUseCase watchInboxMessages;

  StreamSubscription<PresenceEntity>? _presenceSubscription;
  StreamSubscription<InboxMessageEvent>? _messagesSubscription;

  InboxBloc({
    required this.getInbox,
    required this.hideConversation,
    required this.watchPresence,
    required this.watchInboxMessages,
  }) : super(const InboxInitial()) {
    on<LoadInbox>(_onLoad);
    on<RefreshInbox>(_onRefresh);
    on<LoadMoreInbox>(_onLoadMore);
    on<InboxSearchChanged>(_onSearchChanged);
    on<HideInboxConversation>(_onHide);
    on<InboxPresenceChanged>(_onPresenceChanged);
    on<InboxMessageReceived>(_onMessageReceived);

    _presenceSubscription = watchPresence()
        .listen((presence) => add(InboxPresenceChanged(presence)));
    _messagesSubscription = watchInboxMessages()
        .listen((event) => add(InboxMessageReceived(event)));
  }

  @override
  Future<void> close() async {
    await _presenceSubscription?.cancel();
    await _messagesSubscription?.cancel();
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
            activeNow: _activeNowFrom(appended),
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
          inbox: latest.inbox.copyWith(
            conversations: remaining,
            activeNow: _activeNowFrom(remaining),
          ),
        ));
      },
    );
  }

  void _onPresenceChanged(
    InboxPresenceChanged event,
    Emitter<InboxState> emit,
  ) {
    final current = state;
    if (current is! InboxLoaded) return;
    final presence = event.presence;

    final conversations = [
      for (final conversation in current.inbox.conversations)
        conversation.user.id == presence.userId
            ? conversation.copyWith(
                user: conversation.user.withPresence(
                  isOnline: presence.online,
                  lastSeenAt: presence.lastSeenAt,
                ),
              )
            : conversation,
    ];

    emit(current.copyWith(
      inbox: current.inbox.copyWith(
        conversations: conversations,
        activeNow: _activeNowFrom(conversations),
      ),
    ));
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

  /// ACTIVE NOW strip is always derived from the rows' presence flags.
  List<MessageUserEntity> _activeNowFrom(
    List<ConversationEntity> conversations,
  ) =>
      [
        for (final conversation in conversations)
          if (conversation.user.isOnline) conversation.user,
      ];
}
