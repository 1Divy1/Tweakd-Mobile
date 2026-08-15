import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// One car's entry in an event — a row of `GET /map-events/{id}/cars` and of
/// `GET /{id}/cars/mine`.
///
/// The car is the garage module's [CarSummaryEntity]: the backend sends the
/// same `CarSummaryDto` here as it does in a garage, right down to `owner` and
/// `cover_image`, so there is nothing to duplicate.
class MapEventParticipantEntity extends Equatable {
  final CarSummaryEntity car;
  final MapEventParticipation status;
  final DateTime registeredAt;

  /// Why an organizer turned this car away. Non-null only alongside
  /// [MapEventParticipation.rejected] — the backend requires a reason to
  /// reject, so a declined entry always has one to quote.
  final String? rejectionReason;

  const MapEventParticipantEntity({
    required this.car,
    required this.status,
    required this.registeredAt,
    required this.rejectionReason,
  });

  bool get isAccepted => status == MapEventParticipation.accepted;
  bool get isPending => status == MapEventParticipation.pending;
  bool get isWithdrawn => status == MapEventParticipation.withdrawn;
  bool get isRejected => status == MapEventParticipation.rejected;

  @override
  List<Object?> get props => [car, status, registeredAt, rejectionReason];
}
