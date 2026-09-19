// Responsiveness guard for map search: the search screen (field, tabs, phase
// chips, both result lists with their footers) and the map's search pill,
// pumped across a width × text-scale matrix with deliberately long content.
//
// Widget tests render text in a fixed-width test font, a harsher squeeze than
// any real font — anything that survives here survives a device.
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/map/domain/entities/business_search_page.dart';
import 'package:tweakd/features/map/domain/usecases/search_businesses.dart';
import 'package:tweakd/features/map/presentation/bloc/map_search/bloc.dart';
import 'package:tweakd/features/map/presentation/bloc/map_search/event.dart';
import 'package:tweakd/features/map/presentation/pages/map_search_page.dart';
import 'package:tweakd/features/map/presentation/widgets/map_top_bar.dart';
import 'package:tweakd/features/map/presentation/widgets/search/map_search_status_chips.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_page.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_reads.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import 'map_search_fakes.dart';

const _longTitle =
    'Transilvania Night Cruise & Cars and Coffee Grand Opening Edition';

MapSearchBloc _loadedBloc() {
  final events = FakeEventsRepository()
    ..autoAnswer = Right(MapEventPageEntity(
      items: [
        eventPin('e1', status: MapEventStatus.live, title: _longTitle),
        eventPin('e2', title: _longTitle),
        eventPin('e3', status: MapEventStatus.previous, title: _longTitle),
      ],
      // A cursor, so the list also draws its load-more footer.
      nextCursor: 'more',
    ));
  final businesses = FakeMapRepository()
    ..autoAnswer = Right(BusinessSearchPageEntity(
      items: [
        businessPin('b1'),
        businessPin('b2', isOpenNow: false),
      ],
    ));
  return MapSearchBloc(
    searchEvents: SearchMapEventsUseCase(events),
    searchBusinesses: SearchBusinessesUseCase(businesses),
    centre: testCentre,
  );
}

Widget _app(Widget child, double textScale, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: app!,
    ),
    home: child,
  );
}

void main() {
  const widths = [320.0, 375.0, 430.0, 600.0, 834.0, 1024.0];
  const textScales = [1.0, 1.3, 2.0];

  for (final width in widths) {
    for (final textScale in textScales) {
      testWidgets('search screen lays out at ${width.toInt()}pt, text x$textScale',
          (tester) async {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final bloc = _loadedBloc();
        addTearDown(bloc.close);

        await tester.pumpWidget(_app(
          BlocProvider.value(value: bloc, child: const MapSearchPage()),
          textScale,
        ));
        // The prompt state, before anything is typed.
        expect(tester.takeException(), isNull);

        // Past on too, so the widest chip row is the one under test.
        bloc.add(const MapSearchStatusToggled(MapEventStatus.previous));
        await tester.enterText(find.byType(TextField), 'cars');
        bloc.add(const MapSearchQueryChanged('cars'));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(MapSearchStatusChips), findsOneWidget);
        expect(find.text(_longTitle), findsWidgets);

        await tester.tap(find.text('Businesses'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Business b1'), findsOneWidget);
      });
    }
  }

  testWidgets('Romanian chips and tabs fit at 320pt, text x2.0', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final bloc = _loadedBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(_app(
      BlocProvider.value(value: bloc, child: const MapSearchPage()),
      2.0,
      locale: const Locale('ro'),
    ));
    bloc.add(const MapSearchQueryChanged('cars'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 430.0]) {
    for (final textScale in textScales) {
      testWidgets('map search pill lays out at ${width.toInt()}pt, text x$textScale',
          (tester) async {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(
          const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(12),
                // The back button's footprint, as in MapFlutterOverlays.
                child: Row(
                  children: [
                    SizedBox(width: 44, height: 44),
                    SizedBox(width: 10),
                    Expanded(child: MapTopBar()),
                  ],
                ),
              ),
            ),
          ),
          textScale,
        ));

        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Search the map'), findsOneWidget);
      });
    }
  }
}
