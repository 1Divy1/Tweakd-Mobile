import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:tweakd/features/garage/domain/usecases/get_reference_data.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/create_forum_thread.dart';
import '../../../domain/usecases/get_forum_topics.dart';
import '../../utils/forum_error_mapper.dart';
import '../../utils/forum_tags.dart';
import 'event.dart';
import 'state.dart';

/// Drives the new-thread composer: reference data (topics, brand catalog), the
/// brand → model picker, topic chips, the tag selection and the create call.
///
/// Brands come down in one call and are searched inside the picker sheet;
/// models are fetched per brand the first time that brand is picked and cached
/// for the session.
@injectable
class NewThreadBloc extends Bloc<NewThreadEvent, NewThreadState> {
  final GetForumTopicsUseCase getTopics;
  final GetBrandsUseCase getBrands;
  final GetModelsByBrandUseCase getModelsByBrand;
  final CreateForumThreadUseCase createThread;

  final Map<String, List<CarModelEntity>> _modelsByBrand = {};

  NewThreadBloc({
    required this.getTopics,
    required this.getBrands,
    required this.getModelsByBrand,
    required this.createThread,
  }) : super(const NewThreadState()) {
    on<LoadNewThreadRefs>(_onLoadRefs);
    on<SelectNewThreadBrand>(_onSelectBrand);
    on<ClearNewThreadBrand>(_onClearBrand);
    on<SelectNewThreadModel>(_onSelectModel);
    on<ClearNewThreadModel>(_onClearModel);
    on<ToggleNewThreadTopic>(_onToggleTopic);
    on<AddNewThreadTagPerson>(_onAddTagPerson);
    on<RemoveNewThreadTagPerson>(_onRemoveTagPerson);
    on<AddNewThreadTagCar>(_onAddTagCar);
    on<RemoveNewThreadTagCar>(_onRemoveTagCar);
    on<SubmitNewThread>(_onSubmit);
  }

  Future<void> _onLoadRefs(
    LoadNewThreadRefs event,
    Emitter<NewThreadState> emit,
  ) async {
    emit(const NewThreadState(isLoadingRefs: true));

    final topicsFuture = getTopics(NoParams());
    final brandsFuture = getBrands(NoParams());
    final topicsResult = await topicsFuture;
    final brandsResult = await brandsFuture;

    // Topics and brands both make the form; either failing is fatal.
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
      ),
    );
  }

  Future<void> _onSelectBrand(
    SelectNewThreadBrand event,
    Emitter<NewThreadState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedBrand: event.brand,
        clearSelectedModel: true,
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
      ),
    );
  }

  void _onSelectModel(
    SelectNewThreadModel event,
    Emitter<NewThreadState> emit,
  ) {
    emit(state.copyWith(selectedModel: event.model));
  }

  void _onClearModel(ClearNewThreadModel event, Emitter<NewThreadState> emit) {
    emit(state.copyWith(clearSelectedModel: true));
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

  void _onAddTagPerson(
    AddNewThreadTagPerson event,
    Emitter<NewThreadState> emit,
  ) {
    final people = state.taggedPeople;
    if (people.length >= kTagSelectionLimit ||
        people.any((p) => p.id == event.person.id)) {
      return;
    }
    emit(state.copyWith(taggedPeople: [...people, event.person]));
  }

  void _onRemoveTagPerson(
    RemoveNewThreadTagPerson event,
    Emitter<NewThreadState> emit,
  ) {
    emit(
      state.copyWith(
        taggedPeople: [
          for (final p in state.taggedPeople)
            if (p.id != event.personId) p,
        ],
        // A car whose owner is no longer tagged would be rejected on submit.
        taggedCars: tagCarsWithoutOwner(state.taggedCars, event.personId),
      ),
    );
  }

  void _onAddTagCar(AddNewThreadTagCar event, Emitter<NewThreadState> emit) {
    final cars = state.taggedCars;
    if (cars.length >= kTagSelectionLimit || cars.any((c) => c.id == event.car.id)) {
      return;
    }
    emit(state.copyWith(taggedCars: [...cars, event.car]));
  }

  void _onRemoveTagCar(
    RemoveNewThreadTagCar event,
    Emitter<NewThreadState> emit,
  ) {
    emit(
      state.copyWith(
        taggedCars: [
          for (final c in state.taggedCars)
            if (c.id != event.carId) c,
        ],
      ),
    );
  }

  Future<void> _onSubmit(
    SubmitNewThread event,
    Emitter<NewThreadState> emit,
  ) async {
    final title = event.title.trim();
    final content = event.content.trim();
    // The Post button mirrors these guards; title, body and brand are all
    // required, the model isn't.
    if (title.isEmpty ||
        content.isEmpty ||
        state.selectedBrand == null ||
        state.isSubmitting) {
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    final result = await createThread(
      CreateForumThreadParams(
        title: title,
        content: content,
        modelId: state.selectedModel?.id,
        brandId: state.selectedBrand!.id,
        topicIds: state.selectedTopicIds.toList(),
        taggedPeople: [for (final p in state.taggedPeople) p.id],
        taggedCars: [for (final c in state.taggedCars) c.id],
      ),
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          isSubmitting: false,
          actionError: ForumErrorMapper.getCode(
            f,
            validationCode: ForumErrorCode.invalidTags,
          ),
        ),
      ),
      (thread) =>
          emit(state.copyWith(isSubmitting: false, createdThreadId: thread.id)),
    );
  }
}
