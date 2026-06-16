import 'dart:async';

import 'package:car_social_media_app/features/authentication/domain/usecases/auth/check_auth_status.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth/log_out.dart';
import '../../domain/usecases/login/email_password_signin.dart';
import '../../domain/usecases/login/google_signin.dart';
import '../utils/auth_error_mapper.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatus;
  final EmailPasswordSignIn loginUser;
  final GoogleSignIn googleSignIn;
  final LogOut logOut;

  AuthBloc({
    required this.checkAuthStatus,
    required this.loginUser,
    required this.googleSignIn,
    required this.logOut,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<EmailPasswordLoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {

    final result = await checkAuthStatus(NoParams());

    result.fold(
      (failure) {
        emit(AuthInitial());
      },
      (user) {
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  Future<void> _onLoginSubmitted(
    EmailPasswordLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = LoginParams(email: event.email, password: event.password);

    final result = await loginUser(params);

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  FutureOr<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    debugPrint("Event received: GoogleLoginRequested");

    final result = await googleSignIn(NoParams());
    debugPrint("googleSignIn usecase result: $result");

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getMessage(failure))),
      (user) {
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }
}
