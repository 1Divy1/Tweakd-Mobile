import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/deeplinks/deep_link_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/email_validator.dart';
import '../utils/password_policy.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../core/shared/layout/app_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Latches while the Apple flow is being launched. On Android that flow hands
  /// off to an external browser, and there is a short window before the browser
  /// takes over where this page is still live and the button still tappable —
  /// without the latch a second tap launches the whole flow twice.
  bool _appleLaunching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Keeps the sign-in button in step with what has been typed.
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      EmailPasswordLoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  /// Only a shape check — the password policy is not re-applied here, since an
  /// account created before a policy change must still be able to sign in.
  bool get _canSubmit =>
      isValidEmail(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  void _onSocialTap(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        context.read<AuthBloc>().add(GoogleLoginRequested());
      case SocialProvider.apple:
        if (_appleLaunching) return;
        setState(() => _appleLaunching = true);
        context.read<AuthBloc>().add(AppleLoginRequested());
    }
  }

  /// Releases the Apple latch when the app comes back to the foreground. On
  /// Android that is the return from the external browser — whether the user
  /// signed in or abandoned the page — and a browser gives no "user gave up"
  /// callback, so this is what makes the button usable again after a cancel.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _appleLaunching) {
      setState(() => _appleLaunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthenticatedRequiresOnboarding) {
              context.go('/onboarding');
            } else if (state is Authenticated) {
              context.go('/feed');
              // A share link opened before sign-in was parked rather than
              // followed. Releasing it here lands the user on the build their
              // friend sent them, which is the whole point of the link.
              getIt<DeepLinkService>().flushPending();
            } else if (state is AuthError) {
              // An iOS Apple cancel never backgrounds the app, so `resumed`
              // may not fire — this is what releases the latch there.
              if (_appleLaunching) {
                setState(() => _appleLaunching = false);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(authErrorMessage(l10n, state.code))),
              );
              // The account exists but was never confirmed: the only way
              // forward is the confirmation email, so go straight there with a
              // resend button rather than leaving the user stuck on a
              // failed sign-in.
              if (state.code == AuthErrorCode.emailNotConfirmed) {
                context.push(
                  '/signup/confirm',
                  extra: _emailController.text.trim(),
                );
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                  child: ConstrainedBox(
                    // Force the column to fill at least the viewport so the
                    // Spacer below has room to push the sign-up link down.
                    // Content still scrolls on short screens / when the
                    // keyboard shows.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          const AuthBrandHeader(),
                          const SizedBox(height: 36),
                          Text(
                            l10n.authLoginTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authLoginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mute,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            label: l10n.authEmailLabel,
                            icon: Icons.mail_outline,
                            hint: l10n.authEmailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            maxLength: kEmailMaxLength,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: l10n.authPasswordLabel,
                            icon: Icons.lock_outline,
                            hint: l10n.authPasswordHintLogin,
                            controller: _passwordController,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            maxLength: kPasswordMaxLength,
                            onSubmitted: (_) => _onSignIn(),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: Text(
                                l10n.authForgotPassword,
                                style: TextStyle(
                                  color: AppColors.mute,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthPrimaryButton(
                            label: l10n.authSignIn,
                            isLoading: isLoading,
                            onPressed: _canSubmit ? _onSignIn : null,
                          ),
                          const SizedBox(height: 28),
                          AuthDivider(label: l10n.authOrContinueWith),
                          const SizedBox(height: 20),
                          SocialLoginButtons(
                            order: const [
                              SocialProvider.google,
                              SocialProvider.apple,
                            ],
                            onTap: _onSocialTap,
                          ),

                          // ---- Flexible gap eats the leftover height ----
                          const Spacer(),

                          const SizedBox(height: 24),
                          _buildSignUpLink(context, l10n),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/signup'),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15, color: AppColors.mute),
            children: [
              TextSpan(text: l10n.authNoAccountPrefix),
              TextSpan(
                text: l10n.authCreateAccount,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
