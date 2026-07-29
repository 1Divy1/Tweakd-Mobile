import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/usecases/get_notifications.dart';
import '../../../domain/usecases/mark_all_notifications_read.dart';
import '../../../domain/usecases/mark_notification_read.dart';
import '../../utils/notifications_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the notifications page: first load, pull-to-refresh, cursor paging
/// and optimistic read toggles. Marking read is fire-and-forget — the badge is
/// low-stakes, so a failed request leaves the optimistic flip in place.
@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationReadUseCase markNotificationRead;
  final MarkAllNotificationsReadUseCase markAllNotificationsRead;

  NotificationsBloc({
    required this.getNotifications,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
  }) : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<RefreshNotifications>(_onRefresh);
    on<LoadMoreNotifications>(_onLoadMore);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    final result = await getNotifications(const GetNotificationsParams());
    _emitFirstPage(emit, result);
  }

  Future<void> _onRefresh(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final result = await getNotifications(const GetNotificationsParams());
      final current = state;
      result.fold(
        (failure) {
          // A failed refresh shouldn't blow away what's already on screen.
          if (current is! NotificationsLoaded) {
            emit(NotificationsError(NotificationsErrorMapper.getCode(failure)));
          }
        },
        (page) => emit(NotificationsLoaded(
          items: page.items,
          nextCursor: page.nextCursor,
        )),
      );
    } finally {
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await getNotifications(
      GetNotificationsParams(cursor: current.nextCursor),
    );

    result.fold(
      // A failed "load more" keeps the list; just drop the footer loader.
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(NotificationsLoaded(
        items: _dedup([...current.items, ...page.items]),
        nextCursor: page.nextCursor,
      )),
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final index = current.items.indexWhere((n) => n.id == event.id);
    if (index == -1 || current.items[index].read) return;

    // Optimistic: flip locally, fire the request, no revert on failure.
    emit(current.copyWith(
      items: _replaceAt(
        current.items,
        index,
        current.items[index].copyWith(read: true),
      ),
    ));
    await markNotificationRead(event.id);
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded || !current.hasUnread) return;

    // Optimistic: flip every item, fire the request, no revert on failure.
    emit(current.copyWith(
      items: [for (final n in current.items) n.copyWith(read: true)],
    ));
    await markAllNotificationsRead(NoParams());
  }

  void _emitFirstPage(
    Emitter<NotificationsState> emit,
    Either<Failure, NotificationPageEntity> result,
  ) {
    result.fold(
      (failure) =>
          emit(NotificationsError(NotificationsErrorMapper.getCode(failure))),
      (page) => emit(NotificationsLoaded(
        items: page.items,
        nextCursor: page.nextCursor,
      )),
    );
  }

  List<NotificationEntity> _replaceAt(
    List<NotificationEntity> items,
    int index,
    NotificationEntity n,
  ) {
    final next = [...items];
    next[index] = n;
    return next;
  }

  List<NotificationEntity> _dedup(List<NotificationEntity> items) {
    final seen = <String>{};
    return [
      for (final n in items)
        if (seen.add(n.id)) n,
    ];
  }
}
