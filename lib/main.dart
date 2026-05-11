import 'package:car_social_media_app/config/routes/app_router.dart';
import 'package:car_social_media_app/core/di/injection.dart';
import 'package:car_social_media_app/core/storage/secure_local_storage.dart';
import 'package:car_social_media_app/core/theme/app_theme.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/bloc.dart';
import 'package:car_social_media_app/features/authentication/presentation/bloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {

  // Make sure the binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: MaterialApp.router(
        title: 'Cargram',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: appRouter,
      ),
    );
  }
}