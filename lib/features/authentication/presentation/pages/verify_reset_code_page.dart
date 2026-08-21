import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/password_reset/bloc.dart';
import '../bloc/password_reset/event.dart';
import '../bloc/password_reset/state.dart';
import '../utils/auth_error_mapper.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/resend_email_button.dart';

/// Step 2 of the password reset: type the code from the email.
///
/// A typed code rather than a tapped link, so the email can be read on any
/// device — a recovery link would only complete on the device that started the
/// flow, because that is where the PKCE verifier lives.
class VerifyResetCodePage extends StatefulWidget {
  final String email;

  const VerifyResetCodePage({super.key, required this.email});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
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
    context.read<PasswordResetBloc>().add(
      ResetCodeSubmitted(email: widget.email, code: _codeController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state is ResetCodeVerified) {
              // The recovery session is live from here on; the new-password
              // screen needs nothing but the session itself.
              context.push('/forgot-password/new-password');
            } else if (state is ResetCodeSent) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.authResetCodeResent)),
              );
            } else if (state is PasswordResetFailed) {
              // A rejected code stays on screen; clearing it saves the user a
              // long-press to select-all before retyping.
              _codeController.clear();
              messenger.showSnackBar(
                SnackBar(content: Text(authErrorMessage(l10n, state.code))),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const AuthBrandHeader(),
                  const SizedBox(height: 48),
                  Text(
                    l10n.authVerifyCodeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.authVerifyCodeSubtitle(widget.email),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),
                  OtpCodeField(
                    controller: _codeController,
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: l10n.authVerifyCode,
                    isLoading: state is PasswordResetLoading,
                    onPressed: _canSubmit ? _onSubmit : null,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ResendEmailButton(
                      resendCount: state is ResetCodeSent ? state.attempt : 0,
                      onResend: () => context.read<PasswordResetBloc>().add(
                        ResetCodeRequested(widget.email),
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
