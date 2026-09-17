import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/shared/bloc/unread_count_cubit.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_unread_count.dart';

/// App-level unread-DM counter behind the feed top bar's DMs badge. State is
/// the total unread count. Provided once at the app root so it survives page
/// changes.
///
/// Design: no live connection — holding one app-wide would keep a Supabase
/// Realtime socket open for every signed-in user, and peak sockets are what
/// Realtime bills. [refresh] pulls the authoritative count from the backend
/// instead: on feed appear, when returning from the inbox (where reads clear
/// server-side), on a DM push while foregrounded (`PushMessageListener`), and
/// here, whenever the app comes back to the foreground — pushes received
/// while backgrounded never reach the listener.
@injectable
class DmUnreadCubit extends UnreadCountCubit {
  final GetUnreadCountUseCase getUnreadCount;

  late final AppLifecycleListener _lifecycle;

  DmUnreadCubit({required this.getUnreadCount}) {
    _lifecycle = AppLifecycleListener(onResume: refresh);
  }

  @override
  Future<void> close() {
    _lifecycle.dispose();
    return super.close();
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
