# Diff Details

Date : 2026-07-01 22:11:52

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 44 files,  1972 codes, 220 comments, 340 blanks, all 2532 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 21 | 2 | 2 | 25 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 44 | 0 | 0 | 44 |
| [lib/features/feedback/README.md](/lib/features/feedback/README.md) | Markdown | 53 | 0 | 11 | 64 |
| [lib/features/feedback/data/datasources/feedback\_api\_data\_source.dart](/lib/features/feedback/data/datasources/feedback_api_data_source.dart) | Dart | 41 | 6 | 8 | 55 |
| [lib/features/feedback/data/models/feedback\_feature\_model.dart](/lib/features/feedback/data/models/feedback_feature_model.dart) | Dart | 13 | 0 | 5 | 18 |
| [lib/features/feedback/data/models/feedback\_type\_model.dart](/lib/features/feedback/data/models/feedback_type_model.dart) | Dart | 13 | 0 | 5 | 18 |
| [lib/features/feedback/data/models/my\_feedback\_model.dart](/lib/features/feedback/data/models/my_feedback_model.dart) | Dart | 37 | 0 | 5 | 42 |
| [lib/features/feedback/data/repositories/feedback\_repository\_impl.dart](/lib/features/feedback/data/repositories/feedback_repository_impl.dart) | Dart | 86 | 0 | 8 | 94 |
| [lib/features/feedback/domain/entities/feedback\_feature.dart](/lib/features/feedback/domain/entities/feedback_feature.dart) | Dart | 8 | 2 | 4 | 14 |
| [lib/features/feedback/domain/entities/feedback\_type.dart](/lib/features/feedback/domain/entities/feedback_type.dart) | Dart | 8 | 3 | 4 | 15 |
| [lib/features/feedback/domain/entities/my\_feedback.dart](/lib/features/feedback/domain/entities/my_feedback.dart) | Dart | 20 | 4 | 4 | 28 |
| [lib/features/feedback/domain/repositories/feedback\_repository.dart](/lib/features/feedback/domain/repositories/feedback_repository.dart) | Dart | 23 | 6 | 8 | 37 |
| [lib/features/feedback/domain/usecases/get\_feedback\_features.dart](/lib/features/feedback/domain/usecases/get_feedback_features.dart) | Dart | 16 | 0 | 5 | 21 |
| [lib/features/feedback/domain/usecases/get\_feedback\_types.dart](/lib/features/feedback/domain/usecases/get_feedback_types.dart) | Dart | 16 | 0 | 5 | 21 |
| [lib/features/feedback/domain/usecases/get\_my\_feedback.dart](/lib/features/feedback/domain/usecases/get_my_feedback.dart) | Dart | 16 | 0 | 5 | 21 |
| [lib/features/feedback/domain/usecases/submit\_feedback.dart](/lib/features/feedback/domain/usecases/submit_feedback.dart) | Dart | 14 | 0 | 5 | 19 |
| [lib/features/feedback/presentation/bloc/feedback/bloc.dart](/lib/features/feedback/presentation/bloc/feedback/bloc.dart) | Dart | 101 | 8 | 18 | 127 |
| [lib/features/feedback/presentation/bloc/feedback/event.dart](/lib/features/feedback/presentation/bloc/feedback/event.dart) | Dart | 31 | 7 | 11 | 49 |
| [lib/features/feedback/presentation/bloc/feedback/state.dart](/lib/features/feedback/presentation/bloc/feedback/state.dart) | Dart | 54 | 11 | 11 | 76 |
| [lib/features/feedback/presentation/bloc/my\_feedback/bloc.dart](/lib/features/feedback/presentation/bloc/my_feedback/bloc.dart) | Dart | 26 | 2 | 5 | 33 |
| [lib/features/feedback/presentation/bloc/my\_feedback/event.dart](/lib/features/feedback/presentation/bloc/my_feedback/event.dart) | Dart | 9 | 1 | 4 | 14 |
| [lib/features/feedback/presentation/bloc/my\_feedback/state.dart](/lib/features/feedback/presentation/bloc/my_feedback/state.dart) | Dart | 26 | 0 | 10 | 36 |
| [lib/features/feedback/presentation/pages/feedback\_page.dart](/lib/features/feedback/presentation/pages/feedback_page.dart) | Dart | 60 | 4 | 4 | 68 |
| [lib/features/feedback/presentation/pages/my\_feedback\_page.dart](/lib/features/feedback/presentation/pages/my_feedback_page.dart) | Dart | 51 | 2 | 4 | 57 |
| [lib/features/feedback/presentation/utils/feedback\_error\_mapper.dart](/lib/features/feedback/presentation/utils/feedback_error_mapper.dart) | Dart | 14 | 5 | 4 | 23 |
| [lib/features/feedback/presentation/utils/feedback\_type\_visuals.dart](/lib/features/feedback/presentation/utils/feedback_type_visuals.dart) | Dart | 25 | 3 | 4 | 32 |
| [lib/features/feedback/presentation/widgets/feedback\_dropdown\_field.dart](/lib/features/feedback/presentation/widgets/feedback_dropdown_field.dart) | Dart | 83 | 5 | 6 | 94 |
| [lib/features/feedback/presentation/widgets/feedback\_error\_view.dart](/lib/features/feedback/presentation/widgets/feedback_error_view.dart) | Dart | 47 | 2 | 5 | 54 |
| [lib/features/feedback/presentation/widgets/feedback\_feature\_picker.dart](/lib/features/feedback/presentation/widgets/feedback_feature_picker.dart) | Dart | 84 | 2 | 6 | 92 |
| [lib/features/feedback/presentation/widgets/feedback\_form.dart](/lib/features/feedback/presentation/widgets/feedback_form.dart) | Dart | 299 | 15 | 25 | 339 |
| [lib/features/feedback/presentation/widgets/feedback\_loading\_view.dart](/lib/features/feedback/presentation/widgets/feedback_loading_view.dart) | Dart | 11 | 0 | 4 | 15 |
| [lib/features/feedback/presentation/widgets/feedback\_picker\_sheet.dart](/lib/features/feedback/presentation/widgets/feedback_picker_sheet.dart) | Dart | 47 | 2 | 5 | 54 |
| [lib/features/feedback/presentation/widgets/feedback\_section\_label.dart](/lib/features/feedback/presentation/widgets/feedback_section_label.dart) | Dart | 44 | 2 | 5 | 51 |
| [lib/features/feedback/presentation/widgets/feedback\_top\_bar.dart](/lib/features/feedback/presentation/widgets/feedback_top_bar.dart) | Dart | 48 | 2 | 5 | 55 |
| [lib/features/feedback/presentation/widgets/feedback\_type\_picker.dart](/lib/features/feedback/presentation/widgets/feedback_type_picker.dart) | Dart | 103 | 3 | 6 | 112 |
| [lib/features/feedback/presentation/widgets/my\_feedback/my\_feedback\_empty\_view.dart](/lib/features/feedback/presentation/widgets/my_feedback/my_feedback_empty_view.dart) | Dart | 35 | 0 | 4 | 39 |
| [lib/features/feedback/presentation/widgets/my\_feedback/my\_feedback\_error\_view.dart](/lib/features/feedback/presentation/widgets/my_feedback/my_feedback_error_view.dart) | Dart | 48 | 0 | 5 | 53 |
| [lib/features/feedback/presentation/widgets/my\_feedback/my\_feedback\_list\_view.dart](/lib/features/feedback/presentation/widgets/my_feedback/my_feedback_list_view.dart) | Dart | 16 | 1 | 5 | 22 |
| [lib/features/feedback/presentation/widgets/my\_feedback/my\_feedback\_loading\_view.dart](/lib/features/feedback/presentation/widgets/my_feedback/my_feedback_loading_view.dart) | Dart | 11 | 0 | 4 | 15 |
| [lib/features/feedback/presentation/widgets/my\_feedback/my\_feedback\_tile.dart](/lib/features/feedback/presentation/widgets/my_feedback/my_feedback_tile.dart) | Dart | 105 | 4 | 9 | 118 |
| [lib/features/settings/presentation/pages/settings\_page.dart](/lib/features/settings/presentation/pages/settings_page.dart) | Dart | 12 | 0 | 0 | 12 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 29 | 116 | 29 | 174 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 62 | 0 | 29 | 91 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 62 | 0 | 29 | 91 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details