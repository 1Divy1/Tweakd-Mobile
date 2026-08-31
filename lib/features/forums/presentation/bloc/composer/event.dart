import 'package:equatable/equatable.dart';

import 'package:tweakd/core/shared/entities/tag_selection.dart';
import 'package:tweakd/features/garage/domain/entities/reference_data.dart';

sealed class NewThreadEvent extends Equatable {
  const NewThreadEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the composer's reference data: topics and the brand catalog.
class LoadNewThreadRefs extends NewThreadEvent {
  const LoadNewThreadRefs();
}

/// Picks a brand and loads that brand's models.
class SelectNewThreadBrand extends NewThreadEvent {
  final CarBrandEntity brand;
  const SelectNewThreadBrand(this.brand);

  @override
  List<Object?> get props => [brand];
}

/// Clears the brand — and with it the model, which can't outlive its brand.
class ClearNewThreadBrand extends NewThreadEvent {
  const ClearNewThreadBrand();
}

/// Picks a model of the selected brand (optional refinement).
class SelectNewThreadModel extends NewThreadEvent {
  final CarModelEntity model;
  const SelectNewThreadModel(this.model);

  @override
  List<Object?> get props => [model];
}

/// Drops back to a brand-only tag, keeping the brand.
class ClearNewThreadModel extends NewThreadEvent {
  const ClearNewThreadModel();
}

/// Toggles a topic chip, capped at 10 selections.
class ToggleNewThreadTopic extends NewThreadEvent {
  final String topicId;
  const ToggleNewThreadTopic(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

/// Mentions a person in the thread. Ignored past the backend's 30-tag cap.
class AddNewThreadTagPerson extends NewThreadEvent {
  final TaggedPerson person;
  const AddNewThreadTagPerson(this.person);

  @override
  List<Object?> get props => [person.id];
}

/// Un-mentions a person — their cars go with them (own cars stay).
class RemoveNewThreadTagPerson extends NewThreadEvent {
  final String personId;
  const RemoveNewThreadTagPerson(this.personId);

  @override
  List<Object?> get props => [personId];
}

/// Tags a car picked from a mentioned person's garage, or from the viewer's.
class AddNewThreadTagCar extends NewThreadEvent {
  final TaggedCar car;
  const AddNewThreadTagCar(this.car);

  @override
  List<Object?> get props => [car.id];
}

/// Removes one tagged car.
class RemoveNewThreadTagCar extends NewThreadEvent {
  final String carId;
  const RemoveNewThreadTagCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Creates the thread.
class SubmitNewThread extends NewThreadEvent {
  final String title;
  final String content;
  const SubmitNewThread({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}
