// The layout foundation every page builds on (see AppLayout).
//
// Guards the three promises that make tablets, foldables and Split View work
// without per-screen pixel tweaks:
// - phones are untouched: nothing is inset below the reading width;
// - wide windows get a centred column, never a stretched page;
// - the side margins of a scrolling page still scroll (the content is inset
//   inside a full-width scroll view, not the scroll view inside a frame).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/core/shared/layout/app_layout.dart';
import 'package:tweakd/core/shared/widgets/app_bottom_nav.dart';
import 'package:tweakd/l10n/app_localizations.dart';

void _setWindow(WidgetTester tester, double width, {double height = 900}) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('insetFor', () {
    test('is zero on phones', () {
      for (final width in [320.0, 375.0, 430.0, AppLayout.readingWidth]) {
        expect(AppLayout.insetFor(width), 0);
      }
    });

    test('centres the reading column on wide windows', () {
      expect(AppLayout.insetFor(1024), (1024 - AppLayout.readingWidth) / 2);
      expect(
        AppLayout.insetFor(1024, maxWidth: AppLayout.formWidth),
        (1024 - AppLayout.formWidth) / 2,
      );
    });
  });

  for (final width in [320.0, 600.0, 834.0, 1024.0, 1366.0]) {
    testWidgets('ContentFrame caps and centres at ${width.toInt()}pt', (
      tester,
    ) async {
      _setWindow(tester, width);
      const key = Key('content');
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ContentFrame(child: SizedBox.expand(key: key)),
        ),
      );

      final rect = tester.getRect(find.byKey(key));
      expect(rect.width, lessThanOrEqualTo(AppLayout.readingWidth));
      expect(rect.width, width < AppLayout.readingWidth ? width : AppLayout.readingWidth);
      expect(rect.center.dx, closeTo(width / 2, 0.01));
    });
  }

  testWidgets('a side margin of a framed scroll view still scrolls', (
    tester,
  ) async {
    _setWindow(tester, 1024);
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            controller: controller,
            slivers: [
              SliverContentFrame(
                sliver: SliverList.builder(
                  itemCount: 60,
                  itemBuilder: (_, i) => SizedBox(height: 80, child: Text('$i')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final row = tester.getRect(find.text('0'));
    expect(row.left, closeTo((1024 - AppLayout.readingWidth) / 2, 0.01));

    // Drag in the left margin, outside the column.
    await tester.dragFrom(const Offset(40, 600), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
  });

  testWidgets('sheetHeight never exceeds the space above the keyboard', (
    tester,
  ) async {
    // A short landscape window with the keyboard up.
    _setWindow(tester, 800, height: 360);
    late double height;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 360),
          viewInsets: EdgeInsets.only(bottom: 200),
          padding: EdgeInsets.only(top: 24),
        ),
        child: Builder(
          builder: (context) {
            height = AppLayout.sheetHeight(context, 0.62);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(height, 360 - 200 - 24 - AppLayout.kSheetTopGap);
  });

  testWidgets('tab bar paints full width but keeps its slots in the column', (
    tester,
  ) async {
    _setWindow(tester, 1366);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: Column(
              children: [
                Spacer(),
                AppBottomNav(activeTab: AppBottomNavTab.feed),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(tester.getSize(find.byType(AppBottomNav)).width, 1366);
    final slots = tester.getRect(
      find.descendant(of: find.byType(AppBottomNav), matching: find.byType(Row)).first,
    );
    expect(slots.width, lessThanOrEqualTo(AppLayout.readingWidth));
    expect(slots.center.dx, closeTo(1366 / 2, 0.01));
  });
}
