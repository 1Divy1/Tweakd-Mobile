import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_events.dart';
import '../../../../../core/analytics/analytics_service.dart';

import '../../../domain/usecases/signup/email_password_signup.dart';
import '../../../domain/usecases/signup/resend_signup_email.dart';
import '../../../domain/usecases/signup/verify_signup_code.dart';
import '../../utils/auth_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the email/password sign-up form and the "check your inbox" screen.
///
/// Sign-in lives in the root `AuthBloc`; this one is provided per route so the
/// form starts clean every time it is opened.
@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final EmailPasswordSignUp signUp;
  final VerifySignUpCode verifySignUpCode;
  final ResendSignUpEmail resendSignUpEmail;
  final AnalyticsService analytics;

  /// Counts resends so each success emits a distinct state.
  int _resendAttempts = 0;

  SignUpBloc({
    required this.signUp,
    required this.verifySignUpCode,
    required this.resendSignUpEmail,
    this.analytics = const NoopAnalyticsService(),
  }) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<SignUpCodeSubmitted>(_onCodeSubmitted);
    on<ConfirmationEmailResendRequested>(_onResendRequested);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        analyticsConsent: event.analyticsConsent,
      ),
    );

    result.fold(
      (failure) => emit(SignUpFailed(AuthErrorMapper.getCode(failure))),
      (signUpResult) {
        if (signUpResult.requiresEmailConfirmation ||
            signUpResult.user == null) {
          emit(SignUpAwaitingConfirmation(event.email));
        } else {
          emit(SignUpCompleted(signUpResult.user!));
        }
      },
    );
  }

  Future<void> _onCodeSubmitted(
    SignUpCodeSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    final result = await verifySignUpCode(
      VerifySignUpCodeParams(email: event.email, code: event.code),
    );

    result.fold(
      (failure) => emit(SignUpFailed(AuthErrorMapper.getCode(failure))),
      // A verified code signs the user in, so this is the same terminal state
      // the confirmation-off path lands on.
      (user) {
        // The account only becomes real here — before the code, it is dormant.
        analytics.track(AnalyticsEvents.signedUp, {'method': 'email'});
        emit(SignUpCompleted(user));
      },
    );
  }

  Future<void> _onResendRequested(
    ConfirmationEmailResendRequested event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    final result = await resendSignUpEmail(event.email);

    result.fold(
      (failure) => emit(SignUpFailed(AuthErrorMapper.getCode(failure))),
      (_) => emit(SignUpResendSucceeded(++_resendAttempts)),
    );
  }
}
