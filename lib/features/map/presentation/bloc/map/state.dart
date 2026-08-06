import 'package:equatable/equatable.dart';

import '../../../domain/entities/business_detail_entity.dart';
import '../../../domain/entities/business_pin_entity.dart';
import '../../../domain/entities/geo_position.dart';
import '../../utils/map_error_mapper.dart';

/// Lifecycle of the pin data. Unlike the app's list pages the map never swaps
/// itself out for a full-screen error view — a failed fetch keeps whatever pins
/// are already on the map and raises a dismissible banner instead.
enum MapStatus { initial, loading, loaded, failure }

/// Lifecycle of the tapped business's profile, which drives the popup.
enum BusinessDetailStatus { idle, loading, loaded, failure }

/// A one-shot "fly the camera here" request.
///
/// The map is an imperative controller, so this can't be expressed as plain
/// state — [seq] increments on every request so a `BlocListener` can tell a
/// fresh command from a rebuild carrying the same target.
class MapCameraCommand extends Equatable {
  final GeoPosition target;
  final int seq;

  const MapCameraCommand({required this.target, required this.seq});

  @override
  List<Object?> get props => [target, seq];
}

class MapState extends Equatable {
  final MapStatus status;

  /// Centre of the most recent successful fetch. Null until the first one
  /// lands; used to decide whether a settled camera is worth refetching for.
  final GeoPosition? fetchCentre;

  /// False when [fetchCentre] came from [kMapFallbackCentre] rather than a real
  /// device fix — the recentre button uses this to know it has work to do.
  final bool hasDeviceLocation;

  final List<BusinessPinEntity> businesses;

  /// Banner over the map. Never replaces the map itself.
  final MapErrorCode? errorCode;

  final MapCameraCommand? cameraCommand;

  final String? selectedBusinessId;
  final BusinessDetailStatus detailStatus;
  final BusinessDetailEntity? selectedBusiness;
  final MapErrorCode? detailErrorCode;

  const MapState({
    this.status = MapStatus.initial,
    this.fetchCentre,
    this.hasDeviceLocation = false,
    this.businesses = const [],
    this.errorCode,
    this.cameraCommand,
    this.selectedBusinessId,
    this.detailStatus = BusinessDetailStatus.idle,
    this.selectedBusiness,
    this.detailErrorCode,
  });

  bool get isPopupOpen => selectedBusinessId != null;

  /// The tapped pin, available immediately from the already-loaded list so the
  /// popup can show a name and logo while the full profile is still in flight.
  BusinessPinEntity? get selectedPin {
    final id = selectedBusinessId;
    if (id == null) return null;
    for (final b in businesses) {
      if (b.id == id) return b;
    }
    return null;
  }

  MapState copyWith({
    MapStatus? status,
    GeoPosition? fetchCentre,
    bool? hasDeviceLocation,
    List<BusinessPinEntity>? businesses,
    MapErrorCode? errorCode,
    bool clearError = false,
    MapCameraCommand? cameraCommand,
    String? selectedBusinessId,
    BusinessDetailStatus? detailStatus,
    BusinessDetailEntity? selectedBusiness,
    MapErrorCode? detailErrorCode,
    bool clearSelection = false,
    bool clearDetail = false,
  }) {
    final dropDetail = clearSelection || clearDetail;
    return MapState(
      status: status ?? this.status,
      fetchCentre: fetchCentre ?? this.fetchCentre,
      hasDeviceLocation: hasDeviceLocation ?? this.hasDeviceLocation,
      businesses: businesses ?? this.businesses,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      cameraCommand: cameraCommand ?? this.cameraCommand,
      selectedBusinessId:
          clearSelection ? null : (selectedBusinessId ?? this.selectedBusinessId),
      detailStatus: clearSelection
          ? BusinessDetailStatus.idle
          : (detailStatus ?? this.detailStatus),
      selectedBusiness:
          dropDetail ? selectedBusiness : (selectedBusiness ?? this.selectedBusiness),
      detailErrorCode:
          dropDetail ? detailErrorCode : (detailErrorCode ?? this.detailErrorCode),
    );
  }

  @override
  List<Object?> get props => [
        status,
        fetchCentre,
        hasDeviceLocation,
        businesses,
        errorCode,
        cameraCommand,
        selectedBusinessId,
        detailStatus,
        selectedBusiness,
        detailErrorCode,
      ];
}
