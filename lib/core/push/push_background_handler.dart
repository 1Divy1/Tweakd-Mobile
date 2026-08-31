import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';

/// Background/terminated FCM entry point, registered in `main.dart` before
/// `runApp`.
///
/// Runs in its own isolate with none of the app's state: no DI, no navigator,
/// no blocs. It deliberately does **nothing** beyond booting Firebase — the
/// backend sends a `notification` block alongside `data`, so the OS has
/// already drawn the notification by the time this runs, and the tap is
/// handled later by `getInitialMessage`/`onMessageOpenedApp` on the main
/// isolate where the router actually exists.
///
/// It is still registered rather than omitted: without a background handler
/// Android drops the `data` block of a background message, which is what the
/// deep link is built from. Keep it cheap — the OS kills the isolate after
/// roughly 30 seconds, and every message pays for whatever runs here.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
