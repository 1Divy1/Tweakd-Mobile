import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../entities/map_event.dart';
import '../entities/map_event_enums.dart';
import '../repositories/map_events_repository.dart';

class SetMapEventAttendanceParams {
  final String eventId;
  final MapEventAttendance status;

  const SetMapEventAttendanceParams({
    required this.eventId,
    required this.status,
  });
}

/// `PUT /{id}/attendance` — idempotent, so re-sending the same status is
/// harmless and switching attending ↔ interested is a single call.
@lazySingleton
class SetMapEventAttendanceUseCase
    implements UseCase<MapEventEntity, SetMapEventAttendanceParams> {
  final MapEventsRepository repository;

  SetMapEventAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(
    SetMapEventAttendanceParams params,
  ) {
    return repository.setAttendance(params.eventId, params.status);
  }
}

/// `DELETE /{id}/attendance` — how a viewer un-RSVPs, i.e. taps the button
/// that's already active.
@lazySingleton
class ClearMapEventAttendanceUseCase implements UseCase<MapEventEntity, String> {
  final MapEventsRepository repository;

  ClearMapEventAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(String eventId) {
    return repository.clearAttendance(eventId);
  }
}
