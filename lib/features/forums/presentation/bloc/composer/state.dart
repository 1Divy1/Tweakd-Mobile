import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../domain/entities/forum_topic.dart';
import '../../utils/forum_error_mapper.dart';

/// A taggable car: catalog model + its brand (for display and because the
/// backend derives the brand from the model id).
class ComposerCarOption extends Equatable {
  final CarBrandEntity brand;
  final CarModelEntity model;

  const ComposerCarOption({required this.brand, required this.model});

  String get label => '${brand.name} ${model.model}';

  @override
  List<Object?> get props => [brand, model];
}

/// Composer state. Text fields live in the page's controllers; this holds the
/// reference data, the car tag and topic selection, and the submit flow.
/// [createdThreadId] is a one-shot navigation signal.
class NewThreadState extends Equatable {
  final bool isLoadingRefs;
  final ForumErrorCode? refsError;
  final List<ForumTopicGroupEntity> topicGroups;
  final List<CarSummaryEntity> garageCars;
  final List<CarBrandEntity> brands;
  final String carQuery;
  final bool isSearching;
  final List<ComposerCarOption> suggestions;
  final ComposerCarOption? selectedCar;
  final Set<String> selectedTopicIds;
  final bool isSubmitting;
  final String? createdThreadId;
  final ForumErrorCode? actionError;
  final int actionErrorTick;

  const NewThreadState({
    this.isLoadingRefs = true,
    this.refsError,
    this.topicGroups = const [],
    this.garageCars = const [],
    this.brands = const [],
    this.carQuery = '',
    this.isSearching = false,
    this.suggestions = const [],
    this.selectedCar,
    this.selectedTopicIds = const {},
    this.isSubmitting = false,
    this.createdThreadId,
    this.actionError,
    this.actionErrorTick = 0,
  });

  NewThreadState copyWith({
    bool? isLoadingRefs,
    ForumErrorCode? refsError,
    List<ForumTopicGroupEntity>? topicGroups,
    List<CarSummaryEntity>? garageCars,
    List<CarBrandEntity>? brands,
    String? carQuery,
    bool? isSearching,
    List<ComposerCarOption>? suggestions,
    ComposerCarOption? selectedCar,
    bool clearSelectedCar = false,
    Set<String>? selectedTopicIds,
    bool? isSubmitting,
    String? createdThreadId,
    ForumErrorCode? actionError,
  }) {
    return NewThreadState(
      isLoadingRefs: isLoadingRefs ?? this.isLoadingRefs,
      refsError: refsError ?? this.refsError,
      topicGroups: topicGroups ?? this.topicGroups,
      garageCars: garageCars ?? this.garageCars,
      brands: brands ?? this.brands,
      carQuery: carQuery ?? this.carQuery,
      isSearching: isSearching ?? this.isSearching,
      suggestions: suggestions ?? this.suggestions,
      selectedCar: clearSelectedCar ? null : (selectedCar ?? this.selectedCar),
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdThreadId: createdThreadId ?? this.createdThreadId,
      actionError: actionError ?? this.actionError,
      actionErrorTick:
          actionError != null ? actionErrorTick + 1 : actionErrorTick,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingRefs,
        refsError,
        topicGroups,
        garageCars,
        brands,
        carQuery,
        isSearching,
        suggestions,
        selectedCar,
        selectedTopicIds,
        isSubmitting,
        createdThreadId,
        actionError,
        actionErrorTick,
      ];
}
