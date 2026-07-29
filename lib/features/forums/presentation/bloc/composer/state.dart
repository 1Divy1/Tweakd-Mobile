import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../domain/entities/forum_topic.dart';
import '../../utils/forum_error_mapper.dart';

/// Composer state. Text fields live in the page's controllers; this holds the
/// reference data, the thread's category (brand required, model optional) and
/// topic selection, the tag selection, and the submit flow. [createdThreadId]
/// is a one-shot navigation signal.
class NewThreadState extends Equatable {
  final bool isLoadingRefs;
  final ForumErrorCode? refsError;
  final List<ForumTopicEntity> topics;

  /// Brand step — the whole catalog is loaded up front and searched inside the
  /// picker sheet.
  final List<CarBrandEntity> brands;
  final CarBrandEntity? selectedBrand;

  /// Model step — only meaningful once a brand is picked; [models] holds the
  /// selected brand's catalog.
  final List<CarModelEntity> models;
  final bool isLoadingModels;
  final CarModelEntity? selectedModel;

  final Set<String> selectedTopicIds;

  /// Tag selection. Cars are only reachable through a mentioned person (or the
  /// viewer's own garage), so the backend's owner-must-be-tagged rule holds.
  final List<TaggedPerson> taggedPeople;
  final List<TaggedCar> taggedCars;

  final bool isSubmitting;
  final String? createdThreadId;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const NewThreadState({
    this.isLoadingRefs = true,
    this.refsError,
    this.topics = const [],
    this.brands = const [],
    this.selectedBrand,
    this.models = const [],
    this.isLoadingModels = false,
    this.selectedModel,
    this.selectedTopicIds = const {},
    this.taggedPeople = const [],
    this.taggedCars = const [],
    this.isSubmitting = false,
    this.createdThreadId,
    this.actionError,
    this.actionErrorTick = 0,
  });

  /// A brand is required to post; the model is optional.
  bool get hasBrand => selectedBrand != null;

  NewThreadState copyWith({
    bool? isLoadingRefs,
    ForumErrorCode? refsError,
    List<ForumTopicEntity>? topics,
    List<CarBrandEntity>? brands,
    CarBrandEntity? selectedBrand,
    bool clearSelectedBrand = false,
    List<CarModelEntity>? models,
    bool? isLoadingModels,
    CarModelEntity? selectedModel,
    bool clearSelectedModel = false,
    Set<String>? selectedTopicIds,
    List<TaggedPerson>? taggedPeople,
    List<TaggedCar>? taggedCars,
    bool? isSubmitting,
    String? createdThreadId,
    ForumErrorCode? actionError,
  }) {
    return NewThreadState(
      isLoadingRefs: isLoadingRefs ?? this.isLoadingRefs,
      refsError: refsError ?? this.refsError,
      topics: topics ?? this.topics,
      brands: brands ?? this.brands,
      selectedBrand: clearSelectedBrand
          ? null
          : (selectedBrand ?? this.selectedBrand),
      models: models ?? this.models,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      taggedCars: taggedCars ?? this.taggedCars,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdThreadId: createdThreadId ?? this.createdThreadId,
      actionError: actionError ?? this.actionError,
      actionErrorTick: actionError != null
          ? actionErrorTick + 1
          : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingRefs,
    refsError,
    topics,
    brands,
    selectedBrand,
    models,
    isLoadingModels,
    selectedModel,
    selectedTopicIds,
    taggedPeople,
    taggedCars,
    isSubmitting,
    createdThreadId,
    actionError,
    actionErrorTick,
  ];
}
