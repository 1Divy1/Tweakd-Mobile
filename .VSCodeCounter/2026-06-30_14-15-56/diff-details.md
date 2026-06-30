# Diff Details

Date : 2026-06-30 14:15:56

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 77 files,  6116 codes, 425 comments, 837 blanks, all 7378 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [.claude/settings.local.json](/.claude/settings.local.json) | JSON | 1 | 0 | 0 | 1 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 63 | -1 | 0 | 62 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 106 | 0 | 0 | 106 |
| [lib/core/services/car\_image\_service.dart](/lib/core/services/car_image_service.dart) | Dart | -54 | -16 | -10 | -80 |
| [lib/core/services/image\_service.dart](/lib/core/services/image_service.dart) | Dart | 58 | 16 | 9 | 83 |
| [lib/core/shared/entities/image\_ref.dart](/lib/core/shared/entities/image_ref.dart) | Dart | 8 | 4 | 3 | 15 |
| [lib/features/feed/README.md](/lib/features/feed/README.md) | Markdown | 38 | 0 | 12 | 50 |
| [lib/features/feed/data/datasources/feed\_api\_data\_source.dart](/lib/features/feed/data/datasources/feed_api_data_source.dart) | Dart | 18 | 4 | 5 | 27 |
| [lib/features/feed/data/repositories/feed\_repository\_impl.dart](/lib/features/feed/data/repositories/feed_repository_impl.dart) | Dart | 32 | 0 | 5 | 37 |
| [lib/features/feed/domain/repositories/feed\_repository.dart](/lib/features/feed/domain/repositories/feed_repository.dart) | Dart | 9 | 5 | 3 | 17 |
| [lib/features/feed/domain/usecases/get\_global\_feed.dart](/lib/features/feed/domain/usecases/get_global_feed.dart) | Dart | 20 | 0 | 6 | 26 |
| [lib/features/feed/presentation/bloc/feed/bloc.dart](/lib/features/feed/presentation/bloc/feed/bloc.dart) | Dart | 146 | 9 | 21 | 176 |
| [lib/features/feed/presentation/bloc/feed/event.dart](/lib/features/feed/presentation/bloc/feed/event.dart) | Dart | 27 | 6 | 10 | 43 |
| [lib/features/feed/presentation/bloc/feed/state.dart](/lib/features/feed/presentation/bloc/feed/state.dart) | Dart | 44 | 2 | 13 | 59 |
| [lib/features/feed/presentation/pages/feed\_page.dart](/lib/features/feed/presentation/pages/feed_page.dart) | Dart | 160 | 3 | 18 | 181 |
| [lib/features/feed/presentation/utils/feed\_error\_mapper.dart](/lib/features/feed/presentation/utils/feed_error_mapper.dart) | Dart | 14 | 4 | 4 | 22 |
| [lib/features/feed/presentation/widgets/feed\_empty\_view.dart](/lib/features/feed/presentation/widgets/feed_empty_view.dart) | Dart | 43 | 0 | 4 | 47 |
| [lib/features/feed/presentation/widgets/feed\_error\_view.dart](/lib/features/feed/presentation/widgets/feed_error_view.dart) | Dart | 54 | 0 | 5 | 59 |
| [lib/features/feed/presentation/widgets/feed\_loading\_view.dart](/lib/features/feed/presentation/widgets/feed_loading_view.dart) | Dart | 11 | 0 | 4 | 15 |
| [lib/features/feed/presentation/widgets/feed\_post\_card.dart](/lib/features/feed/presentation/widgets/feed_post_card.dart) | Dart | 190 | 4 | 12 | 206 |
| [lib/features/feed/presentation/widgets/feed\_top\_bar.dart](/lib/features/feed/presentation/widgets/feed_top_bar.dart) | Dart | 67 | 4 | 8 | 79 |
| [lib/features/garage/data/models/car\_summary\_model.dart](/lib/features/garage/data/models/car_summary_model.dart) | Dart | 9 | 0 | 0 | 9 |
| [lib/features/garage/domain/entities/car\_image\_ref.dart](/lib/features/garage/domain/entities/car_image_ref.dart) | Dart | -8 | -4 | -4 | -16 |
| [lib/features/garage/domain/entities/car\_summary.dart](/lib/features/garage/domain/entities/car_summary.dart) | Dart | 5 | 2 | 1 | 8 |
| [lib/features/posts/data/datasources/posts\_api\_data\_source.dart](/lib/features/posts/data/datasources/posts_api_data_source.dart) | Dart | 56 | 4 | 13 | 73 |
| [lib/features/posts/data/models/post\_comment\_models.dart](/lib/features/posts/data/models/post_comment_models.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/posts/data/models/post\_models.dart](/lib/features/posts/data/models/post_models.dart) | Dart | 9 | 2 | 0 | 11 |
| [lib/features/posts/data/repositories/posts\_repository\_impl.dart](/lib/features/posts/data/repositories/posts_repository_impl.dart) | Dart | 129 | 4 | 14 | 147 |
| [lib/features/posts/domain/entities/post.dart](/lib/features/posts/domain/entities/post.dart) | Dart | 38 | 0 | 1 | 39 |
| [lib/features/posts/domain/entities/post\_comment.dart](/lib/features/posts/domain/entities/post_comment.dart) | Dart | 23 | 3 | 3 | 29 |
| [lib/features/posts/domain/entities/post\_summary.dart](/lib/features/posts/domain/entities/post_summary.dart) | Dart | 12 | 0 | 3 | 15 |
| [lib/features/posts/domain/entities/post\_tagged\_car.dart](/lib/features/posts/domain/entities/post_tagged_car.dart) | Dart | 4 | 3 | 1 | 8 |
| [lib/features/posts/domain/repositories/posts\_repository.dart](/lib/features/posts/domain/repositories/posts_repository.dart) | Dart | 21 | 3 | 13 | 37 |
| [lib/features/posts/domain/usecases/add\_comment.dart](/lib/features/posts/domain/usecases/add_comment.dart) | Dart | 29 | 1 | 8 | 38 |
| [lib/features/posts/domain/usecases/comment\_actions.dart](/lib/features/posts/domain/usecases/comment_actions.dart) | Dart | 37 | 0 | 12 | 49 |
| [lib/features/posts/domain/usecases/get\_comment\_replies.dart](/lib/features/posts/domain/usecases/get_comment_replies.dart) | Dart | 35 | 0 | 6 | 41 |
| [lib/features/posts/domain/usecases/post\_like.dart](/lib/features/posts/domain/usecases/post_like.dart) | Dart | 27 | 0 | 9 | 36 |
| [lib/features/posts/domain/usecases/post\_save.dart](/lib/features/posts/domain/usecases/post_save.dart) | Dart | 24 | 0 | 8 | 32 |
| [lib/features/posts/domain/usecases/share\_post.dart](/lib/features/posts/domain/usecases/share_post.dart) | Dart | 19 | 1 | 7 | 27 |
| [lib/features/posts/presentation/bloc/comments/bloc.dart](/lib/features/posts/presentation/bloc/comments/bloc.dart) | Dart | 355 | 29 | 44 | 428 |
| [lib/features/posts/presentation/bloc/comments/event.dart](/lib/features/posts/presentation/bloc/comments/event.dart) | Dart | 53 | 7 | 19 | 79 |
| [lib/features/posts/presentation/bloc/comments/state.dart](/lib/features/posts/presentation/bloc/comments/state.dart) | Dart | 86 | 8 | 17 | 111 |
| [lib/features/posts/presentation/bloc/create\_post/bloc.dart](/lib/features/posts/presentation/bloc/create_post/bloc.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/posts/presentation/bloc/edit\_post/bloc.dart](/lib/features/posts/presentation/bloc/edit_post/bloc.dart) | Dart | 122 | 8 | 28 | 158 |
| [lib/features/posts/presentation/bloc/likers/bloc.dart](/lib/features/posts/presentation/bloc/likers/bloc.dart) | Dart | 89 | 5 | 23 | 117 |
| [lib/features/posts/presentation/bloc/post\_detail/bloc.dart](/lib/features/posts/presentation/bloc/post_detail/bloc.dart) | Dart | 107 | 5 | 16 | 128 |
| [lib/features/posts/presentation/bloc/post\_detail/event.dart](/lib/features/posts/presentation/bloc/post_detail/event.dart) | Dart | 34 | 6 | 13 | 53 |
| [lib/features/posts/presentation/bloc/post\_detail/state.dart](/lib/features/posts/presentation/bloc/post_detail/state.dart) | Dart | 33 | 1 | 12 | 46 |
| [lib/features/posts/presentation/bloc/profile\_posts/bloc.dart](/lib/features/posts/presentation/bloc/profile_posts/bloc.dart) | Dart | 98 | 4 | 14 | 116 |
| [lib/features/posts/presentation/bloc/profile\_posts/event.dart](/lib/features/posts/presentation/bloc/profile_posts/event.dart) | Dart | 21 | 6 | 8 | 35 |
| [lib/features/posts/presentation/bloc/profile\_posts/state.dart](/lib/features/posts/presentation/bloc/profile_posts/state.dart) | Dart | 44 | 2 | 13 | 59 |
| [lib/features/posts/presentation/bloc/share\_post/bloc.dart](/lib/features/posts/presentation/bloc/share_post/bloc.dart) | Dart | 32 | 2 | 7 | 41 |
| [lib/features/posts/presentation/bloc/share\_post/event.dart](/lib/features/posts/presentation/bloc/share_post/event.dart) | Dart | 13 | 2 | 6 | 21 |
| [lib/features/posts/presentation/bloc/share\_post/state.dart](/lib/features/posts/presentation/bloc/share_post/state.dart) | Dart | 17 | 1 | 9 | 27 |
| [lib/features/posts/presentation/pages/edit\_post\_page.dart](/lib/features/posts/presentation/pages/edit_post_page.dart) | Dart | 363 | 6 | 23 | 392 |
| [lib/features/posts/presentation/pages/post\_detail\_page.dart](/lib/features/posts/presentation/pages/post_detail_page.dart) | Dart | 377 | 5 | 23 | 405 |
| [lib/features/posts/presentation/pages/share\_post\_page.dart](/lib/features/posts/presentation/pages/share_post_page.dart) | Dart | 302 | 2 | 19 | 323 |
| [lib/features/posts/presentation/widgets/create\_post/photos\_step.dart](/lib/features/posts/presentation/widgets/create_post/photos_step.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/posts/presentation/widgets/create\_post/review\_step.dart](/lib/features/posts/presentation/widgets/create_post/review_step.dart) | Dart | 20 | 0 | 4 | 24 |
| [lib/features/posts/presentation/widgets/create\_post/tags\_step.dart](/lib/features/posts/presentation/widgets/create_post/tags_step.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/posts/presentation/widgets/create\_post/visibility\_step.dart](/lib/features/posts/presentation/widgets/create_post/visibility_step.dart) | Dart | -35 | 0 | -1 | -36 |
| [lib/features/posts/presentation/widgets/post\_card.dart](/lib/features/posts/presentation/widgets/post_card.dart) | Dart | 66 | 2 | 8 | 76 |
| [lib/features/posts/presentation/widgets/post\_card/post\_author\_header.dart](/lib/features/posts/presentation/widgets/post_card/post_author_header.dart) | Dart | 131 | 7 | 10 | 148 |
| [lib/features/posts/presentation/widgets/post\_card/post\_media\_carousel.dart](/lib/features/posts/presentation/widgets/post_card/post_media_carousel.dart) | Dart | 186 | 14 | 23 | 223 |
| [lib/features/posts/presentation/widgets/post\_card/post\_tags.dart](/lib/features/posts/presentation/widgets/post_card/post_tags.dart) | Dart | 69 | 4 | 8 | 81 |
| [lib/features/posts/presentation/widgets/post\_detail/comments\_sheet.dart](/lib/features/posts/presentation/widgets/post_detail/comments_sheet.dart) | Dart | 639 | 5 | 35 | 679 |
| [lib/features/posts/presentation/widgets/post\_detail/likers\_sheet.dart](/lib/features/posts/presentation/widgets/post_detail/likers_sheet.dart) | Dart | 176 | 1 | 7 | 184 |
| [lib/features/posts/presentation/widgets/post\_detail/pinch\_zoom.dart](/lib/features/posts/presentation/widgets/post_detail/pinch_zoom.dart) | Dart | 146 | 21 | 18 | 185 |
| [lib/features/posts/presentation/widgets/post\_detail/post\_detail\_view.dart](/lib/features/posts/presentation/widgets/post_detail/post_detail_view.dart) | Dart | 296 | 3 | 23 | 322 |
| [lib/features/posts/presentation/widgets/post\_detail/post\_time.dart](/lib/features/posts/presentation/widgets/post_detail/post_time.dart) | Dart | 10 | 2 | 2 | 14 |
| [lib/features/profile/presentation/widgets/my\_profile/my\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/my_profile/my_profile_data_view.dart) | Dart | 26 | 0 | 2 | 28 |
| [lib/features/profile/presentation/widgets/public\_profile/public\_profile\_data\_view.dart](/lib/features/profile/presentation/widgets/public_profile/public_profile_data_view.dart) | Dart | 28 | 0 | 2 | 30 |
| [lib/features/profile/presentation/widgets/shared/posts\_section.dart](/lib/features/profile/presentation/widgets/shared/posts_section.dart) | Dart | 227 | 4 | 19 | 250 |
| [lib/features/profile/presentation/widgets/shared/profile\_section\_tabs.dart](/lib/features/profile/presentation/widgets/shared/profile_section_tabs.dart) | Dart | 92 | 4 | 9 | 105 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 49 | 196 | 49 | 294 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 154 | 0 | 49 | 203 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 156 | 0 | 49 | 205 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details