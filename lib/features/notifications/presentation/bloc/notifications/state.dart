import 'package:equatable/equatable.dart';

import '../../../domain/entities/notification.dart';
import '../../utils/notifications_error_mapper.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// The loaded list. [nextCursor] is null on the last page; [isLoadingMore]
/// guards the footer loader against duplicate fetches.
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> items;
  final String? nextCursor;
  final bool isLoadingMore;

  const NotificationsLoaded({
    required this.items,
    required this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  bool get hasUnread => items.any((n) => !n.read);

  NotificationsLoaded copyWith({
    List<NotificationEntity>? items,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return NotificationsLoaded(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, nextCursor, isLoadingMore];
}

class NotificationsError extends NotificationsState {
  final NotificationsErrorCode code;
  const NotificationsError(this.code);

  @override
  List<Object?> get props => [code];
}
