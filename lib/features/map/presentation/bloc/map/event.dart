import 'package:equatable/equatable.dart';

import '../../../domain/entities/geo_position.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the page mounts: resolve the user's position (falling back
/// to the default centre when it's unavailable) and load the first ring of
/// businesses around it.
class MapStarted extends MapEvent {
  const MapStarted();
}

/// The camera stopped moving. The bloc decides whether the new centre is far
/// enough from the last fetch to be worth another request — `onMapIdle` fires
/// after every pan, and most pans don't warrant one.
class MapCameraSettled extends MapEvent {
  final GeoPosition centre;

  const MapCameraSettled(this.centre);

  @override
  List<Object?> get props => [centre];
}

/// A pin was tapped: open the popup and fetch that business's full profile.
class MapBusinessSelected extends MapEvent {
  final String businessId;

  const MapBusinessSelected(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

/// The popup was dismissed (tap outside, close button, back).
class MapBusinessDismissed extends MapEvent {
  const MapBusinessDismissed();
}

/// Retry after a failed business fetch, from the popup's error state.
class MapBusinessDetailRetried extends MapEvent {
  const MapBusinessDetailRetried();
}

/// The "recentre on me" button. Re-asks for a fix and reloads around it.
class MapRecentreRequested extends MapEvent {
  const MapRecentreRequested();
}

/// Dismiss the error banner floating over the map.
class MapErrorDismissed extends MapEvent {
  const MapErrorDismissed();
}
