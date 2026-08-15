import 'dart:io' show Platform;

import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

/// A third-party turn-by-turn navigation app we can hand a destination to.
enum NavigationApp {
  waze,
  googleMaps,

  /// iOS only — never offered on Android.
  appleMaps,
}

/// Hands a destination to a navigation app installed on the device, or sends
/// the user to the store to get one.
///
/// Deep links only carry **coordinates**, never the place's name or address:
/// a name makes the target app run its own search, which can land the driver at
/// a different branch of the same chain. Coordinates are unambiguous.
///
/// Every link asks for *navigation*, not a map preview — `navigate=yes` for
/// Waze, `google.navigation:` for Android, `dirflg=d`/`directionsmode=driving`
/// for the Apple/Google URL schemes — so one tap in the sheet puts the user in
/// turn-by-turn rather than on a preview screen. The origin is deliberately
/// left unset so the target app uses its own live GPS fix.
@lazySingleton
class NavigationLauncherService {
  /// Which of [NavigationApp]'s members can actually handle a destination on
  /// this device, in the order they should be offered.
  ///
  /// This is a real probe, not a platform guess — Apple Maps is deletable since
  /// iOS 10, so even it has to be asked for.
  ///
  /// Both platforms gate these probes: iOS needs the schemes listed under
  /// `LSApplicationQueriesSchemes` in `Info.plist`, Android needs the packages
  /// listed under `<queries>` in `AndroidManifest.xml`. Without those entries
  /// the probe answers "not installed" for an app that is installed.
  Future<List<NavigationApp>> installedApps() async {
    final candidates = [
      NavigationApp.waze,
      NavigationApp.googleMaps,
      if (Platform.isIOS) NavigationApp.appleMaps,
    ];

    final results = await Future.wait(candidates.map(_isInstalled));
    return [
      for (var i = 0; i < candidates.length; i++)
        if (results[i]) candidates[i],
    ];
  }

  /// Opens [app] in turn-by-turn navigation towards ([lat], [lng]).
  ///
  /// Returns false when the app refused to open, which the caller should treat
  /// as "tell the user", not as a crash.
  Future<bool> startNavigation(
    NavigationApp app, {
    required double lat,
    required double lng,
  }) {
    return _launch(_navigationUri(app, lat, lng));
  }

  /// Opens [app]'s page on the App Store / Play Store so the user can install
  /// it. Returns false when even the store couldn't be opened.
  Future<bool> openStorePage(NavigationApp app) => _launch(_storeUri(app));

  Future<bool> _isInstalled(NavigationApp app) async {
    try {
      return await canLaunchUrl(_probeUri(app));
    } on Exception {
      // A platform channel failure means we simply don't know — treat it the
      // same as absent so the sheet still renders with an install option.
      return false;
    }
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }

  /// The cheapest URI that still resolves to [app] and nothing else.
  ///
  /// `geo:` is deliberately avoided on Android — every maps app claims it, so
  /// it would report Google Maps as installed whenever *any* maps app is.
  Uri _probeUri(NavigationApp app) => switch (app) {
        NavigationApp.waze => Uri.parse('waze://'),
        NavigationApp.googleMaps => Platform.isIOS
            ? Uri.parse('comgooglemaps://')
            : Uri.parse('google.navigation:q=0,0'),
        NavigationApp.appleMaps => Uri.parse('maps://'),
      };

  Uri _navigationUri(NavigationApp app, double lat, double lng) =>
      switch (app) {
        // `navigate=yes` skips Waze's destination preview and starts driving.
        NavigationApp.waze =>
          Uri.parse('waze://?ll=$lat,$lng&navigate=yes'),

        // Android has a dedicated navigation scheme that launches straight into
        // guidance; iOS's `comgooglemaps://` has no equivalent, so it opens the
        // driving-directions screen with a Start button instead.
        NavigationApp.googleMaps => Platform.isIOS
            ? Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving')
            : Uri.parse('google.navigation:q=$lat,$lng&mode=d'),

        // `daddr` with no `saddr` means "from wherever I am now".
        NavigationApp.appleMaps =>
          Uri.parse('maps://?daddr=$lat,$lng&dirflg=d'),
      };

  Uri _storeUri(NavigationApp app) {
    if (Platform.isIOS) {
      return Uri.parse(switch (app) {
        NavigationApp.waze => 'https://apps.apple.com/app/id323229106',
        NavigationApp.googleMaps => 'https://apps.apple.com/app/id585027354',
        NavigationApp.appleMaps => 'https://apps.apple.com/app/id915056765',
      });
    }
    return Uri.parse(switch (app) {
      NavigationApp.waze =>
        'https://play.google.com/store/apps/details?id=com.waze',
      NavigationApp.googleMaps =>
        'https://play.google.com/store/apps/details?id=com.google.android.apps.maps',
      // Unreachable: Apple Maps is never offered off iOS.
      NavigationApp.appleMaps =>
        'https://play.google.com/store/apps/details?id=com.google.android.apps.maps',
    });
  }
}
