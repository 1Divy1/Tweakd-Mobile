# Diff Details

Date : 2026-07-17 23:17:04

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 60 files,  2393 codes, 273 comments, 377 blanks, all 3043 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [MINI\_FEATURES\_PROGRESS.md](/MINI_FEATURES_PROGRESS.md) | Markdown | 212 | 0 | 36 | 248 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 11 | 1 | 1 | 13 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 16 | 0 | 0 | 16 |
| [lib/features/feed/presentation/widgets/feed\_top\_bar.dart](/lib/features/feed/presentation/widgets/feed_top_bar.dart) | Dart | 80 | 8 | 12 | 100 |
| [lib/features/garage/presentation/pages/about\_car\_page.dart](/lib/features/garage/presentation/pages/about_car_page.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/garage/presentation/widgets/car\_image.dart](/lib/features/garage/presentation/widgets/car_image.dart) | Dart | 10 | 6 | 3 | 19 |
| [lib/features/messages/data/datasources/messages\_data\_source.dart](/lib/features/messages/data/datasources/messages_data_source.dart) | Dart | 9 | 4 | 2 | 15 |
| [lib/features/messages/data/models/dm\_models.dart](/lib/features/messages/data/models/dm_models.dart) | Dart | 35 | 3 | 4 | 42 |
| [lib/features/messages/data/repositories/messages\_repository\_impl.dart](/lib/features/messages/data/repositories/messages_repository_impl.dart) | Dart | 5 | 0 | 1 | 6 |
| [lib/features/messages/domain/entities/message.dart](/lib/features/messages/domain/entities/message.dart) | Dart | 17 | 12 | 5 | 34 |
| [lib/features/messages/domain/repositories/messages\_repository.dart](/lib/features/messages/domain/repositories/messages_repository.dart) | Dart | 2 | 3 | 1 | 6 |
| [lib/features/messages/domain/usecases/get\_unread\_count.dart](/lib/features/messages/domain/usecases/get_unread_count.dart) | Dart | 13 | 2 | 5 | 20 |
| [lib/features/messages/domain/usecases/send\_message.dart](/lib/features/messages/domain/usecases/send_message.dart) | Dart | 9 | 2 | 1 | 12 |
| [lib/features/messages/presentation/bloc/car\_picker/cubit.dart](/lib/features/messages/presentation/bloc/car_picker/cubit.dart) | Dart | 22 | 2 | 5 | 29 |
| [lib/features/messages/presentation/bloc/car\_picker/state.dart](/lib/features/messages/presentation/bloc/car_picker/state.dart) | Dart | 13 | 1 | 6 | 20 |
| [lib/features/messages/presentation/bloc/chat/bloc.dart](/lib/features/messages/presentation/bloc/chat/bloc.dart) | Dart | 1 | 1 | 0 | 2 |
| [lib/features/messages/presentation/bloc/chat/event.dart](/lib/features/messages/presentation/bloc/chat/event.dart) | Dart | 1 | 2 | 2 | 5 |
| [lib/features/messages/presentation/bloc/unread/cubit.dart](/lib/features/messages/presentation/bloc/unread/cubit.dart) | Dart | 37 | 12 | 10 | 59 |
| [lib/features/messages/presentation/pages/chat\_page.dart](/lib/features/messages/presentation/pages/chat_page.dart) | Dart | 4 | 2 | -1 | 5 |
| [lib/features/messages/presentation/pages/messages\_page.dart](/lib/features/messages/presentation/pages/messages_page.dart) | Dart | 15 | 1 | 0 | 16 |
| [lib/features/messages/presentation/widgets/chat/car\_picker\_sheet.dart](/lib/features/messages/presentation/widgets/chat/car_picker_sheet.dart) | Dart | 287 | 9 | 26 | 322 |
| [lib/features/messages/presentation/widgets/chat/chat\_input\_bar.dart](/lib/features/messages/presentation/widgets/chat/chat_input_bar.dart) | Dart | 115 | 24 | 13 | 152 |
| [lib/features/messages/presentation/widgets/chat/chat\_top\_bar.dart](/lib/features/messages/presentation/widgets/chat/chat_top_bar.dart) | Dart | 16 | 1 | 1 | 18 |
| [lib/features/messages/presentation/widgets/chat/message\_bubble.dart](/lib/features/messages/presentation/widgets/chat/message_bubble.dart) | Dart | 54 | 9 | 6 | 69 |
| [lib/features/messages/presentation/widgets/chat/tagged\_car\_card.dart](/lib/features/messages/presentation/widgets/chat/tagged_car_card.dart) | Dart | 62 | 3 | 5 | 70 |
| [lib/features/messages/presentation/widgets/chat/tagged\_car\_chips.dart](/lib/features/messages/presentation/widgets/chat/tagged_car_chips.dart) | Dart | 80 | 2 | 8 | 90 |
| [lib/features/messages/presentation/widgets/inbox/conversation\_tile.dart](/lib/features/messages/presentation/widgets/inbox/conversation_tile.dart) | Dart | 8 | 3 | 1 | 12 |
| [lib/features/notifications/data/datasources/notifications\_api\_data\_source.dart](/lib/features/notifications/data/datasources/notifications_api_data_source.dart) | Dart | 40 | 3 | 10 | 53 |
| [lib/features/notifications/data/models/notification\_models.dart](/lib/features/notifications/data/models/notification_models.dart) | Dart | 73 | 6 | 11 | 90 |
| [lib/features/notifications/data/repositories/notifications\_repository\_impl.dart](/lib/features/notifications/data/repositories/notifications_repository_impl.dart) | Dart | 75 | 0 | 8 | 83 |
| [lib/features/notifications/domain/entities/notification.dart](/lib/features/notifications/domain/entities/notification.dart) | Dart | 94 | 12 | 14 | 120 |
| [lib/features/notifications/domain/repositories/notifications\_repository.dart](/lib/features/notifications/domain/repositories/notifications_repository.dart) | Dart | 12 | 7 | 6 | 25 |
| [lib/features/notifications/domain/usecases/get\_notifications.dart](/lib/features/notifications/domain/usecases/get_notifications.dart) | Dart | 22 | 1 | 7 | 30 |
| [lib/features/notifications/domain/usecases/get\_unread\_notifications\_count.dart](/lib/features/notifications/domain/usecases/get_unread_notifications_count.dart) | Dart | 13 | 1 | 5 | 19 |
| [lib/features/notifications/domain/usecases/mark\_all\_notifications\_read.dart](/lib/features/notifications/domain/usecases/mark_all_notifications_read.dart) | Dart | 13 | 1 | 5 | 19 |
| [lib/features/notifications/domain/usecases/mark\_notification\_read.dart](/lib/features/notifications/domain/usecases/mark_notification_read.dart) | Dart | 12 | 1 | 5 | 18 |
| [lib/features/notifications/presentation/bloc/notifications/bloc.dart](/lib/features/notifications/presentation/bloc/notifications/bloc.dart) | Dart | 138 | 7 | 18 | 163 |
| [lib/features/notifications/presentation/bloc/notifications/event.dart](/lib/features/notifications/presentation/bloc/notifications/event.dart) | Dart | 28 | 9 | 11 | 48 |
| [lib/features/notifications/presentation/bloc/notifications/state.dart](/lib/features/notifications/presentation/bloc/notifications/state.dart) | Dart | 45 | 2 | 14 | 61 |
| [lib/features/notifications/presentation/bloc/unread/cubit.dart](/lib/features/notifications/presentation/bloc/unread/cubit.dart) | Dart | 18 | 10 | 6 | 34 |
| [lib/features/notifications/presentation/pages/notifications\_page.dart](/lib/features/notifications/presentation/pages/notifications_page.dart) | Dart | 172 | 7 | 16 | 195 |
| [lib/features/notifications/presentation/utils/notifications\_error\_mapper.dart](/lib/features/notifications/presentation/utils/notifications_error_mapper.dart) | Dart | 17 | 3 | 4 | 24 |
| [lib/features/notifications/presentation/widgets/notification\_tile.dart](/lib/features/notifications/presentation/widgets/notification_tile.dart) | Dart | 137 | 5 | 12 | 154 |
| [lib/features/notifications/presentation/widgets/notifications\_empty\_view.dart](/lib/features/notifications/presentation/widgets/notifications_empty_view.dart) | Dart | 46 | 1 | 4 | 51 |
| [lib/features/notifications/presentation/widgets/notifications\_error\_view.dart](/lib/features/notifications/presentation/widgets/notifications_error_view.dart) | Dart | 48 | 1 | 5 | 54 |
| [lib/features/notifications/presentation/widgets/notifications\_top\_bar.dart](/lib/features/notifications/presentation/widgets/notifications_top_bar.dart) | Dart | 72 | 4 | 8 | 84 |
| [lib/features/posts/presentation/widgets/post\_card/post\_media\_carousel.dart](/lib/features/posts/presentation/widgets/post_card/post_media_carousel.dart) | Dart | 4 | 2 | -1 | 5 |
| [lib/features/posts/presentation/widgets/post\_detail/pinch\_zoom.dart](/lib/features/posts/presentation/widgets/post_detail/pinch_zoom.dart) | Dart | 7 | 3 | 1 | 11 |
| [lib/features/profile/presentation/widgets/public\_profile/message\_button.dart](/lib/features/profile/presentation/widgets/public_profile/message_button.dart) | Dart | 47 | 5 | 7 | 59 |
| [lib/features/profile/presentation/widgets/public\_profile/public\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/public_profile/public_profile_data_view.dart) | Dart | 9 | 0 | 0 | 9 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 16 | 64 | 16 | 96 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 40 | 0 | 16 | 56 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 40 | 0 | 16 | 56 |
| [lib/main.dart](/lib/main.dart) | Dart | 8 | 5 | 0 | 13 |
| [linux/flutter/generated\_plugin\_registrant.cc](/linux/flutter/generated_plugin_registrant.cc) | C++ | 4 | 0 | 0 | 4 |
| [linux/flutter/generated\_plugins.cmake](/linux/flutter/generated_plugins.cmake) | CMake | 1 | 0 | 0 | 1 |
| [macos/Flutter/GeneratedPluginRegistrant.swift](/macos/Flutter/GeneratedPluginRegistrant.swift) | Swift | 2 | 0 | 0 | 2 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 1 | 0 | 0 | 1 |
| [windows/flutter/generated\_plugin\_registrant.cc](/windows/flutter/generated_plugin_registrant.cc) | C++ | 3 | 0 | 0 | 3 |
| [windows/flutter/generated\_plugins.cmake](/windows/flutter/generated_plugins.cmake) | CMake | 1 | 0 | 0 | 1 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details