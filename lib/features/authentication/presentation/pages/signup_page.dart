import 'package:car_social_media_app/features/authentication/presentation/bloc/bloc.dart';
import 'package:car_social_media_app/features/authentication/presentation/widgets/social_button_signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../bloc/state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    const accentBlue = Color(0xFF3E7EEB);
    const pageBackground = Color(0xFFEFF0F7);
    const cardBackground = Color(0xFFFFFFFF);
    const inputBackground = Color(0xFFF3F4F9);
    const subtleText = Color(0xFF8A8A8A);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthInitial) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please log in to continue.')),
              );
            } else if (state is AuthLoading) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logging in...')));
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is Authenticated) {
              // TODO: Create FeedPage and add it to the router
            } else if (state is AuthenticatedRequiresOnboarding) {
              context.go('/onboarding');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Cargram',
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 46,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Welcome to\nCargram login now!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _inputContainer(
                          background: inputBackground,
                          child: const TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'joedoe75@gmail.com',
                              hintStyle: TextStyle(
                                color: subtleText,
                                fontSize: 16,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _inputContainer(
                          background: inputBackground,
                          child: TextField(
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '........',
                              hintStyle: const TextStyle(
                                color: subtleText,
                                fontSize: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: subtleText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              side: const BorderSide(color: subtleText),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(color: subtleText, fontSize: 16),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forget password?',
                                style: TextStyle(
                                  color: Color(0xFF5E84AA),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Center(
                          child: Text(
                            'Or Sign in with',
                            style: TextStyle(color: subtleText, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: SocialButtonSignin(
                            svgLogo: SvgPicture.asset(
                              'assets/icons/google_signin_logo.svg',
                              width: 60,
                              height: 60,
                            ),
                            socialApp: 'Google',
                          ),
                        ),
                      ],
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

  Widget _inputContainer({required Widget child, required Color background}) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}
