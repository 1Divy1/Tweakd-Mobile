import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/bloc.dart';
import '../bloc/state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial || state is AuthError) {
          print("State is ${state.toString()}; navigating to signup");
          context.go('/signup');
        } 
        else if (state is AuthenticatedRequiresOnboarding) {
          print("State is ${state.toString()}; navigating to onboarding");
          context.go('/onboarding');
        } 
        else if (state is Authenticated) {
          print("State is ${state.toString()}; navigating to feed");
          context.go('/feed');
        }
      },
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}