import 'dart:async';

import 'package:car_social_media_app/features/authentication/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login/email_password_signin.dart';
import '../../domain/usecases/login/google_signin.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final EmailPasswordSignIn _loginUser;
  final GoogleSignIn _googleSignIn;

  AuthBloc(this._loginUser, this._googleSignIn) : super(AuthInitial()) {
    // TODO: implement CheckAuthentication event handler

    on<EmailPasswordLoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
  }

  Future<void> _onLoginSubmitted(EmailPasswordLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final params = LoginParams(
      email: event.email,
      password: event.password,
    );

    final result = await _loginUser(params);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  FutureOr<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _googleSignIn(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        debugPrint(
          'Google sign-in success: id=${user.id}, name=${user.name}, email=${user.email}, photo=${user.profilePictureUrl}',
        );
        emit(Authenticated(user));
      },
    );
  }
}
