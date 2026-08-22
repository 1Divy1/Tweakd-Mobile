# Email & Password Authentication — Progress

Tracking the end-to-end email/password auth work on branch `email-password-auth`, started 2026-08-20.
Identity is handled entirely by **Supabase Auth** (`supabase_flutter ^2.12.4`, gotrue 2.26.0); the Spring
backend is not involved in any of these flows.

---

## Scope

1. **Sign up** with email + password → email confirmation by entering the code from the
   email → onboarding.
2. **Sign in** — already existed; hardened (Supabase `AuthException`s were leaking past the data layer
   and collapsing into a single generic error).
3. **Password reset** — request → code emailed → verify → set new password.
4. **Password policy** — min 8 chars, at least one lowercase, one uppercase, one digit, one symbol.

## Decisions (confirmed with the owner, not assumed)

| Question | Answer |
|---|---|
| Is Supabase "Confirm email" on? | **Yes.** Originally link-based; the owner then migrated the templates to OTP codes (2026-08-20), so signup confirmation is a typed `{{ .Token }}` code, matching the reset flow. |
| Deep-link scheme | **`tweakd://signup-callback`** (replaces the old, unused `garajapp://login-callback`). Still registered on both platforms and passed as `emailRedirectTo`, but no template currently sends a link, so nothing exercises it. Kept as a safety net — see the note below. |
| Username on the signup form | **Dropped.** Onboarding already collects it with a live availability check (`GET /profile/exists/{username}`); collecting it twice would either duplicate the check or reserve a handle for an account that may never confirm. |
| Password reset mechanism | **OTP code**, not a reset link. Recommended and accepted because supabase_flutter uses the PKCE flow on mobile: a recovery *link* only completes on the exact device that requested it (the code verifier is in that device's local storage), and one-time links get burned by corporate email link-scanners. A typed code works from any device. The owner then applied the same reasoning to the signup confirmation. |
| Password rules | **≥ 8 chars, lowercase + uppercase + digit + symbol.** |

## Facts established from the live project (not assumed)

- Supabase project: `Tweakd` (`fybgmaigzidhbmhbgfhu`).
- Trigger `on_auth_user_created` → `public.handle_new_user()` **already inserts the `profiles` row**
  with `requires_onboarding = true` for every new `auth.users` row (staff accounts excepted). So a
  confirmed signup lands on `AuthenticatedRequiresOnboarding` → `/onboarding` with no extra work.
- `SupabaseAuthDataSource.checkAuthStatus()` signs the user out and reports "session expired" when the
  `profiles` row is missing (PGRST116). That path is not expected for signups, thanks to the trigger.
- Android already declared `garajapp://login-callback`; **iOS had no custom scheme at all** (only the
  Google reversed-client-id one), so a confirmation deep link could never have worked on iOS. Both
  platforms now register `tweakd://signup-callback`.
- Because every auth template is OTP-based, **no flow depends on the deep link any more.**
  `AuthBloc` still subscribes to `WatchExternalSignIn` (Supabase `signedIn` events it did not
  initiate) so a link-based template would work if one is ever reintroduced. The only cost is one
  extra `profiles` query at the moment a code is verified. Say the word and it comes out.

---

## Security notes / deliberate choices

- **No user enumeration on signup.** With confirmation on, Supabase returns a *success* response with an
  empty `identities` list when the email already belongs to an account. The app treats that exactly like a
  fresh signup ("check your inbox") and never says "this email is already registered".
- **Enumeration on sign-in is accepted, narrowly.** A sign-in attempt against an unconfirmed account
  returns `email_not_confirmed`, which does reveal that the address exists. Surfacing it is necessary —
  otherwise the user is stuck with an unexplained failure — so the app routes them to the confirmation
  screen with a resend button. Wrong-password and unknown-email both return the same
  `invalid_credentials` message.
- **Other sessions are revoked after a password reset** (`signOut(scope: SignOutScope.others)`), so a
  reset kicks out anyone signed in elsewhere with the old password. The resetting device stays signed in.
- **Passwords never touch the Spring backend, logs, or `debugPrint`.**
- **Rate limits are surfaced, not swallowed** — `over_email_send_rate_limit` / `over_request_rate_limit`
  get their own message so users stop hammering resend, and the resend buttons carry a 60s cooldown.
- The client-side password policy is **advisory**; the server is the real gate. See the dashboard checklist
  below — Supabase's own minimum must be raised to match, or the server stays the weaker of the two.

---

## Owner action items (Supabase dashboard — I can't set these via MCP)

- [ ] **Auth → URL Configuration → Redirect URLs**: add `tweakd://signup-callback`.
      Remove `garajapp://login-callback` if nothing else uses it.
- [ ] **Auth → Providers → Email**: keep "Confirm email" ON.
- [ ] **Auth → Sign In / Providers → Password settings**: set minimum length **8** and required characters
      to **lowercase, uppercase, digits and symbols** so the server matches the form.
- [ ] **Auth → Password settings**: enable **leaked password protection** (HaveIBeenPwned) — recommended.
- [x] **Auth → Email Templates → Confirm signup**: renders `{{ .Token }}`. Confirmed — template
      supplied by the owner 2026-08-20.
- [ ] **Auth → Email Templates → Reset Password**: must also render `{{ .Token }}`. The owner
      migrated "most" templates; confirm this one specifically, or the reset flow has no code to
      type.
- [ ] Note: `Site URL` must stay an `https://` URL. A custom scheme there makes Go's template escaping
      emit `#ZgotmplZ` and breaks every email link.

---

## File checklist

### Data layer
- [x] `data/exceptions/auth_exceptions.dart` — typed exceptions for every Supabase auth error we act on
- [x] `data/datasources/supabase_auth_data_source.dart` — `signUp`, `verifySignUpCode`,
      `resendSignUpEmail`, `requestPasswordReset`, `verifyPasswordResetCode`, `updatePassword`,
      `onSignedIn`;
      central `AuthException` → custom-exception mapping applied to **all** calls (sign-in included)
- [x] `data/models/sign_up_result_model.dart`
- [x] `data/repositories/auth_repository_impl.dart` — exception → failure mapping for the new paths

### Domain layer
- [x] `domain/entities/sign_up_result.dart`
- [x] `domain/failures/auth_failures.dart` — invalid credentials, email not confirmed, weak password,
      invalid/expired code, rate limited, same password
- [x] `domain/repositories/auth_repository.dart`
- [x] `domain/usecases/signup/email_password_signup.dart`
- [x] `domain/usecases/signup/verify_signup_code.dart`
- [x] `domain/usecases/signup/resend_signup_email.dart`
- [x] `domain/usecases/password_reset/request_password_reset.dart`
- [x] `domain/usecases/password_reset/verify_password_reset_code.dart`
- [x] `domain/usecases/password_reset/update_password.dart`

### Presentation layer
- [x] `presentation/utils/password_policy.dart` — the 4-rule policy + per-rule state for the live checklist
- [x] `presentation/utils/email_validator.dart`
- [x] `presentation/utils/auth_error_mapper.dart` — new codes
- [x] `presentation/bloc/signup/` — `SignUpBloc` (signup + code verification + resend)
- [x] `presentation/bloc/password_reset/` — `PasswordResetBloc` (request / verify / update)
- [x] `presentation/bloc/*` (root `AuthBloc`) — subscribes to Supabase auth-state changes so an
      externally established session (a link-based template, if one returns) re-checks auth status
      and routes the user onward; also fixed to honour `requiresOnboarding` after email sign-in
- [x] `presentation/pages/signup_page.dart` — username field removed, wired to `SignUpBloc`, live policy
- [x] `presentation/pages/confirm_email_page.dart` — code entry + resend
- [x] `presentation/pages/forgot_password_page.dart`
- [x] `presentation/pages/verify_reset_code_page.dart`
- [x] `presentation/pages/new_password_page.dart`
- [x] `presentation/widgets/password_requirements.dart`
- [x] `presentation/widgets/otp_code_field.dart`
- [x] `presentation/widgets/resend_email_button.dart`
- [x] `presentation/pages/login_page.dart` — "Forgot password?" now navigates; unconfirmed-email error
      routes to the confirmation screen

### Docs
- [x] `lib/features/authentication/README.md` — flows, use cases, error table, routes

### Wiring
- [x] `core/routes/app_router.dart` — `/signup/confirm`, `/forgot-password`, `/forgot-password/verify`,
      `/forgot-password/new-password`, each with its bloc provided in the route builder
- [x] `android/app/src/main/AndroidManifest.xml` — `tweakd://signup-callback` intent filter
- [x] `ios/Runner/Info.plist` — `tweakd` URL scheme
- [x] `lib/l10n/app_en.arb` + `app_ro.arb`, regenerated with `flutter gen-l10n`
- [x] `build_runner` regeneration for the new `@lazySingleton` / `@injectable` registrations

### Verification
- [x] `flutter analyze` — clean (3 pre-existing infos elsewhere, none from this work)
- [x] `flutter test` — 49 passing (10 new: password policy, email validator, error mapper)
- [ ] Manual run-through on a device (per standing instruction, Claude does not launch the app)

---

## Manual test plan for the owner

Do the dashboard checklist above first — the reset flow cannot work until the Reset Password template
renders `{{ .Token }}`.

1. **Signup happy path** — `/signup`, real email, password meeting all 4 rules → code entry screen.
   Type the code from the email → signed in → `/onboarding`. The email can be read on any
   device; nothing is device-bound any more.
2. **Wrong / expired signup code** — expect distinct messages, and the field to clear itself.
3. **Duplicate email** — sign up again with an address that already has an account: you should get the
   same code-entry screen with no hint that the account exists (the code that arrives won't verify,
   which is Supabase's behaviour, not a bug in the app).
4. **Weak password** — the Create-account button stays disabled until all four rules are green.
5. **Unconfirmed sign-in** — sign up, don't confirm, try to sign in → routed to the confirmation screen
   with a working Resend (60s cooldown).
6. **Password reset** — `/login` → "Forgot password?" → email → code from the email → new
   password → signed in. Confirm a session on a second device gets kicked out.
7. **Wrong / expired code** — expect distinct messages for a wrong code vs. an expired one.
8. **Reusing the old password** on the reset screen → "same password" message.
9. **Resend spam** — hit resend repeatedly → rate-limit message, not a generic error.

## Round 2 — signup confirmation switched from link to OTP (2026-08-20)

The owner migrated the Supabase email templates to OTP codes after the first pass landed, so the
confirm-signup email now renders `{{ .Token }}` instead of a button. Changes:
- `SupabaseAuthDataSource.verifySignUpCode()` → `verifyOTP(type: OtpType.signup)`, then
  `checkAuthStatus()`; new `VerifySignUpCode` use case, repository method and `SignUpCodeSubmitted`
  event on `SignUpBloc` (success emits the same `SignUpCompleted` state the confirmation-off path
  used).
- `ConfirmEmailPage` rebuilt as a code-entry screen (reuses `OtpCodeField` and `ResendEmailButton`
  from the reset flow); it no longer listens to `AuthBloc`, since the code path resolves the user
  itself.
- Dropped the "open this on the same device" warning — it only applied to the PKCE link.
- `emailRedirectTo` is still sent on signUp/resend and both platforms still register the scheme; it
  is simply unused while every template is OTP-based.

## Status: implementation complete, pending the Reset Password template check + a manual run-through

## Follow-up 2026-08-21 — OTP length is no longer assumed

The owner's Supabase project emails **8-digit** codes, while the app hardcoded 6 (`kOtpLength`),
so the Verify button never enabled. Fixed by removing the assumption entirely rather than
changing 6 to 8:

- `kOtpLength` deleted. `OtpCodeField` no longer sets `maxLength` and no longer auto-submits on
  the Nth digit; it exposes `onSubmitted` (keyboard "done") instead of `onCompleted`.
- Both code screens enable their button on a non-empty field and let Supabase's `verifyOTP` be
  the only judge of whether the code is correct.
- Copy in `app_en.arb` / `app_ro.arb` says "a code", not "a six-digit code", so the OTP length
  can be changed in the Supabase dashboard without shipping a client release.

Still digits-only on input, which matches `{{ .Token }}` in every Supabase configuration.
