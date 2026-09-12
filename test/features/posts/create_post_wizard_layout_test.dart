// Responsiveness guard for the create-post wizard: the chrome (X + progress
// bar, bottom bar) plus every step body, pumped across a width × text-scale
// matrix — the same shape as the create-event and add-car layout tests.
//
// Widget tests render text in a fixed-width test font, so every glyph is as
// wide as it is tall — a harsher squeeze than any real font. Anything that
// survives here survives a device.
//
// The photo steps render no image: a file path a widget test can't read and a
// network URL it can't fetch would both throw. The empty grid — add tile plus
// the count row — is where that step's layout lives.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/shared/bloc/tag_picker/bloc.dart';
import 'package:tweakd/core/shared/entities/tag_selection.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/garage/domain/usecases/get_garage_by_username.dart';
import 'package:tweakd/features/garage/domain/usecases/get_my_garage.dart';
import 'package:tweakd/features/posts/domain/usecases/create_post.dart';
import 'package:tweakd/features/posts/domain/usecases/delete_post.dart';
import 'package:tweakd/features/posts/domain/usecases/get_image_upload_urls.dart';
import 'package:tweakd/features/posts/domain/usecases/save_image_keys.dart';
import 'package:tweakd/features/posts/domain/usecases/upload_post_image.dart';
import 'package:tweakd/features/posts/presentation/bloc/create_post/bloc.dart';
import 'package:tweakd/features/posts/presentation/pages/create_post_page.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/caption_step.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/create_post_chrome.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/create_post_fields.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/photos_step.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/review_step.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/tags_step.dart';
import 'package:tweakd/features/posts/presentation/widgets/create_post/visibility_step.dart';
import 'package:tweakd/features/search/domain/usecases/search_users.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// Nothing here publishes or searches, so no use case is ever called —
/// `noSuchMethod` is enough.
class _FakeSearchUsers implements SearchUsersUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGarageByUsername implements GetGarageByUsernameUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeMyGarage implements GetMyGarageUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCreatePost implements CreatePostUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeUploadUrls implements GetImageUploadUrlsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeUpload implements UploadPostImageUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveKeys implements SaveImageKeysUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeDeletePost implements DeletePostUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

TagPickerBloc _tagBloc() => TagPickerBloc(
      searchUsers: _FakeSearchUsers(),
      getGarageByUsername: _FakeGarageByUsername(),
      getMyGarage: _FakeMyGarage(),
    );

CreatePostBloc _createBloc() => CreatePostBloc(
      createPost: _FakeCreatePost(),
      getImageUploadUrls: _FakeUploadUrls(),
      uploadImage: _FakeUpload(),
      saveImageKeys: _FakeSaveKeys(),
      deletePost: _FakeDeletePost(),
      imageService: ImageService(),
    );

final _caption = TextEditingController(
  text: 'Fresh set of forged wheels and a proper alignment — it finally '
      'sits right. Full story in the build log.',
);
final _search = TextEditingController();

/// Long handles and a long car name, so the chips are what gets squeezed.
const _people = [
  TaggedPerson(id: 'p1', username: 'kinetic_edge_performance_workshop'),
  TaggedPerson(id: 'p2', username: 'ana'),
];
const _cars = [
  TaggedCar(
    id: 'c1',
    name: 'Porsche 911 GT3 Touring',
    ownerId: 'p1',
    ownerHandle: 'kinetic_edge_performance_workshop',
  ),
];

/// Every screen the wizard can show, as (name, step index, body).
List<(String, int, Widget)> _screens() => [
      (
        'photos · empty',
        0,
        PhotosStep(
          photos: const [],
          onAdd: () {},
          onRemove: (_) {},
          onReorder: (_, _) {},
        ),
      ),
      ('caption', 1, CaptionStep(controller: _caption)),
      (
        'tags',
        2,
        TagsStep(
          people: _people,
          cars: _cars,
          peopleSearchCtrl: _search,
          onAddPerson: (_) {},
          onRemovePerson: (_) {},
          onAddCar: (_) {},
          onRemoveCar: (_) {},
        ),
      ),
      (
        'tags · empty',
        2,
        TagsStep(
          people: const [],
          cars: const [],
          peopleSearchCtrl: _search,
          onAddPerson: (_) {},
          onRemovePerson: (_) {},
          onAddCar: (_) {},
          onRemoveCar: (_) {},
        ),
      ),
      (
        'visibility',
        3,
        VisibilityStep(visibility: const PostVisibility(), onChanged: (_) {}),
      ),
      (
        'review',
        4,
        ReviewStep(
          photos: const [],
          caption: _caption.text,
          visibility: const PostVisibility(showShares: false),
          authorName: 'You',
        ),
      ),
    ];

/// Each step body wrapped the way the wizard wraps it: chrome above and below,
/// the body in the scroll view between them.
Widget _wizardSurface(int step, Widget body) {
  return Scaffold(
    backgroundColor: AppColors.bg,
    body: SafeArea(
      child: Column(
        children: [
          PostTopBar(step: step, onClose: () {}),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kPostMaxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: body,
                ),
              ),
            ),
          ),
          PostBottomBar(
            canGoBack: step > 0,
            isLastStep: step == postStepCount - 1,
            isSubmitting: false,
            backLabel: 'BACK',
            nextLabel: 'PUBLISH POST',
            // Always on, so the blocker line is under test at every width.
            blocker: 'Add at least one photo to continue.',
            onBack: () {},
            onNext: () {},
          ),
        ],
      ),
    ),
  );
}

Widget _app(Widget home, double textScale, TagPickerBloc tags) {
  return MaterialApp(
    // The real app's theme, because it sets `filled: true` on every input —
    // the wizard has to opt out of that to keep its rounded corners, and a
    // bare test theme would hide a regression there.
    theme: AppTheme.of(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: BlocProvider<TagPickerBloc>.value(value: tags, child: home),
  );
}

/// The real page, pushed over a home screen so closing it has somewhere to go.
Widget _pageApp(TagPickerBloc tags, CreatePostBloc create) {
  return MaterialApp(
    theme: AppTheme.of(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider<CreatePostBloc>.value(value: create),
                    BlocProvider<TagPickerBloc>.value(value: tags),
                  ],
                  child: const CreatePostPage(),
                ),
              ),
            ),
            child: const Text('open composer'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // 320 = iPhone SE 1st gen, 375 = iPhone 13 mini / SE 3, 430 = 15 Pro Max,
  // 440 = iPhone 17 Pro Max, 834 = iPad Air portrait.
  const widths = [320.0, 375.0, 430.0, 440.0, 834.0];
  // 1.0 = default, 1.3 = a common bump, 2.0 = the accessibility extreme.
  const textScales = [1.0, 1.3, 2.0];

  for (final width in widths) {
    for (final textScale in textScales) {
      final at = '${width.toInt()}pt, text x$textScale';

      // One test per screen, so a failure names the screen and doesn't hide
      // the ones after it.
      for (final (name, step, body) in _screens()) {
        testWidgets('$name lays out at $at', (tester) async {
          tester.view.physicalSize = Size(width * 3, 900 * 3);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);

          final tags = _tagBloc();
          addTearDown(tags.close);

          await tester.pumpWidget(
            _app(_wizardSurface(step, body), textScale, tags),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // ── Regressions ──────────────────────────────────────────────────────────

  // The app theme sets `filled: true` with a square fill and no border. Painted
  // over the wizard's rounded surfaces it squares their corners off, so every
  // field has to opt out.
  testWidgets('every wizard text field opts out of the filled theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var checked = 0;
    for (final (name, step, body) in _screens()) {
      final tags = _tagBloc();
      addTearDown(tags.close);

      await tester.pumpWidget(_app(_wizardSurface(step, body), 1, tags));
      await tester.pump();

      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(
          field.decoration?.filled,
          isFalse,
          reason: '$name has a field that would square its corners',
        );
        checked++;
      }
    }
    expect(checked, greaterThan(0), reason: 'no fields were actually checked');
  });

  // The old wizard opened every step with an accent "01 — PHOTOS" eyebrow and
  // a three-node rail; the progress bar is the only step indicator now.
  testWidgets('no step carries a numbered eyebrow', (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    for (final (name, step, body) in _screens()) {
      final tags = _tagBloc();
      addTearDown(tags.close);

      await tester.pumpWidget(_app(_wizardSurface(step, body), 1, tags));
      await tester.pump();

      expect(
        find.textContaining(RegExp(r'^0\d — ')),
        findsNothing,
        reason: '$name still shows a step eyebrow',
      );
    }
  });

  group('page', () {
    late TagPickerBloc tags;
    late CreatePostBloc create;

    setUp(() {
      tags = _tagBloc();
      create = _createBloc();
    });

    tearDown(() async {
      await tags.close();
      await create.close();
    });

    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_pageApp(tags, create));
      await tester.tap(find.text('open composer'));
      await tester.pumpAndSettle();
    }

    testWidgets('the photos step names what is missing and NEXT stays put', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Pick your shots'), findsOneWidget);
      expect(find.text('Add at least one photo to continue.'), findsOneWidget);
      // First step: nothing to go back to.
      expect(find.text('BACK'), findsNothing);

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Pick your shots'), findsOneWidget);
      expect(find.text('Say something'), findsNothing);
    });

    testWidgets('closing a blank composer leaves without asking', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Discard post?'), findsNothing);
      expect(find.byType(CreatePostPage), findsNothing);
      expect(find.text('open composer'), findsOneWidget);
    });
  });
}
