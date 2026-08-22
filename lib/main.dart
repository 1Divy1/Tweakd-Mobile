import 'package:tweakd/core/routes/app_router.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/realtime/dm_realtime_service.dart';
import 'package:tweakd/core/realtime/presence_service.dart';
import 'package:tweakd/core/storage/secure_local_storage.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/authentication/presentation/bloc/bloc.dart';
import 'package:tweakd/features/authentication/presentation/bloc/event.dart';
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
  const String mapboxAccessToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
  MapboxOptions.setAccessToken(mapboxAccessToken);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );

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

  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) connectRealtime();
  auth.onAuthStateChange.listen((change) {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.tokenRefreshed:
        if (auth.currentSession != null) connectRealtime();
      case AuthChangeEvent.signedOut:
        dmRealtime.disconnect();
        presence.disconnect();
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
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}