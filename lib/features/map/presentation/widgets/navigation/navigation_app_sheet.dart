import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/navigation_launcher_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Bottom sheet that asks which navigation app should take the user to
/// [destinationLabel], then launches it.
///
/// Apps the device actually has come first and launch turn-by-turn on tap;
/// the rest are still listed, but tapping one opens its store page. That way a
/// user with nothing installed still gets somewhere useful instead of a dead
/// button, and the sheet never has an empty state.
///
/// Not map-specific beyond its copy — car meets (and anything else with a
/// coordinate) can open the same sheet.
Future<void> showNavigationAppSheet(
  BuildContext context, {
  required double lat,
  required double lng,
  required String destinationLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _NavigationAppSheet(
      lat: lat,
      lng: lng,
      destinationLabel: destinationLabel,
    ),
  );
}

class _NavigationAppSheet extends StatefulWidget {
  final double lat;
  final double lng;
  final String destinationLabel;

  const _NavigationAppSheet({
    required this.lat,
    required this.lng,
    required this.destinationLabel,
  });

  @override
  State<_NavigationAppSheet> createState() => _NavigationAppSheetState();
}

class _NavigationAppSheetState extends State<_NavigationAppSheet> {
  final _launcher = getIt<NavigationLauncherService>();

  /// Null while the install probe is still running — the rows are known up
  /// front, only their installed/not-installed state has to be waited for.
  List<NavigationApp>? _installed;

  static const _allApps = [
    NavigationApp.waze,
    NavigationApp.googleMaps,
    NavigationApp.appleMaps,
  ];

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    final installed = await _launcher.installedApps();
    if (mounted) setState(() => _installed = installed);
  }

  Future<void> _onAppTapped(NavigationApp app, bool isInstalled) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final opened = isInstalled
        ? await _launcher.startNavigation(
            app,
            lat: widget.lat,
            lng: widget.lng,
          )
        : await _launcher.openStorePage(app);

    navigator.pop();
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.mapNavigateFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final installed = _installed;

    // Apple Maps only exists on iOS; on Android its row would only ever be an
    // install prompt for an app that can't be installed.
    final rows = _allApps
        .where((app) => app != NavigationApp.appleMaps || Platform.isIOS)
        // Installed apps float to the top, so the fast path is the first thing
        // under the thumb.
        .toList()
      ..sort((a, b) {
        if (installed == null) return 0;
        final ai = installed.contains(a) ? 0 : 1;
        final bi = installed.contains(b) ? 0 : 1;
        return ai.compareTo(bi);
      });

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.mapNavigateSheetTitle,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.destinationLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            for (final app in rows) ...[
              _AppRow(
                app: app,
                // Every row stays tappable while probing; the trailing state is
                // all that waits, so the sheet never feels frozen.
                isInstalled: installed?.contains(app) ?? true,
                isProbing: installed == null,
                onTap: () =>
                    _onAppTapped(app, installed?.contains(app) ?? true),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  final NavigationApp app;
  final bool isInstalled;
  final bool isProbing;
  final VoidCallback onTap;

  const _AppRow({
    required this.app,
    required this.isInstalled,
    required this.isProbing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.bgSoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _tint(app).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(app), size: 20, color: _tint(app)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // Brand names, never translated.
                  _name(app),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isProbing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.muteSoft,
                  ),
                )
              else if (isInstalled)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.muteSoft,
                )
              else
                Text(
                  l10n.mapNavigateInstall,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _name(NavigationApp app) => switch (app) {
        NavigationApp.waze => 'Waze',
        NavigationApp.googleMaps => 'Google Maps',
        NavigationApp.appleMaps => 'Apple Maps',
      };

  static IconData _icon(NavigationApp app) => switch (app) {
        NavigationApp.waze => Icons.navigation_rounded,
        NavigationApp.googleMaps => Icons.map_rounded,
        NavigationApp.appleMaps => Icons.explore_rounded,
      };

  static Color _tint(NavigationApp app) => switch (app) {
        NavigationApp.waze => const Color(0xFF00B3E6),
        NavigationApp.googleMaps => const Color(0xFF4285F4),
        NavigationApp.appleMaps => const Color(0xFF007AFF),
      };
}
