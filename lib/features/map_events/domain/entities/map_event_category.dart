import 'package:equatable/equatable.dart';

/// An event category the backend actually accepts, from
/// `GET /map-events/categories`. Today the list holds exactly one entry,
/// `car_meet`.
///
/// The greyed-out `SOON` chips in the create flow (Track Day, Car Show, Cruise)
/// are **not** these — they're hardcoded client-side, because `/categories`
/// only ever returns enabled ones.
class MapEventCategoryEntity extends Equatable {
  final String id;
  final String label;

  const MapEventCategoryEntity({required this.id, required this.label});

  /// The one category with extra required fields — a car meet must carry a
  /// registration deadline.
  static const carMeetId = 'car_meet';

  bool get isCarMeet => id == carMeetId;

  @override
  List<Object?> get props => [id, label];
}
