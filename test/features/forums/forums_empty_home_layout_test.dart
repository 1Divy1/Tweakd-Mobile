// Responsiveness guard for the empty-paddock forums home: the explainer over
// the "popular right now" list, and the no-threads CTA fallback, pumped across
// a width × text-scale matrix in the same sliver structure ForumsHomeView
// builds. See test/features/profile/profile_layout_test.dart for why widget
// tests' fixed-width font makes this a harsher squeeze than any device.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/shared/layout/app_layout.dart';
import 'package:tweakd/features/forums/domain/entities/forum_author.dart';
import 'package:tweakd/features/forums/domain/entities/forum_thread.dart';
import 'package:tweakd/features/forums/domain/entities/forum_topic.dart';
import 'package:tweakd/features/forums/presentation/widgets/home/forums_empty_view.dart';
import 'package:tweakd/features/forums/presentation/widgets/shared/forum_thread_card.dart';
import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:tweakd/l10n/app_localizations.dart';

final _threads = [
  for (var i = 0; i < 3; i++)
    ForumThreadEntity(
      id: 't$i',
      title: 'Best exhaust setup for the S58 without droning on the '
          'motorway — real owner experiences wanted',
      author: const ForumAuthorEntity(
        id: 'a1',
        username: 'a_very_long_username_for_testing',
      ),
      brand: const CarBrandEntity(id: 'b1', name: 'Mercedes-AMG'),
      model: const CarModelEntity(id: 'm1', brandId: 'b1', model: 'GT 63 S'),
      topics: const [
        ForumTopicEntity(id: 'tuning', name: 'Tuning'),
        ForumTopicEntity(id: 'maintenance', name: 'Maintenance'),
      ],
      likesCount: 1284,
      replyCount: 342,
      lastActivityAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
];

Widget _surface({required bool hasThreads}) {
  return CustomScrollView(
    slivers: [
      SliverContentFrame(
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    ForumsEmptyView(hasThreads: hasThreads, onStartThread: () {}),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (hasThreads)
              SliverList.list(
                children: [
                  for (final thread in _threads)
                    ForumThreadCard(
                      thread: thread,
                      onTap: () {},
                      onToggleSave: () {},
                    ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

void main() {
  const widths = [320.0, 375.0, 430.0, 834.0, 1024.0];
  const textScales = [1.0, 1.3, 2.0];

  for (final hasThreads in [true, false]) {
    for (final width in widths) {
      for (final textScale in textScales) {
        testWidgets(
          '${hasThreads ? 'popular list' : 'CTA fallback'} lays out at '
          '${width.toInt()}pt, text x$textScale',
          (tester) async {
            tester.view.physicalSize = Size(width * 3, 900 * 3);
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: Scaffold(body: _surface(hasThreads: hasThreads)),
              ),
            );
            await tester.pump();

            expect(tester.takeException(), isNull);
            expect(find.text('Popular right now'),
                hasThreads ? findsOneWidget : findsNothing);
            expect(find.text('Start the first thread'),
                hasThreads ? findsNothing : findsOneWidget);
          },
        );
      }
    }
  }
}
