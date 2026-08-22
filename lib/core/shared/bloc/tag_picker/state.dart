import 'package:equatable/equatable.dart';

import 'package:tweakd/core/shared/entities/search_result.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';

enum TagLoadStatus { idle, loading, success, failure }

/// Drives the tags step: live people search results and the loaded garage of
/// the person whose car is being picked. The two concerns are independent —
/// people search feeds the typeahead, [ownerCars] feeds the car-picker sheet.
class TagPickerState extends Equatable {
  final TagLoadStatus peopleStatus;
  final List<SearchResultEntity> peopleResults;

  final TagLoadStatus carsStatus;
  final List<CarSummaryEntity> ownerCars;
  final String? ownerUsername;

  /// The viewer's own garage, loaded on demand by [MyCarsRequested]. Kept
  /// separate from [ownerCars] so switching between people doesn't drop it.
  final TagLoadStatus myCarsStatus;
  final List<CarSummaryEntity> myCars;

  const TagPickerState({
    this.peopleStatus = TagLoadStatus.idle,
    this.peopleResults = const [],
    this.carsStatus = TagLoadStatus.idle,
    this.ownerCars = const [],
    this.ownerUsername,
    this.myCarsStatus = TagLoadStatus.idle,
    this.myCars = const [],
  });

  TagPickerState copyWith({
    TagLoadStatus? peopleStatus,
    List<SearchResultEntity>? peopleResults,
    TagLoadStatus? carsStatus,
    List<CarSummaryEntity>? ownerCars,
    String? ownerUsername,
    TagLoadStatus? myCarsStatus,
    List<CarSummaryEntity>? myCars,
  }) {
    return TagPickerState(
      peopleStatus: peopleStatus ?? this.peopleStatus,
      peopleResults: peopleResults ?? this.peopleResults,
      carsStatus: carsStatus ?? this.carsStatus,
      ownerCars: ownerCars ?? this.ownerCars,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      myCarsStatus: myCarsStatus ?? this.myCarsStatus,
      myCars: myCars ?? this.myCars,
    );
  }

  @override
  List<Object?> get props => [
        peopleStatus,
        peopleResults,
        carsStatus,
        ownerCars,
        ownerUsername,
        myCarsStatus,
        myCars,
      ];
}
