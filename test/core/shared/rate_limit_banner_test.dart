import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/network/rate_limit_notifier.dart';
import 'package:tweakd/core/shared/widgets/rate_limit_banner.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:tweakd/l10n/app_localizations_en.dart';
import 'package:tweakd/l10n/app_localizations_ro.dart';

/// The banner sits above every route for the whole app run: invisible until a
/// notice arrives, then shows the wait from the backend, then gets out of the
/// way on its own or on tap.
void main() {
  Future<StreamController<RateLimitNotice>> pumpBanner(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    final notices = StreamController<RateLimitNotice>.broadcast();
    addTearDown(notices.close);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: RateLimitBanner(notices: notices.stream, child: child!),
        ),
        home: const Scaffold(body: Center(child: Text('page behind'))),
      ),
    );
    return notices;
  }

  testWidgets('draws nothing until a notice arrives', (tester) async {
    await pumpBanner(tester);

    expect(find.text('page behind'), findsOneWidget);
    expect(find.text("You're doing that too fast"), findsNothing);
  });

  testWidgets('shows the backend wait, then hides itself', (tester) async {
    final notices = await pumpBanner(tester);

    notices.add(const RateLimitNotice(retryAfter: Duration(seconds: 42)));
    await tester.pumpAndSettle();
    expect(find.text("You're doing that too fast"), findsOneWidget);
    expect(find.text('Try again in 42 seconds.'), findsOneWidget);

    await tester.pump(RateLimitBanner.visibleFor);
    await tester.pumpAndSettle();
    expect(find.text("You're doing that too fast"), findsNothing);
  });

  testWidgets('tap dismisses it and the page underneath stays tappable', (
    tester,
  ) async {
    final notices = await pumpBanner(tester);

    notices.add(const RateLimitNotice(retryAfter: Duration(seconds: 5)));
    await tester.pumpAndSettle();
    await tester.tap(find.text("You're doing that too fast"));
    await tester.pumpAndSettle();

    expect(find.text("You're doing that too fast"), findsNothing);
    expect(find.text('page behind').hitTestable(), findsOneWidget);
  });

  testWidgets('fits a small phone at a large text scale and a tablet', (
    tester,
  ) async {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(1024, 1366), 1.0),
    ]) {
      final notices = await pumpBanner(tester, size: size, textScale: scale);
      notices.add(const RateLimitNotice(retryAfter: Duration(minutes: 59)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Try again in 59 minutes.'), findsOneWidget);
      await tester.pump(RateLimitBanner.visibleFor);
      await tester.pumpAndSettle();
    }
  });

  group('rateLimitRetryMessage', () {
    final en = AppLocalizationsEn();
    final ro = AppLocalizationsRo();

    test('picks the largest unit and rounds up', () {
      expect(rateLimitRetryMessage(en, null), 'Wait a moment and try again.');
      expect(
        rateLimitRetryMessage(en, const Duration(seconds: 1)),
        'Try again in 1 second.',
      );
      expect(
        rateLimitRetryMessage(en, const Duration(milliseconds: 1500)),
        'Try again in 2 seconds.',
      );
      expect(
        rateLimitRetryMessage(en, const Duration(seconds: 59)),
        'Try again in 59 seconds.',
      );
      expect(
        rateLimitRetryMessage(en, const Duration(seconds: 60)),
        'Try again in 1 minute.',
      );
      expect(
        rateLimitRetryMessage(en, const Duration(seconds: 61)),
        'Try again in 2 minutes.',
      );
      expect(
        rateLimitRetryMessage(en, const Duration(hours: 1)),
        'Try again in 1 hour.',
      );
    });

    test('uses Romanian plural forms', () {
      expect(
        rateLimitRetryMessage(ro, const Duration(seconds: 1)),
        'Încearcă din nou peste o secundă.',
      );
      expect(
        rateLimitRetryMessage(ro, const Duration(seconds: 5)),
        'Încearcă din nou peste 5 secunde.',
      );
      expect(
        rateLimitRetryMessage(ro, const Duration(seconds: 30)),
        'Încearcă din nou peste 30 de secunde.',
      );
      expect(
        rateLimitRetryMessage(ro, const Duration(minutes: 2)),
        'Încearcă din nou peste 2 minute.',
      );
    });
  });
}
