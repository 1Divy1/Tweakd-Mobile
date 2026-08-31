import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:equatable/equatable.dart';

/// A pending "let me out" request, from the organizer-only
/// `GET /map-events/{id}/withdrawals`.
///
/// Grouped by owner rather than by car, because the participant withdraws
/// themselves as a whole: `POST /{id}/withdraw` flags *all* of the caller's
/// accepted rows at once, and the approve/reject endpoints are keyed by owner
/// id, not car id.
class MapEventWithdrawalRequestEntity extends Equatable {
  final String ownerId;
  final String ownerUsername;
  final String? ownerAvatarUrl;
  final List<CarSummaryEntity> cars;

  /// The optional message the participant left for the organizers.
  final String? note;

  const MapEventWithdrawalRequestEntity({
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerAvatarUrl,
    required this.cars,
    required this.note,
  });

  @override
  List<Object?> get props => [ownerId, ownerUsername, ownerAvatarUrl, cars, note];
}
