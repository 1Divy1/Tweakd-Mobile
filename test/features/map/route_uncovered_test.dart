import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/map/presentation/utils/route_uncovered.dart';

/// The search result must reach the map only once the map is back on screen:
/// `push` hands the result back when `pop` is *called*, and a camera flight
/// started while the search page still covers the map is dropped on iOS.
void main() {
  testWidgets('waits for the covering route to finish popping', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    late BuildContext baseContext;

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navKey,
      home: Builder(builder: (context) {
        baseContext = context;
        return const Text('map');
      }),
    ));

    final baseRoute = ModalRoute.of(baseContext);
    final result = navKey.currentState!.push<String>(
      MaterialPageRoute(builder: (_) => const Text('search')),
    );
    await tester.pumpAndSettle();

    var uncovered = false;
    navKey.currentState!.pop('picked');
    expect(await result, 'picked');
    routeUncovered(baseRoute).then((_) => uncovered = true);

    // The result is in hand but the search page is still on its way out.
    await tester.pump(const Duration(milliseconds: 50));
    expect(uncovered, isFalse);

    await tester.pumpAndSettle();
    expect(uncovered, isTrue);
  });

  testWidgets('returns at once when nothing covers the route', (tester) async {
    late BuildContext baseContext;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        baseContext = context;
        return const Text('map');
      }),
    ));

    var uncovered = false;
    routeUncovered(ModalRoute.of(baseContext)).then((_) => uncovered = true);
    await tester.pump();

    expect(uncovered, isTrue);
  });
}
