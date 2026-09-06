import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/deeplinks/share_link_route.dart';
import 'package:tweakd/features/garage/domain/entities/car_share.dart';

/// Two risks live in this mapping, and both are silent when they go wrong.
///
/// The first is over-matching: `DeepLinkService` listens to the same link
/// stream Supabase's auth callbacks arrive on, so anything that claims a
/// `tweakd://signup-callback` URL breaks sign-up without an error anywhere.
/// The second is under-matching: a share link the app quietly ignores means a
/// user taps a friend's QR, the app opens, and nothing happens.
void main() {
  group('shareRouteFor', () {
    test('maps a share URL to the resolver route', () {
      expect(
        shareRouteFor(Uri.parse('https://web.tweakdapp.com/c/7KQ3M9XA2F')),
        '/c/7KQ3M9XA2F',
      );
    });

    test('carries the source tag through', () {
      expect(
        shareRouteFor(Uri.parse('https://web.tweakdapp.com/c/7KQ3M9XA2F?s=qr')),
        '/c/7KQ3M9XA2F?s=qr',
      );
    });

    test('accepts the custom-scheme fallback', () {
      expect(
        shareRouteFor(Uri.parse('tweakd://c/7KQ3M9XA2F?s=qr')),
        '/c/7KQ3M9XA2F?s=qr',
      );
    });

    test('leaves the code alone — normalising it is the backend\'s job', () {
      // Lowercase, dashed and O-for-0 variants all resolve server-side. Doing
      // that here too would be a second implementation to drift out of step.
      expect(
        shareRouteFor(Uri.parse('https://web.tweakdapp.com/c/7kq3-m9xa-2f')),
        '/c/7kq3-m9xa-2f',
      );
    });

    test('ignores the Supabase auth callbacks', () {
      expect(shareRouteFor(Uri.parse('tweakd://signup-callback')), isNull);
      expect(
        shareRouteFor(Uri.parse('tweakd://login-callback?code=abc')),
        isNull,
      );
    });

    test('ignores other hosts, other paths and a bare /c', () {
      expect(shareRouteFor(Uri.parse('https://example.com/c/ABC')), isNull);
      expect(shareRouteFor(Uri.parse('https://web.tweakdapp.com/legal')), isNull);
      expect(shareRouteFor(Uri.parse('https://web.tweakdapp.com/c/')), isNull);
      expect(shareRouteFor(Uri.parse('https://web.tweakdapp.com/')), isNull);
    });

    test('ignores the apex, which is the presentation site and serves no codes', () {
      // The app does not claim tweakdapp.com, so the OS never delivers it here.
      // Over-matching it would mean a tap on a marketing page tried to open the
      // app and then failed to resolve the code.
      expect(shareRouteFor(Uri.parse('https://tweakdapp.com/c/7KQ3M9XA2F')), isNull);
      expect(shareRouteFor(Uri.parse('https://www.tweakdapp.com/c/7KQ3M9XA2F')), isNull);
    });

    test('refuses an absurdly long segment rather than routing it', () {
      final long = 'A' * 40;
      expect(shareRouteFor(Uri.parse('https://web.tweakdapp.com/c/$long')), isNull);
    });
  });

  group('CarShareEntity', () {
    const link = CarShareEntity(
      code: '7KQ3M9XA2F',
      url: 'https://web.tweakdapp.com/c/7KQ3M9XA2F',
      qrUrl: 'https://web.tweakdapp.com/c/7KQ3M9XA2F?s=qr',
      enabled: true,
    );

    test('tags the URL per channel', () {
      expect(
        link.urlFor(CarShareChannel.whatsapp),
        'https://web.tweakdapp.com/c/7KQ3M9XA2F?s=wa',
      );
      expect(
        link.urlFor(CarShareChannel.copy),
        'https://web.tweakdapp.com/c/7KQ3M9XA2F?s=copy',
      );
      // What the backend renders into the QR, reproduced by the same rule.
      expect(link.urlFor(CarShareChannel.qr), link.qrUrl);
    });

    test('previews the URL without its scheme, as the sheet shows it', () {
      expect(link.displayUrl, 'web.tweakdapp.com/c/7KQ3M9XA2F');
    });
  });
}
