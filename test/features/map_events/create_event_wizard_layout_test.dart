// Responsiveness guard for the create-event wizard: the chrome (progress bar,
// bottom bar) plus every one of the seven step bodies, pumped across a
// width × text-scale matrix — the same shape as
// test/features/garage/register_car_layout_test.dart.
//
// Widget tests render text in a fixed-width test font, so every glyph is as
// wide as it is tall — a harsher squeeze than any real font. Anything that
// survives here survives a device.
//
// The screens with something to prove are the ones that divide a fixed row
// into cells: the date + time pairs on WHEN & WHERE, the category chips on
// BASICS, the review sections' label + EDIT row, and the bottom bar's
// BACK / NEXT split.
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:tweakd/features/map_events/data/datasources/create_event_draft_local_data_source.dart';
import 'package:tweakd/features/map_events/domain/entities/contest.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_category.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/organizer_candidate.dart';
import 'package:tweakd/features/map_events/domain/repositories/map_event_contests_repository.dart';
import 'package:tweakd/features/map_events/domain/repositories/map_events_repository.dart';
import 'package:tweakd/features/map_events/domain/usecases/manage_map_event.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_contests.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_organizers.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_reads.dart';
import 'package:tweakd/features/map_events/presentation/bloc/create_contest/state.dart';
import 'package:tweakd/features/map_events/presentation/bloc/create_event/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/create_event/state.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/create_event_chrome.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/basics_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/contests_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/cover_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/organizers_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/review_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/rules_step.dart';
import 'package:tweakd/features/map_events/presentation/widgets/create/steps/when_where_step.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// The steps read the bloc only to dispatch on a tap, so nothing here is ever
/// called during layout — `noSuchMethod` is enough, and spares the test a fake
/// implementation of two full repositories.
class _FakeEventsRepo implements MapEventsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeContestsRepo implements MapEventContestsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Keeps the draft off the filesystem: `path_provider` has no implementation in
/// a widget test, and the wizard's layout has nothing to do with persistence.
class _NoDraftStore implements CreateEventDraftLocalDataSource {
  @override
  Future<Map<String, dynamic>?> read() async => null;

  @override
  Future<void> write(Map<String, dynamic> draft) async {}

  @override
  Future<void> clear() async {}
}

CreateMapEventBloc _bloc() {
  final events = _FakeEventsRepo();
  final contests = _FakeContestsRepo();

  return CreateMapEventBloc(
    getCategories: GetMapEventCategoriesUseCase(events),
    createEvent: CreateMapEventUseCase(events),
    updateEvent: UpdateMapEventUseCase(events),
    replaceRules: ReplaceMapEventRulesUseCase(events),
    getCoverUploadUrl: GetMapEventCoverUploadUrlUseCase(events),
    setCover: SetMapEventCoverUseCase(events),
    addOrganizer: AddMapEventOrganizerUseCase(events),
    removeOrganizer: RemoveMapEventOrganizerUseCase(events),
    getContestCategories: GetContestCategoriesUseCase(contests),
    createContest: CreateContestUseCase(contests),
    imageService: ImageService(),
    draftStore: _NoDraftStore(),
  );
}

const _categories = [
  MapEventCategoryEntity(id: 'car_meet', label: 'Car meet'),
];

const _contestCategories = [
  ContestCategoryEntity(
    id: 'exhaust',
    label: 'Best exhaust system',
    icon: ContestCategoryIcon.exhaust,
  ),
  ContestCategoryEntity(
    id: 'custom',
    label: 'Custom',
    icon: ContestCategoryIcon.trophy,
  ),
];

final _start = DateTime(2026, 9, 18, 19);
final _end = DateTime(2026, 9, 18, 23);

/// A fully filled form, so every branch that only appears once a field is set —
/// the picked-location card, the review sections, the contest rows — is the one
/// under test. The empty variants get their own screen below.
final _filled = CreateMapEventState(
  status: CreateEventStatus.ready,
  categories: _categories,
  contestCategories: _contestCategories,
  title: 'Casino Square Cars & Coffee — Autumn Edition',
  description: 'An early-morning meet on the square, coffee on the house, '
      'and a run up the hill afterwards for anyone who wants one.',
  locationName: 'Strada Memorandumului 28, Cluj-Napoca',
  city: 'Cluj-Napoca',
  street: 'Strada Memorandumului',
  number: '28',
  position: const GeoPosition(lat: 46.7712, lng: 23.5949),
  startsAt: _start,
  endsAt: _end,
  registrationDeadline: DateTime(2026, 9, 17, 23, 59),
  capacity: 120,
  requiresApproval: true,
  rules: const [
    'No revving, no burnouts, no exceptions.',
    'Take your rubbish home with you.',
  ],
  pendingOrganizers: const [
    PendingOrganizer(
      OrganizerCandidateEntity(
        type: MapEventOrganizerType.business,
        referenceId: 'b1',
        name: 'Kinetic Edge Performance Workshop',
        username: null,
        imageUrl: null,
      ),
    ),
  ],
  pendingContests: [
    PendingContest(
      localId: 'draft-1',
      categoryId: 'exhaust',
      categoryLabel: 'Best exhaust system',
      title: 'Best exhaust system',
      criteria: 'Note, build quality and how it sounds at idle.',
      opensChoice: ContestOpensChoice.atEventStart,
      customOpensAt: null,
      closesAt: _end,
    ),
  ],
);

/// The same wizard before anything has been entered — every step's empty state.
const _empty = CreateMapEventState(
  status: CreateEventStatus.ready,
  categories: _categories,
  contestCategories: _contestCategories,
);

/// Controllers are shared across the matrix; the steps only read them.
final _text = TextEditingController(text: 'Casino Square Cars & Coffee');
final _rules = [
  TextEditingController(text: 'No revving, no burnouts, no exceptions.'),
  TextEditingController(text: 'Take your rubbish home with you.'),
];

/// Every screen the wizard can show, as (name, step index, body).
List<(String, int, Widget)> _screens() => [
      (
        'basics',
        0,
        BasicsStep(
          state: _filled,
          titleController: _text,
          descriptionController: _text,
        ),
      ),
      ('basics · empty', 0, BasicsStep(
        state: _empty,
        titleController: _text,
        descriptionController: _text,
      )),
      ('organizers', 1, OrganizersStep(state: _filled)),
      ('organizers · empty', 1, const OrganizersStep(state: _empty)),
      ('when & where', 2, WhenWhereStep(state: _filled)),
      ('when & where · empty', 2, const WhenWhereStep(state: _empty)),
      (
        'rules',
        3,
        RulesStep(
          state: _filled,
          capacityController: _text,
          ruleControllers: _rules,
        ),
      ),
      (
        'rules · empty',
        3,
        RulesStep(
          state: _empty,
          capacityController: _text,
          ruleControllers: const [],
        ),
      ),
      ('contests', 4, ContestsStep(state: _filled)),
      ('contests · empty', 4, const ContestsStep(state: _empty)),
      // The cover steps render no image: a file path a widget test can't read
      // and a network URL it can't fetch would both throw. The empty state is
      // where this step's layout actually lives.
      ('cover · empty', 5, CoverStep(state: _empty, onPick: () {})),
      ('review', 6, ReviewStep(state: _filled, onEdit: (_) {})),
      ('review · empty', 6, ReviewStep(state: _empty, onEdit: (_) {})),
    ];

/// Each step body wrapped the way the wizard wraps it: chrome above and below,
/// the body in the scroll view between them.
Widget _wizardSurface(int step, Widget body) {
  return Scaffold(
    backgroundColor: const Color(0xFFF6F4F1),
    body: SafeArea(
      child: Column(
        children: [
          CreateEventTopBar(step: step, stepCount: 7, onClose: () {}),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kCreateEventMaxWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: body,
                ),
              ),
            ),
          ),
          CreateEventBottomBar(
            canGoBack: step > 0,
            isLastStep: step == 6,
            isSubmitting: false,
            backLabel: 'BACK',
            nextLabel: 'PUBLISH FOR REVIEW',
            // The longest thing the bar can be asked to show, so the blocker
            // line is under test at every width too.
            blocker: 'The registration deadline has to be before the event '
                'starts.',
            onBack: () {},
            onNext: () {},
          ),
        ],
      ),
    ),
  );
}

Widget _app(Widget home, double textScale, CreateMapEventBloc bloc) {
  return MaterialApp(
    // The real app's theme, because it sets `filled: true` on every input —
    // the wizard has to opt out of that to keep its rounded corners, and a
    // bare test theme would hide a regression there.
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: BlocProvider<CreateMapEventBloc>.value(value: bloc, child: home),
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

          final bloc = _bloc();
          addTearDown(bloc.close);

          await tester.pumpWidget(
            _app(_wizardSurface(step, body), textScale, bloc),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  // ── Regressions ──────────────────────────────────────────────────────────

  // The app theme sets `filled: true` with a square fill and no border. This
  // feature fills deliberately, so what keeps its corners rounded is that every
  // field brings its own OutlineInputBorder at the wizard's one radius — a
  // field that inherits the theme's border instead comes out square.
  testWidgets('every wizard text field carries the wizard corner radius', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var checked = 0;
    for (final (name, step, body) in _screens()) {
      final bloc = _bloc();
      addTearDown(bloc.close);

      await tester.pumpWidget(_app(_wizardSurface(step, body), 1, bloc));
      await tester.pump();

      for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
        final border = field.decoration?.enabledBorder;
        expect(
          border,
          isA<OutlineInputBorder>().having(
            (b) => b.borderRadius,
            'borderRadius',
            BorderRadius.circular(kCreateEventRadius),
          ),
          reason: '$name has a field that would square its corners',
        );
        checked++;
      }
    }
    expect(checked, greaterThan(0), reason: 'no fields were actually checked');
  });

  // The point of the WHEN & WHERE reframing: `location_name` is the address the
  // picker composed, and there is no way to type one by hand any more. A free
  // text field creeping back in is how the pin and the label start to disagree.
  testWidgets('when & where offers no venue text field', (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final bloc = _bloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _app(_wizardSurface(2, WhenWhereStep(state: _filled)), 1, bloc),
    );
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    // The address the picker returned is shown back, split into its parts.
    expect(find.text('Cluj-Napoca'), findsOneWidget);
    expect(find.text('Strada Memorandumului'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
  });
}
