# Diff Details

Date : 2026-07-04 16:22:56

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 38 files,  759 codes, 50 comments, 97 blanks, all 906 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [FORUMS\_PROGRESS.md](/FORUMS_PROGRESS.md) | Markdown | 4 | 0 | 1 | 5 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 138 | 0 | 0 | 138 |
| [lib/features/forums/data/datasources/forums\_api\_data\_source.dart](/lib/features/forums/data/datasources/forums_api_data_source.dart) | Dart | 26 | 4 | 6 | 36 |
| [lib/features/forums/data/models/forum\_models.dart](/lib/features/forums/data/models/forum_models.dart) | Dart | 27 | 0 | 5 | 32 |
| [lib/features/forums/data/repositories/forums\_repository\_impl.dart](/lib/features/forums/data/repositories/forums_repository_impl.dart) | Dart | 29 | 0 | 4 | 33 |
| [lib/features/forums/domain/entities/forum\_reply.dart](/lib/features/forums/domain/entities/forum_reply.dart) | Dart | 11 | 5 | 3 | 19 |
| [lib/features/forums/domain/entities/forum\_shortcut.dart](/lib/features/forums/domain/entities/forum_shortcut.dart) | Dart | 2 | 2 | 1 | 5 |
| [lib/features/forums/domain/entities/forum\_suggestion.dart](/lib/features/forums/domain/entities/forum_suggestion.dart) | Dart | 20 | 6 | 6 | 32 |
| [lib/features/forums/domain/entities/forum\_thread.dart](/lib/features/forums/domain/entities/forum_thread.dart) | Dart | 21 | 4 | 2 | 27 |
| [lib/features/forums/domain/repositories/forums\_repository.dart](/lib/features/forums/domain/repositories/forums_repository.dart) | Dart | 12 | 3 | 3 | 18 |
| [lib/features/forums/domain/usecases/forum\_saves.dart](/lib/features/forums/domain/usecases/forum_saves.dart) | Dart | 40 | 2 | 14 | 56 |
| [lib/features/forums/domain/usecases/get\_forum\_replies.dart](/lib/features/forums/domain/usecases/get_forum_replies.dart) | Dart | 9 | 0 | 0 | 9 |
| [lib/features/forums/domain/usecases/get\_forum\_suggestions.dart](/lib/features/forums/domain/usecases/get_forum_suggestions.dart) | Dart | 22 | 1 | 7 | 30 |
| [lib/features/forums/presentation/bloc/home/bloc.dart](/lib/features/forums/presentation/bloc/home/bloc.dart) | Dart | 28 | -1 | 3 | 30 |
| [lib/features/forums/presentation/bloc/home/event.dart](/lib/features/forums/presentation/bloc/home/event.dart) | Dart | 6 | 1 | 2 | 9 |
| [lib/features/forums/presentation/bloc/hub/bloc.dart](/lib/features/forums/presentation/bloc/hub/bloc.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/forums/presentation/bloc/hub/event.dart](/lib/features/forums/presentation/bloc/hub/event.dart) | Dart | 6 | 1 | 2 | 9 |
| [lib/features/forums/presentation/bloc/thread/bloc.dart](/lib/features/forums/presentation/bloc/thread/bloc.dart) | Dart | 53 | 3 | 5 | 61 |
| [lib/features/forums/presentation/bloc/thread/event.dart](/lib/features/forums/presentation/bloc/thread/event.dart) | Dart | 10 | 2 | 4 | 16 |
| [lib/features/forums/presentation/bloc/thread/state.dart](/lib/features/forums/presentation/bloc/thread/state.dart) | Dart | 5 | 0 | 0 | 5 |
| [lib/features/forums/presentation/pages/forum\_hub\_page.dart](/lib/features/forums/presentation/pages/forum_hub_page.dart) | Dart | 13 | 0 | 0 | 13 |
| [lib/features/forums/presentation/pages/forum\_thread\_page.dart](/lib/features/forums/presentation/pages/forum_thread_page.dart) | Dart | 34 | 4 | 3 | 41 |
| [lib/features/forums/presentation/pages/forums\_browse\_page.dart](/lib/features/forums/presentation/pages/forums_browse_page.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/forums/presentation/pages/forums\_home\_page.dart](/lib/features/forums/presentation/pages/forums_home_page.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/forums/presentation/widgets/home/forum\_shortcuts\_row.dart](/lib/features/forums/presentation/widgets/home/forum_shortcuts_row.dart) | Dart | 28 | 2 | 3 | 33 |
| [lib/features/forums/presentation/widgets/home/forums\_empty\_view.dart](/lib/features/forums/presentation/widgets/home/forums_empty_view.dart) | Dart | 7 | 0 | 1 | 8 |
| [lib/features/forums/presentation/widgets/home/forums\_top\_bar.dart](/lib/features/forums/presentation/widgets/home/forums_top_bar.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/features/forums/presentation/widgets/shared/forum\_thread\_card.dart](/lib/features/forums/presentation/widgets/shared/forum_thread_card.dart) | Dart | 18 | 1 | 1 | 20 |
| [lib/features/forums/presentation/widgets/thread/reply\_sort\_toggle.dart](/lib/features/forums/presentation/widgets/thread/reply_sort_toggle.dart) | Dart | 71 | 2 | 8 | 81 |
| [lib/features/forums/presentation/widgets/thread/reply\_tile.dart](/lib/features/forums/presentation/widgets/thread/reply_tile.dart) | Dart | 24 | 2 | 2 | 28 |
| [lib/features/forums/presentation/widgets/thread/thread\_header.dart](/lib/features/forums/presentation/widgets/thread/thread_header.dart) | Dart | 12 | 0 | 0 | 12 |
| [lib/features/garage/data/models/reference\_data\_models.dart](/lib/features/garage/data/models/reference_data_models.dart) | Dart | 17 | 2 | 1 | 20 |
| [lib/features/garage/domain/entities/reference\_data.dart](/lib/features/garage/domain/entities/reference_data.dart) | Dart | 7 | 4 | 2 | 13 |
| [lib/features/report/data/datasources/report\_api\_data\_source.dart](/lib/features/report/data/datasources/report_api_data_source.dart) | Dart | 16 | 0 | 4 | 20 |
| [lib/features/report/data/models/my\_report\_model.dart](/lib/features/report/data/models/my_report_model.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/report/data/repositories/report\_repository\_impl.dart](/lib/features/report/data/repositories/report_repository_impl.dart) | Dart | 6 | 0 | 0 | 6 |
| [lib/features/report/domain/entities/report\_target.dart](/lib/features/report/domain/entities/report_target.dart) | Dart | 12 | 0 | 4 | 16 |
| [lib/features/report/presentation/widgets/my\_reports/my\_report\_tile.dart](/lib/features/report/presentation/widgets/my_reports/my_report_tile.dart) | Dart | 8 | 0 | 0 | 8 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details