# Rename: Car Social Media App → Tweakd

Launch rename. Decisions locked by the owner on 2026-08-22.

## Locked decisions

| Thing | Value | Note |
|---|---|---|
| Product name | **Tweakd** | |
| Domain owned | `tweakdapp.com` | justifies the bundle ID |
| iOS/Android bundle ID | `com.tweakdapp` | **irreversible after first store upload** |
| macOS bundle ID | `com.tweakdapp` | |
| Dart package | `tweakd` | `package:tweakd/...` |
| Android namespace + Kotlin pkg | `com.tweakdapp` | |
| Backend base package | `com.tweakdapp.backend` | Maven groupId `com.tweakdapp`, artifactId stays `backend` |
| Deep link scheme | `tweakd://` | already in place before this rename |
| GitHub repos | `Tweakd-Mobile`, `Tweakd-Backend` | moving to a new `Tweakd` org |
| Local folders | `Tweakd-App`, `Tweakd-Backend` | ⚠️ mismatch with repo name — see open questions |
| Out of scope | `Car-Social-Media-Useful-Stuff`, `Tweakd-Dashboard` | owner: app + backend only |

---

## ✅ Done — Flutter app (`Car-Social-Media-App`)

- `pubspec.yaml`: `name: tweakd`, real description
- All 160 files rewritten `package:car_social_media_app/` → `package:tweakd/` (lib + test)
- Android: `namespace = "com.tweakdapp"`; `MainActivity.kt` moved
  `kotlin/com/example/car_social_media_app/` → `kotlin/com/tweakdapp/`, package line updated
- macOS: `AppInfo.xcconfig` PRODUCT_NAME `Tweakd`, bundle ID `com.tweakdapp`, copyright;
  `project.pbxproj` + `Runner.xcscheme` → `Tweakd.app`, tests bundle `com.tweakdapp.RunnerTests`
- Linux: `BINARY_NAME tweakd`, `APPLICATION_ID com.tweakdapp`, window titles `Tweakd`
- Windows: CMake project/binary `tweakd`, `main.cpp` title, all `Runner.rc` version strings
- Web: `index.html` title + apple web app title, `manifest.json` name/short_name/description
- `car_social_media_app.iml` → `tweakd.iml`
- `README.md` rewritten; `CLAUDE.md` + `CONTEXT.md` import convention line updated
- Root widget class `CarSocialMediaApp` → `TweakdApp` in `main.dart`
- `CONTEXT.md` still carried the *older* name "Cargram" in its title/Name field — also updated
- Regenerated `injection.config.dart` via build_runner

**Verified:** Android debug APK builds (exit 0) — namespace valid.
`flutter analyze` → 3 issues, all pre-existing and unrelated
(`app_bottom_nav.dart` curly braces, `usecase.dart` type param, `main.dart` deprecated `anonKey`).
`flutter test` → **49/49 pass**.

## ✅ Done — Backend (`Car-Social-Media-Backend/backend`)

- `src/main/java/com/carsocialmedia` → `src/main/java/com/tweakdapp` (git mv, history kept)
- `src/test/java/com/carsocialmedia` → `src/test/java/com/tweakdapp`
- All `com.carsocialmedia` → `com.tweakdapp` across 699 Java files, `package-info.java`
  Spring Modulith declarations, and every in-tree module `README.md`
- `pom.xml` groupId → `com.tweakdapp`
- `docker-compose.yml` image + container_name → `tweakd-backend`
- Backend docs (`CONTEXT.md`, progress/testing `.md`s) updated

**Verified:** `./mvnw compile` → OK.
`./mvnw test` → **607 tests run, 0 failures, 94 errors** — none caused by the rename:
- **92 errors**: every one is an `*IT` class dying on
  `IllegalStateException: Could not find a valid Docker environment`.
  Testcontainers needs Docker; Docker is not running on this machine.
- **2 errors**: `MapEventsServiceImplTest` NPEs at `MapEventsServiceImpl.java:399`
  (`event` is null in `createEvent`). **Pre-existing** — the leftover pre-rename
  surefire report in `target/` shows the identical `Tests run: 53, Errors: 2`.
  My diff to that file is the package line only. Worth fixing, unrelated to this work.
- ✅ `ModularityTests` (Spring Modulith boundary verification) → **2 run, 0 errors**
  under the new package. This is the check that would break if the rename were wrong.

### Deliberately NOT changed
`cloudbuild.yaml` still points at
`europe-west1-docker.pkg.dev/car-gram-social-media-app/cloud-run-source-deploy/car-social-media-backend/tweakd-backend`.
Those are **live GCP resources**, not source names:
- `car-gram-social-media-app` is the GCP **project ID** — immutable in GCP, ever. Only its
  display name can change.
- `car-social-media-backend` is an Artifact Registry repo — renaming means creating a new repo
  and re-pointing the trigger.

Changing either string here would break deploys. Left alone on purpose.

---

## ⬜ Remaining — owner actions (outside the codebase)

1. Create the `Tweakd` GitHub org
2. Transfer both repos in, rename to `Tweakd-Mobile` / `Tweakd-Backend`
3. Re-point local git remotes
4. Rename local folders `Tweakd-App` (or `Tweakd-Mobile`) + `Tweakd-Backend`
5. Supabase project display name
6. **Google OAuth consent screen app name** — user-visible on the Google sign-in sheet
7. GCP project display name; Cloud Run service name if desired
8. Supabase auth email templates (confirm / reset) — they name the app
9. ⚠️ Do **not** rename R2 buckets — the API token is bucket-scoped and will 403

## Open question
Local folder `Tweakd-App` vs GitHub repo `Tweakd-Mobile` — cloning the repo produces a
`Tweakd-Mobile` folder, so the two drift. Recommend using `Tweakd-Mobile` for both.
