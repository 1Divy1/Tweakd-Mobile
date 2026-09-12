// The add-modification flow, opened from the create sheet (no car yet) or from
// a car's page (car known). What it has to get right is which screen it opens
// on for a given garage — ask, skip, or send the user to add a car — and that
// every one of those screens holds up across widths and text scales.
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/theme/app_theme.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/garage/domain/entities/garage.dart';
import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:tweakd/features/garage/domain/repositories/garage_repository.dart';
import 'package:tweakd/features/garage/domain/usecases/add_modification.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_car.dart';
import 'package:tweakd/features/garage/domain/usecases/delete_modification.dart';
import 'package:tweakd/features/garage/domain/usecases/get_garage_by_username.dart';
import 'package:tweakd/features/garage/domain/usecases/get_modification_upload_urls.dart';
import 'package:tweakd/features/garage/domain/usecases/get_my_garage.dart';
import 'package:tweakd/features/garage/domain/usecases/get_reference_data.dart';
import 'package:tweakd/features/garage/domain/usecases/patch_modification.dart';
import 'package:tweakd/features/garage/presentation/bloc/bloc.dart';
import 'package:tweakd/features/garage/presentation/bloc/event.dart';
import 'package:tweakd/features/garage/presentation/bloc/log_mod/bloc.dart';
import 'package:tweakd/features/garage/presentation/bloc/log_mod/event.dart';
import 'package:tweakd/features/garage/presentation/pages/add_modification_page.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// Answers the two reads the page makes; anything else would be a bug here.
class _FakeGarageRepo implements GarageRepository {
  final List<CarSummaryEntity> cars;

  _FakeGarageRepo(this.cars);

  @override
  Future<Either<Failure, GarageEntity>> getMyGarage() async => Right(
        GarageEntity(
          id: 'g1',
          ownerId: 'u1',
          createdAt: DateTime(2026),
          cars: cars,
        ),
      );

  @override
  Future<Either<Failure, List<CarModCategoryEntity>>> getModCategories() async =>
      const Right([
        CarModCategoryEntity(id: 'cat1', modName: 'Engine & Drivetrain'),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _gt3 = CarSummaryEntity(
  id: 'c1',
  brand: 'Porsche',
  model: '911 GT3 Touring',
  year: 2022,
);
// Long enough to wrap at the narrow widths and large text scales.
const _m3 = CarSummaryEntity(
  id: 'c2',
  brand: 'BMW',
  model: 'M3 Competition Touring xDrive',
  year: 2023,
);

Widget _app({
  required List<CarSummaryEntity> cars,
  String? carId,
  double textScale = 1,
}) {
  final repo = _FakeGarageRepo(cars);

  final logMod = BlocProvider<LogModBloc>(
    create: (_) => LogModBloc(
      getModCategories: GetModCategoriesUseCase(repo),
      addModification: AddModificationUseCase(repo),
      deleteModification: DeleteModificationUseCase(repo),
      getModificationUploadUrls: GetModificationUploadUrlsUseCase(repo),
      patchModification: PatchModificationUseCase(repo),
      imageService: ImageService(),
    )..add(const LoadModCategories()),
  );

  // Mirrors the router: the garage is only loaded when the car isn't known.
  final Widget page = carId != null
      ? MultiBlocProvider(
          providers: [logMod],
          child: AddModificationPage(carId: carId),
        )
      : MultiBlocProvider(
          providers: [
            logMod,
            BlocProvider<GarageBloc>(
              create: (_) => GarageBloc(
                getMyGarage: GetMyGarageUseCase(repo),
                getGarageByUsername: GetGarageByUsernameUseCase(repo),
                deleteCarUseCase: DeleteCarUseCase(repo),
              )..add(const LoadMyGarage()),
            ),
          ],
          child: const AddModificationPage(),
        );

  return MaterialApp(
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
    home: page,
  );
}

void main() {
  setUpAll(() {
    // The page takes its image service from the service locator.
    if (!getIt.isRegistered<ImageService>()) {
      getIt.registerSingleton<ImageService>(ImageService());
    }
  });

  Future<void> pump(
    WidgetTester tester, {
    required List<CarSummaryEntity> cars,
    String? carId,
    double width = 390,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(cars: cars, carId: carId, textScale: textScale),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with several cars it asks which one first', (tester) async {
    await pump(tester, cars: const [_gt3, _m3]);

    expect(find.text('Which car?'), findsOneWidget);
    expect(find.text('Add a build item'), findsNothing);

    // Nothing picked yet: NEXT says so instead of moving on.
    await tester.tap(find.text('NEXT'));
    await tester.pump();
    expect(find.text('Pick a car to continue.'), findsOneWidget);
    expect(find.text('Which car?'), findsOneWidget);

    await tester.tap(find.text('BMW M3 Competition Touring xDrive'));
    await tester.pump();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    expect(find.text('Add a build item'), findsOneWidget);
    expect(find.text('Which car?'), findsNothing);

    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('Which car?'), findsOneWidget);
  });

  testWidgets('with one car it goes straight to the form', (tester) async {
    await pump(tester, cars: const [_gt3]);

    expect(find.text('Add a build item'), findsOneWidget);
    expect(find.text('Which car?'), findsNothing);
    expect(find.text('BACK'), findsNothing);
    expect(find.text('ADD TO BUILD LOG'), findsOneWidget);
  });

  testWidgets('with no cars it points at adding one first', (tester) async {
    await pump(tester, cars: const []);

    expect(find.text('No cars yet'), findsOneWidget);
    expect(find.text('ADD A CAR'), findsOneWidget);
    expect(find.text('Add a build item'), findsNothing);
  });

  testWidgets('opened for a car it skips the garage entirely', (tester) async {
    // No GarageBloc is provided here — reading one would throw.
    await pump(tester, cars: const [_gt3, _m3], carId: 'c1');

    expect(find.text('Add a build item'), findsOneWidget);
    expect(find.text('Which car?'), findsNothing);
  });

  testWidgets('an incomplete entry is not submitted', (tester) async {
    await pump(tester, cars: const [_gt3]);

    await tester.tap(find.text('ADD TO BUILD LOG'));
    await tester.pump();

    expect(find.text('Category, title and date are required.'), findsOneWidget);
    expect(find.text('Add a build item'), findsOneWidget);
  });

  // 320 = iPhone SE 1st gen, 375 = iPhone 13 mini, 440 = 17 Pro Max,
  // 834 = iPad Air portrait.
  const widths = [320.0, 375.0, 440.0, 834.0];
  const textScales = [1.0, 1.3, 2.0];
  final screens = <(String, List<CarSummaryEntity>)>[
    ('car step', const [_gt3, _m3]),
    ('form', const [_gt3]),
    ('no cars', const []),
  ];

  for (final width in widths) {
    for (final textScale in textScales) {
      for (final (name, cars) in screens) {
        testWidgets(
          '$name lays out at ${width.toInt()}pt, text x$textScale',
          (tester) async {
            await pump(
              tester,
              cars: cars,
              width: width,
              textScale: textScale,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
