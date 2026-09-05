import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/deeplinks/deep_link_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/signup/bloc.dart';
import '../bloc/signup/event.dart';
import '../bloc/signup/state.dart';
import '../bloc/state.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/email_validator.dart';
import '../utils/password_policy.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_requirements.dart';
import '../widgets/social_login_buttons.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _showPasswordRequirements = false;
  bool _showTermsError = false;

  /// Latches while the Apple flow is being launched. On Android that flow hands
  /// off to an external browser, and there is a short window before the browser
  /// takes over where this page is still live and the button still tappable —
  /// without the latch a second tap launches the whole flow twice.
  bool _appleLaunching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Drives the live password checklist and the enabled state of the button.
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

  /// The account button unlocks once the address looks like an address and
  /// the terms box is ticked. Password rules are checked on tap instead, so
  /// the checklist only appears once the user actually tries to submit.
  bool get _canSubmit => _agreedToTerms && isValidEmail(_emailController.text);

  void _onCreateAccount() {
    if (!_canSubmit) return;
    if (!PasswordPolicy.isValid(_passwordController.text)) {
      setState(() => _showPasswordRequirements = true);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<SignUpBloc>().add(
      SignUpSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onSocialTap(SocialProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    if (!_agreedToTerms) {
      setState(() => _showTermsError = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authAgreeToTermsFirst)));
      return;
    }
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

  void _showError(AuthErrorCode code) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(authErrorMessage(l10n, code))));
  }

  void _routeAuthenticated(AuthState state) {
    if (state is AuthenticatedRequiresOnboarding) {
      context.go('/onboarding');
    } else if (state is Authenticated) {
      context.go('/profile');
      // A share link parked before sign-up follows the new account to the
      // build that brought them here.
      getIt<DeepLinkService>().flushPending();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Social sign-in still goes through the app-wide AuthBloc.
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  // An iOS Apple cancel never backgrounds the app, so `resumed`
                  // may not fire — this is what releases the latch there.
                  if (_appleLaunching) {
                    setState(() => _appleLaunching = false);
                  }
                  _showError(state.code);
                } else {
                  _routeAuthenticated(state);
                }
              },
            ),
            BlocListener<SignUpBloc, SignUpState>(
              listener: (context, state) {
                switch (state) {
                  // Normal path: Supabase created the account and emailed the
                  // confirmation link. No session exists yet.
                  case SignUpAwaitingConfirmation(:final email):
                    context.go('/signup/confirm', extra: email);
                  // Only reachable if email confirmation is turned off for the
                  // project — the user is already signed in.
                  case SignUpCompleted(:final user):
                    context.go(
                      user.requiresOnboarding ? '/onboarding' : '/profile',
                    );
                  case SignUpFailed(:final code):
                    _showError(code);
                  default:
                    break;
                }
              },
            ),
          ],
          child: BlocBuilder<SignUpBloc, SignUpState>(
            builder: (context, signUpState) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isLoading =
                      signUpState is SignUpLoading || authState is AuthLoading;
                  return _buildForm(context, l10n, isLoading);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            // Force the column to fill at least the viewport so the
            // Spacer below has room to push the footer down. Content
            // still scrolls on short screens / when the keyboard shows.
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Header: brand + title (fixed inner rhythm) ----
                  const SizedBox(height: 16),
                  const AuthBrandHeader(),
                  const SizedBox(height: 28),
                  Text(
                    l10n.authSignupTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authSignupSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.mute, fontSize: 15),
                  ),

                  // ---- Form: fixed gaps between fields ----
                  // The username is asked for during onboarding, where it is
                  // checked against the backend for availability — collecting
                  // it here too would either duplicate that check or reserve a
                  // handle for an account that is never confirmed.
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
                    hint: l10n.authPasswordHintSignup,
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    maxLength: kPasswordMaxLength,
                    onSubmitted: (_) => _onCreateAccount(),
                  ),
                  if (_showPasswordRequirements) ...[
                    const SizedBox(height: 14),
                    PasswordRequirements(password: _passwordController.text),
                  ],
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(l10n),
                  const SizedBox(height: 20),
                  AuthPrimaryButton(
                    label: l10n.authCreateAccount,
                    isLoading: isLoading,
                    onPressed: _canSubmit ? _onCreateAccount : null,
                  ),
                  const SizedBox(height: 24),
                  AuthDivider(label: l10n.authOrSignUpWith),
                  const SizedBox(height: 20),
                  SocialLoginButtons(
                    order: const [SocialProvider.google, SocialProvider.apple],
                    onTap: _onSocialTap,
                  ),
                  // ---- Flexible gap eats the leftover height ----
                  const Spacer(),

                  // ---- Footer: sign-in link ----
                  const SizedBox(height: 24),
                  _buildSignInLink(context, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) => setState(() {
              _agreedToTerms = value ?? false;
              if (_agreedToTerms) _showTermsError = false;
            }),
            activeColor: AppColors.accent,
            side: BorderSide(
              color: _showTermsError ? Colors.red : AppColors.line,
              width: _showTermsError ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mute,
                height: 1.4,
              ),
              children: [
                TextSpan(text: l10n.authTermsPrefix),
                TextSpan(
                  text: l10n.authTermsTerms,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: l10n.authTermsAnd),
                TextSpan(
                  text: l10n.authTermsPrivacy,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15, color: AppColors.mute),
            children: [
              TextSpan(text: l10n.authHaveAccountPrefix),
              TextSpan(
                text: l10n.authSignIn,
                style: const TextStyle(
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
