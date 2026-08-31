import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/organizer_candidate.dart';

sealed class CreateMapEventEvent extends Equatable {
  const CreateMapEventEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the enabled category list and, in edit mode, seeds the form from
/// [editEvent].
class LoadCreateEventRefs extends CreateMapEventEvent {
  final MapEventEntity? editEvent;

  const LoadCreateEventRefs({this.editEvent});

  @override
  List<Object?> get props => [editEvent];
}

/// One event per field rather than a single "form changed" with everything on
/// it: the form is long, and a per-field event keeps each change legible in the
/// bloc log.
class ChangeEventTitle extends CreateMapEventEvent {
  final String value;
  const ChangeEventTitle(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventCategory extends CreateMapEventEvent {
  final String categoryId;
  const ChangeEventCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class ChangeEventDescription extends CreateMapEventEvent {
  final String value;
  const ChangeEventDescription(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventLocationName extends CreateMapEventEvent {
  final String value;
  const ChangeEventLocationName(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventPosition extends CreateMapEventEvent {
  final GeoPosition position;
  const ChangeEventPosition(this.position);
  @override
  List<Object?> get props => [position];
}

class ChangeEventStart extends CreateMapEventEvent {
  final DateTime value;
  const ChangeEventStart(this.value);
  @override
  List<Object?> get props => [value];
}

/// Null clears the end time, which is how an open-ended event is expressed.
class ChangeEventEnd extends CreateMapEventEvent {
  final DateTime? value;
  const ChangeEventEnd(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventCapacity extends CreateMapEventEvent {
  final int? value;
  const ChangeEventCapacity(this.value);
  @override
  List<Object?> get props => [value];
}

class ToggleEventApproval extends CreateMapEventEvent {
  final bool value;
  const ToggleEventApproval(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventDeadline extends CreateMapEventEvent {
  final DateTime? value;
  const ChangeEventDeadline(this.value);
  @override
  List<Object?> get props => [value];
}

class ChangeEventCover extends CreateMapEventEvent {
  final CompressedImage? image;
  const ChangeEventCover(this.image);
  @override
  // CompressedImage holds a Future, so it isn't comparable; the path is.
  List<Object?> get props => [image?.path];
}

class AddEventRule extends CreateMapEventEvent {
  const AddEventRule();
}

class ChangeEventRule extends CreateMapEventEvent {
  final int index;
  final String value;
  const ChangeEventRule(this.index, this.value);
  @override
  List<Object?> get props => [index, value];
}

class RemoveEventRule extends CreateMapEventEvent {
  final int index;
  const RemoveEventRule(this.index);
  @override
  List<Object?> get props => [index];
}

/// Queues a co-organizer. In create mode they're added after the event exists
/// (`POST /{id}/organizers` needs an id); in edit mode the call goes out
/// straight away.
class AddEventOrganizer extends CreateMapEventEvent {
  final OrganizerCandidateEntity candidate;
  const AddEventOrganizer(this.candidate);
  @override
  List<Object?> get props => [candidate];
}

class RemoveEventOrganizer extends CreateMapEventEvent {
  /// The candidate's `referenceId` while queued, or the organizer row id once
  /// the event exists.
  final String id;

  const RemoveEventOrganizer(this.id);

  @override
  List<Object?> get props => [id];
}

class SubmitMapEvent extends CreateMapEventEvent {
  const SubmitMapEvent();
}

class ClearCreateEventError extends CreateMapEventEvent {
  const ClearCreateEventError();
}
