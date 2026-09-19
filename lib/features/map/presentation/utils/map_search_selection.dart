import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';

import '../../domain/entities/business_pin_entity.dart';

/// What the search screen hands back to the map when a result is tapped. The
/// whole pin travels, not just an id: the result can be far outside the ring
/// the map has loaded, and a past event is never in it at all.
sealed class MapSearchSelection {
  const MapSearchSelection();
}

class MapSearchBusinessSelection extends MapSearchSelection {
  final BusinessPinEntity pin;

  const MapSearchBusinessSelection(this.pin);
}

class MapSearchEventSelection extends MapSearchSelection {
  final MapEventPinEntity pin;

  const MapSearchEventSelection(this.pin);
}
