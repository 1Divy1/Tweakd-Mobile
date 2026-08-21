# Feature: Authentication

Handles identity via Supabase (sessions, OAuth, JWT) and communicates onboarding state.

---

## Folder Structure

```
authentication/
├── data/
│   ├── datasources/supabase_auth_data_source.dart
│   ├── exceptions/auth_exceptions.dart
│   ├── models/user_model.dart, sign_up_result_model.dart
│   └── repositories/auth_repository_impl.dart
├── domain/
│   ├── entities/user.dart, sign_up_result.dart
│   ├── failures/auth_failures.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/
│       ├── auth/check_auth_status.dart, log_out.dart, watch_external_sign_in.dart
│       ├── login/email_password_signin.dart, google_signin.dart
│       ├── signup/email_password_signup.dart, verify_signup_code.dart,
│       │   resend_signup_email.dart
│       └── password_reset/request_password_reset.dart,
│           verify_password_reset_code.dart, update_password.dart
└── presentation/
    ├── bloc/bloc.dart, event.dart, state.dart        (AuthBloc — session + sign-in)
    ├── bloc/signup/                                   (SignUpBloc)
    ├── bloc/password_reset/                           (PasswordResetBloc)
    ├── pages/splash_page, login_page, signup_page, confirm_email_page,
    │         forgot_password_page, verify_reset_code_page, new_password_page
    ├── utils/auth_error_mapper.dart, password_policy.dart, email_validator.dart
    └── widgets/auth_*, password_requirements, otp_code_field, resend_email_button
```

---

## Email & password flows

**Sign up** (`/signup` → `SignUpBloc`)
Email + password only — the username is collected during onboarding, which
already checks availability against the backend. The form enforces
[`PasswordPolicy`](presentation/utils/password_policy.dart): ≥ 8 characters with
a lowercase letter, an uppercase letter, a digit and a symbol from Supabase's
own symbol set. Supabase's dashboard policy must match or exceed this; the
server is the real gate.

`supabase.auth.signUp()` returns a user but **no session** (email confirmation
is on), so the app moves to `/signup/confirm`. If the address already has an
account, Supabase returns the same shape with an empty `identities` list — the
app reports the identical result so the form cannot be used to discover
registered addresses.

**Confirmation** (`/signup/confirm`)
The confirm-signup email template renders `{{ .Token }}`, so activation is a
typed code: `verifyOTP(type: OtpType.signup)` → session →
`checkAuthStatus()` → `/onboarding`. Nothing is device-bound; the email can be
read anywhere. Resend has a 60 s cooldown to stay inside Supabase's email rate
limit.

**About the deep link.** `tweakd://signup-callback` is registered in
`AndroidManifest.xml` and `Info.plist`, is on Supabase's redirect allow-list, and
is still passed as `emailRedirectTo`. No template currently sends a link, so
nothing exercises it. `AuthBloc` subscribes to `WatchExternalSignIn` — Supabase
`signedIn` events the app did not initiate — so a link-based template would work
again if one is reintroduced.

**Password reset** (`/forgot-password` → `/verify` → `/new-password`)
Code-based, not link-based: `resetPasswordForEmail` → `{{ .Token }}`
by email → `verifyOTP(type: OtpType.recovery)` → `updateUser(password:)`. A code
can be read on any device, where a recovery *link* would only complete on the
device that started the flow. Saving revokes every other session
(`signOut(scope: SignOutScope.others)`). The **Reset Password email template
must render `{{ .Token }}`** or this flow has nothing to type.

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
  Future<Either<Failure, Unit>> logOut();
  Future<Either<Failure, SignUpResultEntity>> signUp(SignUpParams params);
  Future<Either<Failure, UserEntity>> verifySignUpCode(
    VerifySignUpCodeParams params,
  );
  Future<Either<Failure, Unit>> resendSignUpEmail(String email);
  Future<Either<Failure, Unit>> requestPasswordReset(String email);
  Future<Either<Failure, Unit>> verifyPasswordResetCode(
    VerifyPasswordResetCodeParams params,
  );
  Future<Either<Failure, UserEntity>> updatePassword(String newPassword);
  Stream<void> get onExternalSignIn;
}
```

Implemented by `AuthRepositoryImpl` (`@LazySingleton(as: AuthRepository)`).

**Exception → Failure mapping** — one table in `AuthRepositoryImpl._toFailure`,
so a new call site cannot collapse a specific error into the generic one:

| Exception | Failure |
|---|---|
| `NoActiveSessionException`, `UnauthenticatedException` | `UnauthenticatedFailure` |
| `InvalidCredentialsException` | `InvalidCredentialsFailure` |
| `EmailNotConfirmedException` | `EmailNotConfirmedFailure` |
| `WeakPasswordException` | `WeakPasswordFailure` |
| `InvalidOtpException` / `ExpiredOtpException` | `InvalidCodeFailure` / `ExpiredCodeFailure` |
| `RateLimitedException` | `RateLimitedFailure` |
| `SamePasswordException` | `SamePasswordFailure` |
| `SignUpDisabledException` | `SignUpDisabledFailure` |
| `ServerException` | `ServerFailure` |
| `NetworkException` | `NetworkFailure` |
| anything else | `UnknownFailure` |

Supabase `AuthException`s are translated in
`SupabaseAuthDataSource._mapAuthException` (keyed on gotrue's `code`) and never
escape the data layer.

---

## Use Cases

| Class | Params | Return |
|---|---|---|
| `CheckAuthStatusUseCase` | `NoParams` | `UserEntity` |
| `EmailPasswordSignIn` | `LoginParams { email, password }` | `UserEntity` |
| `GoogleSignIn` | `NoParams` | `UserEntity` |
| `LogOut` | `NoParams` | `Unit` |
| `EmailPasswordSignUp` | `SignUpParams { email, password }` | `SignUpResultEntity` |
| `VerifySignUpCode` | `VerifySignUpCodeParams { email, code }` | `UserEntity` |
| `ResendSignUpEmail` | `String email` | `Unit` |
| `RequestPasswordReset` | `String email` | `Unit` |
| `VerifyPasswordResetCode` | `VerifyPasswordResetCodeParams { email, code }` | `Unit` |
| `UpdatePassword` | `String newPassword` | `UserEntity` |
| `WatchExternalSignIn` | — (not a `UseCase`) | `Stream<void>` |

All annotated `@lazySingleton`.

---

## Data Source

**`SupabaseAuthDataSource`** (`@lazySingleton`)  
Constructor: `SupabaseAuthDataSource(SupabaseClient supabaseClient)`

| Method | Behaviour |
|---|---|
| `checkAuthStatus()` | Reads active session; queries Supabase `profiles` table by session user ID; returns `UserModel` |
| `emailPasswordSignIn(email, password)` | `signInWithPassword` then `checkAuthStatus()` |
| `signUp(email, password)` | `signUp(emailRedirectTo: kSignUpEmailRedirect)`; returns `SignUpResultModel` |
| `verifySignUpCode(email, code)` | `verifyOTP(type: OtpType.signup)` then `checkAuthStatus()` |
| `resendSignUpEmail(email)` | `resend(type: OtpType.signup)` |
| `requestPasswordReset(email)` | `resetPasswordForEmail` (no `redirectTo` — code flow) |
| `verifyPasswordResetCode(email, code)` | `verifyOTP(type: OtpType.recovery)` |
| `updatePassword(newPassword)` | `updateUser` then `signOut(scope: others)`, then `checkAuthStatus()` |
| `googleSignIn()` | GoogleSignIn OAuth flow + Supabase `signInWithIdToken`; then `checkAuthStatus()` |
| `currentSession` (getter) | `supabaseClient.auth.currentSession` |
| `onSignedIn` (getter) | `onAuthStateChange` filtered to `signedIn` — how the confirmation deep link is noticed |
| `logOut()` | `supabaseClient.auth.signOut()` + Google sign-out + secure-storage wipe |

---

## Failures

See the exception → failure table above. All live in
`domain/failures/auth_failures.dart`; the presentation layer never reads their
messages directly — `AuthErrorMapper` turns each into an `AuthErrorCode`, and
`authErrorMessage(l10n, code)` produces the localized copy.

---

## Bloc

**`AuthBloc`** (`@injectable` — factory)

**Events**:
```dart
CheckAuthStatus()
GoogleLoginRequested()
AppleLoginRequested()
EmailPasswordLoginSubmitted(String email, String password)
LogoutRequested()
```

It also subscribes to `WatchExternalSignIn` in its constructor and re-runs
`CheckAuthStatus` when a session appears on its own (the confirmation deep
link), skipping it while one of its own flows is mid-flight.

**`SignUpBloc`** (`@injectable`) — `SignUpSubmitted`, `SignUpCodeSubmitted`,
`ConfirmationEmailResendRequested` → `SignUpAwaitingConfirmation` /
`SignUpCompleted` / `SignUpResendSucceeded` / `SignUpFailed`.

**`PasswordResetBloc`** (`@injectable`) — `ResetCodeRequested`,
`ResetCodeSubmitted`, `NewPasswordSubmitted` → `ResetCodeSent` /
`ResetCodeVerified` / `PasswordResetCompleted` / `PasswordResetFailed`. One
instance per step; the recovery session lives in the Supabase client, so nothing
but the email address travels between screens.

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
| `/login` | `LoginPage` | reads root `AuthBloc` |
| `/signup` | `SignUpPage` | `SignUpBloc` |
| `/signup/confirm` | `ConfirmEmailPage` — code entry (email via `extra`) | `SignUpBloc` |
| `/forgot-password` | `ForgotPasswordPage` | `PasswordResetBloc` |
| `/forgot-password/verify` | `VerifyResetCodePage` (email via `extra`) | `PasswordResetBloc` |
| `/forgot-password/new-password` | `NewPasswordPage` | `PasswordResetBloc` |
| `/onboarding` | `OnboardingPage` | `OnboardingBloc` + `UsernameAvailabilityBloc` |

`SplashPage` listens to `AuthBloc` and redirects:
- `Authenticated` → `/profile`
- `AuthenticatedRequiresOnboarding` → `/onboarding`
- `Unauthenticated` / `AuthError` → `/signup`
