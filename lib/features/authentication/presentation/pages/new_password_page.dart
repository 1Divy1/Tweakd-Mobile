import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/password_reset/bloc.dart';
import '../bloc/password_reset/event.dart';
import '../bloc/password_reset/state.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/password_policy.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_requirements.dart';

/// Step 3 of the password reset: choose the new password.
///
/// Only reachable with a live recovery session (established by the verified
/// code). Saving also revokes every other session, so anyone still signed in
/// elsewhere with the old password is kicked out.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text;

  bool get _canSubmit =>
      PasswordPolicy.isValid(_passwordController.text) && _passwordsMatch;

  void _onSubmit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<PasswordResetBloc>().add(
      NewPasswordSubmitted(_passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showMismatch =
        _confirmController.text.isNotEmpty && !_passwordsMatch;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<PasswordResetBloc, PasswordResetState>(
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state is PasswordResetCompleted) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.authPasswordUpdated)),
              );
              context.go(
                state.user.requiresOnboarding ? '/onboarding' : '/profile',
              );
            } else if (state is PasswordResetFailed) {
              messenger.showSnackBar(
                SnackBar(content: Text(authErrorMessage(l10n, state.code))),
              );
              // The recovery session expired (or this page was opened without
              // one). Nothing can be saved from here — send them back to start.
              if (state.code == AuthErrorCode.sessionExpired) {
                context.go('/login');
              }
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
                  const SizedBox(height: 44),
                  Text(
                    l10n.authNewPasswordTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.authNewPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    label: l10n.authNewPasswordLabel,
                    icon: Icons.lock_outline,
                    hint: l10n.authPasswordHintSignup,
                    controller: _passwordController,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    maxLength: kPasswordMaxLength,
                  ),
                  const SizedBox(height: 14),
                  PasswordRequirements(password: _passwordController.text),
                  const SizedBox(height: 18),
                  AuthTextField(
                    label: l10n.authConfirmPasswordLabel,
                    icon: Icons.lock_outline,
                    hint: l10n.authConfirmPasswordHint,
                    controller: _confirmController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    maxLength: kPasswordMaxLength,
                    onSubmitted: (_) => _onSubmit(),
                  ),
                  if (showMismatch) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.authPasswordsDoNotMatch,
                      style: const TextStyle(
                        color: AppColors.accentHot,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: l10n.authSavePassword,
                    isLoading: state is PasswordResetLoading,
                    onPressed: _canSubmit ? _onSubmit : null,
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
