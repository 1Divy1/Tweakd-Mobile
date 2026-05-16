# CONTEXT.md — Cargram Codebase Reference

Quick-reference for architecture, patterns, and definitions. Read this before exploring files.

---

## App Overview

- **Name**: Cargram (car social media app)
- **Stack**: Flutter + BLoC + Clean Architecture + GoRouter + GetIt/Injectable
- **Backend**: Spring Boot at `http://localhost:8080`, endpoints prefixed `/public/api/v1`
- **Auth**: Supabase (identity/JWT) + Spring (app data). JWT attached to every request via `AuthInterceptor`.
- **Entry**: `main.dart` — loads `.env`, inits Supabase with `SecureLocalStorage`, calls `configureDependencies()`, mounts `CarSocialMediaApp` with root `AuthBloc`.

---

## Folder Structure

```
lib/
├── main.dart
├── config/routes/app_router.dart
├── core/
│   ├── di/
│   │   ├── injection.dart                  # getIt instance + configureDependencies()
│   │   └── modules/
│   │       ├── dio_module.dart             # @module: registers Dio
│   │       └── supabase_module.dart        # @module: registers SupabaseClient
│   ├── error/
│   │   ├── base_exceptions.dart
│   │   └── base_failures.dart
│   ├── network/
│   │   ├── abstract_http.dart              # HTTP interface
│   │   ├── auth_interceptor.dart           # Adds Bearer JWT to every request
│   │   └── dio_http_client.dart            # AbstractHTTP impl, maps DioException → custom exceptions
│   ├── services/
│   │   └── car_image_service.dart          # Image compression & presigned-URL uploads (garage feature)
│   ├── storage/secure_local_storage.dart   # FlutterSecureStorage, plugged into Supabase
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── usecases/usecase.dart               # abstract UseCase<Type, Params> + NoParams
│   ├── utils/
│   │   ├── core_error_mapper.dart
│   │   └── validators.dart                 # UsernameValidator.validate()
│   └── widgets/app_bottom_nav.dart
└── features/
    ├── authentication/
    ├── profile/
    ├── follow/
    ├── search/
    └── garage/
```

Each feature:
```
features/<name>/
├── domain/
│   ├── entities/
│   ├── failures/
│   ├── repositories/   # abstract interface
│   └── usecases/
├── data/
│   ├── models/         # fromJson + toEntity()
│   ├── datasource/     # API/Supabase calls
│   └── repositories/   # impl, exception→failure mapping
└── presentation/
    ├── bloc/           # bloc.dart, event.dart, state.dart
    ├── pages/
    ├── widgets/
    └── utils/          # <Feature>ErrorMapper
```

---

## Core Abstractions

### UseCase
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
class NoParams {}
```

### AbstractHTTP
Methods: `get`, `post`, `put`, `patch`, `delete`
All accept: `(String path, {Map<String,dynamic>? queryParameters, Map<String,String>? headers, CancelToken? cancelToken})`
`post/put/patch/delete` also accept `Object? body`.

Implemented by `DioHttpClient` (`@LazySingleton(as: AbstractHTTP)`).

### DioHttpClient — Exception Mapping
| DioException condition | Throws |
|---|---|
| `DioExceptionType.cancel` | `RequestCancelledException` |
| connection / timeout errors | `NetworkException` |
| HTTP 401 | `UnauthenticatedException` |
| HTTP 409 | `ConflictException(errorCode, message)` |
| HTTP >= 500 | `ServerException` |
| other HTTP errors | `ApiException(statusCode, errorCode, message)` |

---

## Base Exceptions (`core/error/base_exceptions.dart`)

| Class | Default message |
|---|---|
| `ServerException(String message)` | 'A server error occurred.' |
| `NetworkException()` | — |
| `CacheException()` | — |
| `UnauthenticatedException(String message)` | 'Authentication required.' |
| `ConflictException({String? errorCode, String message})` | 'Conflict.' |
| `ApiException({required int statusCode, String? errorCode, String message})` | 'An API error occurred.' |
| `RequestCancelledException()` | — |

## Base Failures (`core/error/base_failures.dart`)

```dart
abstract class Failure { final String message; }
```

| Class | Message |
|---|---|
| `ServerFailure(String message)` | — |
| `NetworkFailure(String message)` | — |
| `UnknownFailure(String message)` | — |
| `RequestCancelledFailure()` | 'Request was cancelled.' |

---

## Error Flow (always follow this pipeline)

```
Data layer throws custom exception
  ↓
Repository impl catches → maps to Failure → returns Left(failure)
  ↓
Bloc folds Either → emits error state with message from <Feature>ErrorMapper
  ↓
<Feature>ErrorMapper falls through to CoreErrorMapper for generic failures
```

**CoreErrorMapper messages:**
- `NetworkFailure` → "It looks like you are not connected to the internet..."
- `ServerFailure` → "Oops! An error occurred on the server..."
- `UnknownFailure` → "Something went wrong..."
- Anything else → `failure.message`

---

## Features

Each feature has its own `README.md` at `lib/features/<name>/README.md` with full detail on entities, repository interfaces, use cases, data sources, exception→failure mapping, Bloc events/states, failures, pages, and widgets.

| Feature | README |
|---|---|
| authentication | [lib/features/authentication/README.md](lib/features/authentication/README.md) |
| profile | [lib/features/profile/README.md](lib/features/profile/README.md) |
| follow | [lib/features/follow/README.md](lib/features/follow/README.md) |
| search | [lib/features/search/README.md](lib/features/search/README.md) |
| garage | [lib/features/garage/README.md](lib/features/garage/README.md) |

---

## Routes (`config/routes/app_router.dart`)

| Path | Page | Notes |
|---|---|---|
| `/` | `SplashPage` | Reads root `AuthBloc`; redirects based on auth state |
| `/signup` | `SignUpPage` | — |
| `/onboarding` | `OnboardingPage` | — |
| `/profile` | `MyProfilePage` | `NoTransitionPage` (bottom nav) |
| `/users/:username` | `PublicProfilePage(username)` | Redirects to `/profile` if `state.extra` userId matches current user |
| `/search` | `SearchPage` | `NoTransitionPage` (bottom nav) |
| `/feed` | Stub `Scaffold` | `NoTransitionPage` (bottom nav); not implemented |
| `/garage/cars/add` | `RegisterCarPage` | 6-step add-car wizard |
| `/garage/cars/:carId` | `ChassisPage` | `state.extra` = `isOwner` bool |
| `/garage/cars/:carId/modifications/add` | `LogModificationPage` | — |

**Navigation**: bottom-nav tabs use `context.go()` (replaces stack, no back gesture). `NoTransitionPage` on all bottom-nav destinations eliminates slide animation. Routes navigated to via `context.push()` keep the default transition.

**BlocProvider rule**: always wired in the route's `pageBuilder`/`builder`, never inside the page file.

---

## DI Registration Summary

| Annotation | Used for |
|---|---|
| `@lazySingleton` | data sources, repos, use cases, HTTP client, interceptors |
| `@LazySingleton(as: Abstract)` | binding impl to interface (e.g. `DioHttpClient as AbstractHTTP`) |
| `@injectable` (factory) | Blocs (fresh instance per page) |
| `@module` | third-party: `DioModule`, `SupabaseModule` |

`injection.config.dart` is **generated** — never hand-edit. Run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**DioModule** configures Dio with:
- Base URL: `${API_BASE_URL}/public/api/v1`
- Connect & receive timeout: 10s
- Headers: `Content-Type: application/json`, `Accept: application/json`
- Interceptors: `AuthInterceptor`, `LogInterceptor`

---

## AppBottomNav

File: `core/widgets/app_bottom_nav.dart`

```dart
enum AppBottomNavTab { feed, map, search, contests, profile }
AppBottomNav({ required AppBottomNavTab activeTab })
```

Tabs: FEED → `/feed` | MAP → stub | SEARCH → `/search` | CONTESTS → stub | PROFILE → `/profile`
Uses `context.go()` and guards with `if (activeTab != tab)` to avoid redundant navigation.

---

## Theme

### AppColors

| Field | Hex | Role |
|---|---|---|
| `bg` | `0xFFF6F4F1` | scaffold background |
| `bgSoft` | `0xFFFAF8F5` | soft background |
| `surface` | `0xFFFFFFFF` | cards, inputs |
| `ink` | `0xFF0A0A0A` | primary text |
| `ink2` | `0xFF3F3F46` | secondary text |
| `mute` | `0xFF8A8680` | muted text |
| `muteSoft` | `0xFFB8B3AC` | placeholder / disabled |
| `line` | `0xFFECE8E2` | borders |
| `line2` | `0xFFF2EFE9` | light borders |
| `accent` | `0xFFFF4D00` | primary CTA (orange) |
| `accentHot` | `0xFFE64500` | pressed accent |
| `accentSoft` | `0xFFFFE4D6` | accent tint |

### AppTheme.light() highlights
- ElevatedButton: accent bg, white fg, 10px radius, 18×14px padding, w800 14px letterSpacing 1.4
- OutlinedButton: ink fg, surface bg, `line` border, 20px radius
- InputDecoration: filled surface, 12px radius, muteSoft hint
- Card: surface, no elevation, `line` border, 12px radius
- AppBar: surface bg, ink fg, no elevation

---

## Key Packages

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | BLoC state management |
| `equatable` | ^2.0.8 | Value equality |
| `go_router` | ^17.2.1 | Routing |
| `dio` | ^5.9.2 | HTTP client |
| `get_it` | ^9.2.1 | Service locator |
| `injectable` | ^2.7.1+4 | DI code generation |
| `supabase_flutter` | ^2.12.4 | Auth + DB |
| `dartz` | ^0.10.1 | Either / Unit |
| `google_sign_in` | ^7.2.0 | Google OAuth |
| `flutter_secure_storage` | ^10.0.0 | Session persistence |
| `flutter_dotenv` | ^6.0.1 | `.env` loading |
| `cached_network_image` | ^3.4.1 | Network images |
| `shimmer` | ^3.0.0 | Loading skeleton |
| `flutter_svg` | ^2.2.4 | SVG rendering |
| `flutter_image_compress` | ^2.4.0 | Image compression (webp) for uploads |
| `image_picker` | ^1.1.2 | File picker for photos |
| `uuid` | ^4.0.0 | UUID generation |
| `hive` | ^2.2.3 | Local cache (not yet actively used) |

---

## Conventions

- Imports: relative within same feature; `package:car_social_media_app/...` across features (existing code mixes both — match surrounding file).
- JSON is snake_case; Dart fields are camelCase; `fromJson` handles the mapping.
- Sub-widgets go in `presentation/widgets/` subdirectories, **never as private classes inside page files**.
- Auth token: never set `Authorization` manually at call sites — `AuthInterceptor` handles it.
- Env vars: `dotenv.env['KEY']` after `dotenv.load()` in `main.dart`.
