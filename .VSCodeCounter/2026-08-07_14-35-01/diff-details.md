# Diff Details

Date : 2026-08-07 14:35:01

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 67 files,  1719 codes, 401 comments, 365 blanks, all 2485 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [.claude/settings.local.json](/.claude/settings.local.json) | JSON | 3 | 0 | 0 | 3 |
| [COMMENT\_TAGGING\_PROGRESS.md](/COMMENT_TAGGING_PROGRESS.md) | Markdown | -75 | 0 | -14 | -89 |
| [FORUMS\_PROGRESS.md](/FORUMS_PROGRESS.md) | Markdown | -310 | 0 | -37 | -347 |
| [MESSAGES\_PROGRESS.md](/MESSAGES_PROGRESS.md) | Markdown | -223 | 0 | -18 | -241 |
| [MINI\_FEATURES\_PROGRESS.md](/MINI_FEATURES_PROGRESS.md) | Markdown | -437 | 0 | -54 | -491 |
| [SUPABASE\_REALTIME\_MIGRATION.md](/SUPABASE_REALTIME_MIGRATION.md) | Markdown | -165 | 0 | -38 | -203 |
| [TAGS\_PROGRESS.md](/TAGS_PROGRESS.md) | Markdown | -90 | 0 | -20 | -110 |
| [android/app/src/main/AndroidManifest.xml](/android/app/src/main/AndroidManifest.xml) | XML | 2 | 2 | 0 | 4 |
| [dart\_defines.dev.json](/dart_defines.dev.json) | JSON | 3 | 0 | 0 | 3 |
| [dart\_defines.prod.json](/dart_defines.prod.json) | JSON | 3 | 0 | 0 | 3 |
| [ios/Podfile](/ios/Podfile) | Ruby | 1 | -1 | 0 | 0 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 38 | 0 | 0 | 38 |
| [lib/core/realtime/supabase\_dm\_realtime\_service.dart](/lib/core/realtime/supabase_dm_realtime_service.dart) | Dart | 47 | 23 | 6 | 76 |
| [lib/core/realtime/supabase\_presence\_service.dart](/lib/core/realtime/supabase_presence_service.dart) | Dart | 39 | 9 | 5 | 53 |
| [lib/core/routes/app\_router.dart](/lib/core/routes/app_router.dart) | Dart | 12 | 1 | 1 | 14 |
| [lib/core/shared/widgets/app\_bottom\_nav.dart](/lib/core/shared/widgets/app_bottom_nav.dart) | Dart | 1 | -1 | 0 | 0 |
| [lib/features/feed/presentation/pages/feed\_page.dart](/lib/features/feed/presentation/pages/feed_page.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/forums/presentation/pages/forum\_hub\_page.dart](/lib/features/forums/presentation/pages/forum_hub_page.dart) | Dart | 22 | 0 | 0 | 22 |
| [lib/features/forums/presentation/pages/forum\_thread\_page.dart](/lib/features/forums/presentation/pages/forum_thread_page.dart) | Dart | 18 | 0 | 0 | 18 |
| [lib/features/forums/presentation/pages/forums\_home\_page.dart](/lib/features/forums/presentation/pages/forums_home_page.dart) | Dart | 23 | 0 | 0 | 23 |
| [lib/features/forums/presentation/widgets/shared/forum\_avatar.dart](/lib/features/forums/presentation/widgets/shared/forum_avatar.dart) | Dart | 5 | 3 | 0 | 8 |
| [lib/features/map/README.md](/lib/features/map/README.md) | Markdown | 484 | 0 | 127 | 611 |
| [lib/features/map/data/datasources/business\_api\_data\_source.dart](/lib/features/map/data/datasources/business_api_data_source.dart) | Dart | 41 | 5 | 7 | 53 |
| [lib/features/map/data/datasources/device\_location\_data\_source.dart](/lib/features/map/data/datasources/device_location_data_source.dart) | Dart | 44 | 15 | 7 | 66 |
| [lib/features/map/data/exceptions/map\_exceptions.dart](/lib/features/map/data/exceptions/map_exceptions.dart) | Dart | 4 | 5 | 1 | 10 |
| [lib/features/map/data/models/business\_detail\_model.dart](/lib/features/map/data/models/business_detail_model.dart) | Dart | 110 | 1 | 6 | 117 |
| [lib/features/map/data/models/business\_hours\_model.dart](/lib/features/map/data/models/business_hours_model.dart) | Dart | 33 | 1 | 5 | 39 |
| [lib/features/map/data/models/business\_pin\_model.dart](/lib/features/map/data/models/business_pin_model.dart) | Dart | 57 | 1 | 5 | 63 |
| [lib/features/map/data/repositories/map\_repository\_impl.dart](/lib/features/map/data/repositories/map_repository_impl.dart) | Dart | 94 | 2 | 7 | 103 |
| [lib/features/map/domain/entities/business\_detail\_entity.dart](/lib/features/map/domain/entities/business_detail_entity.dart) | Dart | 81 | 10 | 14 | 105 |
| [lib/features/map/domain/entities/business\_hours\_entity.dart](/lib/features/map/domain/entities/business_hours_entity.dart) | Dart | 23 | 11 | 5 | 39 |
| [lib/features/map/domain/entities/business\_pin\_entity.dart](/lib/features/map/domain/entities/business_pin_entity.dart) | Dart | 40 | 8 | 12 | 60 |
| [lib/features/map/domain/entities/geo\_position.dart](/lib/features/map/domain/entities/geo_position.dart) | Dart | 21 | 9 | 7 | 37 |
| [lib/features/map/domain/failures/map\_failures.dart](/lib/features/map/domain/failures/map_failures.dart) | Dart | 7 | 5 | 3 | 15 |
| [lib/features/map/domain/map\_defaults.dart](/lib/features/map/domain/map_defaults.dart) | Dart | 5 | 9 | 5 | 19 |
| [lib/features/map/domain/repositories/map\_repository.dart](/lib/features/map/domain/repositories/map_repository.dart) | Dart | 20 | 9 | 5 | 34 |
| [lib/features/map/domain/usecases/get\_business\_detail.dart](/lib/features/map/domain/usecases/get_business_detail.dart) | Dart | 27 | 0 | 7 | 34 |
| [lib/features/map/domain/usecases/get\_current\_position.dart](/lib/features/map/domain/usecases/get_current_position.dart) | Dart | 15 | 0 | 5 | 20 |
| [lib/features/map/domain/usecases/get\_nearby\_businesses.dart](/lib/features/map/domain/usecases/get_nearby_businesses.dart) | Dart | 40 | 0 | 7 | 47 |
| [lib/features/map/presentation/bloc/map/bloc.dart](/lib/features/map/presentation/bloc/map/bloc.dart) | Dart | 186 | 23 | 36 | 245 |
| [lib/features/map/presentation/bloc/map/event.dart](/lib/features/map/presentation/bloc/map/event.dart) | Dart | 34 | 11 | 15 | 60 |
| [lib/features/map/presentation/bloc/map/state.dart](/lib/features/map/presentation/bloc/map/state.dart) | Dart | 94 | 16 | 19 | 129 |
| [lib/features/map/presentation/pages/map\_page.dart](/lib/features/map/presentation/pages/map_page.dart) | Dart | 159 | 50 | 19 | 228 |
| [lib/features/map/presentation/utils/business\_marker\_factory.dart](/lib/features/map/presentation/utils/business_marker_factory.dart) | Dart | 124 | 31 | 29 | 184 |
| [lib/features/map/presentation/utils/map\_error\_mapper.dart](/lib/features/map/presentation/utils/map_error_mapper.dart) | Dart | 21 | 2 | 5 | 28 |
| [lib/features/map/presentation/widgets/businesses/business\_hours\_list.dart](/lib/features/map/presentation/widgets/businesses/business_hours_list.dart) | Dart | 84 | 8 | 14 | 106 |
| [lib/features/map/presentation/widgets/businesses/business\_popup.dart](/lib/features/map/presentation/widgets/businesses/business_popup.dart) | Dart | 209 | 13 | 20 | 242 |
| [lib/features/map/presentation/widgets/businesses/business\_popup\_content.dart](/lib/features/map/presentation/widgets/businesses/business_popup_content.dart) | Dart | 241 | 5 | 24 | 270 |
| [lib/features/map/presentation/widgets/map\_error\_banner.dart](/lib/features/map/presentation/widgets/map_error_banner.dart) | Dart | 56 | 4 | 6 | 66 |
| [lib/features/map/presentation/widgets/map\_layer\_controller.dart](/lib/features/map/presentation/widgets/map_layer_controller.dart) | Dart | 226 | 58 | 39 | 323 |
| [lib/features/map/presentation/widgets/map\_recentre\_button.dart](/lib/features/map/presentation/widgets/map_recentre_button.dart) | Dart | 39 | 3 | 6 | 48 |
| [lib/features/map/presentation/widgets/map\_view.dart](/lib/features/map/presentation/widgets/map_view.dart) | Dart | 55 | 24 | 14 | 93 |
| [lib/features/messages/presentation/pages/chat\_page.dart](/lib/features/messages/presentation/pages/chat_page.dart) | Dart | 53 | 5 | 8 | 66 |
| [lib/features/messages/presentation/pages/messages\_page.dart](/lib/features/messages/presentation/pages/messages_page.dart) | Dart | 25 | 0 | 1 | 26 |
| [lib/features/messages/presentation/widgets/shared/message\_avatar.dart](/lib/features/messages/presentation/widgets/shared/message_avatar.dart) | Dart | 5 | 3 | 0 | 8 |
| [lib/features/posts/presentation/widgets/post\_card/post\_author\_header.dart](/lib/features/posts/presentation/widgets/post_card/post_author_header.dart) | Dart | 6 | 3 | 0 | 9 |
| [lib/features/posts/presentation/widgets/post\_card/post\_media\_carousel.dart](/lib/features/posts/presentation/widgets/post_card/post_media_carousel.dart) | Dart | 3 | 3 | 0 | 6 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 23 | 92 | 23 | 138 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 66 | 0 | 23 | 89 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 68 | 0 | 23 | 91 |
| [lib/main.dart](/lib/main.dart) | Dart | 3 | 1 | 1 | 5 |
| [macos/Flutter/GeneratedPluginRegistrant.swift](/macos/Flutter/GeneratedPluginRegistrant.swift) | Swift | 4 | 0 | 0 | 4 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 2 | 0 | 0 | 2 |
| [supabase/migrations/20260801000000\_realtime\_authorization.sql](/supabase/migrations/20260801000000_realtime_authorization.sql) | MS SQL | -49 | -47 | -9 | -105 |
| [supabase/migrations/20260801000001\_dm\_send\_message.sql](/supabase/migrations/20260801000001_dm_send_message.sql) | MS SQL | -86 | -34 | -17 | -137 |
| [windows/flutter/generated\_plugin\_registrant.cc](/windows/flutter/generated_plugin_registrant.cc) | C++ | 3 | 0 | 0 | 3 |
| [windows/flutter/generated\_plugins.cmake](/windows/flutter/generated_plugins.cmake) | CMake | 1 | 0 | 0 | 1 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details