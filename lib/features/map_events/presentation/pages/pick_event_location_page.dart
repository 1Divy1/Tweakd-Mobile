import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:tweakd/features/map/domain/map_defaults.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/geocode_candidate.dart';
import '../../domain/usecases/map_event_reads.dart';
import '../utils/drop_pin_marker.dart';
import '../utils/map_event_error_mapper.dart';
import '../widgets/location_picker/address_form_sheet.dart';
import '../widgets/location_picker/drop_pin_hint.dart';
import '../widgets/location_picker/geocode_result_list.dart';

/// What the picker hands back: the coordinate the **user** tapped, plus the
/// address they typed.
///
/// Two separate things on purpose. [position] is user-generated content — the
/// point they placed by hand — while [addressLabel] is composed from their own
/// form input. Neither is copied from a geocoding response, which is what
/// keeps the event free of Mapbox data at rest.
class PickedEventLocation {
  final GeoPosition position;

  /// The three address fields, kept apart so the create wizard can show them
  /// on their own lines rather than re-splitting a joined string.
  final String city;
  final String street;
  final String number;

  const PickedEventLocation({
    required this.position,
    required this.city,
    required this.street,
    required this.number,
  });

  /// `"{street} {number}, {city}"` — what the event's `location_name` is set
  /// to. Composed here so the one format lives in one place.
  String get addressLabel {
    final line = [street, number].where((p) => p.isNotEmpty).join(' ');
    return [line, city].where((p) => p.isNotEmpty).join(', ');
  }
}

/// "SET LOCATION ON MAP" — search an address, then place the pin by hand.
///
/// The flow is three stages (see [_PickerStage]): fill the address form,
/// choose among up to five candidates, then drop a pin on the map. The last
/// stage is not skippable, and that is the point of the screen: a geocoder
/// result only aims the camera, and the coordinate the event is created with
/// is always one a person tapped. Storing Mapbox's own coordinates would need
/// their permanent-geocoding licence; a tap costs nothing and is more accurate
/// anyway, since the organizer knows whether the meet is in the yard or out
/// front.
///
/// Pushed with [showPickEventLocation]; returns null if the user backs out.
Future<PickedEventLocation?> showPickEventLocation(
  BuildContext context, {
  GeoPosition? initial,
  PickedEventLocation? initialAddress,
}) {
  return Navigator.of(context).push<PickedEventLocation>(
    MaterialPageRoute(
      builder: (_) => PickEventLocationPage(
        initial: initial,
        initialAddress: initialAddress,
      ),
    ),
  );
}

enum _PickerStage { form, results, placing }

class PickEventLocationPage extends StatefulWidget {
  /// Where a previously chosen pin sat, so re-opening the picker starts on it
  /// rather than back at the fallback city.
  final GeoPosition? initial;

  /// The address that pin was confirmed with. Seeds the three form fields, so
  /// re-opening and confirming doesn't hand back a blank address.
  final PickedEventLocation? initialAddress;

  const PickEventLocationPage({super.key, this.initial, this.initialAddress});

  @override
  State<PickEventLocationPage> createState() => _PickEventLocationPageState();
}

class _PickEventLocationPageState extends State<PickEventLocationPage> {
  MapboxMap? _map;
  PointAnnotationManager? _pins;
  PointAnnotation? _pin;

  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();

  var _stage = _PickerStage.form;

  /// Cached for the lifetime of this screen. Rejecting a location and going
  /// back to the list is free; the cache dies with the picker, so returning
  /// from the create form searches afresh rather than showing coordinates that
  /// may have moved on.
  List<GeocodeCandidateEntity> _results = const [];

  bool _isSearching = false;
  String? _searchError;
  CancelToken? _cancelToken;

  /// The coordinate the user tapped. Null until they do — and the confirm
  /// button stays disabled the whole time it is, which is the mechanism that
  /// stops a candidate's coordinate from ever being submitted.
  GeoPosition? _dropped;

  /// Built once and never rebuilt. [MapWidget] re-applies its `viewport` on
  /// every rebuild where the value isn't `identical` to the last one, and
  /// `CameraViewportState` has no `==` override — so a viewport constructed
  /// inside `build()` re-runs on every `setState` and drags the camera back to
  /// the start position. This page calls `setState` constantly (typing,
  /// searching, dropping the pin), so the field is what keeps the map still.
  /// Every deliberate camera move goes through [_map] instead.
  late final CameraViewportState _viewport = CameraViewportState(
    center: Point(
      coordinates: Position(
        (widget.initial ?? kMapFallbackCentre).lng,
        (widget.initial ?? kMapFallbackCentre).lat,
      ),
    ),
    zoom: widget.initial == null ? 12 : 17,
    // Flat and top-down: a pitched camera makes it ambiguous which ground
    // point a tap lands on.
    pitch: 0,
    bearing: 0,
  );

  @override
  void initState() {
    super.initState();
    // Re-opening the picker on an existing pin: show it straight away, and
    // start in the placing stage so the user can adjust or confirm without
    // being made to search again.
    final address = widget.initialAddress;
    if (address != null) {
      _cityController.text = address.city;
      _streetController.text = address.street;
      _numberController.text = address.number;
    }
    if (widget.initial != null) {
      _dropped = widget.initial;
      _stage = _PickerStage.placing;
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  bool get _canSearch =>
      _cityController.text.trim().isNotEmpty &&
      _streetController.text.trim().isNotEmpty &&
      _numberController.text.trim().isNotEmpty;

  /// `"Strada Memorandumului 28, Cluj-Napoca"` — the user's own words, never
  /// the geocoder's `place_name`.
  String get _addressLabel {
    final street = _streetController.text.trim();
    final number = _numberController.text.trim();
    final city = _cityController.text.trim();
    final line = [street, number].where((p) => p.isNotEmpty).join(' ');
    return [line, city].where((p) => p.isNotEmpty).join(', ');
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;

    // A tap anywhere on the map is a pin drop. There are no other tappable
    // features on this screen, so unlike the browsing map there's nothing to
    // arbitrate against.
    map.addInteraction(
      TapInteraction.onMap((context) => _dropPin(context.point)),
      interactionID: 'pick-location-tap',
    );

    _pins = await map.annotations.createPointAnnotationManager();
    if (!mounted) return;

    // Restore the pin the picker was opened on.
    final existing = _dropped;
    if (existing != null) await _placeMarker(existing);
  }

  Future<void> _dropPin(Point point) async {
    final coordinates = point.coordinates;
    final position = GeoPosition(
      lat: coordinates.lat.toDouble(),
      lng: coordinates.lng.toDouble(),
    );

    setState(() {
      _dropped = position;
      _stage = _PickerStage.placing;
    });
    await _placeMarker(position);
  }

  /// Moves the single pin annotation, creating it the first time.
  ///
  /// The pin is a Mapbox annotation rather than a Flutter overlay so the
  /// renderer keeps it glued to its coordinate while the map moves; an overlay
  /// would need its screen position recomputed on every camera frame.
  Future<void> _placeMarker(GeoPosition position) async {
    final manager = _pins;
    if (manager == null) return;

    final geometry = Point(
      coordinates: Position(position.lng, position.lat),
    );

    final existing = _pin;
    if (existing != null) {
      existing.geometry = geometry;
      await manager.update(existing);
      return;
    }

    _pin = await manager.create(
      PointAnnotationOptions(
        geometry: geometry,
        image: await DropPinMarker.bytes(),
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );
  }

  Future<void> _onSearch() async {
    if (!_canSearch) return;
    FocusScope.of(context).unfocus();

    _cancelToken?.cancel();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    final result = await getIt<SearchMapEventLocationUseCase>()(
      SearchMapEventLocationParams(
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        addressNumber: _numberController.text.trim(),
        cancelToken: cancelToken,
      ),
    );

    if (!mounted || cancelToken != _cancelToken) return;
    final l10n = AppLocalizations.of(context)!;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        setState(() {
          _isSearching = false;
          _searchError = mapEventErrorMessage(
            l10n,
            MapEventErrorMapper.from(failure),
          );
        });
      },
      (candidates) {
        setState(() {
          _isSearching = false;
          _results = candidates;
          _searchError =
              candidates.isEmpty ? l10n.mapEventsLocationSearchNoResults : null;
          if (candidates.isNotEmpty) _stage = _PickerStage.results;
        });
      },
    );
  }

  /// Flies to a candidate and hands over to the user. Deliberately does *not*
  /// record the candidate's coordinate anywhere — it only aims the camera, and
  /// [_dropped] stays whatever the user last tapped (usually null).
  Future<void> _onCandidateSelected(GeocodeCandidateEntity candidate) async {
    setState(() => _stage = _PickerStage.placing);

    await _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(candidate.lng, candidate.lat)),
        zoom: 17,
      ),
      MapAnimationOptions(duration: 1100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dropped = _dropped;
    final isPlacing = _stage == _PickerStage.placing;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapWidget(
            key: const ValueKey('pickEventLocationMap'),
            styleUri: MapboxStyles.STANDARD,
            textureView: true,
            viewport: _viewport,
            onMapCreated: _onMapCreated,
          ),

          // Only while the user still has to place a pin. Once one exists the
          // annotation speaks for itself and a second pin would be confusing.
          if (isPlacing && dropped == null) const DropPinHint(),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.chevron_left_rounded, color: AppColors.ink),
                ),
              ),
            ),
          ),

          if (isPlacing)
            _PlacingBar(
              addressLabel: _addressLabel,
              dropped: dropped,
              canReturnToResults: _results.isNotEmpty,
              onBackToResults: () =>
                  setState(() => _stage = _PickerStage.results),
              onConfirm: dropped == null
                  ? null
                  : () => Navigator.of(context).pop(
                        PickedEventLocation(
                          position: dropped,
                          city: _cityController.text.trim(),
                          street: _streetController.text.trim(),
                          number: _numberController.text.trim(),
                        ),
                      ),
            )
          else
            _Sheet(
              child: _stage == _PickerStage.form
                  ? AddressFormSheet(
                      cityController: _cityController,
                      streetController: _streetController,
                      numberController: _numberController,
                      onChanged: (_) => setState(() {}),
                      canSearch: _canSearch,
                      isSearching: _isSearching,
                      error: _searchError,
                      onSearch: _onSearch,
                    )
                  : GeocodeResultList(
                      candidates: _results,
                      onSelected: _onCandidateSelected,
                      onEditSearch: () =>
                          setState(() => _stage = _PickerStage.form),
                    ),
            ),

          if (isPlacing && dropped == null)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.paddingOf(context).top + 60,
              child: _InstructionPill(text: l10n.mapEventsLocationDropPinTitle),
            ),
        ],
      ),
    );
  }
}

/// The rounded panel the form and the results list sit in.
class _Sheet extends StatelessWidget {
  final Widget child;

  const _Sheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, -4)),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          MediaQuery.paddingOf(context).bottom +
              MediaQuery.viewInsetsOf(context).bottom +
              16,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

/// The bottom bar of the placing stage: what was searched, whether a pin
/// exists, and the two ways out.
class _PlacingBar extends StatelessWidget {
  final String addressLabel;
  final GeoPosition? dropped;
  final bool canReturnToResults;
  final VoidCallback onBackToResults;
  final VoidCallback? onConfirm;

  const _PlacingBar({
    required this.addressLabel,
    required this.dropped,
    required this.canReturnToResults,
    required this.onBackToResults,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final position = dropped;

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      position == null
                          ? Icons.touch_app_outlined
                          : Icons.check_circle_rounded,
                      size: 17,
                      color: position == null
                          ? AppColors.mute
                          : AppColors.accent,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        position == null
                            ? l10n.mapEventsLocationDropPinBody
                            : l10n.mapEventsLocationPinDropped,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: position == null
                              ? AppColors.ink2
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                if (addressLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    addressLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (canReturnToResults) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBackToResults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: AppColors.surface,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: Text(l10n.mapEventsLocationBackToResults),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.line,
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
        ],
      ),
    );
  }
}

class _InstructionPill extends StatelessWidget {
  final String text;

  const _InstructionPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}
