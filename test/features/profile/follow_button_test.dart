// Follow CTA on a public profile.
//
// Layout: the Romanian "unfollow" label used to wrap inside a fixed 50pt
// button and get its second line clipped. The pair (follow + message) is
// pumped across width × text scale × locale; the label must stay on one line
// and the buttons must grow with the text instead of clipping it.
//
// Behaviour: the button shows the relationship ("Following"), and unfollowing
// only happens after confirming in the sheet.
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/follow/domain/entities/follow_status.dart';
import 'package:tweakd/features/follow/domain/repositories/follow_repository.dart';
import 'package:tweakd/features/follow/domain/usecases/follow_user.dart';
import 'package:tweakd/features/follow/domain/usecases/get_follow_status.dart';
import 'package:tweakd/features/follow/domain/usecases/get_followers.dart';
import 'package:tweakd/features/follow/domain/usecases/get_following.dart';
import 'package:tweakd/features/follow/domain/usecases/remove_follower.dart';
import 'package:tweakd/features/follow/domain/usecases/unfollow_user.dart';
import 'package:tweakd/features/follow/presentation/bloc/bloc.dart';
import 'package:tweakd/features/follow/presentation/bloc/event.dart';
import 'package:tweakd/features/profile/presentation/widgets/public_profile/follow_button.dart';
import 'package:tweakd/features/profile/presentation/widgets/shared/profile_action_button.dart';
import 'package:tweakd/l10n/app_localizations.dart';

class _FakeFollowRepository implements FollowRepository {
  int unfollowCalls = 0;

  @override
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(
    String username,
  ) async => const Right(FollowStatusEntity(status: FollowStatus.accepted));

  @override
  Future<Either<Failure, Unit>> unfollow(String username) async {
    unfollowCalls++;
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FollowBloc _bloc(FollowRepository repo) => FollowBloc(
  getFollowStatus: GetFollowStatusUseCase(repo),
  followUser: FollowUserUseCase(repo),
  unfollowUser: UnfollowUserUseCase(repo),
  getFollowers: GetFollowersUseCase(repo),
  getFollowing: GetFollowingUseCase(repo),
  removeFollower: RemoveFollowerUseCase(repo),
)..add(const LoadFollowStatus('david_official'));

Widget _app({
  required FollowBloc bloc,
  required Locale locale,
  double textScale = 1.0,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      body: BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Builder(
            builder: (context) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: FollowButton(username: 'david_official')),
                const SizedBox(width: 10),
                Expanded(
                  child: ProfileActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: AppLocalizations.of(context)!.profileMessage,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const widths = [320.0, 375.0, 600.0];
  const textScales = [1.0, 1.3, 2.0];
  const locales = [Locale('en'), Locale('ro')];

  for (final locale in locales) {
    for (final width in widths) {
      for (final textScale in textScales) {
        testWidgets(
          'fits at ${width.toInt()}pt, text x$textScale, ${locale.languageCode}',
          (tester) async {
            tester.view.physicalSize = Size(width * 3, 700 * 3);
            tester.view.devicePixelRatio = 3;
            addTearDown(tester.view.reset);

            await tester.pumpWidget(
              _app(
                bloc: _bloc(_FakeFollowRepository()),
                locale: locale,
                textScale: textScale,
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);

            final label = locale.languageCode == 'ro'
                ? 'Urmărești'
                : 'Following';
            final labelFinder = find.text(label);
            expect(labelFinder, findsOneWidget);

            // One line, fully inside the button — never a clipped second line.
            final paragraph = tester.renderObject<RenderParagraph>(labelFinder);
            final lines = paragraph.getBoxesForSelection(
              TextSelection(
                baseOffset: 0,
                extentOffset: paragraph.text.toPlainText().length,
              ),
            );
            final lineTops = lines.map((b) => b.top.round()).toSet();
            expect(lineTops.length, 1);

            final button = tester.getRect(find.byType(ElevatedButton));
            final text = tester.getRect(labelFinder);
            expect(
              button.top <= text.top && text.bottom <= button.bottom,
              isTrue,
            );

            // The pair reads as one control.
            expect(
              tester.getSize(find.byType(ElevatedButton)).height,
              tester.getSize(find.byType(OutlinedButton)).height,
            );
          },
        );
      }
    }
  }

  testWidgets('unfollowing needs confirmation; cancel keeps the follow', (
    tester,
  ) async {
    final repo = _FakeFollowRepository();
    await tester.pumpWidget(
      _app(bloc: _bloc(repo), locale: const Locale('en')),
    );
    await tester.pump();

    await tester.tap(find.text('Following'));
    await tester.pumpAndSettle();
    expect(find.text('Unfollow @david_official?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.unfollowCalls, 0);
    expect(find.text('Following'), findsOneWidget);

    await tester.tap(find.text('Following'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unfollow'));
    await tester.pumpAndSettle();
    expect(repo.unfollowCalls, 1);
    expect(find.text('Follow'), findsOneWidget);
  });
}
