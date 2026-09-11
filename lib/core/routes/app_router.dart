import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/injection.dart';
import '../../features/authentication/presentation/bloc/password_reset/bloc.dart';
import '../../features/authentication/presentation/bloc/signup/bloc.dart';
import '../../features/authentication/presentation/pages/confirm_email_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/new_password_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/verify_reset_code_page.dart';
import '../../features/feed/presentation/bloc/feed/bloc.dart';
import '../../features/feed/presentation/bloc/feed/event.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/follow/presentation/bloc/bloc.dart';
import '../../features/forums/domain/entities/forum_filter.dart';
import '../../features/forums/presentation/bloc/browse/bloc.dart';
import '../../features/forums/presentation/bloc/browse/event.dart';
import '../../features/forums/presentation/bloc/composer/bloc.dart';
import '../../features/forums/presentation/bloc/composer/event.dart';
import '../../features/forums/presentation/bloc/home/bloc.dart';
import '../../features/forums/presentation/bloc/home/event.dart';
import '../../features/forums/presentation/bloc/hub/bloc.dart';
import '../../features/forums/presentation/bloc/hub/event.dart';
import '../../features/forums/presentation/bloc/thread/bloc.dart';
import '../../features/forums/presentation/bloc/thread/event.dart';
import '../../features/forums/presentation/pages/forum_hub_page.dart';
import '../../features/forums/presentation/pages/forum_thread_page.dart';
import '../../features/forums/presentation/pages/forums_browse_page.dart';
import '../../features/forums/presentation/pages/forums_home_page.dart';
import '../../features/forums/presentation/pages/new_thread_page.dart';
import '../../features/forums/presentation/pages/saved_threads_page.dart';
import '../../features/forums/presentation/bloc/saved/bloc.dart';
import '../../features/forums/presentation/bloc/saved/event.dart';
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
import '../../features/garage/presentation/bloc/share_resolve/cubit.dart';
import '../../features/garage/presentation/pages/register_car_page.dart';
import '../../features/garage/presentation/pages/share_landing_page.dart';
import '../../features/map/presentation/bloc/map/bloc.dart';
import '../../features/map/presentation/bloc/map/event.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/map_events/domain/entities/contest.dart';
import '../../features/map_events/domain/entities/map_event.dart';
import '../../features/map_events/presentation/bloc/car_event_history/bloc.dart';
import '../../features/map_events/presentation/bloc/car_event_history/event.dart';
import '../../features/map_events/presentation/bloc/contest_detail/bloc.dart';
import '../../features/map_events/presentation/bloc/contest_detail/event.dart';
import '../../features/map_events/presentation/bloc/create_contest/cubit.dart';
import '../../features/map_events/presentation/bloc/event_contests/bloc.dart';
import '../../features/map_events/presentation/bloc/event_contests/event.dart';
import '../../features/map_events/presentation/bloc/manage_contests/bloc.dart';
import '../../features/map_events/presentation/bloc/manage_contests/event.dart';
import '../../features/map_events/presentation/pages/contest_page.dart';
import '../../features/map_events/presentation/pages/create_contest_page.dart';
import '../../features/map_events/presentation/pages/organizer_contests_page.dart';
import '../../features/map_events/presentation/bloc/attendees/bloc.dart';
import '../../features/map_events/presentation/bloc/attendees/event.dart';
import '../../features/map_events/presentation/bloc/create_event/bloc.dart';
import '../../features/map_events/presentation/bloc/create_event/event.dart';
import '../../features/map_events/presentation/bloc/event_detail/bloc.dart';
import '../../features/map_events/presentation/bloc/event_detail/event.dart';
import '../../features/map_events/presentation/bloc/manage_event/bloc.dart';
import '../../features/map_events/presentation/bloc/manage_event/event.dart';
import '../../features/map_events/presentation/bloc/my_events/bloc.dart';
import '../../features/map_events/presentation/bloc/my_events/event.dart';
import '../../features/map_events/presentation/pages/create_map_event_page.dart';
import '../../features/map_events/presentation/pages/manage_map_event_page.dart';
import '../../features/map_events/presentation/pages/map_event_attendees_page.dart';
import '../../features/map_events/presentation/pages/map_event_detail_page.dart';
import '../../features/map_events/presentation/pages/my_map_events_page.dart';
import '../../features/messages/domain/entities/message_user.dart';
import '../../features/messages/presentation/bloc/chat/bloc.dart';
import '../../features/messages/presentation/bloc/chat/event.dart';
import '../../features/messages/presentation/bloc/inbox/bloc.dart';
import '../../features/messages/presentation/bloc/inbox/event.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/bloc/notifications/bloc.dart';
import '../../features/notifications/presentation/bloc/notifications/event.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/bloc/bloc.dart';
import '../../features/posts/domain/entities/post.dart';
import '../../features/posts/presentation/bloc/create_post/bloc.dart';
import '../../features/posts/presentation/bloc/edit_post/bloc.dart';
import '../../features/posts/presentation/bloc/post_detail/bloc.dart';
import '../../features/posts/presentation/bloc/post_detail/event.dart';
import '../../features/posts/presentation/bloc/profile_posts/bloc.dart';
import '../../features/posts/presentation/bloc/profile_posts/event.dart';
import '../../features/posts/presentation/bloc/saved_posts/bloc.dart';
import '../../features/posts/presentation/bloc/saved_posts/event.dart';
import '../../features/posts/presentation/bloc/share_post/bloc.dart';
import '../shared/bloc/tag_picker/bloc.dart';
import '../../features/posts/presentation/pages/create_post_page.dart';
import '../../features/posts/presentation/pages/edit_post_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/posts/presentation/pages/saved_posts_page.dart';
import '../../features/posts/presentation/pages/share_post_page.dart';
import '../../features/onboarding/presentation/bloc/event.dart';
import '../../features/feedback/presentation/bloc/feedback/bloc.dart';
import '../../features/feedback/presentation/bloc/feedback/event.dart';
import '../../features/feedback/presentation/bloc/my_feedback/bloc.dart';
import '../../features/feedback/presentation/bloc/my_feedback/event.dart';
import '../../features/feedback/presentation/pages/feedback_page.dart';
import '../../features/feedback/presentation/pages/my_feedback_page.dart';
import '../../features/feedback_feed/presentation/bloc/board/bloc.dart';
import '../../features/feedback_feed/presentation/bloc/board/event.dart';
import '../../features/feedback_feed/presentation/bloc/completed/bloc.dart';
import '../../features/feedback_feed/presentation/bloc/completed/event.dart';
import '../../features/feedback_feed/presentation/bloc/compose/bloc.dart';
import '../../features/feedback_feed/presentation/bloc/compose/event.dart';
import '../../features/feedback_feed/presentation/pages/completed_feedback_page.dart';
import '../../features/feedback_feed/presentation/pages/compose_feedback_page.dart';
import '../../features/feedback_feed/presentation/pages/feedback_feed_page.dart';
import '../../features/onboarding/presentation/bloc/username_availability/bloc.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/badges/presentation/pages/badge_detail_page.dart';
import '../../features/profile/domain/entities/profile.dart';
import '../../features/profile/presentation/bloc/bloc.dart';
import '../../features/profile/presentation/bloc/edit_profile/bloc.dart';
import '../../features/profile/presentation/bloc/event.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_profile_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/report/presentation/bloc/my_reports/bloc.dart';
import '../../features/report/presentation/bloc/my_reports/event.dart';
import '../../features/report/presentation/pages/my_reports_page.dart';
import '../../features/search/presentation/bloc/bloc.dart';
import '../../features/tags/presentation/bloc/tags/bloc.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/map_events/presentation/bloc/participant_cards/cubit.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ---------- Authentication & Onboarding ----------
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/signup',
      builder: (context, state) => BlocProvider<SignUpBloc>(
        create: (_) => getIt<SignUpBloc>(),
        child: const SignUpPage(),
      ),
      routes: [
        // "Check your inbox". The address travels as `extra` because it is not
        // worth putting an email in a URL; without it there is nothing to
        // resend to, so fall back to the form.
        GoRoute(
          path: 'confirm',
          redirect: (context, state) =>
              state.extra is String ? null : '/signup',
          builder: (context, state) => BlocProvider<SignUpBloc>(
            create: (_) => getIt<SignUpBloc>(),
            child: ConfirmEmailPage(email: state.extra as String),
          ),
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

    // ---------- Password reset (request → verify code → new password) ----------
    // Each step gets its own PasswordResetBloc: the only thing that has to
    // survive between them is the email address, and after the code is verified
    // the recovery session lives in the Supabase client itself.
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => BlocProvider<PasswordResetBloc>(
        create: (_) => getIt<PasswordResetBloc>(),
        child: const ForgotPasswordPage(),
      ),
      routes: [
        GoRoute(
          path: 'verify',
          redirect: (context, state) =>
              state.extra is String ? null : '/forgot-password',
          builder: (context, state) => BlocProvider<PasswordResetBloc>(
            create: (_) => getIt<PasswordResetBloc>(),
            child: VerifyResetCodePage(email: state.extra as String),
          ),
        ),
        GoRoute(
          path: 'new-password',
          builder: (context, state) => BlocProvider<PasswordResetBloc>(
            create: (_) => getIt<PasswordResetBloc>(),
            child: const NewPasswordPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<OnboardingBloc>(
            create: (_) =>
                getIt<OnboardingBloc>()
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
            // No event dispatched: the tags feed is fetched the first time the
            // Tags tab is opened, so a profile visit doesn't pay for it.
            BlocProvider<TagsBloc>(create: (_) => getIt<TagsBloc>()),
            // Same lazy contract for the Events tab.
            BlocProvider<MyMapEventsBloc>(
              create: (_) => getIt<MyMapEventsBloc>(),
            ),
          ],
          child: const MyProfilePage(),
        ),
      ),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) {
        final profile = state.extra as ProfileEntity;
        return BlocProvider<EditProfileBloc>(
          create: (_) => getIt<EditProfileBloc>(param1: profile),
          child: EditProfilePage(profile: profile),
        );
      },
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
              create: (_) =>
                  getIt<ProfilePostsBloc>()..add(LoadPostsByUsername(username)),
            ),
            // Loaded lazily on the first Tags tab open — see the /profile route.
            BlocProvider<TagsBloc>(create: (_) => getIt<TagsBloc>()),
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

    // ---------- Saved Posts ----------
    GoRoute(
      path: '/saved-posts',
      builder: (context, state) => BlocProvider<SavedPostsBloc>(
        create: (_) => getIt<SavedPostsBloc>()..add(const LoadSavedPosts()),
        child: const SavedPostsPage(),
      ),
    ),

    // ---------- My Reports ----------
    GoRoute(
      path: '/reports',
      builder: (context, state) => BlocProvider<MyReportsBloc>(
        create: (_) => getIt<MyReportsBloc>()..add(const LoadMyReports()),
        child: const MyReportsPage(),
      ),
    ),

    // ---------- Send Feedback ----------
    GoRoute(
      path: '/feedback',
      builder: (context, state) => BlocProvider<FeedbackBloc>(
        create: (_) => getIt<FeedbackBloc>()..add(const LoadFeedbackOptions()),
        child: const FeedbackPage(),
      ),
    ),

    // ---------- My Feedback ----------
    GoRoute(
      path: '/feedback/mine',
      builder: (context, state) => BlocProvider<MyFeedbackBloc>(
        create: (_) => getIt<MyFeedbackBloc>()..add(const LoadMyFeedback()),
        child: const MyFeedbackPage(),
      ),
    ),

    // ---------- Feed Page ----------
    GoRoute(
      path: '/feed',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<FeedBloc>(
          create: (_) => getIt<FeedBloc>()..add(const LoadFeed()),
          child: const FeedPage(),
        ),
      ),
    ),

    // ---------- Map ----------
    // Pushed (not go'd) from the bottom nav, so — unlike the other tabs —
    // it keeps the platform's default push/pop transition instead of
    // NoTransitionPage.
    //
    // MapEventDetailBloc rides along because the event popup is the same bloc
    // the /map-events/:id page uses; no event is dispatched here, it loads when
    // a pin is tapped.
    GoRoute(
      path: '/map',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<MapBloc>(
            create: (_) => getIt<MapBloc>()..add(const MapStarted()),
          ),
          BlocProvider<MapEventDetailBloc>(
            create: (_) => getIt<MapEventDetailBloc>(),
          ),
        ],
        child: const MapPage(),
      ),
    ),

    // ---------- Map events ----------
    GoRoute(
      path: '/map-events/create',
      builder: (context, state) => BlocProvider<CreateMapEventBloc>(
        create: (_) =>
            getIt<CreateMapEventBloc>()..add(const LoadCreateEventRefs()),
        child: const CreateMapEventPage(),
      ),
    ),
    GoRoute(
      path: '/map-events/mine',
      builder: (context, state) => BlocProvider<MyMapEventsBloc>(
        create: (_) => getIt<MyMapEventsBloc>()..add(const LoadMyMapEvents()),
        child: const MyMapEventsPage(),
      ),
    ),
    GoRoute(
      path: '/map-events/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        // The contests bloc lives beside the event bloc for the page's whole
        // life: it owns the event's realtime board subscription.
        return MultiBlocProvider(
          providers: [
            BlocProvider<MapEventDetailBloc>(
              create: (_) =>
                  getIt<MapEventDetailBloc>()..add(LoadMapEvent(eventId)),
            ),
            BlocProvider<EventContestsBloc>(
              create: (_) =>
                  getIt<EventContestsBloc>()..add(LoadEventContests(eventId)),
            ),
            // The viewer's participant cards; empty until the event is
            // marked finished, and always for spectators.
            BlocProvider<ParticipantCardsCubit>(
              create: (_) => getIt<ParticipantCardsCubit>()..load(eventId),
            ),
          ],
          child: MapEventDetailPage(eventId: eventId),
        );
      },
      routes: [
        // One contest. `extra` carries the tab's copy (instant paint), the
        // event title and the tab's bloc (so a vote here updates the card
        // behind without a read); a deep link arrives with none of them.
        GoRoute(
          path: 'contests/:contestId',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final contestId = state.pathParameters['contestId']!;
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            final initial = extra['contest'] as ContestEntity?;
            return BlocProvider<ContestDetailBloc>(
              create: (_) => getIt<ContestDetailBloc>()
                ..add(LoadContest(
                  eventId: eventId,
                  contestId: contestId,
                  initial: initial,
                )),
              child: ContestPage(
                eventId: eventId,
                eventTitle: extra['eventTitle'] as String? ?? '',
                tabBloc: extra['tabBloc'] as EventContestsBloc?,
              ),
            );
          },
        ),
        GoRoute(
          path: 'attendees',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            return BlocProvider<MapEventAttendeesBloc>(
              create: (_) =>
                  getIt<MapEventAttendeesBloc>()
                    ..add(LoadMapEventAttendees(eventId)),
              child: const MapEventAttendeesPage(),
            );
          },
        ),
        // Organizer tools. The event travels as `extra` so the page opens with
        // its title and permissions already known; deep-linked without one it
        // still works, just with a plainer header until the bloc loads.
        GoRoute(
          path: 'manage',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final event = state.extra as MapEventEntity?;
            return BlocProvider<ManageMapEventBloc>(
              create: (_) =>
                  getIt<ManageMapEventBloc>()
                    ..add(LoadMapEventManagement(eventId)),
              child: ManageMapEventPage(eventId: eventId, event: event),
            );
          },
          routes: [
            // The organizer's contests console needs the event (title,
            // schedule) and is only ever reached from the manage page with
            // it; a bare deep link falls back to the event page.
            GoRoute(
              path: 'contests',
              redirect: (context, state) => state.extra is MapEventEntity ||
                      state.extra is Map<String, dynamic>
                  ? null
                  : '/map-events/${state.pathParameters['eventId']}',
              builder: (context, state) {
                final eventId = state.pathParameters['eventId']!;
                final event = state.extra as MapEventEntity;
                return BlocProvider<ManageContestsBloc>(
                  create: (_) => getIt<ManageContestsBloc>()
                    ..add(LoadManagedContests(eventId)),
                  child: OrganizerContestsPage(event: event),
                );
              },
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final event = state.extra as MapEventEntity;
                    return BlocProvider<CreateContestCubit>(
                      create: (_) => getIt<CreateContestCubit>()..load(event: event),
                      child: CreateContestPage(event: event),
                    );
                  },
                ),
                GoRoute(
                  path: ':contestId/edit',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    final event = extra['event'] as MapEventEntity;
                    final contest = extra['contest'] as ContestEntity;
                    return BlocProvider<CreateContestCubit>(
                      create: (_) =>
                          getIt<CreateContestCubit>()..load(editing: contest),
                      child: CreateContestPage(event: event, editing: contest),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final event = state.extra as MapEventEntity;
            return BlocProvider<CreateMapEventBloc>(
              create: (_) =>
                  getIt<CreateMapEventBloc>()
                    ..add(LoadCreateEventRefs(editEvent: event)),
              child: CreateMapEventPage(editEvent: event),
            );
          },
        ),
      ],
    ),

    // ---------- Notifications ----------
    GoRoute(
      path: '/notifications',
      builder: (context, state) => BlocProvider<NotificationsBloc>(
        create: (_) =>
            getIt<NotificationsBloc>()..add(const LoadNotifications()),
        child: const NotificationsPage(),
      ),
    ),

    // ---------- Messages (DMs) ----------
    GoRoute(
      path: '/messages',
      builder: (context, state) => BlocProvider<InboxBloc>(
        create: (_) => getIt<InboxBloc>()..add(const LoadInbox()),
        child: const MessagesPage(),
      ),
      routes: [
        // Chat routes carry the peer via `extra` — the messages endpoint has
        // no peer payload, so the header user travels with the navigation.
        // 'new' = composing to a user with no conversation yet; the first
        // message creates it (declared before ':conversationId' so the
        // literal segment wins).
        GoRoute(
          path: 'new',
          builder: (context, state) {
            final peer = state.extra as MessageUserEntity;
            return BlocProvider<ChatBloc>(
              create: (_) =>
                  getIt<ChatBloc>()
                    ..add(LoadChat(conversationId: null, peer: peer)),
              child: ChatPage(conversationId: null, peer: peer),
            );
          },
        ),
        GoRoute(
          path: ':conversationId',
          // The peer travels in `extra` when there is one to hand (the inbox,
          // a profile). When there isn't — a push notification tap, a restored
          // route — the bloc fetches it from the conversation itself, so the
          // link opens the real chat rather than bouncing to the inbox.
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final peer = state.extra is MessageUserEntity
                ? state.extra as MessageUserEntity
                : null;
            return BlocProvider<ChatBloc>(
              create: (_) =>
                  getIt<ChatBloc>()
                    ..add(LoadChat(conversationId: conversationId, peer: peer)),
              child: ChatPage(conversationId: conversationId, peer: peer),
            );
          },
        ),
      ],
    ),

    // ---------- Feedback board (community feed) ----------
    GoRoute(
      path: '/feedback-feed',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<FeedbackBoardBloc>(
          create: (_) =>
              getIt<FeedbackBoardBloc>()..add(const LoadFeedbackBoard()),
          child: const FeedbackFeedPage(),
        ),
      ),
      routes: [
        GoRoute(
          path: 'completed',
          builder: (context, state) => BlocProvider<CompletedFeedbackBloc>(
            create: (_) =>
                getIt<CompletedFeedbackBloc>()
                  ..add(const LoadCompletedFeedback()),
            child: const CompletedFeedbackPage(),
          ),
        ),
        GoRoute(
          path: 'new',
          builder: (context, state) => BlocProvider<ComposeFeedbackBloc>(
            create: (_) =>
                getIt<ComposeFeedbackBloc>()..add(const LoadFeedbackTypes()),
            child: const ComposeFeedbackPage(),
          ),
        ),
      ],
    ),

    // ---------- Forums ----------
    GoRoute(
      path: '/forums',
      pageBuilder: (context, state) => NoTransitionPage(
        child: BlocProvider<ForumsHomeBloc>(
          create: (_) => getIt<ForumsHomeBloc>()..add(const LoadForumsHome()),
          child: const ForumsHomePage(),
        ),
      ),
      routes: [
        GoRoute(
          path: 'browse',
          builder: (context, state) => BlocProvider<ForumBrowseBloc>(
            create: (_) =>
                getIt<ForumBrowseBloc>()..add(const LoadForumBrowse()),
            child: const ForumsBrowsePage(),
          ),
        ),
        GoRoute(
          path: 'saved',
          builder: (context, state) => BlocProvider<SavedThreadsBloc>(
            create: (_) =>
                getIt<SavedThreadsBloc>()..add(const LoadSavedThreads()),
            child: const SavedThreadsPage(),
          ),
        ),
        // The hub filter travels as `extra`; a hub deep-linked without one
        // falls back to the forums home.
        GoRoute(
          path: 'hub',
          redirect: (context, state) =>
              state.extra is ForumFilter ? null : '/forums',
          builder: (context, state) {
            final filter = state.extra as ForumFilter;
            return BlocProvider<ForumHubBloc>(
              create: (_) => getIt<ForumHubBloc>()..add(LoadForumHub(filter)),
              child: const ForumHubPage(),
            );
          },
        ),
        // Both the composer and the thread page tag people & cars, so each
        // gets a TagPickerBloc alongside its own bloc.
        GoRoute(
          path: 'new',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<NewThreadBloc>(
                create: (_) =>
                    getIt<NewThreadBloc>()..add(const LoadNewThreadRefs()),
              ),
              BlocProvider<TagPickerBloc>(
                create: (_) => getIt<TagPickerBloc>(),
              ),
            ],
            child: const NewThreadPage(),
          ),
        ),
        GoRoute(
          path: 'threads/:threadId',
          builder: (context, state) {
            final threadId = state.pathParameters['threadId']!;
            return MultiBlocProvider(
              providers: [
                BlocProvider<ForumThreadBloc>(
                  create: (_) =>
                      getIt<ForumThreadBloc>()..add(LoadForumThread(threadId)),
                ),
                BlocProvider<TagPickerBloc>(
                  create: (_) => getIt<TagPickerBloc>(),
                ),
              ],
              child: ForumThreadPage(threadId: threadId),
            );
          },
        ),
      ],
    ),

    // ---------- Create Post ----------
    GoRoute(
      path: '/posts/create',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<CreatePostBloc>(create: (_) => getIt<CreatePostBloc>()),
          BlocProvider<TagPickerBloc>(create: (_) => getIt<TagPickerBloc>()),
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
        GoRoute(
          path: 'share',
          builder: (context, state) {
            final post = state.extra as PostEntity;
            return BlocProvider<SharePostBloc>(
              create: (_) => getIt<SharePostBloc>(),
              child: SharePostPage(post: post),
            );
          },
        ),
      ],
    ),

    // ---------- Share links (/c/{code}) ----------
    // Where a scanned QR or a tapped Universal Link / App Link lands. The path
    // mirrors the public web URL exactly (`web.tweakdapp.com/c/{code}`), and
    // `tweakd://c/{code}` — the fallback the website's "Open in app" button
    // uses — arrives here too. `DeepLinkService` maps both onto this route.
    //
    // The code is opaque, so the page is a resolver: it asks the backend which
    // car the code means, then replaces itself with that car's screen. The
    // `?s=` tag rides along so an in-app open from a QR is counted as a scan.
    GoRoute(
      path: '/c/:code',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        final source = state.uri.queryParameters['s'];

        return BlocProvider<ShareResolveCubit>(
          create: (_) => getIt<ShareResolveCubit>()..resolve(code, source: source),
          child: const ShareLandingPage(),
        );
      },
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

        return MultiBlocProvider(
          providers: [
            BlocProvider<CarDetailBloc>(
              create: (_) => getIt<CarDetailBloc>()..add(LoadCar(carId)),
            ),
            // The car's attended events and podium places — a small read that
            // paints its own section and stays silent on failure.
            BlocProvider<CarEventHistoryBloc>(
              create: (_) =>
                  getIt<CarEventHistoryBloc>()..add(LoadCarEventHistory(carId)),
            ),
          ],
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

    // ---------- Badge detail ----------
    // A single badge on its own screen, opened from the profile strip or the
    // all-badges sheet. Presented as a modal (bottom-up, X to close) — it is a
    // "look at it up close" view, not a place in the nav. The badge travels
    // whole in `extra`; deep-linked without one it falls back to the profile.
    GoRoute(
      path: '/badge',
      redirect: (context, state) =>
          state.extra is BadgeDetailArgs ? null : '/profile',
      pageBuilder: (context, state) {
        final args = state.extra as BadgeDetailArgs;
        return MaterialPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: BadgeDetailPage(badge: args.badge),
        );
      },
    ),

    // ---------- Fullscreen Image ----------
    GoRoute(
      path: '/full-screen-image',
      builder: (context, state) {
        final extra = state.extra;
        List<String> images;
        int initialIndex;
        if (extra is FullscreenImageArgs) {
          images = extra.images;
          initialIndex = extra.initialIndex;
        } else if (extra is String) {
          images = [extra];
          initialIndex = 0;
        } else {
          images = const [];
          initialIndex = 0;
        }
        if (images.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No image is available')),
          );
        }
        return FullscreenImagePage(images: images, initialIndex: initialIndex);
      },
    ),
  ],
);
