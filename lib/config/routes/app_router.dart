import 'package:car_social_media_app/features/authentication/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/bloc/bloc.dart';
import '../../features/profile/presentation/bloc/event.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => BlocProvider<ProfileBloc>(
        create: (_) => getIt<ProfileBloc>()..add(FetchUserProfileData()),
        child: const ProfilePage(),
      ),
    ),
    // TODO: Implement a real FeedPage
    GoRoute(
      path: '/feed',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Feed Page'))),
    ),
  ],
);
