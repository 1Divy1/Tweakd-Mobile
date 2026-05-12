# Feature: Authentication

Handles identity via Supabase (sessions, OAuth, JWT) and communicates onboarding state.

---

## Folder Structure

```
authentication/
├── data/
│   ├── datasources/supabase_auth_data_source.dart
│   ├── exceptions/auth_exceptions.dart
│   ├── models/user_model.dart
│   └── repositories/auth_repository_impl.dart
├── domain/
│   ├── entities/user.dart
│   ├── failures/auth_failures.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/
│       ├── auth/check_auth_status.dart
│       └── login/
│           ├── email_password_signin.dart
│           └── google_signin.dart
└── presentation/
    ├── bloc/bloc.dart, event.dart, state.dart
    ├── pages/login_page, signup_page, splash_page, onboarding_page
    ├── utils/auth_error_mapper.dart
    └── widgets/social_button_signin.dart
```

---

## Entity

```dart
UserEntity { id: String, requiresOnboarding: bool }
```

**Model** (`UserModel`):
- `fromProfile(User supabaseUser, Map<String,dynamic> profile)` — builds from Supabase session + profiles row
- `fromJson(Map<String,dynamic> json)`
- `toEntity() → UserEntity`

---

## Repository Interface

```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> checkAuthStatus();
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(LoginParams params);
  Future<Either<Failure, UserEntity>> googleSignIn();
}
```

Implemented by `AuthRepositoryImpl` (`@LazySingleton(as: AuthRepository)`).

**Exception → Failure mapping**:
- `NoActiveSessionException` → `UnauthenticatedFailure`
- `ServerException` → `ServerFailure`
- anything else → `UnknownFailure`

---

## Use Cases

| Class | Params | Return |
|---|---|---|
| `CheckAuthStatusUseCase` | `NoParams` | `UserEntity` |
| `EmailPasswordSignIn` | `LoginParams { email: String, password: String }` | `UserEntity` |
| `GoogleSignIn` | `NoParams` | `UserEntity` |

All annotated `@lazySingleton`.

---

## Data Source

**`SupabaseAuthDataSource`** (`@lazySingleton`)  
Constructor: `SupabaseAuthDataSource(SupabaseClient supabaseClient)`

| Method | Behaviour |
|---|---|
| `checkAuthStatus()` | Reads active session; queries Supabase `profiles` table by session user ID; returns `UserModel` |
| `emailPasswordSignIn(email, password)` | `supabaseClient.auth.signInWithPassword` then `checkAuthStatus()` |
| `googleSignIn()` | GoogleSignIn OAuth flow + Supabase `signInWithIdToken`; then `checkAuthStatus()` |
| `currentSession` (getter) | `supabaseClient.auth.currentSession` |
| `logOut()` | `supabaseClient.auth.signOut()` |

---

## Failures

```dart
UnauthenticatedFailure(String message = 'You are not logged in. Please authenticate first.')
```

---

## Bloc

**`AuthBloc`** (`@injectable` — factory)

**Events**:
```dart
CheckAuthStatus()
GoogleLoginRequested()
AppleLoginRequested()
EmailPasswordLoginSubmitted(String email, String password)
```

**States**:
```dart
AuthInitial()
AuthLoading()
Unauthenticated()
Authenticated(UserEntity user)
AuthenticatedRequiresOnboarding(UserEntity user)
AuthError(String message)
```

**Handlers**:
- `_onCheckAuthStatus` → `CheckAuthStatusUseCase`
- `_onLoginSubmitted` → `EmailPasswordSignIn`
- `_onGoogleLoginRequested` → `GoogleSignIn`

---

## Pages & Routing

| Route | Page | Bloc in route |
|---|---|---|
| `/` | `SplashPage` | reads root `AuthBloc` |
| `/signup` | `SignUpPage` | — |
| `/onboarding` | `OnboardingPage` | `ProfileBloc` (provided) |

`SplashPage` listens to `AuthBloc` and redirects:
- `Authenticated` → `/profile`
- `AuthenticatedRequiresOnboarding` → `/onboarding`
- `Unauthenticated` / `AuthError` → `/signup`
