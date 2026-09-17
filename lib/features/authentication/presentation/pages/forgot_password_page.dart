import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/password_reset/bloc.dart';
import '../bloc/password_reset/event.dart';
import '../bloc/password_reset/state.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/email_validator.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// Step 1 of the password reset: ask for the address, email a code.
///
/// Supabase never reveals whether the address has an account, and neither does
/// this screen — it always moves on to the code entry step.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _canSubmit => isValidEmail(_emailController.text);

  void _onSubmit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<PasswordResetBloc>().add(
      ResetCodeRequested(_emailController.text.trim()),
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
            if (state is ResetCodeSent) {
              context.push('/forgot-password/verify', extra: state.email);
            } else if (state is PasswordResetFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(authErrorMessage(l10n, state.code))),
              );
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
                  const SizedBox(height: 48),
                  Text(
                    l10n.authForgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.authForgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.mute,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    label: l10n.authEmailLabel,
                    icon: Icons.mail_outline,
                    hint: l10n.authEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    maxLength: kEmailMaxLength,
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: l10n.authSendCode,
                    isLoading: state is PasswordResetLoading,
                    onPressed: _canSubmit ? _onSubmit : null,
                  ),
                  const SizedBox(height: 12),
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
