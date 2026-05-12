# Feature: Search

Handles user search with debouncing and request cancellation.

---

## Folder Structure

```
search/
├── data/
│   ├── datasource/search_api_data_source.dart
│   ├── models/search_result_model.dart
│   └── repositories/search_repository_impl.dart
├── domain/
│   ├── entities/search_result.dart
│   ├── repositories/search_repository.dart
│   └── usecases/search_users.dart
└── presentation/
    ├── bloc/bloc.dart, event.dart, state.dart
    ├── pages/search_page.dart
    ├── utils/search_error_mapper.dart
    └── widgets/
        ├── search_empty_view
        ├── search_error_view
        ├── search_input
        ├── search_loading_view
        ├── search_result_card
        ├── search_results_view
        └── search_top_bar
```

---

## Entity

```dart
SearchResultEntity { id: String, username: String, avatarUrl: String? }
```

**Model** (`SearchResultModel`):
- `fromJson(Map<String,dynamic> json)` — accepts both `avatar_url` and `avatarUrl` keys
- `toEntity() → SearchResultEntity`

---

## Repository Interface

```dart
abstract class SearchRepository {
  Future<Either<Failure, List<SearchResultEntity>>> searchUsers(
    String query, { CancelToken? cancelToken }
  );
}
```

Implemented by `SearchRepositoryImpl` (`@LazySingleton(as: SearchRepository)`).

**Exception → Failure mapping**:
| Exception | Failure |
|---|---|
| `RequestCancelledException` | `RequestCancelledFailure` |
| `UnauthenticatedException` | `ServerFailure` (generic) |
| `NetworkException` | `NetworkFailure` |

---

## Use Case

**`SearchUsersUseCase`** (`@lazySingleton`)

Params: `SearchUsersParams { query: String, cancelToken: CancelToken? }`  
Return: `Future<Either<Failure, List<SearchResultEntity>>>`

---

## Data Source

**`SearchApiDataSource`** (`@lazySingleton`)  
Constructor: `SearchApiDataSource(AbstractHTTP http)`

| Method | Endpoint |
|---|---|
| `searchUsers(query, {cancelToken?})` | `GET /profile/search?q={query}` |

---

## Bloc

**`SearchBloc`** (`@injectable` — factory)

**Events**:
```dart
SearchQueryChanged(String query)   // user types — triggers debounce
SearchCleared()                    // user clears input
PerformSearch(String query)        // internal, dispatched after debounce delay
```

**States**:
```dart
SearchInitial()
SearchLoading(String query)
SearchSuccess({ required String query, required List<SearchResultEntity> results })
SearchError({ required String query, required String message })
```

**Key behaviour**:
- `SearchQueryChanged` applies a **300ms debounce** before dispatching `PerformSearch`
- Each new search cancels the previous in-flight request via `CancelToken`
- `_cancelActive()` cancels the active token
- `close()` cleans up the debounce timer and active token

`RequestCancelledFailure` is silently ignored (no error state emitted) since cancellations are intentional.

---

## Routing

| Route | Page | Bloc provisioned |
|---|---|---|
| `/search` | `SearchPage` | `SearchBloc` |

Uses `NoTransitionPage` — no slide animation when navigating from bottom nav.
