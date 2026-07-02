import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/feedback_feature.dart';
import '../../../domain/repositories/feedback_repository.dart';
import '../../../domain/usecases/get_feedback_features.dart';
import '../../../domain/usecases/get_feedback_types.dart';
import '../../../domain/usecases/submit_feedback.dart';
import '../../utils/feedback_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the feedback submit screen: loads the type + feature pickers, tracks
/// the current selections, and submits. Free-text fields live in the form's
/// controllers and arrive with [SubmitFeedbackPressed].
@injectable
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final GetFeedbackTypesUseCase getTypes;
  final GetFeedbackFeaturesUseCase getFeatures;
  final SubmitFeedbackUseCase submitFeedback;

  FeedbackBloc({
    required this.getTypes,
    required this.getFeatures,
    required this.submitFeedback,
  }) : super(const FeedbackState()) {
    on<LoadFeedbackOptions>(_onLoad);
    on<SelectFeedbackType>(_onSelectType);
    on<SelectFeedbackFeature>(_onSelectFeature);
    on<SubmitFeedbackPressed>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadFeedbackOptions event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(status: FeedbackStatus.loadingOptions));

    // Kick off both requests together, then await. Types are required, so a
    // failure there blocks the screen; features are optional, so a failure
    // there just leaves the (optional) feature picker empty.
    final typesFuture = getTypes(NoParams());
    final featuresFuture = getFeatures(NoParams());

    final typesResult = await typesFuture;
    final featuresResult = await featuresFuture;

    final types = typesResult.fold((_) => null, (list) => list);
    if (types == null) {
      emit(state.copyWith(status: FeedbackStatus.optionsError));
      return;
    }

    final features = featuresResult.fold(
      (_) => const <FeedbackFeatureEntity>[],
      (list) => list,
    );

    emit(state.copyWith(
      status: FeedbackStatus.ready,
      types: types,
      features: features,
    ));
  }

  void _onSelectType(SelectFeedbackType event, Emitter<FeedbackState> emit) {
    if (state.isSubmitting) return;
    final type = _byId(state.types, event.typeId, (t) => t.id);
    if (type == null) return;
    emit(state.copyWith(selectedType: type, clearError: true));
  }

  void _onSelectFeature(
    SelectFeedbackFeature event,
    Emitter<FeedbackState> emit,
  ) {
    if (state.isSubmitting) return;
    if (event.featureId == null) {
      emit(state.copyWith(clearSelectedFeature: true));
      return;
    }
    final feature = _byId(state.features, event.featureId!, (f) => f.id);
    if (feature == null) return;
    emit(state.copyWith(selectedFeature: feature));
  }

  Future<void> _onSubmit(
    SubmitFeedbackPressed event,
    Emitter<FeedbackState> emit,
  ) async {
    final type = state.selectedType;
    final content = event.content.trim();
    if (type == null || content.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(status: FeedbackStatus.submitting, clearError: true));

    // Reproduction steps only apply to bug reports, and only when filled in.
    final steps = event.reproductionSteps?.trim();
    final reproductionSteps =
        state.isBug && steps != null && steps.isNotEmpty ? steps : null;

    final result = await submitFeedback(FeedbackSubmission(
      content: content,
      typeId: type.id,
      featureId: state.selectedFeature?.id,
      reproductionSteps: reproductionSteps,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeedbackStatus.ready,
        errorCode: FeedbackErrorMapper.getCode(failure),
      )),
      (_) => emit(state.copyWith(status: FeedbackStatus.success)),
    );
  }

  /// First element of [items] whose [idOf] equals [id], or null.
  static T? _byId<T>(List<T> items, String id, String Function(T) idOf) {
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }
}
