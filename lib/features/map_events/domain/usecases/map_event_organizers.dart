import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../entities/map_event.dart';
import '../entities/map_event_enums.dart';
import '../entities/organizer_candidate.dart';
import '../repositories/map_events_repository.dart';

class SearchOrganizerCandidatesParams {
  final String query;
  final CancelToken? cancelToken;

  const SearchOrganizerCandidatesParams({
    required this.query,
    this.cancelToken,
  });
}

@lazySingleton
class SearchOrganizerCandidatesUseCase
    implements
        UseCase<List<OrganizerCandidateEntity>,
            SearchOrganizerCandidatesParams> {
  final MapEventsRepository repository;

  SearchOrganizerCandidatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrganizerCandidateEntity>>> call(
    SearchOrganizerCandidatesParams params,
  ) {
    return repository.searchOrganizers(
      params.query,
      cancelToken: params.cancelToken,
    );
  }
}

class AddMapEventOrganizerParams {
  final String eventId;
  final MapEventOrganizerType type;

  /// The candidate's `referenceId` — the repository routes it into `user_id`
  /// or `business_id` according to [type], since the backend rejects a body
  /// with both or neither set.
  final String referenceId;

  const AddMapEventOrganizerParams({
    required this.eventId,
    required this.type,
    required this.referenceId,
  });
}

@lazySingleton
class AddMapEventOrganizerUseCase
    implements UseCase<MapEventEntity, AddMapEventOrganizerParams> {
  final MapEventsRepository repository;

  AddMapEventOrganizerUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(
    AddMapEventOrganizerParams params,
  ) {
    final isBusiness = params.type == MapEventOrganizerType.business;
    return repository.addOrganizer(
      params.eventId,
      userId: isBusiness ? null : params.referenceId,
      businessId: isBusiness ? params.referenceId : null,
    );
  }
}

class RemoveMapEventOrganizerParams {
  final String eventId;

  /// The organizer **row** id, not the user or business id behind it.
  final String organizerId;

  const RemoveMapEventOrganizerParams({
    required this.eventId,
    required this.organizerId,
  });
}

@lazySingleton
class RemoveMapEventOrganizerUseCase
    implements UseCase<MapEventEntity, RemoveMapEventOrganizerParams> {
  final MapEventsRepository repository;

  RemoveMapEventOrganizerUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(
    RemoveMapEventOrganizerParams params,
  ) {
    return repository.removeOrganizer(params.eventId, params.organizerId);
  }
}
