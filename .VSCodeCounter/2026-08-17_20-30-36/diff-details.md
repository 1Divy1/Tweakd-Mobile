# Diff Details

Date : 2026-08-17 20:30:36

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 62 files,  3172 codes, 488 comments, 568 blanks, all 4228 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [FEEDBACK\_FEED\_PROGRESS.md](/FEEDBACK_FEED_PROGRESS.md) | Markdown | 67 | 0 | 17 | 84 |
| [MAP\_EVENTS\_NOTES.md](/MAP_EVENTS_NOTES.md) | Markdown | 28 | 0 | 0 | 28 |
| [MAP\_EVENTS\_PROGRESS.md](/MAP_EVENTS_PROGRESS.md) | Markdown | 59 | 0 | 4 | 63 |
| [ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json](/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json) | JSON | -121 | 0 | -1 | -122 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 81 | 0 | 0 | 81 |
| [lib/features/feedback\_feed/data/datasources/feedback\_feed\_api\_data\_source.dart](/lib/features/feedback_feed/data/datasources/feedback_feed_api_data_source.dart) | Dart | 98 | 12 | 17 | 127 |
| [lib/features/feedback\_feed/data/models/feedback\_feed\_models.dart](/lib/features/feedback_feed/data/models/feedback_feed_models.dart) | Dart | 156 | 11 | 21 | 188 |
| [lib/features/feedback\_feed/data/repositories/feedback\_feed\_repository\_impl.dart](/lib/features/feedback_feed/data/repositories/feedback_feed_repository_impl.dart) | Dart | 154 | 5 | 14 | 173 |
| [lib/features/feedback\_feed/domain/entities/feedback\_message.dart](/lib/features/feedback_feed/domain/entities/feedback_message.dart) | Dart | 117 | 15 | 19 | 151 |
| [lib/features/feedback\_feed/domain/entities/feedback\_option.dart](/lib/features/feedback_feed/domain/entities/feedback_option.dart) | Dart | 14 | 12 | 6 | 32 |
| [lib/features/feedback\_feed/domain/entities/feedback\_sort.dart](/lib/features/feedback_feed/domain/entities/feedback_sort.dart) | Dart | 8 | 3 | 2 | 13 |
| [lib/features/feedback\_feed/domain/failures/feedback\_feed\_failures.dart](/lib/features/feedback_feed/domain/failures/feedback_feed_failures.dart) | Dart | 7 | 5 | 3 | 15 |
| [lib/features/feedback\_feed/domain/repositories/feedback\_feed\_repository.dart](/lib/features/feedback_feed/domain/repositories/feedback_feed_repository.dart) | Dart | 29 | 11 | 11 | 51 |
| [lib/features/feedback\_feed/domain/usecases/get\_feedback\_board.dart](/lib/features/feedback_feed/domain/usecases/get_feedback_board.dart) | Dart | 50 | 2 | 12 | 64 |
| [lib/features/feedback\_feed/domain/usecases/get\_feedback\_options.dart](/lib/features/feedback_feed/domain/usecases/get_feedback_options.dart) | Dart | 26 | 3 | 8 | 37 |
| [lib/features/feedback\_feed/domain/usecases/manage\_feedback\_message.dart](/lib/features/feedback_feed/domain/usecases/manage_feedback_message.dart) | Dart | 55 | 3 | 14 | 72 |
| [lib/features/feedback\_feed/domain/usecases/vote\_feedback\_message.dart](/lib/features/feedback_feed/domain/usecases/vote_feedback_message.dart) | Dart | 45 | 4 | 12 | 61 |
| [lib/features/feedback\_feed/presentation/bloc/board/bloc.dart](/lib/features/feedback_feed/presentation/bloc/board/bloc.dart) | Dart | 200 | 22 | 28 | 250 |
| [lib/features/feedback\_feed/presentation/bloc/board/event.dart](/lib/features/feedback_feed/presentation/bloc/board/event.dart) | Dart | 39 | 10 | 16 | 65 |
| [lib/features/feedback\_feed/presentation/bloc/board/state.dart](/lib/features/feedback_feed/presentation/bloc/board/state.dart) | Dart | 59 | 6 | 7 | 72 |
| [lib/features/feedback\_feed/presentation/bloc/completed/bloc.dart](/lib/features/feedback_feed/presentation/bloc/completed/bloc.dart) | Dart | 91 | 2 | 14 | 107 |
| [lib/features/feedback\_feed/presentation/bloc/completed/event.dart](/lib/features/feedback_feed/presentation/bloc/completed/event.dart) | Dart | 19 | 4 | 8 | 31 |
| [lib/features/feedback\_feed/presentation/bloc/completed/state.dart](/lib/features/feedback_feed/presentation/bloc/completed/state.dart) | Dart | 43 | 2 | 7 | 52 |
| [lib/features/feedback\_feed/presentation/bloc/compose/bloc.dart](/lib/features/feedback_feed/presentation/bloc/compose/bloc.dart) | Dart | 72 | 4 | 13 | 89 |
| [lib/features/feedback\_feed/presentation/bloc/compose/event.dart](/lib/features/feedback_feed/presentation/bloc/compose/event.dart) | Dart | 24 | 5 | 9 | 38 |
| [lib/features/feedback\_feed/presentation/bloc/compose/state.dart](/lib/features/feedback_feed/presentation/bloc/compose/state.dart) | Dart | 54 | 6 | 13 | 73 |
| [lib/features/feedback\_feed/presentation/utils/feedback\_feed\_error\_mapper.dart](/lib/features/feedback_feed/presentation/utils/feedback_feed_error_mapper.dart) | Dart | 31 | 8 | 8 | 47 |
| [lib/features/feedback\_feed/presentation/utils/feedback\_feed\_format.dart](/lib/features/feedback_feed/presentation/utils/feedback_feed_format.dart) | Dart | 23 | 8 | 5 | 36 |
| [lib/features/feedback\_feed/presentation/utils/feedback\_feed\_visuals.dart](/lib/features/feedback_feed/presentation/utils/feedback_feed_visuals.dart) | Dart | 66 | 13 | 9 | 88 |
| [lib/features/feedback\_feed/presentation/widgets/board/completed\_requests\_banner.dart](/lib/features/feedback_feed/presentation/widgets/board/completed_requests_banner.dart) | Dart | 43 | 1 | 6 | 50 |
| [lib/features/feedback\_feed/presentation/widgets/board/delete\_feedback\_dialog.dart](/lib/features/feedback_feed/presentation/widgets/board/delete_feedback_dialog.dart) | Dart | 45 | 5 | 5 | 55 |
| [lib/features/feedback\_feed/presentation/widgets/board/feedback\_feed\_top\_bar.dart](/lib/features/feedback_feed/presentation/widgets/board/feedback_feed_top_bar.dart) | Dart | 99 | 2 | 9 | 110 |
| [lib/features/feedback\_feed/presentation/widgets/board/feedback\_message\_card.dart](/lib/features/feedback_feed/presentation/widgets/board/feedback_message_card.dart) | Dart | 67 | 3 | 6 | 76 |
| [lib/features/feedback\_feed/presentation/widgets/board/feedback\_sort\_tabs.dart](/lib/features/feedback_feed/presentation/widgets/board/feedback_sort_tabs.dart) | Dart | 83 | 4 | 9 | 96 |
| [lib/features/feedback\_feed/presentation/widgets/board/feedback\_vote\_bar.dart](/lib/features/feedback_feed/presentation/widgets/board/feedback_vote_bar.dart) | Dart | 118 | 5 | 10 | 133 |
| [lib/features/feedback\_feed/presentation/widgets/completed/completed\_feedback\_card.dart](/lib/features/feedback_feed/presentation/widgets/completed/completed_feedback_card.dart) | Dart | 76 | 2 | 6 | 84 |
| [lib/features/feedback\_feed/presentation/widgets/shared/feedback\_avatar.dart](/lib/features/feedback_feed/presentation/widgets/shared/feedback_avatar.dart) | Dart | 48 | 4 | 6 | 58 |
| [lib/features/feedback\_feed/presentation/widgets/shared/feedback\_badges.dart](/lib/features/feedback_feed/presentation/widgets/shared/feedback_badges.dart) | Dart | 77 | 5 | 8 | 90 |
| [lib/features/feedback\_feed/presentation/widgets/shared/feedback\_card\_header.dart](/lib/features/feedback_feed/presentation/widgets/shared/feedback_card_header.dart) | Dart | 77 | 5 | 7 | 89 |
| [lib/features/feedback\_feed/presentation/widgets/shared/feedback\_feed\_views.dart](/lib/features/feedback_feed/presentation/widgets/shared/feedback_feed_views.dart) | Dart | 200 | 5 | 19 | 224 |
| [lib/features/feedback\_feed/presentation/widgets/shared/feedback\_staff\_response.dart](/lib/features/feedback_feed/presentation/widgets/shared/feedback_staff_response.dart) | Dart | 45 | 2 | 6 | 53 |
| [lib/features/map/presentation/widgets/map\_flutter\_overlays.dart](/lib/features/map/presentation/widgets/map_flutter_overlays.dart) | Dart | 35 | 11 | 9 | 55 |
| [lib/features/map/presentation/widgets/map\_view.dart](/lib/features/map/presentation/widgets/map_view.dart) | Dart | 12 | 9 | 3 | 24 |
| [lib/features/map\_events/domain/entities/map\_event.dart](/lib/features/map_events/domain/entities/map_event.dart) | Dart | 6 | 3 | 1 | 10 |
| [lib/features/map\_events/presentation/bloc/create\_event/state.dart](/lib/features/map_events/presentation/bloc/create_event/state.dart) | Dart | 11 | 3 | 2 | 16 |
| [lib/features/map\_events/presentation/bloc/event\_detail/bloc.dart](/lib/features/map_events/presentation/bloc/event_detail/bloc.dart) | Dart | 30 | 10 | 4 | 44 |
| [lib/features/map\_events/presentation/bloc/event\_detail/event.dart](/lib/features/map_events/presentation/bloc/event_detail/event.dart) | Dart | 0 | 2 | 0 | 2 |
| [lib/features/map\_events/presentation/bloc/event\_detail/state.dart](/lib/features/map_events/presentation/bloc/event_detail/state.dart) | Dart | 10 | 15 | 7 | 32 |
| [lib/features/map\_events/presentation/pages/create\_map\_event\_page.dart](/lib/features/map_events/presentation/pages/create_map_event_page.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/features/map\_events/presentation/pages/map\_event\_detail\_page.dart](/lib/features/map_events/presentation/pages/map_event_detail_page.dart) | Dart | 6 | 0 | 0 | 6 |
| [lib/features/map\_events/presentation/utils/map\_event\_error\_mapper.dart](/lib/features/map_events/presentation/utils/map_event_error_mapper.dart) | Dart | 13 | 5 | 2 | 20 |
| [lib/features/map\_events/presentation/widgets/detail/map\_event\_cars\_tab.dart](/lib/features/map_events/presentation/widgets/detail/map_event_cars_tab.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/map\_events/presentation/widgets/detail/map\_event\_overview\_tab.dart](/lib/features/map_events/presentation/widgets/detail/map_event_overview_tab.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/map\_events/presentation/widgets/my\_events/my\_map\_events\_list.dart](/lib/features/map_events/presentation/widgets/my_events/my_map_events_list.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/map\_events/presentation/widgets/popup/map\_event\_popup.dart](/lib/features/map_events/presentation/widgets/popup/map_event_popup.dart) | Dart | -12 | 1 | -2 | -13 |
| [lib/features/map\_events/presentation/widgets/shared/event\_car\_picker\_sheet.dart](/lib/features/map_events/presentation/widgets/shared/event_car_picker_sheet.dart) | Dart | 172 | 7 | 12 | 191 |
| [lib/features/map\_events/presentation/widgets/shared/map\_event\_actions\_row.dart](/lib/features/map_events/presentation/widgets/shared/map_event_actions_row.dart) | Dart | 14 | 15 | 2 | 31 |
| [lib/features/map\_events/presentation/widgets/shared/map\_event\_participation\_strip.dart](/lib/features/map_events/presentation/widgets/shared/map_event_participation_strip.dart) | Dart | 4 | 8 | -1 | 11 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 45 | 180 | 45 | 270 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 117 | 0 | 45 | 162 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 118 | 0 | 45 | 163 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 7 | 0 | 1 | 8 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details