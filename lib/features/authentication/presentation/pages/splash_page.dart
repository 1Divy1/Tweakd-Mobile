import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/push/push_navigator.dart';
import '../bloc/bloc.dart';
import '../bloc/state.dart';

/// Flutter-drawn continuation of the native (OS-level) launch screen. Same
/// background color and same logo per brightness, so the handoff from native
/// splash -> this page is seamless. Stays up until [AuthBloc] resolves
/// (CheckAuthStatus, dispatched at app start), then routes to the right
/// destination.
///
/// Dark mode isn't implemented anywhere else in the app yet (no dark
/// [ThemeData], no user toggle) — this keys off the OS-level brightness
/// directly since that's also what the native launch screen (configured via
/// flutter_native_splash's color_dark/image_dark) already follows. It's
/// intentionally the one piece of UI prepared for dark mode ahead of the
/// rest of the app.
/// Size flutter_native_splash renders the launch image at (256dp/pt on both
/// platforms). Keep in step with the generated launch assets.
const double _nativeSplashLogoSize = 256;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Only remove the native splash once this identical-looking page has
    // actually painted, so there's never a blank frame in between.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/signup');
        } else if (state is AuthenticatedRequiresOnboarding) {
          context.go('/onboarding');
        } else if (state is Authenticated) {
          context.go('/feed');
          // A notification tapped from a terminated app parked its destination
          // here while the session was still resolving. Releasing it now — with
          // the feed already the stack's root — pushes the target on top of the
          // feed, so back goes somewhere sensible instead of nowhere.
          getIt<PushNavigator>().flushPending();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          // The native launch screen centers the same artwork at its natural
          // 256pt size, so matching that here makes the handoff invisible.
          child: SvgPicture.asset(
            isDark
                ? 'assets/app_logo/Tweakd SVG logo transparent - Dark version.svg'
                : 'assets/app_logo/Tweakd SVG logo transparent - Light version.svg',
            width: _nativeSplashLogoSize,
            height: _nativeSplashLogoSize,
          ),
        ),
      ),
    );
  }
}
