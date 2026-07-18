import 'package:injectable/injectable.dart';

import '../../../../../core/shared/bloc/unread_count_cubit.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_unread_notifications_count.dart';

/// App-level unread-notifications counter behind the feed top bar's
/// notifications badge. State is the total unread count. Provided once at the
/// app root so it survives page changes.
///
/// Unlike the DMs badge there is no socket — notifications have no live
/// channel — so [refresh] (called on feed appear and when returning from the
/// notifications page) is the only source of truth.
@injectable
class NotificationsUnreadCubit extends UnreadCountCubit {
  final GetUnreadNotificationsCountUseCase getUnreadCount;

  NotificationsUnreadCubit({required this.getUnreadCount});

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
