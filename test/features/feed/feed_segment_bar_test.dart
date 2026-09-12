import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/feed/presentation/utils/feed_segment.dart';
import 'package:tweakd/features/feed/presentation/widgets/feed_segment_bar.dart';
import 'package:tweakd/features/forums/presentation/widgets/home/forums_home_actions.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// The segment bar puts scaling text beside fixed-size action pills, which
/// makes it the part of the home tab most likely to overflow on a small phone
/// at a large text size.
void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    FeedSegment active = FeedSegment.forums,
    ValueChanged<FeedSegment>? onChanged,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SafeArea(
            child: FeedSegmentBar(
              active: active,
              onChanged: onChanged ?? (_) {},
              // The actions only read their bloc when tapped.
              trailing: active == FeedSegment.forums
                  ? const ForumsHomeActions()
                  : null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(320, 568), Size(390, 844), Size(1024, 1366)]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets('lays out at ${size.width.toInt()}pt, text ×$scale', (
        tester,
      ) async {
        await pumpBar(tester, size: size, textScale: scale);

        expect(tester.takeException(), isNull);
        expect(find.text('Feed'), findsOneWidget);
        expect(find.text('Forums'), findsOneWidget);
      });
    }
  }

  testWidgets('tapping a segment reports it', (tester) async {
    FeedSegment? picked;
    await pumpBar(
      tester,
      size: const Size(390, 844),
      textScale: 1,
      active: FeedSegment.feed,
      onChanged: (segment) => picked = segment,
    );

    await tester.tap(find.text('Forums'));
    await tester.pumpAndSettle();

    expect(picked, FeedSegment.forums);
  });
}
