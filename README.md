# Tweakd

The social network for car people — built with Flutter.

Tweakd is the mobile client. It talks to a Spring Boot backend (`Tweakd-Backend`)
for app data and to Supabase for identity, realtime messaging and storage.

- **Bundle ID / applicationId:** `com.tweakdapp`
- **Deep link scheme:** `tweakd://`
- **Dart package:** `tweakd`

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

You'll need a `.env` at the repo root (see `CLAUDE.md` for the required keys:
Supabase, Google OAuth, Mapbox and the backend base URL).

## Commands

```bash
flutter analyze                            # static analysis
flutter test                               # all tests
dart run build_runner build --delete-conflicting-outputs   # DI codegen
flutter gen-l10n                           # localizations
```

## Architecture

Clean Architecture per feature (`presentation → domain → data`), `get_it` +
`injectable` for DI, `flutter_bloc` for state, `go_router` for navigation.
See [CLAUDE.md](CLAUDE.md) for the full guide.
