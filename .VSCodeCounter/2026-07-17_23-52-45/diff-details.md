# Diff Details

Date : 2026-07-17 23:52:45

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 52 files,  2264 codes, 226 comments, 340 blanks, all 2830 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [MINI\_FEATURES\_PROGRESS.md](/MINI_FEATURES_PROGRESS.md) | Markdown | 173 | 0 | 13 | 186 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 23 | 1 | 1 | 25 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 91 | 0 | 0 | 91 |
| [lib/core/storage/locale\_local\_storage.dart](/lib/core/storage/locale_local_storage.dart) | Dart | 13 | 7 | 4 | 24 |
| [lib/features/posts/data/datasources/posts\_api\_data\_source.dart](/lib/features/posts/data/datasources/posts_api_data_source.dart) | Dart | 10 | 0 | 1 | 11 |
| [lib/features/posts/data/repositories/posts\_repository\_impl.dart](/lib/features/posts/data/repositories/posts_repository_impl.dart) | Dart | 20 | 0 | 1 | 21 |
| [lib/features/posts/domain/repositories/posts\_repository.dart](/lib/features/posts/domain/repositories/posts_repository.dart) | Dart | 4 | 1 | 1 | 6 |
| [lib/features/posts/domain/usecases/get\_saved\_posts.dart](/lib/features/posts/domain/usecases/get_saved_posts.dart) | Dart | 21 | 0 | 6 | 27 |
| [lib/features/posts/presentation/bloc/saved\_posts/bloc.dart](/lib/features/posts/presentation/bloc/saved_posts/bloc.dart) | Dart | 91 | 6 | 12 | 109 |
| [lib/features/posts/presentation/bloc/saved\_posts/event.dart](/lib/features/posts/presentation/bloc/saved_posts/event.dart) | Dart | 19 | 6 | 8 | 33 |
| [lib/features/posts/presentation/bloc/saved\_posts/state.dart](/lib/features/posts/presentation/bloc/saved_posts/state.dart) | Dart | 44 | 2 | 13 | 59 |
| [lib/features/posts/presentation/pages/saved\_posts\_page.dart](/lib/features/posts/presentation/pages/saved_posts_page.dart) | Dart | 58 | 2 | 4 | 64 |
| [lib/features/posts/presentation/widgets/saved\_posts/saved\_posts\_empty\_view.dart](/lib/features/posts/presentation/widgets/saved_posts/saved_posts_empty_view.dart) | Dart | 61 | 2 | 6 | 69 |
| [lib/features/posts/presentation/widgets/saved\_posts/saved\_posts\_error\_view.dart](/lib/features/posts/presentation/widgets/saved_posts/saved_posts_error_view.dart) | Dart | 48 | 0 | 5 | 53 |
| [lib/features/posts/presentation/widgets/saved\_posts/saved\_posts\_grid.dart](/lib/features/posts/presentation/widgets/saved_posts/saved_posts_grid.dart) | Dart | 69 | 4 | 9 | 82 |
| [lib/features/profile/data/datasource/avatar\_storage\_api\_data\_source.dart](/lib/features/profile/data/datasource/avatar_storage_api_data_source.dart) | Dart | 62 | 6 | 6 | 74 |
| [lib/features/profile/data/datasource/profile\_api\_data\_source.dart](/lib/features/profile/data/datasource/profile_api_data_source.dart) | Dart | 25 | 6 | 5 | 36 |
| [lib/features/profile/data/models/avatar\_upload\_model.dart](/lib/features/profile/data/models/avatar_upload_model.dart) | Dart | 14 | 1 | 5 | 20 |
| [lib/features/profile/data/models/language\_option\_model.dart](/lib/features/profile/data/models/language_option_model.dart) | Dart | 14 | 0 | 5 | 19 |
| [lib/features/profile/data/models/profile\_model.dart](/lib/features/profile/data/models/profile_model.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/profile/data/repositories/profile\_repository\_impl.dart](/lib/features/profile/data/repositories/profile_repository_impl.dart) | Dart | 103 | 5 | 4 | 112 |
| [lib/features/profile/domain/entities/avatar\_upload.dart](/lib/features/profile/domain/entities/avatar_upload.dart) | Dart | 5 | 4 | 2 | 11 |
| [lib/features/profile/domain/entities/language\_option.dart](/lib/features/profile/domain/entities/language_option.dart) | Dart | 8 | 3 | 4 | 15 |
| [lib/features/profile/domain/entities/profile.dart](/lib/features/profile/domain/entities/profile.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/profile/domain/failures/profile\_failures.dart](/lib/features/profile/domain/failures/profile_failures.dart) | Dart | 15 | 6 | 3 | 24 |
| [lib/features/profile/domain/repositories/profile\_repository.dart](/lib/features/profile/domain/repositories/profile_repository.dart) | Dart | 8 | 8 | 4 | 20 |
| [lib/features/profile/domain/usecases/change\_profile\_avatar.dart](/lib/features/profile/domain/usecases/change_profile_avatar.dart) | Dart | 22 | 3 | 7 | 32 |
| [lib/features/profile/domain/usecases/get\_language\_options.dart](/lib/features/profile/domain/usecases/get_language_options.dart) | Dart | 16 | 0 | 5 | 21 |
| [lib/features/profile/domain/usecases/set\_app\_language.dart](/lib/features/profile/domain/usecases/set_app_language.dart) | Dart | 20 | 0 | 7 | 27 |
| [lib/features/profile/domain/usecases/update\_profile.dart](/lib/features/profile/domain/usecases/update_profile.dart) | Dart | 20 | 2 | 7 | 29 |
| [lib/features/profile/presentation/bloc/edit\_profile/bloc.dart](/lib/features/profile/presentation/bloc/edit_profile/bloc.dart) | Dart | 79 | 2 | 15 | 96 |
| [lib/features/profile/presentation/bloc/edit\_profile/event.dart](/lib/features/profile/presentation/bloc/edit_profile/event.dart) | Dart | 26 | 4 | 13 | 43 |
| [lib/features/profile/presentation/bloc/edit\_profile/state.dart](/lib/features/profile/presentation/bloc/edit_profile/state.dart) | Dart | 54 | 11 | 14 | 79 |
| [lib/features/profile/presentation/bloc/language\_picker/bloc.dart](/lib/features/profile/presentation/bloc/language_picker/bloc.dart) | Dart | 60 | 4 | 11 | 75 |
| [lib/features/profile/presentation/bloc/language\_picker/event.dart](/lib/features/profile/presentation/bloc/language_picker/event.dart) | Dart | 18 | 4 | 9 | 31 |
| [lib/features/profile/presentation/bloc/language\_picker/state.dart](/lib/features/profile/presentation/bloc/language_picker/state.dart) | Dart | 51 | 8 | 11 | 70 |
| [lib/features/profile/presentation/bloc/locale/cubit.dart](/lib/features/profile/presentation/bloc/locale/cubit.dart) | Dart | 27 | 13 | 8 | 48 |
| [lib/features/profile/presentation/pages/edit\_profile\_page.dart](/lib/features/profile/presentation/pages/edit_profile_page.dart) | Dart | 146 | 7 | 14 | 167 |
| [lib/features/profile/presentation/pages/my\_profile\_page.dart](/lib/features/profile/presentation/pages/my_profile_page.dart) | Dart | 8 | 6 | 0 | 14 |
| [lib/features/profile/presentation/utils/profile\_error\_mapper.dart](/lib/features/profile/presentation/utils/profile_error_mapper.dart) | Dart | 20 | 0 | 0 | 20 |
| [lib/features/profile/presentation/widgets/edit\_profile/edit\_profile\_field.dart](/lib/features/profile/presentation/widgets/edit_profile/edit_profile_field.dart) | Dart | 101 | 3 | 5 | 109 |
| [lib/features/profile/presentation/widgets/edit\_profile/edit\_profile\_save\_button.dart](/lib/features/profile/presentation/widgets/edit_profile/edit_profile_save_button.dart) | Dart | 48 | 2 | 5 | 55 |
| [lib/features/profile/presentation/widgets/edit\_profile/editable\_avatar.dart](/lib/features/profile/presentation/widgets/edit_profile/editable_avatar.dart) | Dart | 133 | 3 | 14 | 150 |
| [lib/features/profile/presentation/widgets/my\_profile/edit\_profile\_button.dart](/lib/features/profile/presentation/widgets/my_profile/edit_profile_button.dart) | Dart | 41 | 2 | 5 | 48 |
| [lib/features/profile/presentation/widgets/my\_profile/my\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/my_profile/my_profile_data_view.dart) | Dart | 8 | 2 | 1 | 11 |
| [lib/features/profile/presentation/widgets/settings/language\_picker\_sheet.dart](/lib/features/profile/presentation/widgets/settings/language_picker_sheet.dart) | Dart | 221 | 7 | 16 | 244 |
| [lib/features/settings/presentation/pages/settings\_page.dart](/lib/features/settings/presentation/pages/settings_page.dart) | Dart | 26 | 0 | 0 | 26 |
| [lib/features/settings/presentation/widgets/settings\_tile.dart](/lib/features/settings/presentation/widgets/settings_tile.dart) | Dart | 13 | 2 | 0 | 15 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 17 | 68 | 17 | 102 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 37 | 0 | 17 | 54 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 39 | 0 | 17 | 56 |
| [lib/main.dart](/lib/main.dart) | Dart | 7 | 3 | 0 | 10 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details