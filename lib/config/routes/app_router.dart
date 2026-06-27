import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/follow/presentation/bloc/bloc.dart';
import '../../features/follow/presentation/bloc/event.dart';
import '../../features/follow/presentation/pages/followers_following_page.dart';
import '../../features/garage/domain/entities/car.dart';
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
import '../../features/onboarding/presentation/bloc/bloc.dart';
import '../../features/posts/domain/entities/post.dart';
import '../../features/posts/presentation/bloc/create_post/bloc.dart';
import '../../features/posts/presentation/bloc/edit_post/bloc.dart';
import '../../features/posts/presentation/bloc/post_detail/bloc.dart';
import '../../features/posts/presentation/bloc/post_detail/event.dart';
import '../../features/posts/presentation/bloc/profile_posts/bloc.dart';
import '../../features/posts/presentation/bloc/profile_posts/event.dart';
import '../../features/posts/presentation/bloc/tag_picker/bloc.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/posts/presentation/pages/edit_post_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/onboarding/presentation/bloc/event.dart';
import '../../features/onboarding/presentation/bloc/username_availability/bloc.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/bloc/bloc.dart';
import '../../features/profile/presentation/bloc/event.dart';
import '../../features/profile/presentation/pages/my_profile_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/search/presentation/bloc/bloc.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ---------- Authentication & Onboarding ----------
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<OnboardingBloc>(
            create: (_) => getIt<OnboardingBloc>()
              ..add(const LoadOnboardingReferenceData()),
          ),
          BlocProvider<UsernameAvailabilityBloc>(
            create: (_) => getIt<UsernameAvailabilityBloc>(),
          ),
        ],
        child: const OnboardingPage(),
      ),
    ),

    // ---------- Profile ----------
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
            BlocProvider<ProfilePostsBloc>(
              create: (_) =>
                  getIt<ProfilePostsBloc>()..add(const LoadMyPosts()),
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
            BlocProvider<FollowBloc>(
              create: (_) =>
                  getIt<FollowBloc>()..add(LoadFollowStatus(username)),
            ),
            BlocProvider<GarageBloc>(
              create: (_) =>
                  getIt<GarageBloc>()..add(LoadGarageByUsername(username)),
            ),
            BlocProvider<ProfilePostsBloc>(
              create: (_) => getIt<ProfilePostsBloc>()
                ..add(LoadPostsByUsername(username)),
            ),
          ],
          child: PublicProfilePage(username: username),
        );
      },
    ),

    // ---------- Search Page ----------
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<SearchBloc>(
          create: (_) => getIt<SearchBloc>(),
          child: const SearchPage(),
        ),
      ),
    ),

    // ---------- Settings Page ----------
    // AuthBloc is provided app-wide in main.dart, so no BlocProvider is
    // needed here.
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),

    // ---------- Feed Page ----------
    // TODO: Implement a real FeedPage
    GoRoute(
      path: '/feed',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: Scaffold(body: Center(child: Text('Feed Page'))),
      ),
    ),

    // ---------- Create Post ----------
    GoRoute(
      path: '/posts/create',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<CreatePostBloc>(
            create: (_) => getIt<CreatePostBloc>(),
          ),
          BlocProvider<TagPickerBloc>(
            create: (_) => getIt<TagPickerBloc>(),
          ),
        ],
        child: const CreatePostPage(),
      ),
    ),
    GoRoute(
      path: '/posts/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return BlocProvider<PostDetailBloc>(
          create: (_) => getIt<PostDetailBloc>()..add(LoadPost(postId)),
          child: const PostDetailPage(),
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final post = state.extra as PostEntity;
            return MultiBlocProvider(
              providers: [
                BlocProvider<EditPostBloc>(
                  create: (_) => getIt<EditPostBloc>(),
                ),
                BlocProvider<TagPickerBloc>(
                  create: (_) => getIt<TagPickerBloc>(),
                ),
              ],
              child: EditPostPage(post: post),
            );
          },
        ),
      ],
    ),

    // ---------- Garage Page ----------
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
          path: 'edit',
          builder: (context, state) {
            final car = state.extra as CarEntity;
            return BlocProvider<AddCarBloc>(
              create: (_) =>
                  getIt<AddCarBloc>()..add(const LoadAddCarReferenceData()),
              child: RegisterCarPage(editCar: car),
            );
          },
        ),
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

    // ---------- Followers & Following Page ----------
    GoRoute(
      path: '/followers',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final username = extra['username'] as String? ?? '';
        final followersCount = extra['followersCount'] as int? ?? 0;
        final followingCount = extra['followingCount'] as int? ?? 0;
        final isOwnProfile = extra['isOwnProfile'] as bool? ?? false;
        return BlocProvider<FollowBloc>(
          create: (_) => getIt<FollowBloc>()..add(LoadFollowers(username)),
          child: FollowersFollowingPage(
            username: username,
            followersCount: followersCount,
            followingCount: followingCount,
            showFollowers: true,
            isOwnProfile: isOwnProfile,
          ),
        );
      },
    ),
    GoRoute(
      path: '/following',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final username = extra['username'] as String? ?? '';
        final followersCount = extra['followersCount'] as int? ?? 0;
        final followingCount = extra['followingCount'] as int? ?? 0;
        final isOwnProfile = extra['isOwnProfile'] as bool? ?? false;
        return BlocProvider<FollowBloc>(
          create: (_) => getIt<FollowBloc>()..add(LoadFollowing(username)),
          child: FollowersFollowingPage(
            username: username,
            followersCount: followersCount,
            followingCount: followingCount,
            showFollowers: false,
            isOwnProfile: isOwnProfile,
          ),
        );
      },
    ),

    // ---------- Fullscreen Image ----------
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
