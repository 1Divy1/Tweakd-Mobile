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
import '../../features/garage/presentation/bloc/add_car/bloc.dart';
import '../../features/garage/presentation/bloc/add_car/event.dart';
import '../../features/garage/presentation/bloc/bloc.dart';
import '../../features/garage/presentation/bloc/car_detail/bloc.dart';
import '../../features/garage/presentation/bloc/car_detail/event.dart';
import '../../features/garage/presentation/bloc/event.dart';
import '../../features/garage/presentation/bloc/log_mod/bloc.dart';
import '../../features/garage/presentation/bloc/log_mod/event.dart';
import '../../features/garage/presentation/pages/about_car_page.dart';
import '../../features/garage/presentation/pages/fullscreen_image_page.dart';
import '../../features/garage/presentation/pages/log_mod_page.dart';
import '../../features/garage/presentation/pages/register_car_page.dart';
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
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>(
              create: (_) => getIt<ProfileBloc>()..add(FetchUserProfileData()),
            ),
            BlocProvider<GarageBloc>(
              create: (_) => getIt<GarageBloc>()..add(const LoadMyGarage()),
            ),
          ],
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
            BlocProvider<GarageBloc>(
              create: (_) =>
                  getIt<GarageBloc>()..add(LoadGarageByUsername(username)),
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
    GoRoute(
      path: '/garage/cars/add',
      builder: (context, state) => BlocProvider<AddCarBloc>(
        create: (_) =>
            getIt<AddCarBloc>()..add(const LoadAddCarReferenceData()),
        child: const RegisterCarPage(),
      ),
    ),
    GoRoute(
      path: '/garage/cars/:carId',
      builder: (context, state) {
        final carId = state.pathParameters['carId']!;
        final isOwner = state.extra as bool? ?? false;

        return BlocProvider<CarDetailBloc>(
          create: (_) => getIt<CarDetailBloc>()..add(LoadCar(carId)),
          child: AboutCarPage(isOwner: isOwner),
        );
      },
      routes: [
        GoRoute(
          path: 'modifications/add',
          builder: (context, state) {
            final carId = state.pathParameters['carId']!;

            return BlocProvider<LogModBloc>(
              create: (_) =>
                  getIt<LogModBloc>()..add(const LoadModCategories()),
              child: LogModificationPage(carId: carId),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/full-screen-image',
      builder: (context, state) {
        final imageUrl = state.extra as String?;
        if (imageUrl == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No image is available')),
          );
        }

        return FullscreenImagePage(url: imageUrl);
      },
    ),
  ],
);
