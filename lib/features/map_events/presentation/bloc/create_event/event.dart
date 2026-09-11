import 'package:tweakd/core/services/image_service.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/organizer_candidate.dart';
import '../../pages/pick_event_location_page.dart';
import 'state.dart';

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

/// The whole result of the map picker: the pin plus the three address parts.
///
/// There is deliberately no event for typing a location by hand — the WHEN &
/// WHERE step has no venue text field, and `location_name` is always the
/// address composed from what the organizer entered in the picker.
class ChangeEventLocation extends CreateMapEventEvent {
  final PickedEventLocation picked;
  const ChangeEventLocation(this.picked);
  @override
  List<Object?> get props => [
        picked.position,
        picked.city,
        picked.street,
        picked.number,
      ];
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

/// Queues a contest for the event being created. Contests can only be created
/// against an event id, so — like organizers — these are held locally and
/// flushed once `POST /map-events` has landed.
class AddDraftContest extends CreateMapEventEvent {
  final PendingContest contest;
  const AddDraftContest(this.contest);
  @override
  List<Object?> get props => [contest];
}

class UpdateDraftContest extends CreateMapEventEvent {
  final PendingContest contest;
  const UpdateDraftContest(this.contest);
  @override
  List<Object?> get props => [contest];
}

class RemoveDraftContest extends CreateMapEventEvent {
  final String localId;
  const RemoveDraftContest(this.localId);
  @override
  List<Object?> get props => [localId];
}

/// Throws away the saved local draft and empties the form. Fired from the
/// wizard's "start over" affordance.
class DiscardEventDraft extends CreateMapEventEvent {
  const DiscardEventDraft();
}

class SubmitMapEvent extends CreateMapEventEvent {
  const SubmitMapEvent();
}

class ClearCreateEventError extends CreateMapEventEvent {
  const ClearCreateEventError();
}
