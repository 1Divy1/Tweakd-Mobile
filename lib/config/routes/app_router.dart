import 'package:car_social_media_app/features/authentication/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/follow/presentation/bloc/bloc.dart';
import '../../features/follow/presentation/bloc/event.dart';
import '../../features/profile/presentation/bloc/bloc.dart';
import '../../features/profile/presentation/bloc/event.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/search/presentation/bloc/bloc.dart';
import '../../features/search/presentation/pages/search_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => BlocProvider<ProfileBloc>(
        create: (_) => getIt<ProfileBloc>(),
        child: const OnboardingPage(),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(FetchUserProfileData()),
          child: const MyProfilePage(),
        ),
      ),
    ),
    GoRoute(
      path: '/users/:username',
      redirect: (context, state) {
        final targetUserId = state.extra as String?;
        final currentUserId = getIt<SupabaseClient>().auth.currentUser?.id;

        if (targetUserId != null &&
            currentUserId != null &&
            targetUserId == currentUserId) {
          return '/profile';
        }

        return null;
      },
      builder: (context, state) {
        final username = state.pathParameters['username'] ?? '';

        return MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>(
              create: (_) =>
                  getIt<ProfileBloc>()..add(FetchProfileByUsername(username)),
            ),
            BlocProvider<FollowStatusBloc>(
              create: (_) =>
                  getIt<FollowStatusBloc>()..add(LoadFollowStatus(username)),
            ),
          ],
          child: PublicProfilePage(username: username),
        );
      },
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<SearchBloc>(
          create: (_) => getIt<SearchBloc>(),
          child: const SearchPage(),
        ),
      ),
    ),
    // TODO: Implement a real FeedPage
    GoRoute(
      path: '/feed',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: Scaffold(body: Center(child: Text('Feed Page'))),
      ),
    ),
  ],
);
