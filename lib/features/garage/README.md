# Feature: Garage

A user's collection of cars, their full specs, modifications ("build log"), and a
photo gallery. Supports viewing your own and other users' garages (privacy-gated),
creating a car in one shot, logging modifications, and deleting cars/images.

---

## Folder Structure

```
garage/
├── data/
│   ├── datasources/
│   │   ├── garage_api_data_source.dart      # backend CRUD + PATCH endpoints
│   │   └── storage_api_data_source.dart     # presigned URL endpoints (/api/storage/...)
│   ├── models/
│   │   ├── car_detail_model.dart
│   │   ├── car_share_model.dart             # CarShareModel + CarShareResolutionModel
│   │   ├── car_modification_model.dart      # + ModificationMediaItemModel
│   │   ├── mod_share_card_model.dart        # `mod_share_card` on a post; tryParse, never throws
│   │   ├── car_status_option_model.dart
│   │   ├── car_summary_model.dart
│   │   ├── create_car_response_model.dart   # + AddModificationResponseModel
│   │   ├── garage_model.dart
│   │   ├── reference_data_models.dart
│   │   └── storage_models.dart              # UploadUrlResponseModel, ModUploadUrlsResponseModel
│   └── repositories/garage_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── car.dart                # CarEntity (+ coverImage, gallery, copyWith)
│   │   ├── car_image_ref.dart      # CarImageRef { key, url } — cover & gallery items
│   │   ├── car_modification.dart   # CarModificationEntity (+ media list w/ key, beforeMedia/afterMedia getters, isPricePublic)
│   │   ├── mod_share_card.dart     # ModShareCardEntity — a shared mod as the feed draws it
│   │   ├── car_share.dart          # CarShareEntity, CarShareChannel (?s= tags), CarShareResolutionEntity
│   │   ├── car_status_option.dart
│   │   ├── car_summary.dart        # CarSummaryEntity (coverImage: CarImageRef? — garage-list cards)
│   │   ├── create_car_result.dart  # UploadUrlResult, ModUploadUrl, ModUploadUrlsResult
│   │   ├── garage.dart
│   │   └── reference_data.dart
│   ├── failures/garage_failures.dart
│   ├── repositories/garage_repository.dart   # + storage methods, ModPatchParams, ModUploadRequest
│   └── usecases/
│       ├── add_car.dart
│       ├── add_modification.dart
│       ├── delete_car.dart
│       ├── delete_modification.dart
│       ├── get_car.dart
│       ├── get_cover_upload_url.dart
│       ├── get_gallery_upload_url.dart
│       ├── get_garage_by_username.dart
│       ├── get_modification_upload_urls.dart
│       ├── get_my_garage.dart
│       ├── get_reference_data.dart
│       ├── patch_modification.dart
│       ├── ensure_car_share_link.dart
│       ├── get_car_share_qr.dart
│       ├── resolve_share_code.dart
│       ├── save_cover_key.dart
│       ├── save_gallery_keys.dart
│       ├── set_car_share_enabled.dart
│       └── update_car.dart
└── presentation/
    ├── bloc/
    │   ├── bloc.dart, event.dart, state.dart      # GarageBloc (garage view + delete car)
    │   ├── add_car/                                # AddCarBloc (create + 3-step uploads)
    │   ├── car_detail/                             # CarDetailBloc (car + gallery delete via PATCH)
    │   ├── car_share/                              # CarShareBloc (link + QR + pause switch)
    │   ├── log_mod/                                # LogModBloc (add mod + 4-step media upload)
    │   └── share_resolve/                          # ShareResolveCubit (incoming code → car id)
    ├── pages/
    │   ├── register_car_page.dart   # 6-step add-car wizard
    │   ├── about_car_page.dart      # car detail (specs, gallery, build log, share)
    │   ├── log_mod_page.dart        # add a modification to an existing car
    │   └── share_landing_page.dart  # /c/:code — resolves an incoming share code
    ├── utils/
    │   └── garage_error_mapper.dart
    └── widgets/
        ├── garage_car_card.dart
        ├── resolved_image.dart      # CachedNetworkImage wrapper (no URL resolution needed)
        └── share/
            ├── share_build_sheet.dart  # showShareBuildSheet — owns the CarShareBloc
            ├── share_qr_dialog.dart    # the QR modal + "Download SVG"
            └── share_origin.dart       # iPad share-popover anchor helper
```

`CarImageService` (in `core/services/`) compresses a picked image to webp and PUTs
the bytes to a Cloudflare R2 presigned URL via a bare `Dio` (no JWT — auth is
embedded in the presigned URL query parameters).

`StorageApiDataSource` uses its own `Dio` instance pointed at `${API_BASE_URL}/api/storage`
(with JWT interceptor) to request presigned upload URLs from the backend.

---

## Backend contract

All garage CRUD paths are relative to the Dio base URL `${API_BASE_URL}/api/v1`.
Storage presigned URL paths are relative to `${API_BASE_URL}/api/storage`.
JSON is **camelCase**.

### Image storage — Cloudflare R2

Images are stored in Cloudflare R2 and persisted by their **R2 key** (the DB
holds keys, not urls; display urls are built on read). Every upload follows a
three-step pattern:

1. **GET presigned URL** from backend (with JWT) → `{ uploadUrl, key }`
2. **PUT file bytes** directly to R2 (NO JWT — auth is embedded in `uploadUrl`)
3. **PATCH backend** with the `key` to persist the image in the DB (cover & gallery)

### CarDto shape (GET /garage/cars/{carId})

```
{
  id, garageId, brandId, brandName, modelId, modelName, drivetrainId,
  drivetrainName, colorId, colorName, colorCode, mileageUnitId, mileageUnitName,
  year, horsepower, torque, weight, engineDisplacement, zeroToOneHundred,
  chassisCode, engineCode,
  coverImage: { key, url } | null, // null until a cover is uploaded
  gallery: [{ key, url }],         // ordered; empty if no gallery
  createdAt, status,
  modifications: [
    {
      id, carId, categoryId, categoryName, title, description,
      media: [{ key, url, type, phase }],  // type: "image"|"video", phase: "before"|"after"
      installationDate, price, isPricePublic, mileageAtInstall, createdAt
    }
  ]
}
```

The backend stores only the domain/bucket-agnostic R2 `key`; it builds a
fully-qualified `url` on the fly when an image is read. Rule of thumb: **display
`url`, send `key` back** to the key-based endpoints — never reconstruct a key
from a url.

### Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/garage/me` | own garage (no privacy gate) |
| GET | `/garage/by-username/{username}` | 403 if private & not accepted follower |
| GET | `/garage/cars/{carId}` | full CarDto (cover + gallery + mods with media) |
| POST | `/garage/cars` | create car + mods (text only); media uploaded separately |
| PUT | `/garage/cars/{carId}` | full replace of car specs |
| DELETE | `/garage/cars/{carId}` | cascades mods + gallery; R2 objects cleaned up |
| PATCH | `/garage/cars/{carId}/cover?key=...` | step 3 for cover — R2 key from the upload-url response |
| DELETE | `/garage/cars/{carId}/cover` | no param/body — backend deletes the current cover by car id |
| PATCH | `/garage/cars/{carId}/gallery` | `{ keys: [...] }` — full ordered list of R2 keys; diffs and deletes removed R2 objects |
| DELETE | `/garage/cars/{carId}/gallery` | `{ keys: [...] }` — delete the given gallery photos |
| POST | `/garage/cars/{carId}/modifications` | add mod (text only) |
| PATCH | `/garage/cars/{carId}/modifications/{modId}` | partial update: text fields and/or `{ add_media: [{key, phase}], remove_media_keys: [...] }` |
| DELETE | `/garage/cars/{carId}/modifications/{modId}` | |
| GET | `/garage/reference/{brands,...}` | lookup data |
| POST | `/garage/cars/{carId}/share` | owner-only, idempotent — returns the car's share link, minting the code on first call |
| PATCH | `/garage/cars/{carId}/share` | `{ enabled: bool }` — pause / resume. The code never changes |
| GET | `/garage/cars/{carId}/share/qr.svg` | `image/svg+xml`, raw SVG source (not JSON) |
| GET | `/garage/share/resolve/{code}?s=` | any signed-in user — `{ car_id, owner_username }`; 404 unknown, 410 paused/revoked |

### Storage presigned URL endpoints (base: `/api/storage`)

| Method | Path | Returns |
|---|---|---|
| GET | `/cars/{carId}/cover` | `{ uploadUrl, key }` |
| GET | `/cars/{carId}/gallery` | `{ uploadUrl, key }` |
| POST | `/cars/{carId}/modifications/{modId}/upload-urls` | `{ files: [{phase, format}] }` → `{ uploads: [{uploadUrl, key, phase}] }` |

---

## Upload flows

### Cover image
1. `GET /api/storage/cars/{carId}/cover` → `{ uploadUrl, key }`
2. Compress to webp → `PUT uploadUrl` (Content-Type: image/webp, no JWT)
3. `PATCH /api/v1/garage/cars/{carId}/cover?key={key}`

Replacing a cover: upload the new file, `DELETE /garage/cars/{carId}/cover`
(deletes the current cover by car id), then PATCH the new key.

### Gallery (per photo, then save all)
1. `GET /api/storage/cars/{carId}/gallery` → `{ uploadUrl, key }`
2. Compress to webp → `PUT uploadUrl` (no JWT); collect `key`
3. Repeat 1-2 for each new photo
4. `PATCH /api/v1/garage/cars/{carId}/gallery` with `{ keys: [all current keys in order] }`

Gallery deletion: `DELETE /garage/cars/{carId}/gallery` with `{ keys: [...] }`,
then drop those refs from the local list. Backend deletes the R2 objects.

### Modification media
1. `POST /api/storage/cars/{carId}/modifications/{modId}/upload-urls` with `{ files: [{phase, format}] }`
2. Upload all files to R2 in parallel (no JWT)
3. `PATCH /api/v1/garage/cars/{carId}/modifications/{modId}` with `{ addMedia: [{key, phase}] }`

---

## Blocs

| Bloc | Events | Notes |
|---|---|---|
| `GarageBloc` | `LoadMyGarage`, `LoadGarageByUsername`, `DeleteCar` | used by profile's `GarageSection` |
| `AddCarBloc` | `LoadAddCarReferenceData`, `AddCarBrandSelected`, `SubmitNewCar` | creates car then orchestrates 3-step uploads for cover, gallery, and mod media; rolls back via `DELETE /garage/cars/{carId}` on failure |
| `CarDetailBloc` | `LoadCar`, `DeleteCarFromDetail`, `DeleteGalleryImage`, `DeleteModificationFromDetail` | gallery is embedded in `CarEntity.gallery` (list of `{key, url}`); `DeleteGalleryImage` deletes by R2 key then drops the ref locally |
| `LogModBloc` | `LoadModCategories`, `SubmitModification` | creates mod then requests batch upload URLs, uploads to R2, PATCHes with `addMedia`; rolls back via delete on failure. With `shareToFeed` it then posts the finished entry to the feed (see *Sharing a mod to the feed*) — a failed share never undoes the mod |
| `CarShareBloc` | `LoadShareLink`, `LoadShareQr`, `SetShareEnabled` | owns the whole share sheet: link, QR SVG and the pause switch. Created by `showShareBuildSheet`, not by a route, so the sheet and the QR modal share one bloc and one `POST …/share` |
| `ShareResolveCubit` | `resolve(code, source:)` | one call, once: turns an incoming share code into a car id for `ShareLandingPage` |

---

## Sharing a mod to the feed

A modification logged through `/garage/cars/:carId/modifications/add` can go
straight to the feed. The toggle sits under the form in `AddModificationPage`
and is **on by default**, labelled *Recommended*: the build log is where the
app's content comes from, and an opt-in switch would be a much quieter feature.
It is deliberately absent from the register-car wizard's mods step — a new car
with six mods would post six cards at once.

- **Order.** The mod and all of its photos are saved first; the share is a
  second request (`POST /posts/mod-share`, the **posts** feature's
  `ShareModificationUseCase`). So the card the feed derives is the finished
  entry, and a share that fails leaves the mod in the build log and only
  changes the closing snackbar (`LogModSuccess.shareFailed`).
- **No caption.** The toggle is the whole interaction. The mod's own
  description is what the card carries.
- **The post is an ordinary post** that tags the car and stores the
  modification's id. The card is re-derived on every read, so editing the mod
  updates it everywhere and deleting the mod leaves a plain post behind, with
  its likes and comments intact. Drawn by `PostModShareCardView`
  (`features/posts/.../post_card/`) from `ModShareCardEntity`.
- **One post per mod.** The backend returns the existing post instead of a
  second one, so a retry cannot double-post.

### Price visibility

`car_modifications.is_price_public` is off by default: a price is recorded for
the owner's own expense tracking unless they publish it. The toggle appears in
`BuildLogEntryForm` only once a price has been typed, and the flag governs
every non-owner read — the in-app car detail, the public car page and the feed
card. The backend omits `price` entirely rather than the app hiding it, so
there is nothing on this side to leak.

---

## Routes

| Path | Bloc(s) | Page |
|---|---|---|
| `/garage/cars/add` | `AddCarBloc` | `RegisterCarPage` (6 steps: Identity, Performance, Drivetrain, Story, Gallery, Mods) |
| `/garage/cars/:carId` | `CarDetailBloc` | `AboutCarPage` (`state.extra` = `isOwner` bool) |
| `/garage/cars/:carId/modifications/add` | `LogModBloc` | `LogModificationPage` |
| `/c/:code` | `ShareResolveCubit` | `ShareLandingPage` — where a scanned QR / tapped share link lands; resolves the code, then `pushReplacement`s to the car |

---

## Failures (`domain/failures/garage_failures.dart`)

`CarNotFoundFailure`, `GarageNotFoundFailure`, `PrivateGarageFailure`,
`NotCarOwnerFailure`, `InvalidReferenceFailure`, `ShareLinkNotFoundFailure`,
`ShareLinkGoneFailure`. Mapped from HTTP status in `GarageRepositoryImpl`;
surfaced via `GarageErrorMapper` (falls through to `CoreErrorMapper`).

---

## Car sharing (public link + QR)

An owner can share a car as a public web link and a printable QR code. Full
design, decisions and the backend/website halves live in
`Tweakd-Backend/backend/CAR_SHARING_PROGRESS.md` — read that before changing
anything here.

### The shape of it

```
https://web.tweakdapp.com/c/7KQ3M9XA2F?s=qr
        └── website ──┘ └─ code ─┘ └ channel tag: qr | wa | tg | x | sms | ig | copy | app
```

The code is opaque, immutable and belongs to one (car, owner) pair, because it
ends up printed on a sticker. There is **no regenerate** in the app: pausing
(`PATCH …/share`) turns the public page off while keeping the code alive, so
resuming brings the same sticker back. Revoking is a backend-only event (car
deleted, car transferred, account deleted).

### Owner flow

`AboutCarPage` top bar → share pill (owner only) → `showShareBuildSheet`:

- **Get QR code** → closes the sheet, opens `showShareQrDialog` over the page
  (as the design shows it) with the same bloc, so the link is not re-fetched.
  "Download SVG" writes `tweakd-{code}.svg` to the temp dir and hands it to the
  system sheet — that is what surfaces "Save to Files" on iOS. There is no
  "save to gallery": the photo library cannot hold a vector.
- **Copy link / channel tiles** → `ShareLauncherService`. Every tile appends
  its own `?s=<tag>`, which is the entire reason they exist instead of one
  system-share button; a tile whose app is missing falls back to the system
  sheet (tagged `app`).
- **Footer** → the pause switch plus `Scanned N · Opened N`.

The QR is rendered by the **backend**, not on device: one renderer means an
identical code everywhere and a print-ready vector, which no on-device QR
widget produces. `qr.svg` comes back as raw SVG source — dio only JSON-decodes
JSON content types, so the default transformer hands back the string.

### Incoming links

`DeepLinkService` (`core/deeplinks/`) listens to `app_links` and maps
`https://web.tweakdapp.com/c/{code}` and `tweakd://c/{code}` onto `/c/:code` via
the pure `shareRouteFor`. Shared events (`/e/{id}`) ride the same service via
`eventRouteFor` — see the map_events README. **Flutter's built-in deep linking is deliberately
off** (`FlutterDeepLinkingEnabled` / `flutter_deeplinking_enabled` are not
set): turning it on would also route the `tweakd://signup-callback` and
`tweakd://login-callback` URLs Supabase's PKCE and Android Sign-in-with-Apple
flows depend on into go_router, which has no routes for them.

A link that arrives while the app is signing in is **parked**, exactly like a
tapped push notification, and released by `flushPending()` from `SplashPage`,
`LoginPage`, `SignUpPage` and `OnboardingPage` — so a link from a friend
survives a full sign-up. `main.dart` clears it on sign-out.

### Platform wiring

- iOS: `applinks:web.tweakdapp.com` in `Runner.entitlements`. Also needs the
  Associated Domains capability on the App ID in the developer portal.
- Android: an `autoVerify` intent-filter for `https://web.tweakdapp.com/c/` plus a
  plain one for `tweakd://c`.
- **Neither works until the website serves
  `/.well-known/apple-app-site-association` and `/.well-known/assetlinks.json`**
  (phase 10 of the plan — Apple Team ID `25P3V4ZWCF`; the Android SHA-256
  fingerprints still have to be pulled from the Play Console). Until then the
  links open the browser, and `tweakd://c/{code}` is the way to test the app
  half:
  `xcrun simctl openurl booted "tweakd://c/7KQ3M9XA2F?s=qr"` /
  `adb shell am start -a android.intent.action.VIEW -d "tweakd://c/7KQ3M9XA2F"`.
