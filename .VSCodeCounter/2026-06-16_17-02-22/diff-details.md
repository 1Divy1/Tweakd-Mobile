# Diff Details

Date : 2026-06-16 17:02:22

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 59 files,  1978 codes, 177 comments, 194 blanks, all 2349 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [assets/icons/apple\_signin\_logo.svg](/assets/icons/apple_signin_logo.svg) | XML | -8 | -1 | -7 | -16 |
| [assets/icons/google\_signin\_logo.svg](/assets/icons/google_signin_logo.svg) | XML | -14 | 0 | -1 | -15 |
| [assets/logos/facebook\_logo\_button.svg](/assets/logos/facebook_logo_button.svg) | XML | 14 | 0 | 0 | 14 |
| [assets/logos/google\_logo\_button.svg](/assets/logos/google_logo_button.svg) | XML | 14 | 0 | 1 | 15 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 19 | 3 | 1 | 23 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 24 | 0 | 0 | 24 |
| [lib/core/services/car\_image\_service.dart](/lib/core/services/car_image_service.dart) | Dart | 10 | 11 | 3 | 24 |
| [lib/features/authentication/data/datasources/supabase\_auth\_data\_source.dart](/lib/features/authentication/data/datasources/supabase_auth_data_source.dart) | Dart | 15 | 14 | 2 | 31 |
| [lib/features/authentication/data/repositories/auth\_repository\_impl.dart](/lib/features/authentication/data/repositories/auth_repository_impl.dart) | Dart | 12 | 0 | 1 | 13 |
| [lib/features/authentication/domain/repositories/auth\_repository.dart](/lib/features/authentication/domain/repositories/auth_repository.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/domain/usecases/auth/log\_out.dart](/lib/features/authentication/domain/usecases/auth/log_out.dart) | Dart | 14 | 0 | 4 | 18 |
| [lib/features/authentication/presentation/bloc/bloc.dart](/lib/features/authentication/presentation/bloc/bloc.dart) | Dart | 15 | 0 | 3 | 18 |
| [lib/features/authentication/presentation/bloc/event.dart](/lib/features/authentication/presentation/bloc/event.dart) | Dart | 1 | 1 | 1 | 3 |
| [lib/features/authentication/presentation/pages/login\_page.dart](/lib/features/authentication/presentation/pages/login_page.dart) | Dart | 180 | 0 | 11 | 191 |
| [lib/features/authentication/presentation/pages/signup\_page.dart](/lib/features/authentication/presentation/pages/signup_page.dart) | Dart | -42 | 1 | 5 | -36 |
| [lib/features/authentication/presentation/widgets/auth\_brand\_header.dart](/lib/features/authentication/presentation/widgets/auth_brand_header.dart) | Dart | 35 | 2 | 4 | 41 |
| [lib/features/authentication/presentation/widgets/auth\_divider.dart](/lib/features/authentication/presentation/widgets/auth_divider.dart) | Dart | 27 | 1 | 5 | 33 |
| [lib/features/authentication/presentation/widgets/auth\_primary\_button.dart](/lib/features/authentication/presentation/widgets/auth_primary_button.dart) | Dart | 56 | 2 | 5 | 63 |
| [lib/features/authentication/presentation/widgets/auth\_text\_field.dart](/lib/features/authentication/presentation/widgets/auth_text_field.dart) | Dart | 69 | 3 | 7 | 79 |
| [lib/features/authentication/presentation/widgets/social\_button\_signin.dart](/lib/features/authentication/presentation/widgets/social_button_signin.dart) | Dart | -32 | 0 | -5 | -37 |
| [lib/features/authentication/presentation/widgets/social\_login\_buttons.dart](/lib/features/authentication/presentation/widgets/social_login_buttons.dart) | Dart | 79 | 3 | 11 | 93 |
| [lib/features/garage/data/datasources/garage\_api\_data\_source.dart](/lib/features/garage/data/datasources/garage_api_data_source.dart) | Dart | 23 | 2 | 4 | 29 |
| [lib/features/garage/data/models/car\_model.dart](/lib/features/garage/data/models/car_model.dart) | Dart | 16 | 0 | 0 | 16 |
| [lib/features/garage/data/models/car\_modification\_model.dart](/lib/features/garage/data/models/car_modification_model.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/features/garage/data/models/reference\_data\_models.dart](/lib/features/garage/data/models/reference_data_models.dart) | Dart | 13 | 0 | 4 | 17 |
| [lib/features/garage/data/repositories/garage\_repository\_impl.dart](/lib/features/garage/data/repositories/garage_repository_impl.dart) | Dart | 51 | 1 | 4 | 56 |
| [lib/features/garage/domain/entities/car.dart](/lib/features/garage/domain/entities/car.dart) | Dart | 20 | 0 | 0 | 20 |
| [lib/features/garage/domain/entities/reference\_data.dart](/lib/features/garage/domain/entities/reference_data.dart) | Dart | 7 | 0 | 3 | 10 |
| [lib/features/garage/domain/repositories/garage\_repository.dart](/lib/features/garage/domain/repositories/garage_repository.dart) | Dart | 17 | 3 | 2 | 22 |
| [lib/features/garage/domain/usecases/delete\_cover\_image.dart](/lib/features/garage/domain/usecases/delete_cover_image.dart) | Dart | 19 | 0 | 6 | 25 |
| [lib/features/garage/domain/usecases/delete\_gallery\_images.dart](/lib/features/garage/domain/usecases/delete_gallery_images.dart) | Dart | 20 | 0 | 6 | 26 |
| [lib/features/garage/domain/usecases/get\_reference\_data.dart](/lib/features/garage/domain/usecases/get_reference_data.dart) | Dart | 9 | 0 | 2 | 11 |
| [lib/features/garage/presentation/bloc/add\_car/bloc.dart](/lib/features/garage/presentation/bloc/add_car/bloc.dart) | Dart | 172 | 28 | 19 | 219 |
| [lib/features/garage/presentation/bloc/add\_car/event.dart](/lib/features/garage/presentation/bloc/add_car/event.dart) | Dart | 34 | 11 | 3 | 48 |
| [lib/features/garage/presentation/bloc/add\_car/state.dart](/lib/features/garage/presentation/bloc/add_car/state.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/garage/presentation/bloc/car\_detail/bloc.dart](/lib/features/garage/presentation/bloc/car_detail/bloc.dart) | Dart | 0 | 1 | 0 | 1 |
| [lib/features/garage/presentation/bloc/log\_mod/bloc.dart](/lib/features/garage/presentation/bloc/log_mod/bloc.dart) | Dart | -2 | 1 | 0 | -1 |
| [lib/features/garage/presentation/bloc/log\_mod/event.dart](/lib/features/garage/presentation/bloc/log_mod/event.dart) | Dart | 1 | 1 | 1 | 3 |
| [lib/features/garage/presentation/pages/about\_car\_page.dart](/lib/features/garage/presentation/pages/about_car_page.dart) | Dart | 238 | 18 | 14 | 270 |
| [lib/features/garage/presentation/pages/fullscreen\_image\_page.dart](/lib/features/garage/presentation/pages/fullscreen_image_page.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/features/garage/presentation/pages/log\_mod\_page.dart](/lib/features/garage/presentation/pages/log_mod_page.dart) | Dart | 4 | 3 | 1 | 8 |
| [lib/features/garage/presentation/pages/register\_car\_page.dart](/lib/features/garage/presentation/pages/register_car_page.dart) | Dart | 313 | 28 | 24 | 365 |
| [lib/features/garage/presentation/widgets/register\_car/add\_mod\_sheet.dart](/lib/features/garage/presentation/widgets/register_car/add_mod_sheet.dart) | Dart | 111 | 10 | 8 | 129 |
| [lib/features/garage/presentation/widgets/register\_car/drivetrain\_step.dart](/lib/features/garage/presentation/widgets/register_car/drivetrain_step.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/features/garage/presentation/widgets/register\_car/editable\_image.dart](/lib/features/garage/presentation/widgets/register_car/editable_image.dart) | Dart | 17 | 6 | 7 | 30 |
| [lib/features/garage/presentation/widgets/register\_car/gallery\_step.dart](/lib/features/garage/presentation/widgets/register_car/gallery_step.dart) | Dart | 6 | 1 | 0 | 7 |
| [lib/features/garage/presentation/widgets/register\_car/identity\_step.dart](/lib/features/garage/presentation/widgets/register_car/identity_step.dart) | Dart | 28 | 3 | 1 | 32 |
| [lib/features/garage/presentation/widgets/register\_car/mod\_slot.dart](/lib/features/garage/presentation/widgets/register_car/mod_slot.dart) | Dart | 85 | 11 | 13 | 109 |
| [lib/features/garage/presentation/widgets/register\_car/mods\_step.dart](/lib/features/garage/presentation/widgets/register_car/mods_step.dart) | Dart | 10 | 1 | 0 | 11 |
| [lib/features/garage/presentation/widgets/register\_car/performance\_step.dart](/lib/features/garage/presentation/widgets/register_car/performance_step.dart) | Dart | 27 | 0 | 0 | 27 |
| [lib/features/garage/presentation/widgets/register\_car/register\_car\_chrome.dart](/lib/features/garage/presentation/widgets/register_car/register_car_chrome.dart) | Dart | 2 | 1 | 1 | 4 |
| [lib/features/garage/presentation/widgets/register\_car/register\_car\_fields.dart](/lib/features/garage/presentation/widgets/register_car/register_car_fields.dart) | Dart | 117 | 3 | 10 | 130 |
| [lib/features/garage/presentation/widgets/register\_car/story\_step.dart](/lib/features/garage/presentation/widgets/register_car/story_step.dart) | Dart | -32 | 1 | -2 | -33 |
| [lib/features/profile/presentation/widgets/my\_profile/my\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/my_profile/my_profile_data_view.dart) | Dart | 0 | -1 | 0 | -1 |
| [lib/features/settings/presentation/pages/settings\_page.dart](/lib/features/settings/presentation/pages/settings_page.dart) | Dart | 84 | 2 | 6 | 92 |
| [lib/features/settings/presentation/widgets/logout\_button.dart](/lib/features/settings/presentation/widgets/logout_button.dart) | Dart | 51 | 1 | 5 | 57 |
| [lib/main.dart](/lib/main.dart) | Dart | 5 | 1 | 1 | 7 |
| [macos/Flutter/GeneratedPluginRegistrant.swift](/macos/Flutter/GeneratedPluginRegistrant.swift) | Swift | 4 | 0 | 0 | 4 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 3 | 0 | 0 | 3 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details