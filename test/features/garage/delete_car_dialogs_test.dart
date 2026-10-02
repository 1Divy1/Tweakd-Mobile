import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/garage/presentation/widgets/delete_car/delete_car_dialogs.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// Deleting a car is irreversible, so it takes two separate confirmations:
/// what goes with the car, then a last "for good?" check.
void main() {
  late bool? result;

  Future<void> open(WidgetTester tester, {double textScale = 1}) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await confirmCarDeletion(context, carTitle: 'BMW M3'),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists what goes with the car before the final check',
      (tester) async {
    await open(tester);

    expect(find.byType(DeleteCarWarningDialog), findsOneWidget);
    expect(find.text('Its cover photo and gallery'), findsOneWidget);
    expect(
      find.text('Event attendance and contest history, including votes and wins'),
      findsOneWidget,
    );
    expect(find.byType(DeleteCarFinalDialog), findsNothing);
  });

  testWidgets('both confirmations delete', (tester) async {
    await open(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Delete BMW M3 for good?'), findsOneWidget);
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('cancelling the first step never reaches the second',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteCarFinalDialog), findsNothing);
    expect(result, isFalse);
  });

  testWidgets('keeping the car at the last step does not delete',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep car'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('the warning fits a small phone at a large text scale',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await open(tester, textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text('Continue'), findsOneWidget);
  });
}
