import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../domain/entities/forum_topic.dart';
import '../../utils/forum_error_mapper.dart';

/// Composer state. Text fields live in the page's controllers; this holds the
/// reference data, the car tag (brand required, model optional) and topic
/// selection, and the submit flow. [createdThreadId] is a one-shot navigation
/// signal.
class NewThreadState extends Equatable {
  final bool isLoadingRefs;
  final ForumErrorCode? refsError;
  final List<ForumTopicEntity> topics;
  final List<CarSummaryEntity> garageCars;

  /// Brand step — the whole catalog is loaded up front and filtered locally.
  final List<CarBrandEntity> brands;
  final String brandQuery;
  final CarBrandEntity? selectedBrand;

  /// Model step — only meaningful once a brand is picked; [models] holds the
  /// selected brand's catalog and is filtered locally by [modelQuery].
  final List<CarModelEntity> models;
  final bool isLoadingModels;
  final String modelQuery;
  final CarModelEntity? selectedModel;

  final Set<String> selectedTopicIds;
  final bool isSubmitting;
  final String? createdThreadId;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const NewThreadState({
    this.isLoadingRefs = true,
    this.refsError,
    this.topics = const [],
    this.garageCars = const [],
    this.brands = const [],
    this.brandQuery = '',
    this.selectedBrand,
    this.models = const [],
    this.isLoadingModels = false,
    this.modelQuery = '',
    this.selectedModel,
    this.selectedTopicIds = const {},
    this.isSubmitting = false,
    this.createdThreadId,
    this.actionError,
    this.actionErrorTick = 0,
  });

  /// Brands matching the brand search box.
  List<CarBrandEntity> get filteredBrands {
    final query = brandQuery.trim().toLowerCase();
    if (query.isEmpty) return brands;
    return brands
        .where((b) => b.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// Models of the selected brand matching the model search box.
  List<CarModelEntity> get filteredModels {
    final query = modelQuery.trim().toLowerCase();
    if (query.isEmpty) return models;
    return models
        .where((m) => m.model.toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// A brand is required to post; the model is optional.
  bool get hasBrand => selectedBrand != null;

  NewThreadState copyWith({
    bool? isLoadingRefs,
    ForumErrorCode? refsError,
    List<ForumTopicEntity>? topics,
    List<CarSummaryEntity>? garageCars,
    List<CarBrandEntity>? brands,
    String? brandQuery,
    CarBrandEntity? selectedBrand,
    bool clearSelectedBrand = false,
    List<CarModelEntity>? models,
    bool? isLoadingModels,
    String? modelQuery,
    CarModelEntity? selectedModel,
    bool clearSelectedModel = false,
    Set<String>? selectedTopicIds,
    bool? isSubmitting,
    String? createdThreadId,
    ForumErrorCode? actionError,
  }) {
    return NewThreadState(
      isLoadingRefs: isLoadingRefs ?? this.isLoadingRefs,
      refsError: refsError ?? this.refsError,
      topics: topics ?? this.topics,
      garageCars: garageCars ?? this.garageCars,
      brands: brands ?? this.brands,
      brandQuery: brandQuery ?? this.brandQuery,
      selectedBrand: clearSelectedBrand
          ? null
          : (selectedBrand ?? this.selectedBrand),
      models: models ?? this.models,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      modelQuery: modelQuery ?? this.modelQuery,
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
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
    garageCars,
    brands,
    brandQuery,
    selectedBrand,
    models,
    isLoadingModels,
    modelQuery,
    selectedModel,
    selectedTopicIds,
    isSubmitting,
    createdThreadId,
    actionError,
    actionErrorTick,
  ];
}
