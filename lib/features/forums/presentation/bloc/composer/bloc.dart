import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';
import 'package:car_social_media_app/features/garage/domain/usecases/get_my_garage.dart';
import 'package:car_social_media_app/features/garage/domain/usecases/get_reference_data.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/create_forum_thread.dart';
import '../../../domain/usecases/get_forum_topics.dart';
import '../../utils/forum_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the new-thread composer: reference data (topics, brand catalog,
/// garage), the model autocomplete, topic chips and the create call.
///
/// The catalog has no cross-brand model search endpoint, so the first query
/// fetches every brand's models once and caches them for the session.
@injectable
class NewThreadBloc extends Bloc<NewThreadEvent, NewThreadState> {
  final GetForumTopicsUseCase getTopics;
  final GetBrandsUseCase getBrands;
  final GetModelsByBrandUseCase getModelsByBrand;
  final GetMyGarageUseCase getMyGarage;
  final CreateForumThreadUseCase createThread;

  final Map<String, List<CarModelEntity>> _modelsByBrand = {};

  NewThreadBloc({
    required this.getTopics,
    required this.getBrands,
    required this.getModelsByBrand,
    required this.getMyGarage,
    required this.createThread,
  }) : super(const NewThreadState()) {
    on<LoadNewThreadRefs>(_onLoadRefs);
    on<NewThreadCarQueryChanged>(_onQueryChanged);
    on<SelectNewThreadCar>(_onSelectCar);
    on<SelectGarageCar>(_onSelectGarageCar);
    on<ClearNewThreadCar>(_onClearCar);
    on<ToggleNewThreadTopic>(_onToggleTopic);
    on<SubmitNewThread>(_onSubmit);
  }

  Future<void> _onLoadRefs(
    LoadNewThreadRefs event,
    Emitter<NewThreadState> emit,
  ) async {
    emit(const NewThreadState(isLoadingRefs: true));

    final topicsFuture = getTopics(NoParams());
    final brandsFuture = getBrands(NoParams());
    final garageFuture = getMyGarage(NoParams());
    final topicsResult = await topicsFuture;
    final brandsResult = await brandsFuture;
    final garageResult = await garageFuture;

    // Topics and brands make the form; the garage suggestion is optional.
    ForumErrorCode? fatal;
    topicsResult.fold((f) => fatal = ForumErrorMapper.getCode(f), (_) {});
    brandsResult.fold((f) => fatal ??= ForumErrorMapper.getCode(f), (_) {});
    if (fatal != null) {
      emit(NewThreadState(isLoadingRefs: false, refsError: fatal));
      return;
    }

    emit(NewThreadState(
      isLoadingRefs: false,
      topicGroups: topicsResult.getOrElse(() => const []),
      brands: brandsResult.getOrElse(() => const []),
      garageCars: garageResult.fold((_) => const [], (g) => g.cars),
    ));
  }

  Future<void> _onQueryChanged(
    NewThreadCarQueryChanged event,
    Emitter<NewThreadState> emit,
  ) async {
    final query = event.query.trim().toLowerCase();
    if (query.length < 2) {
      emit(state.copyWith(
        carQuery: event.query,
        suggestions: const [],
        isSearching: false,
      ));
      return;
    }

    emit(state.copyWith(carQuery: event.query, isSearching: true));
    await _ensureAllModelsLoaded();

    // The user may have kept typing while models were being fetched.
    if (state.carQuery.trim().toLowerCase() != query) return;

    final matches = <ComposerCarOption>[];
    for (final brand in state.brands) {
      for (final model in _modelsByBrand[brand.id] ?? const []) {
        final label = '${brand.name} ${model.model}'.toLowerCase();
        if (label.contains(query) ||
            model.model.toLowerCase().contains(query)) {
          matches.add(ComposerCarOption(brand: brand, model: model));
        }
      }
    }
    matches.sort((a, b) => a.label.compareTo(b.label));

    emit(state.copyWith(
      isSearching: false,
      suggestions: matches.take(8).toList(),
    ));
  }

  Future<void> _ensureAllModelsLoaded() async {
    final missing =
        state.brands.where((b) => !_modelsByBrand.containsKey(b.id)).toList();
    if (missing.isEmpty) return;

    final results = await Future.wait(missing.map(
        (b) => getModelsByBrand(GetModelsByBrandParams(brandId: b.id))));
    for (var i = 0; i < missing.length; i++) {
      results[i].fold(
        // Leave failed brands out of the cache so a later search retries them.
        (_) {},
        (models) => _modelsByBrand[missing[i].id] = models,
      );
    }
  }

  void _onSelectCar(SelectNewThreadCar event, Emitter<NewThreadState> emit) {
    emit(state.copyWith(
      selectedCar: event.option,
      suggestions: const [],
      carQuery: '',
    ));
  }

  Future<void> _onSelectGarageCar(
    SelectGarageCar event,
    Emitter<NewThreadState> emit,
  ) async {
    // Garage cars carry brand/model names only — resolve them against the
    // catalog to get the model id the backend needs.
    final brand = state.brands.where(
      (b) => b.name.toLowerCase() == event.car.brand.toLowerCase(),
    );
    if (brand.isEmpty) {
      emit(state.copyWith(actionError: ForumErrorCode.generic));
      return;
    }

    if (!_modelsByBrand.containsKey(brand.first.id)) {
      final result = await getModelsByBrand(
          GetModelsByBrandParams(brandId: brand.first.id));
      result.fold((_) {}, (m) => _modelsByBrand[brand.first.id] = m);
    }

    final model = (_modelsByBrand[brand.first.id] ?? const []).where(
      (m) => m.model.toLowerCase() == event.car.model.toLowerCase(),
    );
    if (model.isEmpty) {
      emit(state.copyWith(actionError: ForumErrorCode.generic));
      return;
    }

    emit(state.copyWith(
      selectedCar: ComposerCarOption(brand: brand.first, model: model.first),
      suggestions: const [],
      carQuery: '',
    ));
  }

  void _onClearCar(ClearNewThreadCar event, Emitter<NewThreadState> emit) {
    emit(state.copyWith(clearSelectedCar: true));
  }

  void _onToggleTopic(
    ToggleNewThreadTopic event,
    Emitter<NewThreadState> emit,
  ) {
    final selected = {...state.selectedTopicIds};
    if (!selected.remove(event.topicId)) {
      if (selected.length >= 10) return; // backend cap
      selected.add(event.topicId);
    }
    emit(state.copyWith(selectedTopicIds: selected));
  }

  Future<void> _onSubmit(
    SubmitNewThread event,
    Emitter<NewThreadState> emit,
  ) async {
    final title = event.title.trim();
    final content = event.content.trim();
    if (title.isEmpty || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));

    final result = await createThread(CreateForumThreadParams(
      title: title,
      content: content.isEmpty ? null : content,
      modelId: state.selectedCar?.model.id,
      topicIds: state.selectedTopicIds.toList(),
    ));
    result.fold(
      (f) => emit(state.copyWith(
        isSubmitting: false,
        actionError: ForumErrorMapper.getCode(f),
      )),
      (thread) => emit(state.copyWith(
        isSubmitting: false,
        createdThreadId: thread.id,
      )),
    );
  }
}
