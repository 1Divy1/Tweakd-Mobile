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
/// garage), the brand → model picker, topic chips and the create call.
///
/// Brands come down in one call and are filtered locally; models are fetched
/// per brand the first time that brand is picked and cached for the session.
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
    on<NewThreadBrandQueryChanged>(_onBrandQueryChanged);
    on<SelectNewThreadBrand>(_onSelectBrand);
    on<ClearNewThreadBrand>(_onClearBrand);
    on<NewThreadModelQueryChanged>(_onModelQueryChanged);
    on<SelectNewThreadModel>(_onSelectModel);
    on<ClearNewThreadModel>(_onClearModel);
    on<SelectGarageCar>(_onSelectGarageCar);
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

    emit(
      NewThreadState(
        isLoadingRefs: false,
        topics: topicsResult.getOrElse(() => const []),
        brands: brandsResult.getOrElse(() => const []),
        garageCars: garageResult.fold((_) => const [], (g) => g.cars),
      ),
    );
  }

  void _onBrandQueryChanged(
    NewThreadBrandQueryChanged event,
    Emitter<NewThreadState> emit,
  ) {
    emit(state.copyWith(brandQuery: event.query));
  }

  Future<void> _onSelectBrand(
    SelectNewThreadBrand event,
    Emitter<NewThreadState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedBrand: event.brand,
        clearSelectedModel: true,
        brandQuery: '',
        modelQuery: '',
        models: const [],
        isLoadingModels: !_modelsByBrand.containsKey(event.brand.id),
      ),
    );

    final models = await _loadModels(event.brand.id);

    // The user may have changed brand while the models were loading.
    if (state.selectedBrand?.id != event.brand.id) return;
    emit(state.copyWith(models: models, isLoadingModels: false));
  }

  void _onClearBrand(ClearNewThreadBrand event, Emitter<NewThreadState> emit) {
    emit(
      state.copyWith(
        clearSelectedBrand: true,
        clearSelectedModel: true,
        models: const [],
        isLoadingModels: false,
        brandQuery: '',
        modelQuery: '',
      ),
    );
  }

  void _onModelQueryChanged(
    NewThreadModelQueryChanged event,
    Emitter<NewThreadState> emit,
  ) {
    emit(state.copyWith(modelQuery: event.query));
  }

  void _onSelectModel(
    SelectNewThreadModel event,
    Emitter<NewThreadState> emit,
  ) {
    emit(state.copyWith(selectedModel: event.model, modelQuery: ''));
  }

  void _onClearModel(ClearNewThreadModel event, Emitter<NewThreadState> emit) {
    emit(state.copyWith(clearSelectedModel: true, modelQuery: ''));
  }

  Future<void> _onSelectGarageCar(
    SelectGarageCar event,
    Emitter<NewThreadState> emit,
  ) async {
    // Garage cars carry brand/model names only — resolve them against the
    // catalog to get the ids the backend needs.
    final brand = state.brands.where(
      (b) => b.name.toLowerCase() == event.car.brand.toLowerCase(),
    );
    if (brand.isEmpty) {
      emit(state.copyWith(actionError: ForumErrorCode.generic));
      return;
    }

    emit(
      state.copyWith(
        selectedBrand: brand.first,
        clearSelectedModel: true,
        brandQuery: '',
        modelQuery: '',
        models: const [],
        isLoadingModels: true,
      ),
    );

    final models = await _loadModels(brand.first.id);
    if (state.selectedBrand?.id != brand.first.id) return;

    // An unresolvable model still leaves a usable brand-only tag.
    final model = models.where(
      (m) => m.model.toLowerCase() == event.car.model.toLowerCase(),
    );

    emit(
      state.copyWith(
        models: models,
        isLoadingModels: false,
        selectedModel: model.isEmpty ? null : model.first,
      ),
    );
  }

  /// Models for [brandId], from cache when possible. A failed fetch yields an
  /// empty list and is left out of the cache so a later pick retries it.
  Future<List<CarModelEntity>> _loadModels(String brandId) async {
    final cached = _modelsByBrand[brandId];
    if (cached != null) return cached;

    final result = await getModelsByBrand(
      GetModelsByBrandParams(brandId: brandId),
    );
    return result.fold((_) => const [], (models) {
      _modelsByBrand[brandId] = models;
      return models;
    });
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
    // The Post button mirrors these guards; a brand is required, a model isn't.
    if (title.isEmpty || state.selectedBrand == null || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    final result = await createThread(
      CreateForumThreadParams(
        title: title,
        content: content.isEmpty ? null : content,
        modelId: state.selectedModel?.id,
        brandId: state.selectedBrand?.id,
        topicIds: state.selectedTopicIds.toList(),
      ),
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          isSubmitting: false,
          actionError: ForumErrorMapper.getCode(f),
        ),
      ),
      (thread) =>
          emit(state.copyWith(isSubmitting: false, createdThreadId: thread.id)),
    );
  }
}
