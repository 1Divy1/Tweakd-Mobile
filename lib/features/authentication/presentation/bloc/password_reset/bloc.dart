import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/password_reset/request_password_reset.dart';
import '../../../domain/usecases/password_reset/update_password.dart';
import '../../../domain/usecases/password_reset/verify_password_reset_code.dart';
import '../../utils/auth_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives all three password-reset screens (request → verify code → new
/// password). Each screen gets its own instance from its route; nothing needs
/// to travel between them except the email address, because the recovery
/// session itself lives in the Supabase client after the code is verified.
@injectable
class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final RequestPasswordReset requestPasswordReset;
  final VerifyPasswordResetCode verifyPasswordResetCode;
  final UpdatePassword updatePassword;

  int _sendAttempts = 0;

  PasswordResetBloc({
    required this.requestPasswordReset,
    required this.verifyPasswordResetCode,
    required this.updatePassword,
  }) : super(PasswordResetInitial()) {
    on<ResetCodeRequested>(_onCodeRequested);
    on<ResetCodeSubmitted>(_onCodeSubmitted);
    on<NewPasswordSubmitted>(_onNewPasswordSubmitted);
  }

  Future<void> _onCodeRequested(
    ResetCodeRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await requestPasswordReset(event.email);

    result.fold(
      (failure) => emit(PasswordResetFailed(AuthErrorMapper.getCode(failure))),
      (_) => emit(ResetCodeSent(email: event.email, attempt: ++_sendAttempts)),
    );
  }

  Future<void> _onCodeSubmitted(
    ResetCodeSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await verifyPasswordResetCode(
      VerifyPasswordResetCodeParams(email: event.email, code: event.code),
    );

    result.fold(
      (failure) => emit(PasswordResetFailed(AuthErrorMapper.getCode(failure))),
      (_) => emit(ResetCodeVerified()),
    );
  }

  Future<void> _onNewPasswordSubmitted(
    NewPasswordSubmitted event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(PasswordResetLoading());

    final result = await updatePassword(event.password);

    result.fold(
      (failure) => emit(PasswordResetFailed(AuthErrorMapper.getCode(failure))),
      (user) => emit(PasswordResetCompleted(user)),
    );
  }
}
