import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/share_resolve/cubit.dart';
import '../bloc/share_resolve/state.dart';

/// Where a scanned QR or a tapped share link lands inside the app.
///
/// Deliberately not a car screen: the URL carries an opaque code, and only the
/// backend can say which car it means. This resolves it, then *replaces*
/// itself with `/garage/cars/{carId}` so the back button never returns to a
/// spinner.
///
/// The code itself never reaches this page: the route dispatches the resolve
/// on [ShareResolveCubit] with the raw segment, and case, dashes and the
/// O/0, I/L/1 confusions a hand-typed sticker produces are the backend's to
/// sort out.
class ShareLandingPage extends StatelessWidget {
  const ShareLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocConsumer<ShareResolveCubit, ShareResolveState>(
        listener: (context, state) {
          if (state is ShareResolveResolved) {
            // `pushReplacement`, not `go`: the link was opened from wherever
            // the user already was, and that history is worth keeping.
            context.pushReplacement('/garage/cars/${state.carId}');
          }
        },
        builder: (context, state) => switch (state) {
          ShareResolveFailed() => const _UnavailableView(),
          _ => _ResolvingView(message: l10n.garageShareResolving),
        },
      ),
    );
  }
}

class _ResolvingView extends StatelessWidget {
  final String message;
  const _ResolvingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent),
          const SizedBox(height: 18),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// The dead-link screen: unknown code, paused link, revoked link, banned
/// owner. All four say the same thing on purpose — the difference matters to
/// crawlers on the website, not to the person holding the phone.
class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.link_off,
                  size: 28,
                  color: AppColors.mute,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.garageShareUnavailableTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.garageShareUnavailableBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/feed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.garageShareBackToFeed,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
