# Feature: Garage

A user's collection of cars, their full specs, modifications ("build log"), and a
photo gallery. Supports viewing your own and other users' garages (privacy-gated),
creating a car in one shot, logging modifications, and deleting cars/images.

---

## Folder Structure

```
garage/
├── data/
│   ├── datasources/garage_api_data_source.dart
│   ├── models/
│   │   ├── car_detail_model.dart
│   │   ├── car_image_model.dart
│   │   ├── car_modification_model.dart
│   │   ├── car_status_option_model.dart
│   │   ├── car_summary_model.dart
│   │   ├── create_car_response_model.dart   # + UploadSlot/GallerySlot/ModUploadSlots/AddModResponse
│   │   ├── garage_model.dart
│   │   └── reference_data_models.dart
│   └── repositories/garage_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── car.dart                # CarEntity (+ copyWith)
│   │   ├── car_image.dart          # CarImageEntity (gallery)
│   │   ├── car_modification.dart
│   │   ├── car_status_option.dart
│   │   ├── car_summary.dart
│   │   ├── create_car_result.dart  # UploadSlot/GallerySlot/ModUploadSlots/CreateCarResult/AddModificationResult
│   │   ├── garage.dart
│   │   └── reference_data.dart
│   ├── failures/garage_failures.dart
│   ├── repositories/garage_repository.dart   # + CarRequestParams/ModRequestParams/CreateCarParams
│   └── usecases/
│       ├── add_car.dart                 # CreateCarParams -> CreateCarResult
│       ├── add_modification.dart        # -> AddModificationResult
│       ├── delete_car.dart
│       ├── delete_car_image.dart
│       ├── delete_modification.dart
│       ├── get_car.dart
│       ├── get_car_images.dart
│       ├── get_garage_by_username.dart
│       ├── get_my_garage.dart
│       ├── get_reference_data.dart
│       ├── resolve_image_url.dart       # storage path -> signed URL
│       └── update_car.dart
└── presentation/
    ├── bloc/
    │   ├── bloc.dart, event.dart, state.dart      # GarageBloc (garage view + delete car)
    │   ├── add_car/                                # AddCarBloc (single-shot create + uploads)
    │   ├── car_detail/                             # CarDetailBloc (car + gallery + deletes)
    │   └── log_mod/                                # LogModBloc (add mod + image uploads)
    ├── pages/
    │   ├── register_car_page.dart   # 6-step add-car wizard
    │   ├── chassis_page.dart        # car detail (specs, gallery, build log)
    │   └── log_mod_page.dart        # add a modification to an existing car
    ├── utils/
    │   ├── garage_error_mapper.dart
    │   └── image_url_resolver.dart  # cached storagePath -> signed URL resolver
    └── widgets/
        ├── garage_car_card.dart
        └── resolved_image.dart      # resolves + renders a storage path
```

`CarImageService` (in `core/services/`) is shared infra: it compresses a picked
image to webp and PUTs the bytes to a backend-issued presigned URL via a bare
`Dio` (no app JWT — the Supabase upload token is embedded in the URL).

---

## Backend contract (Spring Modulith `garage` module)

All paths are relative to the Dio base URL `${API_BASE_URL}/api/v1`. JSON is
**snake_case** (global Jackson `SNAKE_CASE`).

### Image model — IMPORTANT

Image fields (`cover_image_url`, `before_image_url`, `after_image_url`,
`storage_path`) are **canonical storage paths**, not URLs
(`car-photos/{ownerId}/{carId}/...`). To display any image you must resolve the
path to a short-lived signed URL via `POST /garage/storage/download-url`. This is
done transparently by `ImageUrlResolver` (in-memory cached, 5h TTL) behind the
`ResolvedImage` widget.

### Single-shot car creation

`POST /garage/cars` body `{ car, modifications[], gallery_count }` →
`{ car, cover: UploadSlot, modifications: [ModUploadSlots], gallery: [GallerySlot] }`.
The backend creates all rows with deterministic storage paths and returns
presigned upload URLs. The client (`AddCarBloc`) then PUTs every image's bytes to
its slot; on **any** upload failure it rolls back via
`DELETE /garage/cars/{carId}` (mods + gallery cascade). Slots map by order:
`modifications[i]` ↔ submitted mod `i`; `gallery[i]` ↔ gallery file `i`.

### Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/garage/me` | own garage (no privacy gate) |
| GET | `/garage/by-username/{username}` | 403 if private & not accepted follower |
| GET | `/garage/cars/{carId}` | full car + mods; privacy-gated |
| POST | `/garage/cars` | single-shot create (see above) |
| PUT | `/garage/cars/{carId}` | full replace; 403 not owner |
| DELETE | `/garage/cars/{carId}` | cascades mods + gallery |
| POST | `/garage/cars/{carId}/modifications` | add mod **¹** |
| PUT | `/garage/cars/{carId}/modifications/{modId}` | full replace |
| DELETE | `/garage/cars/{carId}/modifications/{modId}` | |
| GET | `/garage/cars/{carId}/images` | gallery list (not embedded in CarDto) |
| DELETE | `/garage/cars/{carId}/images/{imageId}` | owner only |
| POST | `/garage/storage/download-url` | `{storage_path}` → `{signed_url}` |
| GET | `/garage/reference/{brands,brands/{id}/models,drivetrains,colors,distance-units,status-options,mod-categories}` | lookup data |

**¹** `POST .../modifications` returns
`{ modification, before: UploadSlot, after: UploadSlot }`
(`AddModificationResponseModel` / `AddModificationResult`); `LogModBloc` uploads
both images and rolls back via `DELETE .../modifications/{modId}` on failure —
symmetric to the single-shot create flow. A
`POST .../modifications/{modId}/upload-urls` → `ModificationUploadSlots`
endpoint also exists for refreshing presigned URLs on retry; the client does not
use it yet (it rolls back and resubmits instead).

---

## Blocs

| Bloc | Events | Notes |
|---|---|---|
| `GarageBloc` | `LoadMyGarage`, `LoadGarageByUsername`, `DeleteCar` | used by profile's `GarageSection` |
| `AddCarBloc` | `LoadAddCarReferenceData`, `AddCarBrandSelected`, `SubmitNewCar` | `SubmitNewCar` carries car params + local cover/gallery/mod file paths; orchestrates create → uploads → rollback. `AddCarSubmitting.statusLabel` drives the progress label |
| `CarDetailBloc` | `LoadCar`, `DeleteCarFromDetail`, `DeleteGalleryImage`, `DeleteModificationFromDetail` | `LoadCar` loads car + gallery in parallel |
| `LogModBloc` | `LoadModCategories`, `SubmitModification` | `SubmitModification` carries params + before/after file paths |

---

## Routes

| Path | Bloc(s) | Page |
|---|---|---|
| `/garage/cars/add` | `AddCarBloc` | `RegisterCarPage` (6 steps: Identity, Performance, Drivetrain, Story, Gallery, Mods) |
| `/garage/cars/:carId` | `CarDetailBloc` | `ChassisPage` (`state.extra` = `isOwner` bool) |
| `/garage/cars/:carId/modifications/add` | `LogModBloc` | `LogModificationPage` |

Garage view itself has no route — `GarageSection` (profile feature) renders it on
`/profile` and `/users/:username` using `GarageBloc` provided by those routes.

---

## Failures (`domain/failures/garage_failures.dart`)

`CarNotFoundFailure`, `GarageNotFoundFailure`, `PrivateGarageFailure`,
`NotCarOwnerFailure`, `InvalidReferenceFailure`. Mapped from HTTP status in
`GarageRepositoryImpl`; surfaced via `GarageErrorMapper` (falls through to
`CoreErrorMapper`).
