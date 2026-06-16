import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/bloc.dart';
import '../bloc/event.dart';
import '../bloc/state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    context.read<AuthBloc>().add(
      EmailPasswordLoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onSocialTap(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        context.read<AuthBloc>().add(GoogleLoginRequested());
      case SocialProvider.apple:
      case SocialProvider.facebook:
        _showComingSoon('${_providerName(provider)} sign-in');
    }
  }

  String _providerName(SocialProvider provider) => switch (provider) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
    SocialProvider.facebook => 'Facebook',
  };

  void _showComingSoon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthenticatedRequiresOnboarding) {
              context.go('/onboarding');
            } else if (state is Authenticated) {
              context.go('/profile');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const AuthBrandHeader(),
                  const SizedBox(height: 36),
                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to get back in the garage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mute, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  AuthTextField(
                    label: 'Email',
                    icon: Icons.mail_outline,
                    hint: 'you@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showComingSoon('Password recovery'),
                      child: const Text(
                        'FORGOT PASSWORD?',
                        style: TextStyle(
                          color: AppColors.mute,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthPrimaryButton(
                    label: 'Sign in',
                    isLoading: isLoading,
                    onPressed: _onSignIn,
                  ),
                  const SizedBox(height: 28),
                  const AuthDivider(label: 'Or continue with'),
                  const SizedBox(height: 20),
                  SocialLoginButtons(
                    order: const [
                      SocialProvider.google,
                      SocialProvider.apple,
                      SocialProvider.facebook,
                    ],
                    onTap: _onSocialTap,
                  ),
                  const SizedBox(height: 28),
                  _buildSignUpLink(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/signup'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 15, color: AppColors.mute),
            children: [
              TextSpan(text: 'New to Tweakd? '),
              TextSpan(
                text: 'Create account',
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
