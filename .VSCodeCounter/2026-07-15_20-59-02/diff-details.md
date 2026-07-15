# Diff Details

Date : 2026-07-15 20:59:02

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 53 files,  3357 codes, 250 comments, 510 blanks, all 4117 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [MESSAGES\_PROGRESS.md](/MESSAGES_PROGRESS.md) | Markdown | 110 | 0 | 11 | 121 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 25 | 1 | 1 | 27 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 54 | 0 | 0 | 54 |
| [lib/features/feed/presentation/widgets/feed\_top\_bar.dart](/lib/features/feed/presentation/widgets/feed_top_bar.dart) | Dart | 1 | 1 | 0 | 2 |
| [lib/features/messages/data/datasources/messages\_data\_source.dart](/lib/features/messages/data/datasources/messages_data_source.dart) | Dart | 405 | 14 | 43 | 462 |
| [lib/features/messages/data/repositories/messages\_repository\_impl.dart](/lib/features/messages/data/repositories/messages_repository_impl.dart) | Dart | 60 | 2 | 11 | 73 |
| [lib/features/messages/domain/entities/chat.dart](/lib/features/messages/domain/entities/chat.dart) | Dart | 15 | 2 | 5 | 22 |
| [lib/features/messages/domain/entities/chat\_events.dart](/lib/features/messages/domain/entities/chat_events.dart) | Dart | 22 | 5 | 9 | 36 |
| [lib/features/messages/domain/entities/conversation.dart](/lib/features/messages/domain/entities/conversation.dart) | Dart | 49 | 8 | 13 | 70 |
| [lib/features/messages/domain/entities/message.dart](/lib/features/messages/domain/entities/message.dart) | Dart | 49 | 3 | 10 | 62 |
| [lib/features/messages/domain/entities/message\_user.dart](/lib/features/messages/domain/entities/message_user.dart) | Dart | 29 | 3 | 5 | 37 |
| [lib/features/messages/domain/repositories/messages\_repository.dart](/lib/features/messages/domain/repositories/messages_repository.dart) | Dart | 20 | 6 | 8 | 34 |
| [lib/features/messages/domain/usecases/compose.dart](/lib/features/messages/domain/usecases/compose.dart) | Dart | 23 | 2 | 8 | 33 |
| [lib/features/messages/domain/usecases/get\_chat.dart](/lib/features/messages/domain/usecases/get_chat.dart) | Dart | 14 | 0 | 5 | 19 |
| [lib/features/messages/domain/usecases/get\_inbox.dart](/lib/features/messages/domain/usecases/get_inbox.dart) | Dart | 14 | 0 | 5 | 19 |
| [lib/features/messages/domain/usecases/send\_message.dart](/lib/features/messages/domain/usecases/send_message.dart) | Dart | 22 | 0 | 8 | 30 |
| [lib/features/messages/domain/usecases/watch\_chat.dart](/lib/features/messages/domain/usecases/watch_chat.dart) | Dart | 10 | 2 | 5 | 17 |
| [lib/features/messages/presentation/bloc/chat/bloc.dart](/lib/features/messages/presentation/bloc/chat/bloc.dart) | Dart | 96 | 3 | 12 | 111 |
| [lib/features/messages/presentation/bloc/chat/event.dart](/lib/features/messages/presentation/bloc/chat/event.dart) | Dart | 25 | 2 | 10 | 37 |
| [lib/features/messages/presentation/bloc/chat/state.dart](/lib/features/messages/presentation/bloc/chat/state.dart) | Dart | 50 | 3 | 14 | 67 |
| [lib/features/messages/presentation/bloc/compose/bloc.dart](/lib/features/messages/presentation/bloc/compose/bloc.dart) | Dart | 39 | 2 | 6 | 47 |
| [lib/features/messages/presentation/bloc/compose/event.dart](/lib/features/messages/presentation/bloc/compose/event.dart) | Dart | 18 | 2 | 7 | 27 |
| [lib/features/messages/presentation/bloc/compose/state.dart](/lib/features/messages/presentation/bloc/compose/state.dart) | Dart | 24 | 2 | 7 | 33 |
| [lib/features/messages/presentation/bloc/inbox/bloc.dart](/lib/features/messages/presentation/bloc/inbox/bloc.dart) | Dart | 44 | 2 | 7 | 53 |
| [lib/features/messages/presentation/bloc/inbox/event.dart](/lib/features/messages/presentation/bloc/inbox/event.dart) | Dart | 20 | 2 | 8 | 30 |
| [lib/features/messages/presentation/bloc/inbox/state.dart](/lib/features/messages/presentation/bloc/inbox/state.dart) | Dart | 39 | 1 | 14 | 54 |
| [lib/features/messages/presentation/pages/chat\_page.dart](/lib/features/messages/presentation/pages/chat_page.dart) | Dart | 172 | 8 | 20 | 200 |
| [lib/features/messages/presentation/pages/messages\_page.dart](/lib/features/messages/presentation/pages/messages_page.dart) | Dart | 174 | 5 | 14 | 193 |
| [lib/features/messages/presentation/utils/message\_time.dart](/lib/features/messages/presentation/utils/message_time.dart) | Dart | 11 | 2 | 3 | 16 |
| [lib/features/messages/presentation/utils/messages\_error\_mapper.dart](/lib/features/messages/presentation/utils/messages_error_mapper.dart) | Dart | 14 | 3 | 4 | 21 |
| [lib/features/messages/presentation/widgets/chat/bubble\_entrance.dart](/lib/features/messages/presentation/widgets/chat/bubble_entrance.dart) | Dart | 57 | 3 | 8 | 68 |
| [lib/features/messages/presentation/widgets/chat/chat\_date\_pill.dart](/lib/features/messages/presentation/widgets/chat/chat_date_pill.dart) | Dart | 29 | 1 | 5 | 35 |
| [lib/features/messages/presentation/widgets/chat/chat\_input\_bar.dart](/lib/features/messages/presentation/widgets/chat/chat_input_bar.dart) | Dart | 136 | 2 | 10 | 148 |
| [lib/features/messages/presentation/widgets/chat/chat\_intro\_header.dart](/lib/features/messages/presentation/widgets/chat/chat_intro_header.dart) | Dart | 54 | 2 | 6 | 62 |
| [lib/features/messages/presentation/widgets/chat/chat\_top\_bar.dart](/lib/features/messages/presentation/widgets/chat/chat_top_bar.dart) | Dart | 118 | 4 | 11 | 133 |
| [lib/features/messages/presentation/widgets/chat/message\_bubble.dart](/lib/features/messages/presentation/widgets/chat/message_bubble.dart) | Dart | 66 | 4 | 8 | 78 |
| [lib/features/messages/presentation/widgets/chat/shared\_post\_bubble.dart](/lib/features/messages/presentation/widgets/chat/shared_post_bubble.dart) | Dart | 109 | 3 | 9 | 121 |
| [lib/features/messages/presentation/widgets/chat/typing\_indicator.dart](/lib/features/messages/presentation/widgets/chat/typing_indicator.dart) | Dart | 79 | 3 | 12 | 94 |
| [lib/features/messages/presentation/widgets/inbox/active\_now\_row.dart](/lib/features/messages/presentation/widgets/inbox/active_now_row.dart) | Dart | 68 | 3 | 6 | 77 |
| [lib/features/messages/presentation/widgets/inbox/conversation\_tile.dart](/lib/features/messages/presentation/widgets/inbox/conversation_tile.dart) | Dart | 166 | 5 | 17 | 188 |
| [lib/features/messages/presentation/widgets/inbox/inbox\_search\_field.dart](/lib/features/messages/presentation/widgets/inbox/inbox_search_field.dart) | Dart | 45 | 1 | 5 | 51 |
| [lib/features/messages/presentation/widgets/inbox/message\_requests\_tile.dart](/lib/features/messages/presentation/widgets/inbox/message_requests_tile.dart) | Dart | 91 | 2 | 6 | 99 |
| [lib/features/messages/presentation/widgets/inbox/messages\_empty\_view.dart](/lib/features/messages/presentation/widgets/inbox/messages_empty_view.dart) | Dart | 74 | 1 | 5 | 80 |
| [lib/features/messages/presentation/widgets/inbox/messages\_top\_bar.dart](/lib/features/messages/presentation/widgets/inbox/messages_top_bar.dart) | Dart | 38 | 2 | 5 | 45 |
| [lib/features/messages/presentation/widgets/inbox/new\_message\_sheet.dart](/lib/features/messages/presentation/widgets/inbox/new_message_sheet.dart) | Dart | 181 | 3 | 6 | 190 |
| [lib/features/messages/presentation/widgets/shared/message\_avatar.dart](/lib/features/messages/presentation/widgets/shared/message_avatar.dart) | Dart | 91 | 7 | 11 | 109 |
| [lib/features/messages/presentation/widgets/shared/message\_pill\_button.dart](/lib/features/messages/presentation/widgets/shared/message_pill_button.dart) | Dart | 23 | 1 | 5 | 29 |
| [lib/features/messages/presentation/widgets/shared/messages\_error\_view.dart](/lib/features/messages/presentation/widgets/shared/messages_error_view.dart) | Dart | 43 | 1 | 5 | 49 |
| [lib/features/messages/presentation/widgets/shared/staggered\_entrance.dart](/lib/features/messages/presentation/widgets/shared/staggered_entrance.dart) | Dart | 43 | 3 | 8 | 54 |
| [lib/features/messages/presentation/widgets/shared/verified\_badge.dart](/lib/features/messages/presentation/widgets/shared/verified_badge.dart) | Dart | 22 | 1 | 5 | 28 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 28 | 112 | 28 | 168 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 74 | 0 | 28 | 102 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 74 | 0 | 28 | 102 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details