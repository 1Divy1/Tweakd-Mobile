# Diff Details

Date : 2026-09-05 12:21:05

Directory /Users/mbpro/Developer/Apps/Tweakd-Mobile

Total : 72 files,  2996 codes, 582 comments, 509 blanks, all 4087 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [CONTEXT.md](/CONTEXT.md) | Markdown | 9 | 0 | 0 | 9 |
| [android/app/src/main/AndroidManifest.xml](/android/app/src/main/AndroidManifest.xml) | XML | 12 | 12 | 2 | 26 |
| [lib/core/deeplinks/deep\_link\_service.dart](/lib/core/deeplinks/deep_link_service.dart) | Dart | 80 | 46 | 23 | 149 |
| [lib/core/deeplinks/share\_link\_route.dart](/lib/core/deeplinks/share_link_route.dart) | Dart | 35 | 25 | 10 | 70 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 60 | 0 | 1 | 61 |
| [lib/core/di/modules/app\_links\_module.dart](/lib/core/di/modules/app_links_module.dart) | Dart | 7 | 4 | 2 | 13 |
| [lib/core/routes/app\_router.dart](/lib/core/routes/app_router.dart) | Dart | 13 | 9 | 2 | 24 |
| [lib/core/services/share\_launcher\_service.dart](/lib/core/services/share_launcher_service.dart) | Dart | 97 | 39 | 13 | 149 |
| [lib/features/authentication/presentation/pages/login\_page.dart](/lib/features/authentication/presentation/pages/login_page.dart) | Dart | 3 | 3 | 0 | 6 |
| [lib/features/authentication/presentation/pages/signup\_page.dart](/lib/features/authentication/presentation/pages/signup_page.dart) | Dart | 3 | 2 | 0 | 5 |
| [lib/features/authentication/presentation/pages/splash\_page.dart](/lib/features/authentication/presentation/pages/splash_page.dart) | Dart | 2 | 3 | 0 | 5 |
| [lib/features/badges/README.md](/lib/features/badges/README.md) | Markdown | 26 | 0 | 4 | 30 |
| [lib/features/badges/data/datasources/badge\_api\_data\_source.dart](/lib/features/badges/data/datasources/badge_api_data_source.dart) | Dart | 11 | 5 | 2 | 18 |
| [lib/features/badges/data/datasources/badge\_data\_source.dart](/lib/features/badges/data/datasources/badge_data_source.dart) | Dart | 3 | 13 | 2 | 18 |
| [lib/features/badges/data/repositories/badge\_repository\_impl.dart](/lib/features/badges/data/repositories/badge_repository_impl.dart) | Dart | 34 | 0 | 2 | 36 |
| [lib/features/badges/domain/repositories/badge\_repository.dart](/lib/features/badges/domain/repositories/badge_repository.dart) | Dart | 3 | 4 | 2 | 9 |
| [lib/features/badges/domain/usecases/get\_pending\_badge\_celebrations.dart](/lib/features/badges/domain/usecases/get_pending_badge_celebrations.dart) | Dart | 16 | 3 | 5 | 24 |
| [lib/features/badges/domain/usecases/mark\_badge\_celebrated.dart](/lib/features/badges/domain/usecases/mark_badge_celebrated.dart) | Dart | 22 | 3 | 7 | 32 |
| [lib/features/badges/presentation/bloc/celebration/cubit.dart](/lib/features/badges/presentation/bloc/celebration/cubit.dart) | Dart | 28 | 19 | 9 | 56 |
| [lib/features/badges/presentation/bloc/celebration/state.dart](/lib/features/badges/presentation/bloc/celebration/state.dart) | Dart | 11 | 5 | 8 | 24 |
| [lib/features/badges/presentation/widgets/badge\_celebration\_overlay.dart](/lib/features/badges/presentation/widgets/badge_celebration_overlay.dart) | Dart | 413 | 21 | 34 | 468 |
| [lib/features/feed/README.md](/lib/features/feed/README.md) | Markdown | 8 | 0 | 0 | 8 |
| [lib/features/feed/data/datasources/feed\_api\_data\_source.dart](/lib/features/feed/data/datasources/feed_api_data_source.dart) | Dart | -3 | 3 | 0 | 0 |
| [lib/features/feed/data/models/feed\_page\_model.dart](/lib/features/feed/data/models/feed_page_model.dart) | Dart | 28 | 7 | 5 | 40 |
| [lib/features/feed/domain/entities/feed\_page.dart](/lib/features/feed/domain/entities/feed_page.dart) | Dart | 15 | 7 | 5 | 27 |
| [lib/features/feed/domain/repositories/feed\_repository.dart](/lib/features/feed/domain/repositories/feed_repository.dart) | Dart | 0 | 3 | 0 | 3 |
| [lib/features/feed/domain/usecases/get\_global\_feed.dart](/lib/features/feed/domain/usecases/get_global_feed.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/feed/presentation/bloc/feed/bloc.dart](/lib/features/feed/presentation/bloc/feed/bloc.dart) | Dart | 18 | 2 | 0 | 20 |
| [lib/features/feed/presentation/bloc/feed/state.dart](/lib/features/feed/presentation/bloc/feed/state.dart) | Dart | 9 | 7 | 0 | 16 |
| [lib/features/feed/presentation/pages/feed\_page.dart](/lib/features/feed/presentation/pages/feed_page.dart) | Dart | 10 | 2 | 0 | 12 |
| [lib/features/forums/domain/entities/forum\_suggestion.dart](/lib/features/forums/domain/entities/forum_suggestion.dart) | Dart | 22 | 6 | 3 | 31 |
| [lib/features/forums/presentation/bloc/home/bloc.dart](/lib/features/forums/presentation/bloc/home/bloc.dart) | Dart | -19 | 0 | -1 | -20 |
| [lib/features/forums/presentation/bloc/home/event.dart](/lib/features/forums/presentation/bloc/home/event.dart) | Dart | -7 | -1 | -2 | -10 |
| [lib/features/forums/presentation/widgets/home/forums\_empty\_view.dart](/lib/features/forums/presentation/widgets/home/forums_empty_view.dart) | Dart | -7 | 0 | 0 | -7 |
| [lib/features/garage/README.md](/lib/features/garage/README.md) | Markdown | 77 | 0 | 15 | 92 |
| [lib/features/garage/data/datasources/garage\_api\_data\_source.dart](/lib/features/garage/data/datasources/garage_api_data_source.dart) | Dart | 26 | 16 | 5 | 47 |
| [lib/features/garage/data/models/car\_share\_model.dart](/lib/features/garage/data/models/car_share_model.dart) | Dart | 61 | 5 | 10 | 76 |
| [lib/features/garage/data/repositories/garage\_repository\_impl.dart](/lib/features/garage/data/repositories/garage_repository_impl.dart) | Dart | 87 | 4 | 5 | 96 |
| [lib/features/garage/domain/entities/car\_share.dart](/lib/features/garage/domain/entities/car_share.dart) | Dart | 75 | 32 | 22 | 129 |
| [lib/features/garage/domain/failures/garage\_failures.dart](/lib/features/garage/domain/failures/garage_failures.dart) | Dart | 7 | 5 | 2 | 14 |
| [lib/features/garage/domain/repositories/garage\_repository.dart](/lib/features/garage/domain/repositories/garage_repository.dart) | Dart | 11 | 8 | 4 | 23 |
| [lib/features/garage/domain/usecases/ensure\_car\_share\_link.dart](/lib/features/garage/domain/usecases/ensure_car_share_link.dart) | Dart | 22 | 3 | 6 | 31 |
| [lib/features/garage/domain/usecases/get\_car\_share\_qr.dart](/lib/features/garage/domain/usecases/get_car_share_qr.dart) | Dart | 18 | 5 | 6 | 29 |
| [lib/features/garage/domain/usecases/resolve\_share\_code.dart](/lib/features/garage/domain/usecases/resolve_share_code.dart) | Dart | 23 | 4 | 8 | 35 |
| [lib/features/garage/domain/usecases/set\_car\_share\_enabled.dart](/lib/features/garage/domain/usecases/set_car_share_enabled.dart) | Dart | 21 | 3 | 6 | 30 |
| [lib/features/garage/presentation/bloc/car\_share/bloc.dart](/lib/features/garage/presentation/bloc/car_share/bloc.dart) | Dart | 81 | 8 | 11 | 100 |
| [lib/features/garage/presentation/bloc/car\_share/event.dart](/lib/features/garage/presentation/bloc/car_share/event.dart) | Dart | 25 | 6 | 9 | 40 |
| [lib/features/garage/presentation/bloc/car\_share/state.dart](/lib/features/garage/presentation/bloc/car_share/state.dart) | Dart | 55 | 8 | 14 | 77 |
| [lib/features/garage/presentation/bloc/share\_resolve/cubit.dart](/lib/features/garage/presentation/bloc/share_resolve/cubit.dart) | Dart | 27 | 4 | 5 | 36 |
| [lib/features/garage/presentation/bloc/share\_resolve/state.dart](/lib/features/garage/presentation/bloc/share_resolve/state.dart) | Dart | 26 | 5 | 10 | 41 |
| [lib/features/garage/presentation/pages/about\_car\_page.dart](/lib/features/garage/presentation/pages/about_car_page.dart) | Dart | 17 | 4 | 1 | 22 |
| [lib/features/garage/presentation/pages/share\_landing\_page.dart](/lib/features/garage/presentation/pages/share_landing_page.dart) | Dart | 129 | 16 | 10 | 155 |
| [lib/features/garage/presentation/utils/garage\_error\_mapper.dart](/lib/features/garage/presentation/utils/garage_error_mapper.dart) | Dart | 8 | 0 | 0 | 8 |
| [lib/features/garage/presentation/widgets/share/share\_build\_sheet.dart](/lib/features/garage/presentation/widgets/share/share_build_sheet.dart) | Dart | 524 | 24 | 48 | 596 |
| [lib/features/garage/presentation/widgets/share/share\_origin.dart](/lib/features/garage/presentation/widgets/share/share_origin.dart) | Dart | 6 | 4 | 2 | 12 |
| [lib/features/garage/presentation/widgets/share/share\_qr\_dialog.dart](/lib/features/garage/presentation/widgets/share/share_qr_dialog.dart) | Dart | 236 | 13 | 22 | 271 |
| [lib/features/onboarding/presentation/pages/onboarding\_page.dart](/lib/features/onboarding/presentation/pages/onboarding_page.dart) | Dart | 2 | 2 | 0 | 4 |
| [lib/features/posts/presentation/widgets/post\_card.dart](/lib/features/posts/presentation/widgets/post_card.dart) | Dart | -8 | 2 | 0 | -6 |
| [lib/features/posts/presentation/widgets/saved\_posts/saved\_posts\_grid.dart](/lib/features/posts/presentation/widgets/saved_posts/saved_posts_grid.dart) | Dart | 0 | 1 | 0 | 1 |
| [lib/features/profile/presentation/widgets/shared/posts\_section.dart](/lib/features/profile/presentation/widgets/shared/posts_section.dart) | Dart | 1 | 4 | 0 | 5 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 26 | 104 | 26 | 156 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 57 | 0 | 26 | 83 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 59 | 0 | 26 | 85 |
| [lib/main.dart](/lib/main.dart) | Dart | 15 | 15 | 3 | 33 |
| [macos/Flutter/GeneratedPluginRegistrant.swift](/macos/Flutter/GeneratedPluginRegistrant.swift) | Swift | 2 | 0 | 0 | 2 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 3 | 0 | 0 | 3 |
| [test/features/badges/badge\_celebration\_cubit\_test.dart](/test/features/badges/badge_celebration_cubit_test.dart) | Dart | 67 | 4 | 24 | 95 |
| [test/features/badges/badge\_celebration\_overlay\_test.dart](/test/features/badges/badge_celebration_overlay_test.dart) | Dart | 115 | 7 | 25 | 147 |
| [test/features/feed/feed\_page\_model\_test.dart](/test/features/feed/feed_page_model_test.dart) | Dart | 51 | 4 | 8 | 63 |
| [test/features/garage/share\_link\_route\_test.dart](/test/features/garage/share_link_route_test.dart) | Dart | 77 | 10 | 12 | 99 |
| [windows/flutter/generated\_plugin\_registrant.cc](/windows/flutter/generated_plugin_registrant.cc) | C++ | 3 | 0 | 0 | 3 |
| [windows/flutter/generated\_plugins.cmake](/windows/flutter/generated_plugins.cmake) | CMake | 1 | 0 | 0 | 1 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details