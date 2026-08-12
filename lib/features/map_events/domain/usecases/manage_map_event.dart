import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/map_event.dart';
import '../repositories/map_events_repository.dart';

// ── Create ─────────────────────────────────────────────────────────────────

class CreateMapEventParams {
  final String categoryId;
  final String title;
  final String description;
  final String locationName;
  final GeoPosition position;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool requiresParticipantApproval;

  /// Required for `car_meet`. The create form enforces that before this is
  /// ever built, so a null here on a car meet is a programming error the
  /// backend will answer with a 400.
  final DateTime? registrationDeadline;

  final int? maxParticipantCapacity;
  final List<String>? rules;

  const CreateMapEventParams({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.locationName,
    required this.position,
    required this.startsAt,
    this.endsAt,
    required this.requiresParticipantApproval,
    this.registrationDeadline,
    this.maxParticipantCapacity,
    this.rules,
  });
}

@lazySingleton
class CreateMapEventUseCase
    implements UseCase<MapEventEntity, CreateMapEventParams> {
  final MapEventsRepository repository;

  CreateMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(CreateMapEventParams params) {
    return repository.createEvent(
      categoryId: params.categoryId,
      title: params.title,
      description: params.description,
      locationName: params.locationName,
      position: params.position,
      startsAt: params.startsAt,
      endsAt: params.endsAt,
      requiresParticipantApproval: params.requiresParticipantApproval,
      registrationDeadline: params.registrationDeadline,
      maxParticipantCapacity: params.maxParticipantCapacity,
      rules: params.rules,
    );
  }
}

// ── Update (pending/rejected only) ─────────────────────────────────────────

class UpdateMapEventParams {
  final String eventId;
  final String? title;
  final String? description;
  final String? locationName;
  final GeoPosition? position;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool? requiresParticipantApproval;
  final DateTime? registrationDeadline;
  final int? maxParticipantCapacity;

  const UpdateMapEventParams({
    required this.eventId,
    this.title,
    this.description,
    this.locationName,
    this.position,
    this.startsAt,
    this.endsAt,
    this.requiresParticipantApproval,
    this.registrationDeadline,
    this.maxParticipantCapacity,
  });
}

@lazySingleton
class UpdateMapEventUseCase
    implements UseCase<MapEventEntity, UpdateMapEventParams> {
  final MapEventsRepository repository;

  UpdateMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(UpdateMapEventParams params) {
    return repository.updateEvent(
      params.eventId,
      title: params.title,
      description: params.description,
      locationName: params.locationName,
      position: params.position,
      startsAt: params.startsAt,
      endsAt: params.endsAt,
      requiresParticipantApproval: params.requiresParticipantApproval,
      registrationDeadline: params.registrationDeadline,
      maxParticipantCapacity: params.maxParticipantCapacity,
    );
  }
}

// ── Rules (full replace) ───────────────────────────────────────────────────

class ReplaceMapEventRulesParams {
  final String eventId;

  /// Max 50 entries, each non-blank and ≤300 characters. Order becomes
  /// `sort_order`; an empty list clears every rule.
  final List<String> rules;

  const ReplaceMapEventRulesParams({
    required this.eventId,
    required this.rules,
  });
}

@lazySingleton
class ReplaceMapEventRulesUseCase
    implements UseCase<MapEventEntity, ReplaceMapEventRulesParams> {
  final MapEventsRepository repository;

  ReplaceMapEventRulesUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(
    ReplaceMapEventRulesParams params,
  ) {
    return repository.replaceRules(params.eventId, params.rules);
  }
}

// ── Cover image ────────────────────────────────────────────────────────────

@lazySingleton
class GetMapEventCoverUploadUrlUseCase
    implements UseCase<({String key, String uploadUrl}), String> {
  final MapEventsRepository repository;

  GetMapEventCoverUploadUrlUseCase(this.repository);

  @override
  Future<Either<Failure, ({String key, String uploadUrl})>> call(
    String eventId,
  ) {
    return repository.getCoverUploadUrl(eventId);
  }
}

class SetMapEventCoverParams {
  final String eventId;

  /// The `events/{id}/{uuid}.webp` key handed back by the storage module —
  /// never a URL, and never reconstructed by the client.
  final String key;

  const SetMapEventCoverParams({required this.eventId, required this.key});
}

@lazySingleton
class SetMapEventCoverUseCase
    implements UseCase<MapEventEntity, SetMapEventCoverParams> {
  final MapEventsRepository repository;

  SetMapEventCoverUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(SetMapEventCoverParams params) {
    return repository.setCover(params.eventId, params.key);
  }
}

// ── Lifecycle ──────────────────────────────────────────────────────────────

@lazySingleton
class CancelMapEventUseCase implements UseCase<MapEventEntity, String> {
  final MapEventsRepository repository;

  CancelMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(String eventId) {
    return repository.cancelEvent(eventId);
  }
}

@lazySingleton
class FinishMapEventUseCase implements UseCase<MapEventEntity, String> {
  final MapEventsRepository repository;

  FinishMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(String eventId) {
    return repository.finishEvent(eventId);
  }
}

@lazySingleton
class DeleteMapEventUseCase implements UseCase<Unit, String> {
  final MapEventsRepository repository;

  DeleteMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}
