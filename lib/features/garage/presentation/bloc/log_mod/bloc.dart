import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/image_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../../domain/usecases/add_modification.dart';
import '../../../domain/usecases/delete_modification.dart';
import '../../../domain/usecases/get_modification_upload_urls.dart';
import '../../../domain/usecases/get_reference_data.dart';
import '../../../domain/usecases/patch_modification.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

@injectable
class LogModBloc extends Bloc<LogModEvent, LogModState> {
  final GetModCategoriesUseCase getModCategories;
  final AddModificationUseCase addModification;
  final DeleteModificationUseCase deleteModification;
  final GetModificationUploadUrlsUseCase getModificationUploadUrls;
  final PatchModificationUseCase patchModification;
  final ImageService imageService;
  final AnalyticsService analytics;

  LogModBloc({
    required this.getModCategories,
    required this.addModification,
    required this.deleteModification,
    required this.getModificationUploadUrls,
    required this.patchModification,
    required this.imageService,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const LogModInitial()) {
    on<LoadModCategories>(_onLoadCategories);
    on<SubmitModification>(_onSubmit);
  }

  FutureOr<void> _onLoadCategories(
    LoadModCategories event,
    Emitter<LogModState> emit,
  ) async {
    emit(const LogModCategoriesLoading());

    final result = await getModCategories(NoParams());

    result.fold(
      (_) => emit(const LogModCategoriesError(
        code: GarageErrorCode.categoriesLoadFailed,
      )),
      (categories) => emit(LogModCategoriesLoaded(categories: categories)),
    );
  }

  void _trackAdded(int imageCount) {
    analytics.track(AnalyticsEvents.modificationAdded, {
      'source': 'log',
      'image_count': imageCount,
    });
  }

  FutureOr<void> _onSubmit(
    SubmitModification event,
    Emitter<LogModState> emit,
  ) async {
    final current = state;
    final categories = switch (current) {
      LogModCategoriesLoaded(:final categories) => categories,
      LogModError(:final categories) => categories,
      LogModSubmitting(:final categories) => categories,
      _ => const [],
    };

    emit(LogModSubmitting(categories: List.from(categories)));

    // ── Step 1: create modification (text data only) ──────────────────────────
    final addResult = await addModification(
      AddModificationParams(carId: event.carId, request: event.input.request),
    );

    final modification = await addResult.fold(
      (failure) async {
        emit(LogModError(
          code: GarageErrorMapper.getCode(failure),
          categories: List.from(categories),
        ));
        return null;
      },
      (mod) async => mod,
    );
    if (modification == null) return;

    // ── Steps 2–4: upload media; roll back modification on any failure ─────────
    final before = event.input.before;
    final after = event.input.after;
    // A phase can carry several images, so the response's `phase` field can't
    // say which image a slot is for. The backend returns slots in request
    // order, so the request is `[...before, ...after]` and paired by index.
    final images = <CompressedImage>[...before, ...after];

    if (images.isEmpty) {
      _trackAdded(images.length);
      emit(LogModSuccess(modification));
      return;
    }

    final files = <ModUploadRequest>[
      for (var i = 0; i < before.length; i++)
        const ModUploadRequest(phase: 'BEFORE', format: 'WEBP'),
      for (var i = 0; i < after.length; i++)
        const ModUploadRequest(phase: 'AFTER', format: 'WEBP'),
    ];

    try {
      // Step 2: request presigned upload URLs in one shot
      final uploadUrlsResult = await getModificationUploadUrls(
        GetModificationUploadUrlsParams(
          carId: event.carId,
          modId: modification.id,
          files: files,
        ),
      );
      final uploads = uploadUrlsResult.fold(
        (f) => throw Exception('$f'),
        (r) => r.uploads,
      );

      // Defensive: a short response would silently mis-pair images with slots.
      if (uploads.length != images.length) {
        throw Exception(
          'Expected ${images.length} upload slots, got ${uploads.length}',
        );
      }

      // Step 3: upload all files to R2 in parallel. Bytes are already being
      // compressed (since selection), so this only awaits them and PUTs.
      await Future.wait([
        for (var i = 0; i < uploads.length; i++)
          images[i].bytes.then(
                (bytes) => imageService.uploadToR2(uploads[i].uploadUrl, bytes),
              ),
      ]);

      // Step 4: save URLs to backend
      final addMedia = uploads
          .map((u) => ModMediaInput(key: u.key, phase: u.phase))
          .toList();
      final patchResult = await patchModification(PatchModificationParams(
        carId: event.carId,
        modId: modification.id,
        params: ModPatchParams(addMedia: addMedia),
      ));

      patchResult.fold(
        (f) => throw Exception('$f'),
        (updated) {
          _trackAdded(images.length);
          emit(LogModSuccess(updated));
        },
      );
    } catch (_) {
      await deleteModification(DeleteModificationParams(
        carId: event.carId,
        modId: modification.id,
      ));
      emit(LogModError(
        code: GarageErrorCode.photoUploadFailed,
        categories: List.from(categories),
      ));
    }
  }
}
