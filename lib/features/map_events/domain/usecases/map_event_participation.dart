import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/map_event_enums.dart';
import '../entities/map_event_participant.dart';
import '../repositories/map_events_repository.dart';

class RegisterCarParams {
  final String eventId;
  final String carId;

  const RegisterCarParams({required this.eventId, required this.carId});
}

/// `POST /{id}/cars`. Answers 409 when the event has finished, the deadline has
/// passed, or the entry list is full — the failure carries the server's own
/// message, which is what the UI shows.
@lazySingleton
class RegisterCarForMapEventUseCase
    implements UseCase<MapEventParticipantEntity, RegisterCarParams> {
  final MapEventsRepository repository;

  RegisterCarForMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventParticipantEntity>> call(
    RegisterCarParams params,
  ) {
    return repository.registerCar(params.eventId, params.carId);
  }
}

/// `DELETE /{id}/cars/{car_id}` — **pending registrations only**. An accepted
/// entry has to go through the withdrawal request flow instead.
@lazySingleton
class CancelCarRegistrationUseCase implements UseCase<Unit, RegisterCarParams> {
  final MapEventsRepository repository;

  CancelCarRegistrationUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RegisterCarParams params) {
    return repository.cancelCarRegistration(params.eventId, params.carId);
  }
}

class ReviewCarRegistrationParams {
  final String eventId;
  final String carId;

  /// Only [MapEventParticipation.accepted] and
  /// [MapEventParticipation.rejected] are accepted by the endpoint.
  final MapEventParticipation status;

  const ReviewCarRegistrationParams({
    required this.eventId,
    required this.carId,
    required this.status,
  });
}

/// `PATCH /{id}/cars/{car_id}` — the organizer's accept/reject on a pending
/// entry.
@lazySingleton
class ReviewCarRegistrationUseCase
    implements UseCase<MapEventParticipantEntity, ReviewCarRegistrationParams> {
  final MapEventsRepository repository;

  ReviewCarRegistrationUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventParticipantEntity>> call(
    ReviewCarRegistrationParams params,
  ) {
    return repository.reviewCarRegistration(
      params.eventId,
      params.carId,
      params.status,
    );
  }
}
