import 'package:car_social_media_app/core/routes/app_router.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:car_social_media_app/core/di/injection.dart';
import 'package:car_social_media_app/core/realtime/dm_socket_service.dart';
import 'package:car_social_media_app/core/storage/secure_local_storage.dart';
import 'package:car_social_media_app/core/theme/app_theme.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/bloc.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/messages/presentation/bloc/unread/cubit.dart';
import 'package:car_social_media_app/features/notifications/presentation/bloc/unread/cubit.dart';
import 'package:car_social_media_app/features/profile/presentation/bloc/locale/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {

  // Make sure the binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

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

  // Keep the app-wide DM socket in step with the auth session. It is opened
  // at app start (not on the DM screen) because "Active now" means "has the
  // app open", and closed on sign-out so no stale connection outlives the
  // session.
  final dmSocket = getIt<DmSocketService>();
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) dmSocket.connect();
  auth.onAuthStateChange.listen((change) {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.tokenRefreshed:
        if (auth.currentSession != null) dmSocket.connect();
      case AuthChangeEvent.signedOut:
        dmSocket.disconnect();
      default:
        break;
    }
  });

  runApp(const CarSocialMediaApp());
}

class CarSocialMediaApp extends StatelessWidget {
  const CarSocialMediaApp({super.key});

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