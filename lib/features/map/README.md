# map

The virtual map: a 3D Mapbox map showing **businesses**, **car meets**, **driving
roads** (as drawn lines), and eventually **live users/convoys**.

Powered by [`mapbox_maps_flutter`](https://pub.dev/packages/mapbox_maps_flutter)
`^2.27.0`, which wraps the native Mapbox Maps SDK v11 (iOS + Android only —
desktop unsupported, web only on the `3.0.0-alpha` line).

---

## 1. The mental model (read this first)

Maps are not "a widget with a list of markers". A Mapbox map is a **rendering
engine driven by a style**. Internalise these five nouns and everything else
follows:

| Noun | What it is | Our use |
|---|---|---|
| **Style** | A JSON document describing the whole map's look. Loaded by URI (`mapbox://styles/...`). The v3 "Standard" style is itself a *style import* you configure at runtime. | `MapboxStyles.STANDARD` — gives 3D buildings, lighting presets and shadows for free. |
| **Source** | Where data comes from. `GeoJsonSource` = our own data (points/lines) as GeoJSON. | One source per domain layer: businesses, meets, roads, live users. |
| **Layer** | *How* a source is drawn. A source with no layer renders nothing; one source can feed many layers. `SymbolLayer` (icons/text), `CircleLayer`, `LineLayer`, `ModelLayer` (3D glTF), `FillExtrusionLayer`. | `SymbolLayer` for pins, `LineLayer` for roads, `ModelLayer` for cars. |
| **Camera** | Where the viewer is: `center`, `zoom`, `bearing` (rotation), `pitch` (tilt — **pitch > 0 is what makes it look 3D**). | Default pitch ~45–55°. |
| **Expression** | A JSON mini-language evaluated per feature/zoom, e.g. `["get","name"]`, `["interpolate",["linear"],["zoom"],10,4,16,12]`. Data-driven styling without Dart code. | Icon per business category, line width by zoom. |

**The single most important architectural decision:** there are two ways to put
things on the map, and you should pick per micro-feature.

### Annotations vs. style layers

```
AnnotationManager (PointAnnotationManager, PolylineAnnotationManager, …)
  + Dead simple: create objects, attach a tap callback, done.
  + Per-annotation Dart click listeners.
  − Slow past a few hundred objects.
  − NO clustering. NO data-driven expressions.

GeoJsonSource + Layer
  + Fast with thousands of features (rendered natively, never crosses the bridge per-item).
  + Clustering, expressions, zoom-dependent styling, 3D models.
  − More code; tap handling goes through the Interactions API / queryRenderedFeatures.
```

> Mapbox's own guidance: use style layers "for the large amount of annotations
> (e.g. hundreds and thousands of them)".

**Recommendation for this app: use `GeoJsonSource` + layers for everything.**
A map of businesses/meets/roads across a country is exactly the "thousands of
features, needs clustering" case, and mixing the two APIs means two tap systems
and two styling systems. Annotations are only worth it for one-off ephemeral
things (e.g. a draggable pin while the user is *creating* a meet).

---

## 2. Setup & gotchas

### 2.1 Two different tokens — this trips everyone up

| Token | Scope | Where it goes | What breaks without it |
|---|---|---|---|
| **Public** (`pk.…`) | default | Runtime, via `MapboxOptions.setAccessToken()` | Map tiles never load (blank/grey map) |
| **Secret** (`sk.…`) | `Downloads: Read` | **Build machine**, not the repo | The *build itself* fails — the native SDK binaries are fetched from Mapbox's private maven/CocoaPods registry |

The secret token is a build-time credential, created at
<https://account.mapbox.com/access-tokens/> with the `DOWNLOADS:READ` scope checked.

- **iOS** — `~/.netrc` (home dir, *not* the project):
  ```
  machine api.mapbox.com
    login mapbox
    password sk.eyJ1...
  ```
  Symptom if missing: `Error installing Mapbox-iOS-SDK curl: (22) … 401 Unauthorized` on `pod install`.
- **Android** — `~/.gradle/gradle.properties`:
  ```
  SDK_REGISTRY_TOKEN=sk.eyJ1...
  ```
  (The plugin's `android/build.gradle` reads `System.getenv("SDK_REGISTRY_TOKEN")`
  then `project.findProperty("SDK_REGISTRY_TOKEN")`.)

Every developer and every CI runner needs this. Document it in the repo's setup
instructions.

### 2.2 The public token in `main.dart` — make it `const`

Current code:

```dart
MapboxOptions.setAccessToken(String.fromEnvironment("MAPBOX_ACCESS_TOKEN"));
```

`String.fromEnvironment` is a **const constructor**; `--dart-define` values are
baked in at compile time. Invoked non-const it is only *guaranteed* to return the
default (`""`) — this is a documented Dart footgun and the classic cause of
"works in debug, blank map in release". Write it as:

```dart
const mapboxToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
MapboxOptions.setAccessToken(mapboxToken);
```

Note this feature is the one place in the app that uses `--dart-define` instead
of `.env`/`dotenv` — that's fine (the token must be compile-time), but it means
`flutter run` **must** be given `--dart-define-from-file=dart_defines.dev.json`
or the map silently fails. Wire it into `.vscode/launch.json` so nobody forgets.

`pk.…` tokens are designed to ship inside apps, so committing
`dart_defines.*.json` is not a credential leak — but add a **URL restriction** on
the token in the Mapbox dashboard so it can't be scraped and used elsewhere, and
never let an `sk.…` token near these files.

### 2.3 Platform config

- **Min versions**: iOS 14+, Android `minSdk` 21+.
- **Permissions** — needed for the location puck / live convoy:
  - `AndroidManifest.xml`: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
  - `Info.plist`: `NSLocationWhenInUseUsageDescription` (+
    `NSLocationAlwaysAndWhenInUseUsageDescription` only if convoy tracking must
    survive backgrounding — that's an App Review conversation, defer it).
  - Request at runtime with `permission_handler`
    (`Permission.locationWhenInUse.request()`), which is already the pattern for
    photos in this app.
- **Billing**: Mapbox charges per *map load* (a `MapWidget` mount). Keep the map
  page alive across tab switches rather than rebuilding it, and don't mount a
  `MapWidget` in list cells.

---

## 3. The 3D look

The Standard style (`MapboxStyles.STANDARD`) already contains 3D buildings,
landmarks, trees and real-time shadows. You mainly *configure* it.

```dart
MapWidget(
  key: const ValueKey('mapWidget'),
  styleUri: MapboxStyles.STANDARD,
  textureView: true,                       // recommended on Android
  cameraOptions: CameraOptions(
    center: Point(coordinates: Position(lng, lat)),
    zoom: 16,
    pitch: 55,                             // the tilt = the 3D feel
    bearing: 20,
  ),
  onMapCreated: _onMapCreated,
  onStyleLoadedListener: _onStyleLoaded,   // add sources/layers HERE, never earlier
)
```

Runtime configuration of the basemap import:

```dart
mapboxMap.style.setStyleImportConfigProperties('basemap', {
  'lightPreset': 'dusk',        // dawn | day | dusk | night — drives shadow dir + colour temp
  'theme': 'monochrome',        // default | faded | monochrome
  'show3dObjects': true,
  'showPointOfInterestLabels': false,   // hide Mapbox POIs so OUR pins stand out
  'showTransitLabels': false,
  'colorBuildingHighlight': 'hsl(214, 94%, 59%)',
});
```

Tweakd drives `lightPreset` off the app theme, not the clock: light → `day`,
dark → `night` (`presentation/utils/map_light_preset.dart`), and relights live
when the theme changes.

For full manual control of shadows there's `style.setLights(...)` with
`AmbientLight` + `DirectionalLight(castShadows: true)`, but the presets are
almost always enough — reach for explicit lights only if the default shadows
fight the app's palette.

### 3D car models

Two separate mechanisms, don't confuse them:

**A. The user's own car = the location puck.** Replace the blue dot with a glTF model:

```dart
mapboxMap.location.updateSettings(LocationComponentSettings(
  enabled: true,
  puckBearingEnabled: true,
  locationPuck: LocationPuck(
    locationPuck3D: LocationPuck3D(
      modelUri: 'asset://assets/models/sportcar.glb',
      modelScale: [12, 12, 12],   // tune by eye; scale is in metres-ish, varies per model
    ),
  ),
));
```

Then `FollowPuckViewportState` (via `MapboxMap.viewport`) makes the camera chase
the car; `IdleViewportState` releases it when the user pans.

**B. Other users' cars = a `ModelLayer` over a `GeoJsonSource`.**

```dart
await mapboxMap.style.addStyleModel('car-model', 'asset://assets/models/sportcar.glb');
await mapboxMap.style.addSource(GeoJsonSource(id: 'live-users', data: geoJsonString));

final layer = ModelLayer(id: 'live-users-layer', sourceId: 'live-users')
  ..modelId = 'car-model'
  ..modelScale = [4, 4, 4]
  ..modelRotation = [0, 0, 90]      // z-rotation = heading; drive from the feature via expression
  ..modelType = ModelType.COMMON_3D;
await mapboxMap.style.addLayer(layer);
```

`modelId` also accepts a URL, so per-user car models could later be served from
R2 — but ship with 2–3 bundled `.glb` silhouettes first. Keep models under a few
hundred KB; glTF/glb only, and a 3D model per user is the fastest way to tank
frame rate, so cap how many render at once (filter by viewport bounds).

---

## 4. Structuring the feature (clean architecture)

The skeleton already matches the project's convention. Fill it in like this:

```
features/map/
├── domain/
│   ├── entities/
│   │   ├── map_bounds.dart            LatLng + bounding box value objects
│   │   ├── map_marker_entity.dart     sealed base: id, position, kind
│   │   ├── business_entity.dart       ─┐
│   │   ├── car_meet_entity.dart        ├─ the three "pin" kinds
│   │   ├── driving_road_entity.dart   ─┘  (road holds List<Position> path)
│   │   └── live_user_entity.dart      userId, position, heading, carModelId
│   ├── repositories/map_repository.dart
│   └── usecases/
│       ├── get_businesses_in_bounds.dart
│       ├── get_car_meets_in_bounds.dart
│       ├── get_driving_roads_in_bounds.dart
│       └── watch_live_users.dart      → Stream, not Future
├── data/
│   ├── models/   *_model.dart (snake_case fromJson) + geo_json_mapper.dart
│   ├── datasources/
│   │   ├── map_api_data_source.dart        Spring backend, REST
│   │   └── live_users_realtime_data_source.dart   Supabase Broadcast/Presence
│   └── repositories/map_repository_impl.dart
└── presentation/
    ├── bloc/map/            MapBloc — see §5
    ├── pages/map_page.dart  MapWidget + AppBottomNav(activeTab: .map)
    ├── widgets/
    │   ├── map_view.dart               the MapWidget itself
    │   ├── map_layer_controller.dart   ★ imperative bridge, see below
    │   ├── map_filter_bar.dart         toggle businesses / meets / roads
    │   ├── business_detail_sheet.dart  bottom sheets on tap
    │   ├── car_meet_detail_sheet.dart
    │   └── driving_road_detail_sheet.dart
    └── utils/map_error_mapper.dart
```

### The one place this feature bends the project's rules

Everywhere else in the app, state → widget rebuild. **A map does not rebuild.**
`MapboxMap` is an imperative native controller; re-creating the `MapWidget` on
every state change would reload the style, refetch tiles, cost a map load, and
flicker.

So introduce **`MapLayerController`** — a plain Dart class (not a widget) that
owns the `MapboxMap` instance and exposes intention-revealing methods:

```dart
class MapLayerController {
  MapLayerController(this._map);
  final MapboxMap _map;

  Future<void> installLayers();                       // once, on style loaded
  Future<void> setBusinesses(List<BusinessEntity> v); // → source.updateGeoJSON(...)
  Future<void> setCarMeets(List<CarMeetEntity> v);
  Future<void> setDrivingRoads(List<DrivingRoadEntity> v);
  Future<void> setLiveUsers(List<LiveUserEntity> v);
  Future<void> setLayerVisible(MapLayerKind kind, bool visible);
}
```

The page keeps a `BlocListener<MapBloc, MapState>` that pushes state *into* the
controller (`listener:` side effects), and a `BlocBuilder` only for the Flutter
chrome around the map (filter bar, loading pill, sheets). The `MapWidget` sits
inside a `const`/keyed subtree so it never rebuilds.

This keeps domain/data 100% conventional — only `presentation/widgets/` knows
Mapbox exists. Entities must **not** import `mapbox_maps_flutter`; convert
entity → GeoJSON in a `geo_json_mapper` in the data or presentation layer.

---

## 5. `MapBloc`

Map data is **viewport-scoped**, not cursor-paginated — a different shape from
the app's other blocs.

```
Events
  MapStarted                       load style config, request permission
  MapCameraSettled(bounds, zoom)   debounced ~400ms after the camera stops
  MapFilterToggled(kind)
  MapFeatureTapped(kind, id)
  LiveUsersStreamUpdated(users)    internal, from the Supabase subscription

State
  MapState {
    status, bounds, zoom,
    Set<MapLayerKind> visibleLayers,
    List<BusinessEntity> businesses,
    List<CarMeetEntity> meets,
    List<DrivingRoadEntity> roads,
    List<LiveUserEntity> liveUsers,
    MapMarkerEntity? selected,
    String? errorMessage,
  }
```

Rules that matter:

- **Debounce the camera.** `onCameraChangeListener` fires per frame. Use
  `EventTransformer` (`debounce` + `restartable`) or you'll DDoS your own backend.
- **Don't refetch on every pan.** Cache by tile/geohash bucket, or only refetch
  when the new bounds aren't contained in the last fetched bounds (padded ~20%).
- **Skip fetching below a min zoom** (e.g. zoom < 8) — return clusters/counts instead.
- **`restartable()` for the live-user stream** so it re-subscribes cleanly.
- Errors go through the standard pipeline: exception → `Failure` → `MapErrorMapper`.
  A map error should show a dismissible banner over a still-usable map, never
  replace the whole page with an error view.

---

## 6. Implementation recipes per micro-feature

Build them in this order — each one teaches what the next needs.

### 6.0 Businesses — as actually built

The businesses layer ships; this is the reference pattern every later layer
copies. Where it diverges from the sketch below, **this section wins.**

**Backend** — `${API_BASE_URL}/api/v1`, snake_case, JWT via `AuthInterceptor`:

```
GET /businesses/nearby?lat=&lng=&radius_km=&type=&limit=   → pins, nearest-first
GET /businesses/{id}                                        → full profile + hours
GET /businesses/types                                       → filter vocabulary (not consumed yet)
```

Not a bounding-box query — a **radius** query centred on a point, which is why
`MapBloc` tracks a `fetchCentre` rather than bounds. `radius_km` is fixed at
`kMapSearchRadiusKm` (25); the backend rejects >500 and `limit` >500 with a 400.

`GET /businesses/{id}` answers **404 for hidden businesses** (pending,
suspended, rejected) exactly as for deleted ones — deliberately
indistinguishable, so `BusinessNotFoundFailure` never gets a "this was
suspended" variant and the popup doesn't offer a retry for it.

**Location.** `geolocator` (foreground, one-shot, `LocationAccuracy.low` —
25 km doesn't need GPS-grade precision) behind `DeviceLocationDataSource`, which
re-throws every refusal as `LocationUnavailableException`. Denied or unavailable
falls back silently to `kMapFallbackCentre` (Cluj-Napoca); only the explicit
recentre button surfaces the refusal as a banner. Permissions are declared in
`Info.plist` (`NSLocationWhenInUseUsageDescription`) and `AndroidManifest.xml`
(`ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`) — no background location.

**Refetch on pan.** `onMapIdle` → `MapCameraSettled(centre)` → refetch only once
the camera has moved `kMapRefetchDistanceKm` (12 km) from the last fetch centre.
`onMapIdle` beats debouncing `onCameraChange`: it fires once per gesture instead
of once per frame, so there's nothing to debounce.

**Markers are rasterised, not widgets.** The design is "the business's logo in a
white circle", and a Mapbox symbol is a registered raster image — so
`BusinessMarkerFactory` fetches each logo with plain `http` (*not* the app's Dio:
`AuthInterceptor` would leak the user's JWT to the CDN), composites shadow +
ring + circle-cropped logo on a `Canvas`, and hands the premultiplied RGBA to
`style.addStyleImage` under the id `business-logo-<id>`.

Loading is progressive: pins render immediately on a shared placeholder image,
then logos stream in eight at a time and the source is re-pushed per batch as
they register. Registered ids are cached, so panning back never re-downloads.

**No clustering.** Clusters would hide the logos that are the whole point.
Instead `iconAllowOverlap: false` lets Mapbox drop colliding pins for free, and
`symbol-sort-key` = distance (−1 when selected) decides who survives a collision
— nearest businesses win, and the open popup's pin always does.

**Tap handling** is a single `TapInteraction.onMap` that calls
`queryRenderedFeatures` scoped to `businesses-pins` over a ±12 px box: a hit
selects, a miss dismisses the popup. One interaction, so nothing depends on
Mapbox's evaluation order between a pin interaction and a dismiss interaction —
and no Flutter barrier, so the map stays pannable while the popup is open.

**Turn-by-turn navigation** is the popup's one action. A pinned bar at the
bottom of the card (outside the scroll area, so it survives a long description)
opens a sheet listing Waze, Google Maps and — on iOS only — Apple Maps; tapping
an installed one deep-links straight into guidance, tapping a missing one opens
its store page. Details in §6.0b.

### 6.0b Navigating to a pin

`NavigationLauncherService` ([lib/core/services/navigation_launcher_service.dart](../../core/services/navigation_launcher_service.dart))
lives in `core/` rather than the map feature, because it is a device capability
like `ImageService`/`PushPermissionService` — and because meets, roads and
anything else with a coordinate will want it. It is injected with
`getIt<NavigationLauncherService>()` straight from the widget; there is no use
case, no `Either`, no bloc. Launching an external app is a UI side effect with a
boolean outcome, not domain logic, and routing it through the error pipeline
would buy nothing.

The UI is two widgets under `presentation/widgets/navigation/`:

| Widget | Role |
|---|---|
| `NavigateButton(position, label)` | Full-width accent button. Takes a bare `GeoPosition` + label, **not** a business — a car meet drops it in unchanged. |
| `showNavigationAppSheet(context, lat, lng, destinationLabel)` | The chooser. Probes what's installed, launches or sends to the store. |

Things that will bite if changed carelessly:

- **Deep links carry coordinates only, never the name or address.** A name makes
  the target app run its own search, which happily routes the driver to a
  different branch of the same chain.
- **Every link asks for navigation, not a preview** — `navigate=yes` (Waze),
  `google.navigation:q=…&mode=d` (Android), `dirflg=d` /
  `directionsmode=driving` (Apple / Google iOS). iOS Google Maps has no
  start-immediately parameter, so it lands on the directions screen with a Start
  button; that's the platform's ceiling, not a bug.
- **No origin is sent.** The navigation app uses its own live GPS fix, which is
  fresher than ours and needs no location permission from us.
- **`canLaunchUrl` is gated by the manifests.** iOS needs the scheme in
  `LSApplicationQueriesSchemes` (`comgooglemaps`, `waze`, `maps`), Android needs
  the package in `<queries>` (`com.waze`,
  `com.google.android.apps.maps`). Miss one and an installed app reports as
  missing — the failure is silent and looks like a probe bug.
- **Never probe Android with `geo:`.** Every maps app claims it, so Google Maps
  would report installed whenever *any* maps app is. Hence
  `google.navigation:q=0,0` as the probe.
- **Apple Maps is probed, not assumed.** It's been deletable since iOS 10.

### 6.1 Map events — as actually built

Events (car meets, with more categories to come) ship as the second pin layer.
They live in their own feature module, `lib/features/map_events/` — read
[its README](../map_events/README.md) for the domain, the backend contract and
the popup/detail/create screens. What follows is only the **map-side** half.

**Same machinery as businesses, two cosmetic differences.** `MapLayerController`
now carries both layers through one shared `_PinLayer` description (source id,
layer id, placeholder image id, image-id prefix) and one
`MapMarkerFactory` — the generalised `BusinessMarkerFactory`, which grew a
per-call ring colour and placeholder glyph so a single factory serves every
layer. Event markers show the event's **cover photo**, and the ring turns
**accent orange while the event is live**.

> The ring colour is baked into the bitmap, so it has to be part of the style
> image id (`map-event-cover-<id>-live`). Miss that and an event that goes live
> keeps the white-ringed image it was first registered with.

**Ordering and taps.** The events layer is installed *after* businesses, so it
draws on top; the single map-wide `TapInteraction` queries the event layer
first, then businesses, then falls through to "dismiss". A tap that hits both
belongs to the event.

**Independent failure.** `MapBloc` fires both `/nearby` requests on the same
camera-settled trigger and folds them separately: whichever succeeds updates its
pins, and only a failure of *both* raises the banner. One dead endpoint emptying
the other's layer would read as "there's nothing here" rather than "something
broke".

**No `distance_km` any more.** The backend dropped it from both nearby
endpoints. `setBusinesses`/`setEvents` take the fetch centre and compute
`symbol-sort-key` (collision priority) with `GeoPosition.distanceKmTo`; the
popups compute their displayed distance the same way, in km.

**The popup is the events feature's.** `MapFlutterOverlays` renders either
`BusinessPopup` or `MapEventPopup` — selection is mutually exclusive, so one
`AnimatedSwitcher` cross-fades between them. The event popup reads
`MapEventDetailBloc`, which the `/map` route provides alongside `MapBloc` and
which the full `/map-events/:id` page shares, so RSVP and participation logic
exists once.

**Top bar.** The search pill (opens `/map/search`, see §6.1c) plus the orange
**+** that opens the create-event flow.

### 6.1c Map search — as actually built

The pill in `MapTopBar` pushes **`/map/search`** (`MapSearchPage`) *over* the
map. That way the `MapWidget` below is never torn down, which matters because
Mapbox bills per map load. The route's `extra` is the centre to rank results
around (`MapState.fetchCentre`), and the page pops back with a
`MapSearchSelection`.

- **Backend**: `GET /businesses/search` and `GET /map-events/search`, both
  keyset-paged, nearest to the centre first, with **no radius**. Each kind
  pages separately, so there are two endpoints and not one combined response.
  The event pins' `status` is the **clock-derived** phase: nothing ever stores
  `live`. The contract lives in the Spring module READMEs (§ Map search).
- **Data/domain**: `SearchBusinessesUseCase` (this feature, `MapRepository`)
  and `SearchMapEventsUseCase` (`map_events`, `MapEventsRepository`). These
  sit beside their `/nearby` counterparts, and both reuse the existing pin
  models.
- **`MapSearchBloc`**: a 300 ms debounce and a 2-character minimum. It keeps
  two independent `MapSearchSection`s (events, businesses), and each has its
  own cancel token, cursor, and failure. A new query, chip change, or clear
  cancels the older request, and a late answer is dropped on arrival. The
  *Live / Upcoming / Past* chips are multi-select, default to live +
  upcoming, and the last one can't be turned off.
- **Landing on a result**: `MapSearchBusinessChosen` or `MapSearchEventChosen`
  selects the result, flies to it at `kMapSearchResultZoom`, and keeps the pin
  as `MapState.searchBusiness` / `searchEvent`. The layers draw
  `visibleBusinesses` / `visibleEvents` (the nearby list plus that pin, with no
  duplicates). The pin is needed because the result can be outside the loaded
  ring, and a **past event is never returned by `/nearby`**. The pin lives as
  long as its selection: dismissing the popup or tapping another pin drops it.
  An event result is also loaded into `MapEventDetailBloc`, the same way a
  tapped pin is.

### 6.1b Clustering, if a layer ever needs it

Neither shipped layer clusters — clusters would hide the logos and covers that
are the whole point, and `iconAllowOverlap: false` already declutters for free.
Should a future layer want it: one source per kind, `cluster: true`, three
layers per source (cluster circles, cluster count, unclustered pins):

```dart
await style.addSource(GeoJsonSource(
  id: 'businesses',
  data: '{"type":"FeatureCollection","features":[]}',
  cluster: true,
  clusterRadius: 50,
  clusterMaxZoom: 14,
));

await style.addLayer(CircleLayer(id: 'businesses-clusters', sourceId: 'businesses')
  ..filter = ['has', 'point_count']
  ..circleRadius = 18.0
  ..circleColor = AppColors.primary.value);

await style.addLayer(SymbolLayer(id: 'businesses-count', sourceId: 'businesses')
  ..filter = ['has', 'point_count']
  ..textField = '{point_count_abbreviated}'
  ..textSize = 12.0);

await style.addLayer(SymbolLayer(id: 'businesses-pins', sourceId: 'businesses')
  ..filter = ['!', ['has', 'point_count']]
  ..iconImage = '{category}-pin'       // per-feature icon from a property
  ..iconAllowOverlap = true);
```

Register pin PNGs once with `style.addStyleImage(...)` before the layer draws.
Feed the source with `(source as GeoJsonSource).updateGeoJSON(jsonString)` —
never remove and re-add the source, that flickers.

Clustering helpers you get for free: `getGeoJsonClusterExpansionZoom` (zoom to
fit on cluster tap), `getGeoJsonClusterLeaves` (list the members in a sheet).

Events already carry a **time** dimension, currently expressed as a ring colour
per liveness (§6.1). Filtering by `starts_at` with a style expression — so the
map can hide anything that's already over without a refetch — is the obvious
next step if the pin count ever gets uncomfortable.

### 6.2 Driving roads (lines)

This is where a road is genuinely a `LineString`, not two pins. The backend must
store an ordered coordinate array — the geometry *is* the data.

```dart
await style.addSource(GeoJsonSource(
  id: 'roads',
  data: geoJson,
  lineMetrics: true,      // required for line-gradient / line-trim-offset
));

await style.addLayer(LineLayer(id: 'roads-casing', sourceId: 'roads')
  ..lineWidth = 10.0 ..lineColor = Colors.black.value ..lineOpacity = 0.35
  ..lineJoin = LineJoin.ROUND ..lineCap = LineCap.ROUND);

await style.addLayer(LineLayer(id: 'roads-line', sourceId: 'roads')
  ..lineWidth = 6.0 ..lineJoin = LineJoin.ROUND ..lineCap = LineCap.ROUND
  ..lineColor = AppColors.primary.value);
```

Two layers (a wide dark "casing" under a narrow bright line) is the standard
trick that makes routes readable over any basemap.

Polish, cheap to add later:
- **Gradient by elevation/twistiness** — `line-gradient` expression over
  `["line-progress"]` (needs `lineMetrics: true`).
- **Animated reveal** on opening a road's detail — tween
  `style.setStyleLayerProperty('roads-line', 'line-trim-offset', [t, 1.0])`
  with an `AnimationController`, exactly as Mapbox's `animated_route_example`.
- **Simplify server-side.** A mountain road can be 10k points. Ship a
  Douglas–Peucker-simplified geometry at low zoom, full detail only in the
  detail view.

**How does a user *create* a road?** Three options, increasing effort:
1. Draw by tapping waypoints, then snap to real roads with the Mapbox
   **Map Matching API** (`/matching/v5`) — best result, separate REST call.
2. Record a GPS trace while driving, then simplify. Great fit for a car app.
3. Import GPX. Cheapest to build.

### 6.3 Live users / convoys (realtime)

Reuse the existing Supabase Realtime setup — this is the same problem as
presence/DMs, which already moved off Spring to Supabase Broadcast + Presence.

- **Transport**: a Supabase Realtime channel per convoy (or a geohash-bucketed
  channel for the open map), clients broadcasting their own
  `{lat, lng, heading, speed, car_model_id}`. Same client-authored-payload
  pattern as the DM migration.
- **Throttle hard**: broadcast at most 1–2 Hz. Never on every GPS fix.
- **Interpolate on the client**: raw 1 Hz points look like teleporting cars.
  Tween between the last two positions over the update interval with a
  `Ticker`, and push interpolated positions into the `ModelLayer`'s source with
  `updateGeoJSON` on each frame (or every other frame). This is what sells the
  "cars moving on the map" effect.
- **Heading**: drive `model-rotation`'s z-component from the feature's `heading`
  property via an expression, so cars point where they're going.
- **Privacy is a product decision, not an afterthought.** Location is the most
  sensitive data this app will handle. Bake in: opt-in only, visible only to
  followers/convoy members, a hard "go offline" switch, auto-expiry, and
  optionally coordinate fuzzing outside an active convoy. Decide the rules
  *before* writing the table.
- Only render live users in the current viewport, capped (e.g. 50).

---

## 7. Tap handling

Three mechanisms, pick by target:

1. **Standard-style features** (buildings, POIs, place labels) — the Interactions
   API with typed featuresets:
   ```dart
   mapboxMap.addInteraction(TapInteraction(StandardPOIs(), (feature, _) { … }));
   mapboxMap.addInteraction(LongTapInteraction.onMap((ctx) { … }));
   ```
   You can also set feature state (`setFeatureStateForFeaturesetFeature`) to
   highlight a tapped building — nice for a business's actual building.
2. **Our own layers** — `TapInteraction` scoped to a featureset, or
   `MapboxMap.queryRenderedFeatures(RenderedQueryGeometry.fromScreenCoordinate(...),
   RenderedQueryOptions(layerIds: ['businesses-pins', 'roads-line']))` inside a
   map tap listener, then read the feature's `id` property and dispatch
   `MapFeatureTapped`.
3. **Annotations** — per-manager click listeners (only if you use annotations).

`stopPropagation` controls whether a tap continues to lower interactions —
register our pins *before* the basemap POI interaction and stop propagation so a
tap on our pin doesn't also select a Mapbox POI.

---

## 8. Where the data lives, and who talks to whom

Settled by inspecting the live Supabase project (`Tweakd`, `fybgmaigzidhbmhbgfhu`):

- **Supabase Postgres *is* the app's database** — `posts`, `comments`,
  `forum_threads`, `cars`, `dm_messages` and every other domain table live there.
  Spring is an API layer over that same database, not a separate store.
- **PostGIS 3.3.7 is already installed** (`postgis`, schema `public` — that's why
  `spatial_ref_sys` shows up in the table list). Nothing to enable.
- `pgrouting` is available but not installed — relevant only if driving roads
  ever need graph routing rather than stored geometries.

So there is no "Supabase *or* Spring" choice to make. Geo tables go in the same
Postgres as everything else, with `geography(Point,4326)` /
`geography(LineString,4326)` columns and GIST indexes, and Flutter reaches them
**through Spring** exactly like posts and forums — same REST style, same
`AuthInterceptor` JWT, same snake_case, same error pipeline.

The one established exception carries over: **live user positions go over
Supabase Realtime directly**, the same way presence and DM delivery already do.
Ephemeral, high-frequency data has no business making a REST round trip.

### Talking to Mapbox

| Traffic | Route | Why |
|---|---|---|
| Map tiles, styles, fonts, sprites, 3D models | **Flutter → Mapbox directly** | Non-negotiable. The native SDK owns its own tile fetching, caching and prefetch. Proxying tiles would break caching, add latency, put your servers in the path of every pan, and violate the terms of service. |
| Mapbox **REST** APIs — Map Matching (snapping a drawn/recorded road to real roads), Geocoding (address → coords when a business registers), Directions | **Flutter → Spring → Mapbox** | These are billable per request and need a token with more scope than a map-load token. Proxying keeps that token server-side, lets you rate-limit per user, and lets you **cache** — a snapped road is computed once at creation and stored forever, so it should never be requested twice. |

Rule of thumb: the rendering path is direct, the billable-query path is proxied.

## 8b. Backend contract (to agree with the Spring side)

snake_case on the wire, as everywhere else in this app.

Businesses **shipped against a different shape** than what was sketched here —
a radius query under `/businesses/*`, not a bbox query under `/map/*`. See §6.0
for the real contract. The rest of this section is still the proposal for the
layers that haven't been built.

```
GET /map/meets?…&from=&to=
GET /map/roads?…              → each road includes `path: [[lng,lat], …]`
GET /map/roads/{id}           → full-resolution path
POST /map/roads               → create (path + name + description + tags)
```

Two things worth insisting on:

- **Bounding-box queries, not "give me everything"** — with a PostGIS `geography`
  column and a GIST index, or at minimum a lat/lng BETWEEN with a composite index.
- **`[lng, lat]` order.** GeoJSON is longitude-first. Getting this backwards puts
  everything in the ocean off West Africa and is the #1 map bug. Consider a
  `Position`-typed value object in the domain layer so the order can't be
  swapped by accident.

The API can return either domain JSON (mapped to GeoJSON on the client) or
GeoJSON directly. **Prefer domain JSON** — it keeps the data layer consistent
with every other feature here, and the GeoJSON conversion is ~20 lines in a
mapper.

---

## 9. Suggested build order

1. Route `/map` + `MapPage` with a bare `MapWidget`, Standard style, pitch 55.
   Wire the `AppBottomNav` map tab (currently a no-op TODO in
   `app_bottom_nav.dart`). Confirm tiles load on both platforms → tokens are right.
2. Location permission + 2D puck, "recenter" FAB via `FollowPuckViewportState`.
3. `MapLayerController` + `MapBloc` + debounced camera → businesses source,
   clustered, with a detail sheet on tap. **This is the reference pattern**;
   every later layer is a copy.
4. ~~Car meets~~ **done** — see §6.1 and `lib/features/map_events/README.md`.
5. Driving roads (`LineLayer`, casing + line, detail sheet).
6. 3D: swap the puck for the car model, `lightPreset` from the app theme.
7. Live users / convoys (Supabase Realtime + `ModelLayer` + interpolation).
8. Creating content on the map: long-press → "add meet here", road recording.

Steps 1–3 are the real work. 4–8 mostly reuse it.

---

## 10. Sources

- [mapbox_maps_flutter on pub.dev](https://pub.dev/packages/mapbox_maps_flutter)
- [mapbox/mapbox-maps-flutter README + examples](https://github.com/mapbox/mapbox-maps-flutter)
- [Maps SDK for Flutter guides](https://docs.mapbox.com/flutter/maps/guides/)
- [Standard Styles](https://docs.mapbox.com/map-styles/guides/standard-styles/)
- [Style spec expressions](https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/)
- [iOS SDK install troubleshooting (.netrc)](https://docs.mapbox.com/help/troubleshooting/ios-sdk-installation/)
- [GeoJsonSource API](https://pub.dev/documentation/mapbox_maps_flutter/latest/mapbox_maps_flutter/GeoJsonSource-class.html)
