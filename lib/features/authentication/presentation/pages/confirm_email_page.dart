import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/signup/bloc.dart';
import '../bloc/signup/event.dart';
import '../bloc/signup/state.dart';
import '../utils/auth_error_mapper.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/resend_email_button.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// Confirms a new account with the code from the sign-up email.
///
/// Reached after sign-up, and from a sign-in attempt on an account whose
/// address was never confirmed. The confirm-signup template renders
/// `{{ .Token }}` rather than a link, so the code — not a deep link — is what
/// activates the account; that also means the email can be read on any device.
///
/// Verifying signs the user in, so this screen leads straight into onboarding.
class ConfirmEmailPage extends StatefulWidget {
  final String email;

  const ConfirmEmailPage({super.key, required this.email});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _codeController.text.isNotEmpty;

  void _onSubmit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<SignUpBloc>().add(
      SignUpCodeSubmitted(email: widget.email, code: _codeController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            switch (state) {
              // The code was accepted and the account is active — a brand new
              // account always needs onboarding, but route on the flag rather
              // than assuming it.
              case SignUpCompleted(:final user):
                context.go(
                  user.requiresOnboarding ? '/onboarding' : '/feed',
                );
              case SignUpResendSucceeded():
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.authConfirmEmailResent)),
                );
              case SignUpFailed(:final code):
                // Clear the rejected code so the next attempt starts from an
                // empty field rather than a select-all.
                _codeController.clear();
                messenger.showSnackBar(
                  SnackBar(content: Text(authErrorMessage(l10n, code))),
                );
              default:
                break;
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const AuthBrandHeader(),
                  const SizedBox(height: 40),
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.authConfirmEmailTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.authConfirmEmailSubtitle(widget.email),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mute,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  OtpCodeField(
                    controller: _codeController,
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: l10n.authConfirmEmailVerify,
                    isLoading: state is SignUpLoading,
                    onPressed: _canSubmit ? _onSubmit : null,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ResendEmailButton(
                      resendCount: state is SignUpResendSucceeded
                          ? state.attempt
                          : 0,
                      onResend: () => context.read<SignUpBloc>().add(
                        ConfirmationEmailResendRequested(widget.email),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink,
                      ),
                      child: Text(
                        l10n.authBackToSignIn,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
