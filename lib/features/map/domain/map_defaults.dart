import 'entities/geo_position.dart';

/// Where the map looks when the device won't say where it is — permission
/// denied, location services off, or no fix. Cluj-Napoca, the app's home city.
const kMapFallbackCentre = GeoPosition(lat: 46.770439, lng: 23.591423);

/// Radius of the `/businesses/nearby` query, in kilometres. Fixed for now — the
/// backend caps it at 500.
const kMapSearchRadiusKm = 25.0;

/// Upper bound on pins per fetch. The backend caps it at 500; 200 is already
/// more markers than a phone screen can usefully show.
const kMapSearchLimit = 200;

/// How far the camera must travel from the last fetch centre before another
/// request is worth making. Roughly half the radius, so the rings overlap and
/// the user never pans into an empty area.
const kMapRefetchDistanceKm = 12.0;

/// Camera zoom when landing on a search result: close enough to single out the
/// one pin the user picked, with a few streets of context around it. The
/// overview zoom (12.5) would drop it among everything else nearby.
const kMapSearchResultZoom = 15.0;
