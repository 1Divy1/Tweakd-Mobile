import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/add_modification.dart';
import '../../../domain/usecases/delete_modification.dart';
import '../../../domain/usecases/get_reference_data.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class LogModBloc extends Bloc<LogModEvent, LogModState> {
  final GetModCategoriesUseCase getModCategories;
  final AddModificationUseCase addModification;
  final DeleteModificationUseCase deleteModification;
  final CarImageService imageService;

  LogModBloc({
    required this.getModCategories,
    required this.addModification,
    required this.deleteModification,
    required this.imageService,
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
        message: 'Failed to load categories. Please try again.',
      )),
      (categories) => emit(LogModCategoriesLoaded(categories: categories)),
    );
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

    final addResult = await addModification(
      AddModificationParams(carId: event.carId, request: event.params),
    );

    final result = await addResult.fold(
      (failure) async {
        emit(LogModError(
          message: GarageErrorMapper.getMessage(failure),
          categories: List.from(categories),
        ));
        return null;
      },
      (created) async => created,
    );
    if (result == null) return;

    try {
      await Future.wait([
        imageService.uploadToSignedUrl(
            result.before.uploadUrl, event.beforeFilePath),
        imageService.uploadToSignedUrl(
            result.after.uploadUrl, event.afterFilePath),
      ]);
      emit(LogModSuccess(result.modification));
    } catch (_) {
      await deleteModification(DeleteModificationParams(
        carId: event.carId,
        modId: result.modification.id,
      ));
      emit(LogModError(
        message: 'Photo upload failed. Please try again.',
        categories: List.from(categories),
      ));
    }
  }
}
