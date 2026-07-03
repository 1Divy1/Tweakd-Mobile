import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';

import 'state.dart';

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

/// Live model search across the brand catalog.
class NewThreadCarQueryChanged extends NewThreadEvent {
  final String query;
  const NewThreadCarQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Picks a model from the suggestion list.
class SelectNewThreadCar extends NewThreadEvent {
  final ComposerCarOption option;
  const SelectNewThreadCar(this.option);

  @override
  List<Object?> get props => [option];
}

/// Picks one of the user's garage cars (resolved against the catalog).
class SelectGarageCar extends NewThreadEvent {
  final CarSummaryEntity car;
  const SelectGarageCar(this.car);

  @override
  List<Object?> get props => [car];
}

/// Clears the tagged car.
class ClearNewThreadCar extends NewThreadEvent {
  const ClearNewThreadCar();
}

/// Toggles a topic chip (component or format), capped at 10 selections.
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
