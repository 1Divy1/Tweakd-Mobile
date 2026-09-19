/// Turns an incoming URL into an in-app route.
///
/// Kept as a pure function, apart from [DeepLinkService], so the mapping can be
/// unit-tested and so the router and the service can never disagree about what
/// a share URL means.
library;

/// The host the app claims via Universal Links (iOS) / App Links (Android).
///
/// The `web.` subdomain, not the apex: `tweakdapp.com` is the presentation site
/// and serves no share codes. Must stay in step with `Runner.entitlements`, the
/// `AndroidManifest` intent-filter, the `.well-known/` files served by the
/// Tweakd-Web-App Worker, and the backend's `sharing.public-base-url` — a
/// mismatch anywhere in that chain means links open a browser instead of the
/// app, with nothing to say why.
const String shareLinkHost = 'web.tweakdapp.com';

/// Hosts an incoming `https` link may carry.
///
/// A set rather than one string so an alias can be added without touching the
/// matcher. The apex is deliberately absent: the app does not claim it, so the
/// OS will never deliver it here, and a link to it would 404 anyway.
const Set<String> shareLinkHosts = {shareLinkHost};

/// The custom scheme kept as a fallback for the website's "Open in app"
/// button: Universal Links deliberately do not fire when the tap happens on a
/// page already served from the same domain.
const String shareLinkScheme = 'tweakd';

/// The single path segment share links live under: `/c/{code}`.
const String shareLinkPathSegment = 'c';

/// The in-app route a share link opens, or null if [uri] is not one.
///
/// Recognises the shape only — `/c/<something>` — and hands the segment on
/// untouched. Validating the code here would be a second implementation of the
/// backend's normalisation (which already rescues lowercase, dashes and the
/// O/0, I/L/1 confusions a hand-typed sticker produces), and the two drifting
/// apart would mean links the server would happily serve dying silently in the
/// client. An unknown code answers 404 and the user gets the "unavailable"
/// screen, which is the honest outcome either way.
String? shareRouteFor(Uri uri) {
  final code = shareCodeFor(uri);
  if (code == null) return null;

  final source = uri.queryParameters['s'];
  final path = '/$shareLinkPathSegment/${Uri.encodeComponent(code)}';
  return source == null || source.isEmpty
      ? path
      : '$path?s=${Uri.encodeQueryComponent(source)}';
}

/// The raw share code carried by [uri], or null if it carries none.
String? shareCodeFor(Uri uri) {
  final segments = uri.pathSegments;

  final String? raw;
  if (uri.scheme == 'https' || uri.scheme == 'http') {
    final matchesHost = shareLinkHosts.contains(uri.host.toLowerCase());
    raw = matchesHost &&
            segments.length >= 2 &&
            segments.first == shareLinkPathSegment
        ? segments[1]
        : null;
  } else if (uri.scheme == shareLinkScheme &&
      uri.host.toLowerCase() == shareLinkPathSegment) {
    // `tweakd://c/7KQ3M9XA2F` — the host is the segment, the code is the path.
    raw = segments.isNotEmpty ? segments.first : null;
  } else {
    raw = null;
  }

  if (raw == null) return null;

  // Hygiene only, not validation: keep whitespace and absurd lengths out of the
  // route. Case, dashes and O/I/L substitutions are the backend's business.
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed.length > 24) return null;
  return trimmed;
}

// ---------------------------------------------------------------------------
// Shared events: `https://web.tweakdapp.com/e/{eventId}` and `tweakd://e/{eventId}`
// ---------------------------------------------------------------------------

/// The single path segment shared events live under: `/e/{eventId}`. Must
/// match the Tweakd-Web-App Worker's `EVENT_PATH`, its `apple-app-site-
/// association` claim and the `AndroidManifest` intent filters.
const String eventLinkPathSegment = 'e';

final RegExp _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// The public URL anyone can open for an event, app or no app.
///
/// An event is shared by its plain id rather than a code like a car: an
/// approved event is already visible to every user, so there is nothing to
/// hide, mint, pause or count.
String eventShareUrl(String eventId) =>
    'https://$shareLinkHost/$eventLinkPathSegment/$eventId';

/// The in-app route a shared event link opens — straight onto the event page,
/// no resolve step — or null if [uri] is not one.
///
/// Unlike a car code, the id *is* validated: the app mints these links itself
/// from real UUIDs, so anything else was mangled on the way and would only
/// produce a "not found" page.
String? eventRouteFor(Uri uri) {
  final segments = uri.pathSegments;

  final String? raw;
  if (uri.scheme == 'https' || uri.scheme == 'http') {
    raw = shareLinkHosts.contains(uri.host.toLowerCase()) &&
            segments.length >= 2 &&
            segments.first == eventLinkPathSegment
        ? segments[1]
        : null;
  } else if (uri.scheme == shareLinkScheme &&
      uri.host.toLowerCase() == eventLinkPathSegment) {
    // `tweakd://e/{id}` — the host is the segment, the id is the path.
    raw = segments.isNotEmpty ? segments.first : null;
  } else {
    raw = null;
  }

  if (raw == null) return null;
  final id = raw.trim().toLowerCase();
  return _uuid.hasMatch(id) ? '/map-events/$id' : null;
}
