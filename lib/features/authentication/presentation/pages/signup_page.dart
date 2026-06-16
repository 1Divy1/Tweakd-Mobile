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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    // Email/password sign up has no backend yet; the social and email login
    // flows live in AuthBloc. Surface a placeholder until it is wired up.
    _showComingSoon('Email sign up');
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
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: ConstrainedBox(
                    // Force the column to fill at least the viewport so the
                    // Spacer below has room to push the footer down. Content
                    // still scrolls on short screens / when the keyboard shows.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ---- Header: brand + title (fixed inner rhythm) ----
                          const SizedBox(height: 16),
                          const AuthBrandHeader(),
                          const SizedBox(height: 28),
                          const Text(
                            'Join the grid',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your account and build your garage.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mute,
                              fontSize: 15,
                            ),
                          ),

                          // ---- Form: fixed gaps between fields ----
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
                            label: 'Username',
                            icon: Icons.alternate_email,
                            hint: 'username',
                            controller: _usernameController,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            hint: 'Create a password',
                            controller: _passwordController,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 24),
                          AuthPrimaryButton(
                            label: 'Create account',
                            isLoading: isLoading,
                            onPressed: _onCreateAccount,
                          ),
                          const SizedBox(height: 16),
                          _buildTermsText(),

                          // ---- Flexible gap eats the leftover height ----
                          const Spacer(),

                          // ---- Footer: divider + social + sign-in link ----
                          const SizedBox(height: 24),
                          const AuthDivider(label: 'Or sign up with'),
                          const SizedBox(height: 20),
                          SocialLoginButtons(
                            order: const [
                              SocialProvider.google,
                              SocialProvider.apple,
                              SocialProvider.facebook,
                            ],
                            onTap: _onSocialTap,
                          ),
                          const SizedBox(height: 24),
                          _buildSignInLink(context),
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

  Widget _buildTermsText() {
    return Text.rich(
      const TextSpan(
        style: TextStyle(fontSize: 13, color: AppColors.mute, height: 1.4),
        children: [
          TextSpan(text: 'By creating an account you agree to the '),
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 15, color: AppColors.mute),
            children: [
              TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign in',
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
