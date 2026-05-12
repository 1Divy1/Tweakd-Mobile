# Feature: Follow

Handles follow/unfollow actions, follow status checks, follower/following lists, and pending request management.

---

## Folder Structure

```
follow/
├── data/
│   ├── datasource/follow_api_data_source.dart
│   ├── models/
│   │   ├── follow_request_model.dart
│   │   ├── follow_status_model.dart
│   │   └── follow_user_model.dart
│   └── repositories/follow_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── follow_request.dart
│   │   ├── follow_status.dart
│   │   └── follow_user.dart
│   ├── failures/follow_failures.dart
│   ├── repositories/follow_repository.dart
│   └── usecases/
│       ├── accept_follow_request.dart
│       ├── follow_user.dart
│       ├── get_follow_status.dart
│       ├── get_followers.dart
│       ├── get_following.dart
│       ├── get_pending_requests.dart
│       ├── reject_follow_request.dart
│       └── unfollow_user.dart
└── presentation/
    ├── bloc/bloc.dart, event.dart, state.dart
    └── utils/follow_error_mapper.dart
```

---

## Entities

```dart
// Follow status for a given target user
FollowStatusEntity { status: FollowStatus }
// FollowStatus enum: notFollowing | pending | accepted
// Getters: isFollowing, isPending, isNotFollowing

// A user in a followers/following list
FollowUserEntity { id: String, username: String, avatarUrl: String? }

// A pending incoming follow request
FollowRequestEntity { profileId: String, username: String, avatarUrl: String?, requestedAt: DateTime }
```

**Models**:
- `FollowStatusModel.fromJson` — parses raw string `'ACCEPTED'` / `'PENDING'` / default → `FollowStatus` enum
- `FollowUserModel.fromJson` — maps `avatar_url`
- `FollowRequestModel.fromJson` — maps `profile_id`, `avatar_url`, `requested_at`

---

## Repository Interface

```dart
abstract class FollowRepository {
  Future<Either<Failure, FollowStatusEntity>> follow(String username);
  Future<Either<Failure, Unit>>              unfollow(String username);
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(String username);
  Future<Either<Failure, List<FollowRequestEntity>>> getPendingRequests();
  Future<Either<Failure, Unit>>              acceptRequest(String username);
  Future<Either<Failure, Unit>>              rejectRequest(String username);
  Future<Either<Failure, List<FollowUserEntity>>> getFollowers(String username);
  Future<Either<Failure, List<FollowUserEntity>>> getFollowing(String username);
}
```

Implemented by `FollowRepositoryImpl` (`@LazySingleton(as: FollowRepository)`).

**Exception → Failure mapping**:
| Exception | Failure |
|---|---|
| `ApiException(400)` | `CannotFollowSelfFailure` |
| `ApiException(403)` | `PrivateProfileFailure` |
| `ApiException(404)` | `TargetUserNotFoundFailure` or `FollowRequestNotFoundFailure` |
| `UnauthenticatedException` | `UnauthenticatedFollowFailure` |

---

## Use Cases

| Class | Params | Return |
|---|---|---|
| `FollowUserUseCase` | `FollowUserParams { username: String }` | `FollowStatusEntity` |
| `UnfollowUserUseCase` | `UnfollowUserParams { username: String }` | `Unit` |
| `GetFollowStatusUseCase` | `GetFollowStatusParams { username: String }` | `FollowStatusEntity` |
| `GetFollowersUseCase` | `GetFollowersParams { username: String }` | `List<FollowUserEntity>` |
| `GetFollowingUseCase` | `GetFollowingParams { username: String }` | `List<FollowUserEntity>` |
| `GetPendingRequestsUseCase` | `NoParams` | `List<FollowRequestEntity>` |
| `AcceptFollowRequestUseCase` | `AcceptFollowRequestParams { username: String }` | `Unit` |
| `RejectFollowRequestUseCase` | `RejectFollowRequestParams { username: String }` | `Unit` |

All annotated `@lazySingleton`.

---

## Data Source

**`FollowApiDataSource`** (`@lazySingleton`)  
Constructor: `FollowApiDataSource(AbstractHTTP http)`

| Method | Endpoint |
|---|---|
| `follow(username)` | `POST /follow/{username}` |
| `unfollow(username)` | `DELETE /follow/{username}` |
| `getFollowStatus(username)` | `GET /follow/{username}/status` |
| `getPendingRequests()` | `GET /follow/requests` |
| `acceptRequest(username)` | `POST /follow/requests/{username}/accept` |
| `rejectRequest(username)` | `DELETE /follow/requests/{username}` |
| `getFollowers(username)` | `GET /follow/{username}/followers` |
| `getFollowing(username)` | `GET /follow/{username}/following` |

---

## Failures

```dart
TargetUserNotFoundFailure(message = 'This user could not be found.')
CannotFollowSelfFailure(message = 'You cannot follow yourself.')
PrivateProfileFailure(message = 'This profile is private.')
FollowRequestNotFoundFailure(message = 'No pending follow request from this user.')
UnauthenticatedFollowFailure(message = 'You are not logged in. Please authenticate first.')
```

---

## Bloc

**`FollowStatusBloc`** (`@injectable` — factory)

**Events**:
```dart
LoadFollowStatus(String username)
ToggleFollow(String username)
```

**States**:
```dart
FollowStatusInitial()
FollowStatusLoading()
FollowStatusLoaded({ required FollowStatusEntity followStatus, bool isUpdating = false })
// FollowStatusLoaded has copyWith()
FollowStatusError({ required String message })
```

**Handlers**:
- `_onLoadFollowStatus` → `GetFollowStatusUseCase`
- `_onToggleFollow` → dispatches `FollowUserUseCase` or `UnfollowUserUseCase` based on current `followStatus`
- `_doFollow` / `_doUnfollow` — private helpers with optimistic state update via `isUpdating: true`

---

## Routing

`FollowStatusBloc` is provisioned on the `/users/:username` route alongside `ProfileBloc`:

```dart
BlocProvider<FollowStatusBloc>(
  create: (_) => getIt<FollowStatusBloc>()..add(LoadFollowStatus(username)),
)
```

The follow button (`public_profile/follow_button.dart`) reads `FollowStatusBloc` state and dispatches `ToggleFollow`.
