// Responsiveness guard for the profile page: the header, badge strip, pinned
// section tabs and garage card, pumped across a width × text-scale matrix in
// the same structure the real data views build.
//
// Widget tests render text in a fixed-width test font, so every glyph is as
// wide as it is tall — a harsher squeeze than any real font. Anything that
// survives here survives a device.
//
// This file exists because two layout bugs shipped during the profile
// redesign: the stats row overflowed beside the avatar at 320pt, and the
// pinned tabs header declared more height than it painted, which threw
// "layoutExtent exceeds paintExtent" as soon as it pinned.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/shared/entities/image_ref.dart';
import 'package:tweakd/features/badges/domain/entities/badge.dart';
import 'package:tweakd/features/badges/domain/entities/user_badge.dart';
import 'package:tweakd/features/badges/presentation/widgets/badge_strip.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/garage/presentation/widgets/garage_car_card.dart';
import 'package:tweakd/features/profile/domain/entities/profile.dart';
import 'package:tweakd/features/profile/presentation/widgets/my_profile/edit_profile_button.dart';
import 'package:tweakd/features/profile/presentation/widgets/my_profile/share_profile_button.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_avatar.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_content_frame.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_header.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_section_tabs.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_stats_row.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_tabs_sliver_header.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_top_bar.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// Five badges, so the strip has to hide one behind the "+N" slot.
///
/// The artwork URL is deliberately empty: a widget test has no network, and
/// flutter_svg surfaces a failed fetch as an unhandled async error that fails
/// the test rather than as something `errorBuilder` can absorb. `BadgeArt`
/// short-circuits an empty URL to its medal fallback, which occupies exactly
/// the same box — so the layout under test is the real one.
final _badges = [
  for (var i = 0; i < 5; i++)
    UserBadgeEntity(
      badge: BadgeEntity(
        id: 'badge_$i',
        title: 'Achievement $i',
        description: 'Earned by taking part in the community.',
        unlockedUrl: '',
      ),
      earnedAt: DateTime.utc(2026, 5, 8),
    ),
];

final _profile = ProfileEntity(
  id: 'p1',
  role: 'user',
  name: 'Marcus Vlox',
  username: 'marcus_vlox',
  avatarUrl: '',
  bio:
      'Apex hunter from the principality. Cold starts, mountain switchbacks, '
      'and a soft spot for naturally aspirated straight-sixes.',
  externalLink: '',
  followersCount: 1500,
  followingCount: 53,
  reputationScore: 3240,
  isVerified: true,
  isBusiness: false,
  requiresOnboarding: false,
  appLanguage: 'en',
  badges: _badges,
);

const _car = CarSummaryEntity(
  id: 'c1',
  brand: 'Mercedes-AMG',
  model: 'G63',
  coverImage: ImageRef(key: 'k', url: ''),
  year: 2023,
  horsepower: 577,
  torque: 627,
);

void _noop() {}

/// Mirrors what the data views build: the frame, a top bar, and a scroll view
/// whose header scrolls away under a pinned tab bar.
Widget _profileSurface() {
  return ProfileContentFrame(
    child: Column(
      children: [
        const ProfileTopBar(
          title: '@marcus_vlox',
          alignTitleStart: true,
          showBackButton: false,
        ),
        Expanded(
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      ProfileHeader(profile: _profile, isOwnProfile: false),
                      const SizedBox(height: 18),
                      // The own-profile action row: two of the widest
                      // labels the shared pill ever carries.
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(child: EditProfileButton(onTap: _noop)),
                            SizedBox(width: 10),
                            Expanded(child: ShareProfileButton()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      BadgeStrip(badges: _badges, isOwner: false),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ProfileTabsSliverHeader(
                    active: ProfileSection.garage,
                    onChanged: (_) {},
                    height: ProfileTabsSliverHeader.heightFor(context),
                    showEvents: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Column(
                      children: [
                        GarageCarCard(car: _car, onTap: () {}),
                        const SizedBox(height: 12),
                        GarageCarCard(car: _car, onTap: () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  // 320 = iPhone SE 1st gen, 375 = iPhone 13 mini / SE 3, 430 = 15 Pro Max,
  // 600 = large phone in landscape, 834 = iPad Air portrait, 1024 = landscape.
  const widths = [320.0, 375.0, 430.0, 600.0, 834.0, 1024.0];
  // 1.0 = default, 1.3 = a common bump, 2.0 = the accessibility extreme.
  const textScales = [1.0, 1.3, 2.0];

  for (final width in widths) {
    for (final textScale in textScales) {
      testWidgets('lays out at ${width.toInt()}pt, text x$textScale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: Scaffold(body: _profileSurface()),
          ),
        );

        // Let the mocked badge latency resolve.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Slivers build lazily, so each assertion has to happen while its
        // part of the page is on screen: the header first...
        expect(find.text('Marcus Vlox'), findsOneWidget);
        expect(find.text('3,240'), findsOneWidget);
        expect(find.text('1,500'), findsOneWidget);

        // ...then scroll it away, which is both where the tabs pin (the
        // paintExtent assertion) and where the cards come into view. At x2.0
        // the header is tall enough that they aren't built before this.
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // The card's spec row: power, torque, year.
        expect(find.text('577'), findsWidgets);
        expect(find.text('2023'), findsWidgets);
      });
    }
  }

  testWidgets('content is capped on a wide display', (tester) async {
    tester.view.physicalSize = const Size(1024 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: _profileSurface()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // The bio must not run the full 1024pt: a line that long is unreadable.
    final headerWidth = tester.getSize(find.byType(ProfileHeader)).width;
    expect(headerWidth, lessThanOrEqualTo(ProfileContentFrame.maxContentWidth));
  });

  // Two alignment rules from the mockup, both easy to regress by reaching for
  // Expanded: the counters line up with the display name, and the active tab's
  // underline is the width of that tab, not of a third of the row.
  testWidgets('counters align with the name and the underline hugs its tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: _profileSurface()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // The first counter's label starts exactly where the name above it does.
    expect(
      tester.getTopLeft(find.text('reputation')).dx,
      closeTo(tester.getTopLeft(find.text('Marcus Vlox')).dx, 0.5),
    );

    // Scroll the header away so the tabs are pinned and definitely built.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // The underlined box is the tab's own content plus its padding — nowhere
    // near the quarter of the row the tab itself occupies — and it starts at
    // the same 20pt inset as everything else on the page.
    final icon = find.byIcon(Icons.house);
    final box = find.ancestor(of: icon, matching: find.byType(Container)).first;
    final rowWidth = tester.getSize(find.byType(ProfileSectionTabs)).width;
    expect(tester.getSize(box).width, lessThan(rowWidth / 4));
    expect(tester.getTopLeft(box).dx, closeTo(20, 0.5));
  });

  // The tabs carry their labels wherever the row has room for all of them, and
  // fall back to bare icons where it doesn't, rather than ellipsising each
  // label into a stump. Widget tests use a fixed-width font, so the width these
  // flip at is far narrower on a real device.
  for (final (width, expectLabels) in [(834.0, true), (320.0, false)]) {
    testWidgets('tabs ${expectLabels ? 'carry labels' : 'drop to icons'} '
        'at ${width.toInt()}pt', (tester) async {
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: _profileSurface()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Garage'), expectLabels ? findsOneWidget : findsNothing);
      // The icons are there either way — they are what a tab always is.
      expect(find.byIcon(Icons.house), findsOneWidget);
    });
  }

  // The three counters only fit beside the avatar when there is room for them.
  // Where there isn't, they take their own line rather than ellipsizing every
  // label down to nothing.
  for (final (width, expectBeside) in [(375.0, true), (320.0, false)]) {
    testWidgets(
      'stats ${expectBeside ? 'sit beside' : 'drop below'} the avatar '
      'at ${width.toInt()}pt',
      (tester) async {
        tester.view.physicalSize = Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: _profileSurface()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        final avatarBottom = tester
            .getBottomLeft(find.byType(ProfileAvatar))
            .dy;
        final statsTop = tester.getTopLeft(find.byType(ProfileStatsRow)).dy;
        expect(statsTop < avatarBottom, expectBeside);
      },
    );
  }
}
