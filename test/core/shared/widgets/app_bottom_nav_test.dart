import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/core/shared/widgets/app_bottom_nav.dart';
import 'package:tweakd/core/shared/widgets/create_sheet.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// The nav and its create sheet are fixed-size chrome around text that scales,
/// so the risks are layout (small phones, large text, tablets) and wiring
/// (each option opening its composer, the host hearing when it closes).
void main() {
  late List<CreateAction> closed;

  setUp(() => closed = []);

  /// The icon-only slots are identified by their accessibility label.
  Finder labelled(String label) => find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );

  Future<void> pumpNav(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Column(
              children: [
                const Spacer(),
                AppBottomNav(
                  activeTab: AppBottomNavTab.feed,
                  onCreateClosed: closed.add,
                ),
              ],
            ),
          ),
        ),
        for (final action in CreateAction.values)
          GoRoute(
            path: action.route,
            builder: (_, _) =>
                Scaffold(body: Center(child: Text('composer:${action.name}'))),
          ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
  }

  const sizes = [Size(320, 568), Size(390, 844), Size(1024, 1366)];

  for (final size in sizes) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets(
        'nav and create sheet lay out at ${size.width.toInt()}pt, '
        'text ×$scale',
        (tester) async {
          await pumpNav(tester, size: size, textScale: scale);

          for (final label in ['Feed', 'Map', 'Create', 'Search', 'Profile']) {
            expect(labelled(label), findsOneWidget);
          }

          await tester.tap(labelled('Create'));
          await tester.pumpAndSettle();

          expect(find.text('Post'), findsOneWidget);
          expect(find.text('Forum thread'), findsOneWidget);
          expect(find.text('Car event'), findsOneWidget);
          expect(find.text('Add modification'), findsOneWidget);
          expect(find.text('Add a car'), findsNothing);
          // No heading and no close button: the rows say what they are, and
          // a sheet is dismissed by tapping outside or swiping down.
          expect(find.text('What do you want to share?'), findsNothing);
          expect(labelled('Close'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('an option opens its composer; closing it notifies the host', (
    tester,
  ) async {
    await pumpNav(tester);

    await tester.tap(labelled('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forum thread'));
    await tester.pumpAndSettle();

    expect(find.text('composer:thread'), findsOneWidget);
    expect(closed, isEmpty);

    GoRouter.of(tester.element(find.text('composer:thread'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('composer:thread'), findsNothing);
    expect(closed, [CreateAction.thread]);
  });

  testWidgets('the modification option opens its flow', (tester) async {
    await pumpNav(tester);

    await tester.tap(labelled('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add modification'));
    await tester.pumpAndSettle();

    expect(find.text('composer:modification'), findsOneWidget);
  });

  testWidgets('tapping outside the sheet opens nothing and notifies no one', (
    tester,
  ) async {
    await pumpNav(tester);

    await tester.tap(labelled('Create'));
    await tester.pumpAndSettle();
    // The barrier above the sheet.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Post'), findsNothing);
    expect(closed, isEmpty);
  });

  testWidgets('swiping the sheet down opens nothing and notifies no one', (
    tester,
  ) async {
    await pumpNav(tester);

    await tester.tap(labelled('Create'));
    await tester.pumpAndSettle();
    await tester.fling(find.text('Post'), const Offset(0, 600), 2000);
    await tester.pumpAndSettle();

    expect(find.text('Post'), findsNothing);
    expect(closed, isEmpty);
  });
}
