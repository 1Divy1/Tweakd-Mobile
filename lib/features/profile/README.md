# Feature: Profile

Handles fetching and displaying user profiles — both the authenticated user's own profile and public profiles. Also owns the onboarding submission flow.

---

## Folder Structure

```
profile/
├── data/
│   ├── datasource/profile_api_data_source.dart
│   ├── models/profile_model.dart
│   └── repositories/profile_repository_impl.dart
├── domain/
│   ├── entities/profile.dart
│   ├── failures/profile_failures.dart
│   ├── repositories/profile_repository.dart
│   └── usecases/
│       ├── get_current_user_profile.dart
│       ├── get_profile_by_username.dart
│       └── submit_onboarding.dart
└── presentation/
    ├── bloc/bloc.dart, event.dart, state.dart
    ├── pages/profile_page.dart, public_profile_page.dart
    ├── utils/profile_error_mapper.dart
    └── widgets/
        ├── my_profile/      my_profile_data_view, settings_button
        ├── public_profile/  follow_button, public_profile_data_view
        ├── shared/          garage_section, profile_avatar, profile_bio,
        │                    profile_identity, profile_stats_row, profile_top_bar
        ├── profile_error_view
        └── profile_loading_view
```

---

## Entity

```dart
ProfileEntity {
  id: String
  role: String
  name: String
  username: String
  avatarUrl: String
  bio: String
  externalLink: String
  followersCount: int
  followingCount: int
  isVerified: bool
  isBusiness: bool
  requiresOnboarding: bool

  // method
  copyWith({int? followersCount}) → ProfileEntity
}
```

**Model** (`ProfileModel`):
- `fromJson(Map<String,dynamic> json)` — maps snake_case JSON to camelCase fields
- `toEntity() → ProfileEntity`

---

## Repository Interface

```dart
abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile({bool forceRefresh});
  Future<Either<Failure, ProfileEntity>> submitOnboarding({required String username, String? bio});
  Future<Either<Failure, ProfileEntity>> getProfileByUsername(String username);
}
```

Implemented by `ProfileRepositoryImpl` (`@LazySingleton(as: ProfileRepository)`).

**Caching**: `_cachedProfile` field — `getCurrentUserProfile` returns cache unless `forceRefresh: true`.

**Exception → Failure mapping**:
| Exception | Failure |
|---|---|
| `ConflictException` | `UsernameTakenFailure` |
| `UnauthenticatedException` | `UnauthenticatedFailure` |
| `NetworkException` | `NetworkFailure` |
| `ApiException(400)` | `InvalidUsernameFailure` |
| `ApiException(404)` (getByUsername only) | `ProfileNotFoundFailure` |

---

## Use Cases

| Class | Params | Return |
|---|---|---|
| `GetCurrentUserProfileUseCase` | `GetCurrentUserParams { fetchFromRemote: bool }` | `ProfileEntity` |
| `GetProfileByUsernameUseCase` | `GetProfileByUsernameParams { username: String }` | `ProfileEntity` |
| `SubmitOnboardingUseCase` | `SubmitOnboardingParams { username: String, bio: String? }` | `ProfileEntity` |

All annotated `@lazySingleton`.

---

## Data Source

**`ProfileApiDataSource`** (`@lazySingleton`)  
Constructor: `ProfileApiDataSource(AbstractHTTP http)`

| Method | Endpoint |
|---|---|
| `getCurrentUserProfile()` | `GET /profile/me` |
| `submitOnboarding({username, bio?})` | `POST /profile/onboarding` |
| `getProfileByUsername(username)` | `GET /profile/by-username/{username}` |

---

## Failures

```dart
UsernameTakenFailure(message = 'This username is already taken.')
UnauthenticatedFailure(message = 'You are not logged in. Please authenticate first.')
ProfileNotFoundFailure(message = 'This user could not be found.')
InvalidUsernameFailure(message = 'Username can only contain lowercase letters, numbers, dots and underscores.')
```

---

## Bloc

**`ProfileBloc`** (`@injectable` — factory)

**Events**:
```dart
FetchUserProfileData({ bool fetchFromRemote = false })
FetchProfileByUsername(String username)
SubmitOnboarding({ required String username, String? bio })
```

**States**:
```dart
ProfileLoading()
ProfileLoaded(ProfileEntity profile)
ProfileError(String message)
OnboardingSubmitting()
OnboardingSubmitted(ProfileEntity profile)
OnboardingError(String message)
```

**Handlers**:
- `_onFetchUserProfileData` → `GetCurrentUserProfileUseCase`
- `_onFetchProfileByUsername` → `GetProfileByUsernameUseCase`
- `_onSubmitOnboarding` → `SubmitOnboardingUseCase`

---

## Pages & Routing

| Route | Page | Blocs provisioned |
|---|---|---|
| `/profile` | `MyProfilePage` (own, editable) | `ProfileBloc` + `FetchUserProfileData()` |
| `/onboarding` | `OnboardingPage` | `ProfileBloc` |
| `/users/:username` | `PublicProfilePage` (read-only) | `ProfileBloc` + `FetchProfileByUsername(u)`, `FollowStatusBloc` + `LoadFollowStatus(u)` |

`/users/:username` redirects to `/profile` if `state.extra` (target user ID) matches the current Supabase user ID.
