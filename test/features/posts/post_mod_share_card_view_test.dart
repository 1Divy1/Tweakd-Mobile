// The card a shared mod draws in the feed: what it says, what it offers, and
// that it holds together at every width and text scale.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/garage/domain/entities/car_modification.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/garage/domain/entities/mod_share_card.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_mod_share_card_view.dart';
import 'package:tweakd/l10n/app_localizations.dart';

ModShareCardEntity _card({
  double? price,
  String? priceCurrency,
  bool before = true,
  bool after = true,
}) =>
    ModShareCardEntity(
      modificationId: 'm1',
      car: const CarSummaryEntity(
        id: 'c1',
        brand: 'BMW',
        model: 'M3 Competition Touring xDrive',
        year: 2023,
      ),
      categoryName: 'Suspension',
      title: 'H&R Coilovers',
      description: 'Dropped 30mm.',
      beforeMedia: before ? [_media('before')] : const [],
      afterMedia: after ? [_media('after')] : const [],
      installationDate: DateTime.utc(2026, 4, 1),
      price: price,
      priceCurrency: priceCurrency,
    );

ModificationMediaEntity _media(String phase) => ModificationMediaEntity(
      key: '$phase.jpg',
      url: 'https://media.tweakdapp.com/$phase.jpg',
      type: 'image',
      phase: phase,
    );

Widget _app(Widget body, {double textScale = 1}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: body)),
    );

void main() {
  testWidgets('names the mod and the car it went on', (tester) async {
    await tester.pumpWidget(_app(PostModShareCardView(card: _card())));
    await tester.pump();

    expect(find.text('H&R Coilovers'), findsOneWidget);
    expect(find.text('Suspension'), findsOneWidget);
    expect(find.text('New mod'), findsOneWidget);
    expect(
      find.text('on 2023 BMW M3 Competition Touring xDrive'),
      findsOneWidget,
    );
  });

  testWidgets('offers before/after only when there is both', (tester) async {
    await tester.pumpWidget(_app(PostModShareCardView(card: _card())));
    await tester.pump();
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);

    await tester.pumpWidget(
      _app(PostModShareCardView(card: _card(before: false))),
    );
    await tester.pump();
    // One phase is not a comparison, so there is nothing to switch between.
    expect(find.text('Before'), findsNothing);
    expect(find.text('After'), findsNothing);
  });

  testWidgets('shows a price only when the owner published one',
      (tester) async {
    await tester.pumpWidget(_app(PostModShareCardView(card: _card())));
    await tester.pump();
    expect(find.textContaining('1200'), findsNothing);

    await tester.pumpWidget(
      _app(PostModShareCardView(
        card: _card(price: 1200, priceCurrency: 'EUR'),
      )),
    );
    await tester.pump();
    expect(find.text('1200 EUR'), findsOneWidget);
  });

  testWidgets('display-only mode drops the switcher and the chevron',
      (tester) async {
    await tester.pumpWidget(
      _app(PostModShareCardView(card: _card(), interactive: false)),
    );
    await tester.pump();

    // Nothing here promises a tap it cannot honour.
    expect(find.text('Before'), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  // 320 = iPhone SE 1st gen, 440 = 17 Pro Max, 834 = iPad Air portrait.
  for (final width in const [320.0, 375.0, 440.0, 834.0]) {
    for (final textScale in const [1.0, 1.3, 2.0]) {
      testWidgets('lays out at ${width.toInt()}pt, text x$textScale',
          (tester) async {
        tester.view.physicalSize = Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _app(
            PostModShareCardView(card: _card(price: 1200)),
            textScale: textScale,
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
