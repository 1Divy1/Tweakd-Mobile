// The strip's one rule: five slots, and the "ALL" button only appears when the
// collection doesn't fit in them. Locked badges are not shown anywhere, so a
// profile with nothing earned gets no strip at all — the "ALL" slot used to be
// kept on your own profile as a way into the locked catalogue, and that
// catalogue is gone.
//
// The artwork URL is deliberately empty: a widget test has no network, and
// flutter_svg surfaces a failed fetch as an unhandled async error. `BadgeArt`
// short-circuits an empty URL to its medal fallback.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/badges/domain/entities/badge.dart';
import 'package:tweakd/features/badges/domain/entities/user_badge.dart';
import 'package:tweakd/features/badges/presentation/widgets/badge_circle.dart';
import 'package:tweakd/features/badges/presentation/widgets/badge_strip.dart';
import 'package:tweakd/l10n/app_localizations.dart';

List<UserBadgeEntity> _badges(int count) => [
  for (var i = 0; i < count; i++)
    UserBadgeEntity(
      badge: BadgeEntity(id: 'badge_$i', title: 'Badge $i', unlockedUrl: ''),
      earnedAt: DateTime(2026, 1, i + 1),
    ),
];

Future<void> _pumpStrip(WidgetTester tester, int count) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: BadgeStrip(badges: _badges(count))),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('nothing earned draws no strip', (tester) async {
    await _pumpStrip(tester, 0);

    expect(find.byType(BadgeCircle), findsNothing);
    expect(find.byType(BadgeOverflowCircle), findsNothing);
  });

  for (final count in [1, 4, 5]) {
    testWidgets('$count badges all fit, with no ALL button', (tester) async {
      await _pumpStrip(tester, count);

      expect(find.byType(BadgeCircle), findsNWidgets(count));
      expect(find.byType(BadgeOverflowCircle), findsNothing);
    });
  }

  testWidgets('a sixth badge gives the last slot to ALL', (tester) async {
    await _pumpStrip(tester, 6);

    // Four badges plus the "+2" slot: the two the row couldn't fit, and the
    // one whose slot the button took.
    expect(find.byType(BadgeCircle), findsNWidgets(4));
    expect(find.byType(BadgeOverflowCircle), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });
}
