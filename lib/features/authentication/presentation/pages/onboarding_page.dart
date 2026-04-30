import 'package:car_social_media_app/features/authentication/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/event.dart';
import '../bloc/state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _primaryColor = Color(0xFFFF4D00);

  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/profile');
            }
            else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Cargram',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 42),
                  const Text(
                    'CLAIM YOUR',
                    style: TextStyle(
                      color: Color(0xFF1B1B1D),
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'This is how other enthusiasts will find\nand follow you on the grid.',
                    style: TextStyle(
                      color: Color(0xFF5E5F66),
                      fontSize: 24,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 38),
                  const Text(
                    'USERNAME',
                    style: TextStyle(
                      color: Color(0xFF3A3A40),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6D7DD)),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: Color(0xFF2E2E33),
                        fontSize: 22,
                        letterSpacing: 0.1,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixText: '@  ',
                        prefixStyle: TextStyle(
                          color: Color(0xFF5A5B62),
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'driver_name',
                        hintStyle: TextStyle(
                          color: Color(0xFFB4B5BC),
                          fontSize: 35,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF6A6B73),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Username must be unique and contain at least\n3 characters.',
                          style: TextStyle(
                            color: Color(0xFF6A6B73),
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E3E9)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEBDD),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: _primaryColor,
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRO TIP',
                                style: TextStyle(
                                  color: Color(0xFF202127),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Keep it short. Shorter handles look\ncleaner on the race telemetry\ndashboards.',
                                style: TextStyle(
                                  color: Color(0xFF55565D),
                                  fontSize: 16,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: state is AuthLoading
                        ? CircularProgressIndicator()
                        : TextButton(
                            onPressed: () => context.read<AuthBloc>().add(
                              SubmitUsername(_usernameController.text.trim()),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue to garage',
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward,
                                  color: _primaryColor,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'SKIP FOR NOW',
                        style: TextStyle(
                          color: Color(0xFF6F7078),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
