# Onboarding Refactor — Progress

Tracking the UI refactor of `lib/features/onboarding/` requested 2026-08-18.

## Scope
1. Remove visible borders from onboarding text fields / tiles / pills / cards — flat fill + soft shadow only, matching the borderless pattern already used elsewhere (`EditProfileField`, `InboxSearchField`, forum pickers/chips).
2. Responsive layout — avoid hardcoded dimensions where the layout should adapt to screen size.
3. Merge steps: Identity absorbs Role (step 03 disappears), Preferences absorbs Taste (step 04 disappears). 6 steps → 4 steps (Identity+Role, Preferences+Taste, Location, Notifications). New slim linear progress bar starts at 20% (signup already counts as step 1 of 5) and animates to the right on every forward navigation: `fraction = (step+1)/(stepCount+1)`.
4. Top bar: drop the bolt icon, switch "TWEAKD" to the `Tweakd.` wordmark (Bricolage Grotesque ExtraBold, accent 'k' + accent trailing dot) per the attached logo reference.

## Decisions made without re-asking (superseded — see below)
- ~~Bundled `Bricolage Grotesque` as a local variable font asset instead of adding the `google_fonts` package.~~ Corrected per owner feedback 2026-08-18: this was a dependency-shape decision (package vs. hand-fetched asset) that should have been asked about instead of decided unilaterally. Switched to `google_fonts: ^6.3.2` + `GoogleFonts.bricolageGrotesque(...)`; removed the bundled `assets/fonts/` files and the `fonts:` block from `pubspec.yaml`.
- Merged-step content/order and copy confirmed against the existing `onboardingGarageLabel` ("02 — PREFERENCES") l10n key and the attached screenshots — no separate section header for the folded-in Role/Taste content, just a field label ("ROLES" / "CATEGORIES") consistent with the reference screenshots.
- Taste minimum bumped from 1 → 3 selected categories (screenshot shows "pick at least 3").
- Identity step now depends on reference data (needs the roles list), so the ref-loading gate in `onboarding_page.dart` no longer special-cases step 0.

## File checklist
- [x] `pubspec.yaml` — `google_fonts` dependency (bundled-asset approach reverted)
- [x] `lib/l10n/app_en.arb` — merged copy, renumbered step labels, dropped step-name/rail keys
- [x] `lib/l10n/app_ro.arb` — same, translated
- [x] regenerate `lib/l10n/app_localizations*.dart` via `flutter gen-l10n`
- [x] `onboarding_chrome.dart` — new wordmark, linear progress bar, borderless bottom bar/back button
- [x] `onboarding_pickers.dart` — borderless selector tile / search field / choice pill
- [x] `identity_step.dart` — borderless fields, absorbs Role section
- [x] `car_preferences_step.dart` — renamed `GarageStep` → `PreferencesStep`, borderless, absorbs Taste section
- [x] `location_step.dart` — verified (no borders introduced by shared widgets)
- [x] `notifications_step.dart` — borderless banners/toggle rows
- [x] delete `role_step.dart`, `taste_step.dart`
- [x] `onboarding_page.dart` — 4-step wiring, validation, submit, ref-loading gate
- [x] `flutter analyze` clean (whole project, 0 new issues)

## Round 2 — bug fixes & polish (2026-08-18)
Reported after the first pass landed:
1. **Username field's right corners looked square.** Root cause: the app theme sets `inputDecorationTheme.filled: true, fillColor: AppColors.surface` globally; any `TextField` that doesn't override `filled: false` paints its own square-cornered fill rectangle flush against the parent container's edge, covering the rounded-corner cutout. Added `filled: false` to the username field, bio field, and picker search field (`identity_step.dart`, `onboarding_pickers.dart`) — this was the same root cause behind bug #4 below.
2. **Car icon removed** from the empty brand badge in `car_preferences_step.dart` (`_BrandBadge` now renders nothing, not an icon, when no brand is picked).
3. **Search field no longer autofocuses** — dropped `autofocus: true` from `_PickerSearchField` (shared by both the brand and model pickers). The keyboard now only opens when the user taps in.
4. **Search field's grey/white split fixed** — container fill changed from `AppColors.bg` (cream) to `AppColors.surface` (white); combined with the `filled: false` fix in #1, the field is now uniformly white with no residual color seam around the icon.
5. **`AppColors.accentSoft` (pale/light-orange fill) removed from onboarding** — swapped for `AppColors.ink` (black) paired with `AppColors.accent`-colored icon/text, mirroring the black-card-with-accent-highlight look already used by the location step's `_RadiusCard`. Touched: `_AddBrandButton`, the granted-push icon chip, and the (currently unused) `OnboardingNoteCard`.
6. **Brand selection is now required** — added `_hasBrand` check to step-1 validation and the pre-submit re-check in `onboarding_page.dart`, plus a new `onboardingErrorPickBrand` l10n string (en + ro); dropped `optional: true` from the "YOUR PICKS" field label.
7. **Push-notification request card is black, not orange** — `_ActionBanner`'s `filled: true` case (the "enable push" CTA card) now fills with `AppColors.ink`; the white button + accent-orange label inside were left as-is since they already read well against black.
8. **Top-left back button removed** from `OnboardingTopBar` entirely (no back affordance in the chrome anymore); `_onTopBack` deleted from `onboarding_page.dart`. The bottom bar's BACK button (visible from step 2 onward) is unaffected and still lets you revisit an earlier step.

Also corrected per owner feedback: switched the Bricolage Grotesque font from a hand-bundled local asset to the `google_fonts` package (see the struck-through note above) — this should have been asked about up front rather than decided unilaterally; saved as a standing reminder in memory (`feedback_ask_never_assume`).

Note: the wordmark's 'k' color was hand-edited by the owner directly in `onboarding_chrome.dart` (now `Colors.redAccent` instead of `AppColors.accent`) while this round was in progress — left untouched.

`flutter analyze` (whole project) and `flutter test` both clean after round 2.

## Round 3 — role & category selection removed (2026-08-18)
Owner dropped the backing Supabase tables (`profile_community_roles_junction`, `community_role_options`, `profile_car_categories_junction`, `car_category_options`) and the backend logic, so the feature is gone end-to-end, not just hidden in the UI:
- Identity step (01) no longer shows the ROLES picker; Preferences step (02) no longer shows the CATEGORIES picker.
- Deleted: `domain/entities/onboarding reference/community_role_entity.dart`, `car_category_entity.dart`; `domain/usecases/get_community_roles.dart`, `get_car_categories.dart`; `data/models/onboarding reference/community_role_model.dart`, `car_category_model.dart`.
- `OnboardingRepository`/`OnboardingRepositoryImpl`/`OnboardingApiDataSource` — removed `getCommunityRoles()`/`getCarCategories()` (was hitting `/profile/reference/community-roles` and `/profile/reference/car-categories`, both gone from the backend).
- `OnboardingSubmissionParams` no longer sends `category_ids`/`role_ids` in the `POST /profile/onboarding` body.
- `OnboardingBloc`/`OnboardingRefLoaded` no longer depend on `GetCommunityRolesUseCase`/`GetCarCategoriesUseCase` or carry `communityRoles`/`carCategories`.
- `onboarding_page.dart` dropped `_roleIds`/`_categoryIds` state, validation and submit re-checks; brand selection is still required (unrelated to this change).
- `kMinTasteCategories` constant removed along with the "N selected · pick at least 3" hint text.
- l10n: dropped `onboardingErrorPickRole`, `onboardingErrorPickCategory`, `onboardingFieldRoles`, `onboardingFieldCategories`, `onboardingTasteSelectedCount`, `onboardingTastePickHint` (en+ro); reworded `onboardingIdentityTitle/Subtitle` and `onboardingGarageTitle/Subtitle` to drop the now-false "& role" / "& taste" framing.
- Regenerated l10n (`flutter gen-l10n`) and DI config (`build_runner`, since `OnboardingBloc`'s constructor shape changed). `flutter analyze` clean, all 39 tests pass.

## Round 4 — notifications payload shape changed (2026-08-18)
Backend note: `PUT /profile/me/notifications` now requires 9 fields (still full-replace, 400 if any is missing).
- `price_drops_enabled` → **removed**, replaced in the same slot by `service_reminders_enabled` (reminders for scheduled services / expiring documents on the user's cars — no backend producer wired up yet, safe to ship the toggle ahead of it).
- `event_organizer_enabled` → **new field**, didn't exist in the app at all before. Gates notifications when someone enters a car in your event, is added as co-organizer, or asks to withdraw. Added as a new toggle in the "MEETS & EVENTS" group, right after "Organized events".
- Since the old "MARKETPLACE" group only ever held the price-drops toggle, and that toggle is now about car service/documents (not marketplace), renamed the group to "YOUR GARAGE" (owner confirmed this call).
- Touched: `NotificationPreferences` entity (field rename + new field + updated `toJson`/`copyWith`/`defaults`/`props`), `notifications_step.dart` (renamed group + toggle, added the new toggle row with a `car_repair_rounded` icon for service reminders and `admin_panel_settings_rounded` for event organizer), l10n en+ro (dropped `onboardingNotifGroupMarketplace`/`onboardingNotifPriceDrops*`, added `onboardingNotifGroupGarage`, `onboardingNotifServiceReminders*`, `onboardingNotifEventOrganizer*`).
- No other UI surface exists for notification prefs yet (onboarding is the only place they're edited — the entity has no `fromJson`, it's write-only), so nothing else needed updating.
- Regenerated l10n; `flutter analyze` clean, all 39 tests pass.

## Not done / needs manual check
- Not run in a simulator — per standing instruction, Claude does not launch the app. Please run the onboarding flow manually to confirm all of the above, especially the rounded corners and the search field appearance on a real device/simulator.

## Status: COMPLETE (pending manual run-through)
