import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:car_social_media_app/features/map/domain/map_defaults.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// "SET LOCATION ON MAP": a full-screen map with a fixed pin at the centre.
///
/// The pin doesn't move — the map does. That's the standard pattern for
/// coordinate picking, and it avoids the two problems a draggable marker has on
/// a phone: the finger covers the target, and a dragged annotation needs its
/// own hit-testing and drag state.
///
/// Pushed with [showPickEventLocation] and returns the chosen [GeoPosition], or
/// null if the user backs out.
Future<GeoPosition?> showPickEventLocation(
  BuildContext context, {
  GeoPosition? initial,
}) {
  return Navigator.of(context).push<GeoPosition>(
    MaterialPageRoute(
      builder: (_) => PickEventLocationPage(initial: initial),
    ),
  );
}

class PickEventLocationPage extends StatefulWidget {
  final GeoPosition? initial;

  const PickEventLocationPage({super.key, this.initial});

  @override
  State<PickEventLocationPage> createState() => _PickEventLocationPageState();
}

class _PickEventLocationPageState extends State<PickEventLocationPage> {
  MapboxMap? _map;

  /// Mirrors the camera so the confirm button always has a value, even before
  /// the user touches anything.
  late GeoPosition _centre = widget.initial ?? kMapFallbackCentre;

  Future<void> _onCameraIdle() async {
    final map = _map;
    if (map == null) return;
    try {
      final camera = await map.getCameraState();
      final coordinates = camera.center.coordinates;
      if (!mounted) return;
      setState(() {
        _centre = GeoPosition(
          lat: coordinates.lat.toDouble(),
          lng: coordinates.lng.toDouble(),
        );
      });
    } catch (_) {
      // A camera read that fails leaves the last known centre in place, which
      // is still a usable answer.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final start = widget.initial ?? kMapFallbackCentre;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapWidget(
            key: const ValueKey('pickEventLocationMap'),
            styleUri: MapboxStyles.STANDARD,
            textureView: true,
            // Flat and top-down, unlike the browsing map's pitched view: a
            // tilted camera makes the centre pin ambiguous about which point
            // on the ground it marks.
            viewport: CameraViewportState(
              center: Point(coordinates: Position(start.lng, start.lat)),
              zoom: 15,
              pitch: 0,
              bearing: 0,
            ),
            onMapCreated: (map) => _map = map,
            onMapIdleListener: (_) => _onCameraIdle(),
          ),

          // The pin sits at the exact centre of the viewport. Offset up by half
          // its height so its *point*, not its middle, marks the spot.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 34),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: AppColors.accent,
                  shadows: [
                    Shadow(color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: () => context.pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.chevron_left_rounded, color: AppColors.ink),
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.mapEventsPickLocationHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.ink2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_centre.lat.toStringAsFixed(5)}, '
                        '${_centre.lng.toStringAsFixed(5)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_centre),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    child: Text(l10n.mapEventsUseThisLocation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
