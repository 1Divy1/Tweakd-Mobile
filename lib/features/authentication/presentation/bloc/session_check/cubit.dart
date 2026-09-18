import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/failures/auth_failures.dart';
import '../../../domain/usecases/auth/check_auth_status.dart';
import 'state.dart';

/// Confirms, after the fact, a launch that went straight to the feed on the
/// strength of the device's own memory (`GetCachedAuthStatusUseCase`).
///
/// The splash used to wait on this exact `profiles` lookup before showing
/// anything. It now runs while the feed is already up, and only an answer that
/// contradicts the launch changes the state. A network error is deliberately
/// *not* one: an offline user keeps their cached feed rather than being thrown
/// out to sign-up.
@injectable
class SessionCheckCubit extends Cubit<SessionCheckState> {
  final CheckAuthStatusUseCase checkAuthStatus;

  SessionCheckCubit({required this.checkAuthStatus})
    : super(const SessionCheckPending());

  Future<void> check() async {
    final result = await checkAuthStatus(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) {
        if (failure is UnauthenticatedFailure) {
          emit(const SessionCheckSignedOut());
        }
      },
      (user) {
        if (user.requiresOnboarding) {
          emit(const SessionCheckRequiresOnboarding());
        }
      },
    );
  }
}
