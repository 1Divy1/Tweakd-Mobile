# Diff Details

Date : 2026-07-01 21:38:34

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 48 files,  1959 codes, 217 comments, 340 blanks, all 2516 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 10 | 1 | 1 | 12 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 36 | 0 | 0 | 36 |
| [lib/features/feed/README.md](/lib/features/feed/README.md) | Markdown | 11 | 0 | 0 | 11 |
| [lib/features/feed/presentation/bloc/feed/bloc.dart](/lib/features/feed/presentation/bloc/feed/bloc.dart) | Dart | 70 | 5 | 6 | 81 |
| [lib/features/feed/presentation/bloc/feed/event.dart](/lib/features/feed/presentation/bloc/feed/event.dart) | Dart | 24 | 9 | 8 | 41 |
| [lib/features/feed/presentation/pages/feed\_page.dart](/lib/features/feed/presentation/pages/feed_page.dart) | Dart | 29 | 4 | 4 | 37 |
| [lib/features/feed/presentation/widgets/feed\_post\_card.dart](/lib/features/feed/presentation/widgets/feed_post_card.dart) | Dart | 86 | 6 | 7 | 99 |
| [lib/features/posts/presentation/bloc/comments/bloc.dart](/lib/features/posts/presentation/bloc/comments/bloc.dart) | Dart | 25 | 5 | 3 | 33 |
| [lib/features/posts/presentation/bloc/comments/event.dart](/lib/features/posts/presentation/bloc/comments/event.dart) | Dart | 6 | 2 | 2 | 10 |
| [lib/features/posts/presentation/pages/post\_detail\_page.dart](/lib/features/posts/presentation/pages/post_detail_page.dart) | Dart | 13 | 3 | 2 | 18 |
| [lib/features/posts/presentation/widgets/post\_card/post\_options\_sheet.dart](/lib/features/posts/presentation/widgets/post_card/post_options_sheet.dart) | Dart | 76 | 4 | 7 | 87 |
| [lib/features/posts/presentation/widgets/post\_detail/comments\_sheet.dart](/lib/features/posts/presentation/widgets/post_detail/comments_sheet.dart) | Dart | 40 | 3 | 2 | 45 |
| [lib/features/posts/presentation/widgets/post\_detail/post\_detail\_view.dart](/lib/features/posts/presentation/widgets/post_detail/post_detail_view.dart) | Dart | -65 | 0 | -5 | -70 |
| [lib/features/profile/presentation/widgets/public\_profile/profile\_options\_sheet.dart](/lib/features/profile/presentation/widgets/public_profile/profile_options_sheet.dart) | Dart | 76 | 4 | 7 | 87 |
| [lib/features/profile/presentation/widgets/public\_profile/public\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/public_profile/public_profile_data_view.dart) | Dart | 39 | 3 | 5 | 47 |
| [lib/features/report/README.md](/lib/features/report/README.md) | Markdown | 69 | 0 | 15 | 84 |
| [lib/features/report/data/datasources/report\_api\_data\_source.dart](/lib/features/report/data/datasources/report_api_data_source.dart) | Dart | 46 | 7 | 15 | 68 |
| [lib/features/report/data/models/my\_report\_model.dart](/lib/features/report/data/models/my_report_model.dart) | Dart | 46 | 2 | 7 | 55 |
| [lib/features/report/data/models/report\_reason\_model.dart](/lib/features/report/data/models/report_reason_model.dart) | Dart | 14 | 0 | 5 | 19 |
| [lib/features/report/data/repositories/report\_repository\_impl.dart](/lib/features/report/data/repositories/report_repository_impl.dart) | Dart | 90 | 3 | 7 | 100 |
| [lib/features/report/domain/entities/my\_report.dart](/lib/features/report/domain/entities/my_report.dart) | Dart | 19 | 5 | 6 | 30 |
| [lib/features/report/domain/entities/report\_reason.dart](/lib/features/report/domain/entities/report_reason.dart) | Dart | 8 | 2 | 4 | 14 |
| [lib/features/report/domain/entities/report\_target.dart](/lib/features/report/domain/entities/report_target.dart) | Dart | 25 | 3 | 9 | 37 |
| [lib/features/report/domain/failures/report\_failures.dart](/lib/features/report/domain/failures/report_failures.dart) | Dart | 13 | 4 | 5 | 22 |
| [lib/features/report/domain/repositories/report\_repository.dart](/lib/features/report/domain/repositories/report_repository.dart) | Dart | 15 | 3 | 5 | 23 |
| [lib/features/report/domain/usecases/get\_my\_reports.dart](/lib/features/report/domain/usecases/get_my_reports.dart) | Dart | 15 | 0 | 5 | 20 |
| [lib/features/report/domain/usecases/get\_report\_reasons.dart](/lib/features/report/domain/usecases/get_report_reasons.dart) | Dart | 17 | 0 | 5 | 22 |
| [lib/features/report/domain/usecases/submit\_report.dart](/lib/features/report/domain/usecases/submit_report.dart) | Dart | 20 | 0 | 6 | 26 |
| [lib/features/report/presentation/bloc/my\_reports/bloc.dart](/lib/features/report/presentation/bloc/my_reports/bloc.dart) | Dart | 26 | 2 | 5 | 33 |
| [lib/features/report/presentation/bloc/my\_reports/event.dart](/lib/features/report/presentation/bloc/my_reports/event.dart) | Dart | 9 | 1 | 4 | 14 |
| [lib/features/report/presentation/bloc/my\_reports/state.dart](/lib/features/report/presentation/bloc/my_reports/state.dart) | Dart | 26 | 0 | 10 | 36 |
| [lib/features/report/presentation/bloc/report/bloc.dart](/lib/features/report/presentation/bloc/report/bloc.dart) | Dart | 62 | 2 | 11 | 75 |
| [lib/features/report/presentation/bloc/report/event.dart](/lib/features/report/presentation/bloc/report/event.dart) | Dart | 22 | 3 | 9 | 34 |
| [lib/features/report/presentation/bloc/report/state.dart](/lib/features/report/presentation/bloc/report/state.dart) | Dart | 40 | 8 | 9 | 57 |
| [lib/features/report/presentation/pages/my\_reports\_page.dart](/lib/features/report/presentation/pages/my_reports_page.dart) | Dart | 51 | 2 | 4 | 57 |
| [lib/features/report/presentation/utils/report\_error\_mapper.dart](/lib/features/report/presentation/utils/report_error_mapper.dart) | Dart | 36 | 5 | 4 | 45 |
| [lib/features/report/presentation/widgets/my\_reports/my\_report\_status\_chip.dart](/lib/features/report/presentation/widgets/my_reports/my_report_status_chip.dart) | Dart | 45 | 1 | 6 | 52 |
| [lib/features/report/presentation/widgets/my\_reports/my\_report\_tile.dart](/lib/features/report/presentation/widgets/my_reports/my_report_tile.dart) | Dart | 93 | 2 | 6 | 101 |
| [lib/features/report/presentation/widgets/my\_reports/my\_reports\_empty\_view.dart](/lib/features/report/presentation/widgets/my_reports/my_reports_empty_view.dart) | Dart | 31 | 0 | 4 | 35 |
| [lib/features/report/presentation/widgets/my\_reports/my\_reports\_error\_view.dart](/lib/features/report/presentation/widgets/my_reports/my_reports_error_view.dart) | Dart | 48 | 0 | 5 | 53 |
| [lib/features/report/presentation/widgets/my\_reports/my\_reports\_list\_view.dart](/lib/features/report/presentation/widgets/my_reports/my_reports_list_view.dart) | Dart | 16 | 1 | 5 | 22 |
| [lib/features/report/presentation/widgets/my\_reports/my\_reports\_loading\_view.dart](/lib/features/report/presentation/widgets/my_reports/my_reports_loading_view.dart) | Dart | 11 | 0 | 4 | 15 |
| [lib/features/report/presentation/widgets/report\_reason\_sheet.dart](/lib/features/report/presentation/widgets/report_reason_sheet.dart) | Dart | 379 | 7 | 28 | 414 |
| [lib/features/settings/presentation/pages/settings\_page.dart](/lib/features/settings/presentation/pages/settings_page.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/features/settings/presentation/widgets/settings\_tile.dart](/lib/features/settings/presentation/widgets/settings_tile.dart) | Dart | 45 | 1 | 5 | 51 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 26 | 104 | 26 | 156 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 56 | 0 | 26 | 82 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 57 | 0 | 26 | 83 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details