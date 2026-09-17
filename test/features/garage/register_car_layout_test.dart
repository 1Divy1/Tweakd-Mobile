// Responsiveness guard for the refactored add-a-car wizard: the chrome
// (progress bar, bottom bar) plus every step body, pumped across a
// width × text-scale matrix.
//
// Widget tests render text in a fixed-width test font, so every glyph is as
// wide as it is tall — a harsher squeeze than any real font. Anything that
// survives here survives a device.
//
// The steps that pack two fields onto one row (year + chassis code, power +
// torque, price + mileage) and the before/after photo rows are the ones with
// something to prove: they divide a fixed row into equal cells, which is
// exactly the shape that overflows once labels grow.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/garage/domain/entities/car_status_option.dart';
import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:tweakd/features/garage/presentation/pages/build_log_entry_page.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/editable_image.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/gallery_step.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/mods_step.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/register_car_chrome.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/specs_step.dart';
import 'package:tweakd/features/garage/presentation/widgets/register_car/story_step.dart';
import 'package:tweakd/l10n/app_localizations.dart';

const _brands = [
  CarBrandEntity(id: 'b1', name: 'Mercedes-AMG'),
  CarBrandEntity(id: 'b2', name: 'BMW'),
];

const _models = [
  CarModelEntity(id: 'm1', brandId: 'b2', model: 'M3 Competition xDrive'),
];

const _drivetrains = [
  CarDrivetrainEntity(id: 'd1', name: 'All-Wheel Drive'),
];

const _colors = [
  CarColorEntity(id: 'c1', name: 'Frozen Deep Green', colorCode: '#123321'),
];

const _distanceUnits = [
  CarDistanceUnitEntity(id: 'u1', name: 'Kilometers'),
  CarDistanceUnitEntity(id: 'u2', name: 'Miles'),
];

const _fuelTypes = [
  CarFuelTypeOptionEntity(id: 'f1', name: 'Petrol'),
];

const _statusOptions = [
  CarStatusOptionEntity(id: 's1', type: 'Daily driver'),
  CarStatusOptionEntity(id: 's2', type: 'Weekend toy'),
  CarStatusOptionEntity(id: 's3', type: 'Project car'),
];

const _categories = [
  CarModCategoryEntity(id: 'cat1', modName: 'Engine & Drivetrain'),
];

/// Each step body wrapped the way the wizard wraps it: chrome above and below,
/// the body in the scroll view between them.
Widget _wizardSurface(int step, Widget body) {
  return Scaffold(
    backgroundColor: const Color(0xFFF6F4F1),
    body: SafeArea(
      child: Column(
        children: [
          RegisterStepProgress(step: step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: body,
            ),
          ),
          RegisterBottomBar(
            step: step,
            isSubmitting: false,
            onBack: () {},
            onNext: () {},
          ),
        ],
      ),
    ),
  );
}

/// Controllers are shared across the matrix; the steps only read them.
final _ctrl = TextEditingController(text: '2024');

/// The specs step with one of its tabs open. All three tabs live on step 0,
/// so each is pumped at that index.
Widget _specs(SpecsTab tab, {ValueChanged<SpecsTab>? onTabChanged}) => SpecsStep(
      tab: tab,
      onTabChanged: onTabChanged ?? (_) {},
      selectedBrand: _brands[1],
      selectedModel: _models[0],
      brands: _brands,
      models: _models,
      modelsLoading: false,
      yearCtrl: _ctrl,
      chassisCodeCtrl: _ctrl,
      modelCodeCtrl: _ctrl,
      onSelectBrand: (_) {},
      onSelectModel: (_) {},
      hpCtrl: _ctrl,
      torqueCtrl: _ctrl,
      zeroToHundredCtrl: _ctrl,
      weightCtrl: _ctrl,
      displacementCtrl: _ctrl,
      engineCodeCtrl: _ctrl,
      fuelTypeOptions: _fuelTypes,
      selectedFuelType: _fuelTypes[0],
      onSelectFuelType: (_) {},
      drivetrains: _drivetrains,
      colors: _colors,
      distanceUnits: _distanceUnits,
      selectedDrivetrain: _drivetrains[0],
      selectedColor: _colors[0],
      selectedDistanceUnit: _distanceUnits[0],
      mileageCtrl: _ctrl,
      onSelectDrivetrain: (_) {},
      onSelectColor: (_) {},
      onSelectDistanceUnit: (_) {},
    );

/// Every screen the wizard can show, as (name, step index, body). The three
/// specs tabs share step 0 — the tab bar is part of that step's body, so each
/// tab has to be laid out with the chrome that sits around it.
List<(String, int, Widget)> _screens() => [
      ('specs · basics', 0, _specs(SpecsTab.basics)),
      ('specs · power', 0, _specs(SpecsTab.power)),
      ('specs · config', 0, _specs(SpecsTab.config)),
      (
        'build log',
        1,
        ModsStep(
          mods: const [],
          categories: _categories,
          onAdd: () {},
          onRemove: (_) {},
        ),
      ),
      (
        'story',
        2,
        StoryStep(
          statusOptions: _statusOptions,
          selectedStatus: _statusOptions[0],
          storyCtrl: _ctrl,
          onSelectStatus: (_) {},
        ),
      ),
      (
        'gallery',
        3,
        GalleryStep(
          // Remote slots render as network images, which a widget test can't
          // fetch; the empty gallery still exercises the cover card, the add
          // tile and the grid delegate, which is where the layout lives.
          images: const <SlotImage>[],
          coverFilePath: null,
          coverNetworkUrl: null,
          onPickCover: () {},
          onAdd: () {},
          onRemove: (_) {},
          onReorder: (_, _) {},
        ),
      ),
    ];

Widget _app(Widget home, double textScale) {
  return MaterialApp(
    // The real app's theme, because it sets `filled: true` on every input —
    // the wizard has to opt out of that to keep its rounded corners, and a
    // bare test theme would hide a regression there.
    theme: AppTheme.of(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
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

          await tester.pumpWidget(_app(_wizardSurface(step, body), textScale));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('build log entry lays out at $at', (tester) async {
        tester.view.physicalSize = Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _app(
            BuildLogEntryPage(
              categories: _categories,
              imageService: ImageService(),
            ),
            textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  // ── Regressions ──────────────────────────────────────────────────────────

  // The app theme sets `filled: true` with a square fill and no border. Painted
  // over the wizard's rounded containers it squares their corners off, which is
  // how the rounded corners silently went missing on every screen that has a
  // text field. Each field must opt out.
  testWidgets('every wizard text field opts out of the filled theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var checked = 0;
    for (final (name, step, body) in _screens()) {
      await tester.pumpWidget(_app(_wizardSurface(step, body), 1));
      await tester.pumpAndSettle();
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

  // The three technical sections share one step, so the only thing standing
  // between the user and two thirds of the form is the tab bar.
  testWidgets('specs tabs swap the body and report the tap', (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var tab = SpecsTab.basics;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => _wizardSurface(
            0,
            _specs(tab, onTabChanged: (t) => setState(() => tab = t)),
          ),
        ),
        1,
      ),
    );
    await tester.pumpAndSettle();

    // Basics is open: the make selector is on screen, the power fields aren't.
    expect(find.text('Make'), findsOneWidget);
    expect(find.text('Torque'), findsNothing);

    await tester.tap(find.text('Power'));
    await tester.pumpAndSettle();

    expect(tab, SpecsTab.power);
    expect(find.text('Torque'), findsOneWidget);
    expect(find.text('Make'), findsNothing);

    await tester.tap(find.text('Config'));
    await tester.pumpAndSettle();

    expect(tab, SpecsTab.config);
    expect(find.text('Drivetrain'), findsOneWidget);
  });

  testWidgets('build-log widgets share the left edge of the other steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        _wizardSurface(
          1,
          ModsStep(
            mods: const [],
            categories: _categories,
            onAdd: () {},
            onRemove: (_) {},
          ),
        ),
        1,
      ),
    );
    await tester.pumpAndSettle();

    // The step title sets the left edge every other widget has to meet. The
    // add tile's content starts with its icon, inset only by the tile's own
    // padding — if it were centred instead, the gap would be far wider.
    final titleLeft = tester.getRect(find.text('Build log')).left;
    final iconLeft = tester
        .getRect(find.byIcon(Icons.add_rounded).first)
        .left;
    expect(
      iconLeft - titleLeft,
      lessThanOrEqualTo(20),
      reason: 'the add affordance is centred while the rest of the step is not',
    );
  });
}

