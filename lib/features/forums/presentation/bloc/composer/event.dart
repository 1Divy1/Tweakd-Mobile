import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

sealed class NewThreadEvent extends Equatable {
  const NewThreadEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the composer's reference data: topics, the brand catalog and the
/// user's garage (for the "from your garage" suggestion).
class LoadNewThreadRefs extends NewThreadEvent {
  const LoadNewThreadRefs();
}

/// Filters the brand list (local, the catalog is already loaded).
class NewThreadBrandQueryChanged extends NewThreadEvent {
  final String query;
  const NewThreadBrandQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
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

/// Filters the selected brand's model list (local).
class NewThreadModelQueryChanged extends NewThreadEvent {
  final String query;
  const NewThreadModelQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
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

/// Picks one of the user's garage cars (resolved against the catalog).
class SelectGarageCar extends NewThreadEvent {
  final CarSummaryEntity car;
  const SelectGarageCar(this.car);

  @override
  List<Object?> get props => [car];
}

/// Toggles a topic chip, capped at 10 selections.
class ToggleNewThreadTopic extends NewThreadEvent {
  final String topicId;
  const ToggleNewThreadTopic(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

/// Creates the thread.
class SubmitNewThread extends NewThreadEvent {
  final String title;
  final String content;
  const SubmitNewThread({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}
