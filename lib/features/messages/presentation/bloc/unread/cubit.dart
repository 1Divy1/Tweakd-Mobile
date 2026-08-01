import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/shared/bloc/unread_count_cubit.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/usecases/get_unread_count.dart';
import '../../../domain/usecases/watch_inbox.dart';

/// App-level unread-DM counter behind the feed top bar's DMs badge. State is
/// the total unread count. Provided once at the app root so it survives page
/// changes and keeps its realtime subscription alive for the whole session.
///
/// Design: [refresh] pulls the authoritative count from the backend (called
/// on feed appear and when returning from the inbox, where reads clear
/// server-side). Between refreshes, `message.created` broadcasts increment it
/// optimistically for messages the viewer didn't send.
@injectable
class DmUnreadCubit extends UnreadCountCubit {
  final GetUnreadCountUseCase getUnreadCount;
  final WatchInboxMessagesUseCase watchInboxMessages;

  StreamSubscription<InboxMessageEvent>? _subscription;

  DmUnreadCubit({
    required this.getUnreadCount,
    required this.watchInboxMessages,
  }) {
    _subscription = watchInboxMessages().listen(_onInboxMessage);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  /// Optimistic bump for an inbound message the viewer didn't send.
  void _onInboxMessage(InboxMessageEvent event) {
    if (event.message.isMine || event.message.isDeleted) return;
    emit(state + 1);
  }

  /// Re-fetch the authoritative count. Failures (e.g. signed out) are
  /// swallowed — the badge is cosmetic and must never surface an error.
  @override
  Future<void> refresh() async {
    final result = await getUnreadCount(NoParams());
    result.fold((_) {}, (count) {
      if (!isClosed) emit(count);
    });
  }
}
