// Responsiveness guard for Settings → Blocked accounts: the list rows (long
// usernames, a name line, the Unblock button in both languages and its
// spinner) and the empty view, pumped across a width × text-scale matrix.
//
// Widget tests render text in a fixed-width test font, harsher than any real
// font, so a row that survives here survives a device.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/features/block/domain/entities/blocked_account.dart';
import 'package:tweakd/features/block/presentation/widgets/blocked_accounts/blocked_accounts_empty_view.dart';
import 'package:tweakd/features/block/presentation/widgets/blocked_accounts/blocked_accounts_list_view.dart';
import 'package:tweakd/l10n/app_localizations.dart';

const _accounts = [
  BlockedAccountEntity(
    id: '1',
    username: 'an_exceptionally_long_username_for_a_car_account',
    name: 'Someone With A Really Long Display Name Indeed',
  ),
  BlockedAccountEntity(id: '2', username: 'bob'),
  BlockedAccountEntity(id: '3', username: 'carol', name: 'Carol'),
];

Widget _host({
  required Widget child,
  required double width,
  required double textScale,
  required Locale locale,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: 800, child: child),
        ),
      ),
    ),
  );
}

void main() {
  const widths = [320.0, 375.0, 430.0, 820.0];
  const scales = [1.0, 1.5, 2.0];
  const locales = [Locale('en'), Locale('ro')];

  for (final locale in locales) {
    for (final width in widths) {
      for (final scale in scales) {
        final label = '${locale.languageCode} ${width.toInt()}pt @${scale}x';

        testWidgets('blocked accounts list lays out — $label', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(_host(
            width: width,
            textScale: scale,
            locale: locale,
            child: BlockedAccountsListView(
              accounts: _accounts,
              unblocking: const {'bob'},
              onUnblock: (_) {},
            ),
          ));
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

        testWidgets('blocked accounts empty view lays out — $label',
            (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(_host(
            width: width,
            textScale: scale,
            locale: locale,
            child: const BlockedAccountsEmptyView(),
          ));
          await tester.pump();

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
