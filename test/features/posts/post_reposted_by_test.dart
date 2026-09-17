import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/posts/domain/entities/post_reposted_by.dart';
import 'package:tweakd/features/posts/domain/entities/post_user.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_reposted_by.dart';
import 'package:tweakd/l10n/app_localizations.dart';

const _andrei = PostUserEntity(id: 'u1', username: 'andrei');
const _mihai = PostUserEntity(id: 'u2', username: 'mihai');
const _long = PostUserEntity(
  id: 'u3',
  username: 'apex_hunter_from_the_principality_of_monaco',
);

/// The "reposted by" line sits above every feed card a followee reposted, so
/// it must read right for one, two and many reposters and never overflow the
/// card, whatever the username length, width or text size.
void main() {
  Future<void> pump(
    WidgetTester tester,
    RepostedByEntity repostedBy, {
    double width = 375,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 200);
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
          body: Padding(
            // The feed card's margin plus the line's own padding.
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: PostRepostedBy(repostedBy: repostedBy),
          ),
        ),
      ),
    );
  }

  testWidgets('names a single reposter', (tester) async {
    await pump(
      tester,
      const RepostedByEntity(users: [_andrei], totalCount: 1),
    );
    expect(find.text('@andrei reposted'), findsOneWidget);
  });

  testWidgets('names both of two reposters', (tester) async {
    await pump(
      tester,
      const RepostedByEntity(users: [_andrei, _mihai], totalCount: 2),
    );
    expect(find.text('@andrei and @mihai reposted'), findsOneWidget);
  });

  testWidgets('counts everyone past the most recent reposter', (tester) async {
    await pump(
      tester,
      const RepostedByEntity(users: [_andrei, _mihai], totalCount: 5),
    );
    expect(find.text('@andrei and 4 others reposted'), findsOneWidget);
  });

  for (final width in [320.0, 375.0, 834.0]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'a long username fits at ${width.toInt()}pt, text x$textScale',
        (tester) async {
          await pump(
            tester,
            const RepostedByEntity(users: [_long, _mihai], totalCount: 12),
            width: width,
            textScale: textScale,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
