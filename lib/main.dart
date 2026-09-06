import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tweakd/core/routes/app_router.dart';
import 'package:tweakd/firebase_options.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:tweakd/core/deeplinks/deep_link_service.dart';
import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/push/push_background_handler.dart';
import 'package:tweakd/core/push/push_message_listener.dart';
import 'package:tweakd/core/push/push_navigator.dart';
import 'package:tweakd/core/push/push_notification_service.dart';
import 'package:tweakd/core/push/push_registration.dart';
import 'package:tweakd/core/realtime/dm_realtime_service.dart';
import 'package:tweakd/core/realtime/presence_service.dart';
import 'package:tweakd/core/storage/secure_local_storage.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/authentication/presentation/bloc/bloc.dart';
import 'package:tweakd/features/authentication/presentation/bloc/event.dart';
import 'package:tweakd/features/badges/presentation/bloc/celebration/cubit.dart';
import 'package:tweakd/features/badges/presentation/widgets/badge_celebration_overlay.dart';
import 'package:tweakd/features/messages/presentation/bloc/unread/cubit.dart';
import 'package:tweakd/features/notifications/presentation/bloc/unread/cubit.dart';
import 'package:tweakd/features/profile/presentation/bloc/locale/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Make sure the binding is initialized
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native (OS-level) launch screen on screen through all of the
  // setup below, instead of letting it disappear into a blank frame the
  // moment the Flutter engine attaches. SplashPage removes it once its own,
  // visually-identical splash has actually painted (see its initState).
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock the app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Setup MapBox access token
  const String mapboxAccessToken = String.fromEnvironment(
    "MAPBOX_ACCESS_TOKEN",
  );
  MapboxOptions.setAccessToken(mapboxAccessToken);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  // Initialize Firebase using the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must be registered before runApp and outside any closure — FCM looks the
  // handler up by entry point to spin up a background isolate. See
  // push_background_handler.dart for why it deliberately does nothing.
  FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);

  // Initialize dependency injection
  configureDependencies();

  // Keep the app-wide Supabase Realtime channels in step with the auth
  // session: the viewer's DM topic (`user:<id>`) and the global presence
  // channel. Both are opened at app start rather than on the DM screen —
  // "Active now" means "has the app open" — and torn down on sign-out so no
  // stale subscription outlives the session.
  final dmRealtime = getIt<DmRealtimeService>();
  final presence = getIt<PresenceService>();
  void connectRealtime() {
    dmRealtime.connect();
    presence.connect();
  }

  // App-level queue for the badge unlock celebration. The list itself arrives
  // on the first page of the feed (`pending_badge_celebrations`); this only
  // needs clearing on sign-out so a badge the previous user earned can't
  // animate for whoever signs in next.
  final badgeCelebrations = getIt<BadgeCelebrationCubit>();

  // Push notifications. The service only wires FCM up — it never prompts for
  // permission (the onboarding notifications step owns the one prompt) and it
  // never talks to our backend; PushTokenSync does that, on sign-in.
  final push = getIt<PushNotificationService>();
  final pushNavigator = getIt<PushNavigator>();
  final pushTokenSync = getIt<PushRegistration>();

  // Universal Links / App Links (and the `tweakd://c/{code}` fallback). Wired
  // the same way as push, and for the same reason: the router imports the
  // pages, so a service the pages reach through DI can't import it back.
  //
  // Flutter's built-in deep linking is switched *off* in Info.plist and
  // AndroidManifest.xml (it is on by default): it would route the
  // `tweakd://signup-callback` / `login-callback` URLs Supabase's auth flows
  // depend on into go_router as well, and the resulting error page replaces
  // the splash — leaving the app stuck on its launch screen. See
  // DeepLinkService for the full reasoning.
  final deepLinks = getIt<DeepLinkService>();

  // The navigator can't import the router (the router imports the pages, which
  // reach the navigator through DI), so the connection is made from here.
  pushNavigator.attach(appRouter.push);
  push.opened.listen(pushNavigator.handleTap);
  unawaited(push.start());

  deepLinks.attach(appRouter.push);
  unawaited(deepLinks.start());

  // A tap that launched the app from terminated lands here while the splash is
  // still resolving the session, so it is parked rather than followed —
  // SplashPage releases it once the user is actually signed in.
  unawaited(
    push.takeInitialMessage().then((message) {
      if (message != null) pushNavigator.deferTap(message);
    }),
  );

  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) {
    connectRealtime();
    unawaited(pushTokenSync.start());
  }
  auth.onAuthStateChange.listen((change) {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
        if (auth.currentSession != null) {
          connectRealtime();
          // Not on tokenRefreshed: that fires roughly hourly for the whole
          // session and the registration hasn't changed.
          unawaited(pushTokenSync.start());
        }
      case AuthChangeEvent.tokenRefreshed:
        if (auth.currentSession != null) connectRealtime();
      case AuthChangeEvent.signedOut:
        dmRealtime.disconnect();
        presence.disconnect();
        badgeCelebrations.reset();
        // Unregistering the device happens in the auth data source, before the
        // session is torn down — by here the JWT is already gone. All that is
        // left is to make sure a notification the previous user tapped, or a
        // share link they opened, can't navigate whoever signs in next.
        pushNavigator.clearPending();
        deepLinks.clearPending();
      default:
        break;
    }
  });

  runApp(const TweakdApp());
}

class TweakdApp extends StatelessWidget {
  const TweakdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(CheckAuthStatus()),
        ),
        // App-level DMs unread counter — the feed top bar reads it, and its
        // socket subscription must outlive individual pages.
        // No eager refresh here: the feed top-bar pills fetch the counts when
        // they mount, which happens right after startup anyway — fetching at
        // root too would just duplicate both requests on every cold start.
        BlocProvider<DmUnreadCubit>(
          create: (context) => getIt<DmUnreadCubit>(),
        ),
        // App-level notifications unread counter — the feed top bar reads it.
        // No socket (notifications have no live channel): it refreshes on feed
        // appear and when returning from the notifications page.
        BlocProvider<NotificationsUnreadCubit>(
          create: (context) => getIt<NotificationsUnreadCubit>(),
        ),
        // App-level active locale (null = follow system). Seeded from local
        // secure storage; the settings language picker and the profile-fetch
        // sync rule both flip it live via LocaleCubit.setLocale/syncFromBackend.
        BlocProvider<LocaleCubit>(
          create: (context) => getIt<LocaleCubit>()..loadPersisted(),
        ),
        // App-level badge unlock celebration queue. Fed by the feed page from
        // the launch payload; read by the overlay wired into MaterialApp below.
        BlocProvider<BadgeCelebrationCubit>(
          create: (context) => getIt<BadgeCelebrationCubit>(),
        ),
      ],
      // Inside the providers on purpose: the unread cubits are factories, so
      // this is the only place that can reach the instances the feed reads.
      child: PushMessageListener(
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter,
            // Floats the badge unlock celebration above every route.
            builder: (context, child) => BadgeCelebrationOverlay(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
