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
│   │   ├── car_modification_model.dart      # + ModificationMediaItemModel
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
│   │   ├── car_modification.dart   # CarModificationEntity (+ media list w/ key, beforeMedia/afterMedia getters)
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
│       ├── save_cover_key.dart
│       ├── save_gallery_keys.dart
│       └── update_car.dart
└── presentation/
    ├── bloc/
    │   ├── bloc.dart, event.dart, state.dart      # GarageBloc (garage view + delete car)
    │   ├── add_car/                                # AddCarBloc (create + 3-step uploads)
    │   ├── car_detail/                             # CarDetailBloc (car + gallery delete via PATCH)
    │   └── log_mod/                                # LogModBloc (add mod + 4-step media upload)
    ├── pages/
    │   ├── register_car_page.dart   # 6-step add-car wizard
    │   ├── chassis_page.dart        # car detail (specs, gallery, build log)
    │   └── log_mod_page.dart        # add a modification to an existing car
    ├── utils/
    │   └── garage_error_mapper.dart
    └── widgets/
        ├── garage_car_card.dart
        └── resolved_image.dart      # CachedNetworkImage wrapper (no URL resolution needed)
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
| `LogModBloc` | `LoadModCategories`, `SubmitModification` | creates mod then requests batch upload URLs, uploads to R2, PATCHes with `addMedia`; rolls back via delete on failure |

---

## Routes

| Path | Bloc(s) | Page |
|---|---|---|
| `/garage/cars/add` | `AddCarBloc` | `RegisterCarPage` (6 steps: Identity, Performance, Drivetrain, Story, Gallery, Mods) |
| `/garage/cars/:carId` | `CarDetailBloc` | `ChassisPage` (`state.extra` = `isOwner` bool) |
| `/garage/cars/:carId/modifications/add` | `LogModBloc` | `LogModificationPage` |

---

## Failures (`domain/failures/garage_failures.dart`)

`CarNotFoundFailure`, `GarageNotFoundFailure`, `PrivateGarageFailure`,
`NotCarOwnerFailure`, `InvalidReferenceFailure`. Mapped from HTTP status in
`GarageRepositoryImpl`; surfaced via `GarageErrorMapper` (falls through to
`CoreErrorMapper`).
