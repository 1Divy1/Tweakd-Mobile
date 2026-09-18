import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/deeplinks/deep_link_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/push/push_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/bloc.dart';
import '../bloc/state.dart';

/// Resolves the session over the network when the device alone can't — no
/// saved session, or a user not yet known to have finished onboarding — then
/// routes to the right destination. A signed-in, onboarded user never sees it:
/// `main()` opens those launches straight on the feed.
///
/// The native (OS-level) launch screen stays up over this page the whole time
/// and is only removed once the destination has painted. This page used to
/// remove it on its own first frame, which is what made the launch look like
/// two splashes in a row: the native one is a bitmap (on Android 12+, also
/// shrunk into the icon mask), this one a crisp vector at a different size.
/// Its artwork below is now only a fallback for a platform that drops the
/// native screen early.
///
/// Reads [AppColors.isDark] rather than `MediaQuery.platformBrightnessOf`
/// directly: by the time this page builds, `main.dart` has already resolved
/// `ThemeModeCubit`'s preference (which may override the OS setting) against
/// the platform brightness and applied it to `AppColors`. Reading the raw
/// platform brightness here would ignore a manual light/dark override and
/// mismatch the rest of the app for a frame. The native launch screen itself
/// (flutter_native_splash's color_dark/image_dark) still only ever sees the
/// OS setting — the two can only briefly disagree if the user manually
/// overrides the theme, which happens after this page has already painted.
/// Size flutter_native_splash renders the launch image at (256dp/pt on both
/// platforms). Keep in step with the generated launch assets.
const double _nativeSplashLogoSize = 256;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// Lifts the native launch screen once the destination just navigated to
  /// has painted underneath it.
  void _removeNativeSplashAfterNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/signup');
          _removeNativeSplashAfterNextFrame();
        } else if (state is AuthenticatedRequiresOnboarding) {
          context.go('/onboarding');
          _removeNativeSplashAfterNextFrame();
        } else if (state is Authenticated) {
          context.go('/feed');
          // A notification tapped from a terminated app parked its destination
          // here while the session was still resolving. Releasing it now — with
          // the feed already the stack's root — pushes the target on top of the
          // feed, so back goes somewhere sensible instead of nowhere.
          getIt<PushNavigator>().flushPending();
          // Same for a share link that launched the app from terminated: it
          // was parked while the session resolved, and the feed is now the
          // stack's root, so the car opens on top of somewhere sensible.
          getIt<DeepLinkService>().flushPending();
          _removeNativeSplashAfterNextFrame();
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
