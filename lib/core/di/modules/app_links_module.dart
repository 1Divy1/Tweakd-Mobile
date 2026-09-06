import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

/// `AppLinks()` is a singleton in the package itself — one platform
/// subscription behind a broadcast stream — so registering it here just makes
/// that instance injectable rather than reached for globally. Supabase's auth
/// listener reads the same stream; both get every event.
@module
abstract class AppLinksModule {
  @lazySingleton
  AppLinks get appLinks => AppLinks();
}
