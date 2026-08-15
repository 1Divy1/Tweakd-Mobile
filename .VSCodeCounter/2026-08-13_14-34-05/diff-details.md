# Diff Details

Date : 2026-08-13 14:34:05

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 39 files,  517 codes, 61 comments, 49 blanks, all 627 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [MAP\_EVENTS\_NOTES.md](/MAP_EVENTS_NOTES.md) | Markdown | 44 | 0 | 6 | 50 |
| [MAP\_EVENTS\_PROGRESS.md](/MAP_EVENTS_PROGRESS.md) | Markdown | 42 | 0 | 5 | 47 |
| [lib/core/di/injection.config.dart](/lib/core/di/injection.config.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/map/presentation/widgets/businesses/business\_popup.dart](/lib/features/map/presentation/widgets/businesses/business_popup.dart) | Dart | -6 | -3 | -1 | -10 |
| [lib/features/map/presentation/widgets/businesses/business\_popup\_content.dart](/lib/features/map/presentation/widgets/businesses/business_popup_content.dart) | Dart | -13 | 2 | -1 | -12 |
| [lib/features/map/presentation/widgets/map\_flutter\_overlays.dart](/lib/features/map/presentation/widgets/map_flutter_overlays.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/features/map\_events/README.md](/lib/features/map_events/README.md) | Markdown | 9 | 0 | 3 | 12 |
| [lib/features/map\_events/data/datasources/map\_events\_api\_data\_source.dart](/lib/features/map_events/data/datasources/map_events_api_data_source.dart) | Dart | 13 | 9 | 1 | 23 |
| [lib/features/map\_events/data/models/map\_event\_list\_models.dart](/lib/features/map_events/data/models/map_event_list_models.dart) | Dart | 12 | 2 | 0 | 14 |
| [lib/features/map\_events/data/models/map\_event\_model.dart](/lib/features/map_events/data/models/map_event_model.dart) | Dart | 4 | 1 | 2 | 7 |
| [lib/features/map\_events/data/repositories/map\_events\_repository\_impl.dart](/lib/features/map_events/data/repositories/map_events_repository_impl.dart) | Dart | 15 | 0 | 1 | 16 |
| [lib/features/map\_events/domain/entities/map\_event.dart](/lib/features/map_events/domain/entities/map_event.dart) | Dart | 11 | 3 | 1 | 15 |
| [lib/features/map\_events/domain/entities/map\_event\_attendee.dart](/lib/features/map_events/domain/entities/map_event_attendee.dart) | Dart | 2 | 2 | 2 | 6 |
| [lib/features/map\_events/domain/entities/map\_event\_participant.dart](/lib/features/map_events/domain/entities/map_event_participant.dart) | Dart | 2 | 3 | 1 | 6 |
| [lib/features/map\_events/domain/entities/organizer\_candidate.dart](/lib/features/map_events/domain/entities/organizer_candidate.dart) | Dart | 2 | 1 | 2 | 5 |
| [lib/features/map\_events/domain/repositories/map\_events\_repository.dart](/lib/features/map_events/domain/repositories/map_events_repository.dart) | Dart | 5 | 9 | 1 | 15 |
| [lib/features/map\_events/domain/usecases/map\_event\_participation.dart](/lib/features/map_events/domain/usecases/map_event_participation.dart) | Dart | 2 | 2 | 1 | 5 |
| [lib/features/map\_events/domain/usecases/map\_event\_reads.dart](/lib/features/map_events/domain/usecases/map_event_reads.dart) | Dart | 21 | 4 | 6 | 31 |
| [lib/features/map\_events/domain/usecases/map\_event\_withdrawals.dart](/lib/features/map_events/domain/usecases/map_event_withdrawals.dart) | Dart | -3 | 1 | 0 | -2 |
| [lib/features/map\_events/presentation/bloc/event\_detail/bloc.dart](/lib/features/map_events/presentation/bloc/event_detail/bloc.dart) | Dart | -44 | -5 | -4 | -53 |
| [lib/features/map\_events/presentation/bloc/event\_detail/state.dart](/lib/features/map_events/presentation/bloc/event_detail/state.dart) | Dart | 0 | -7 | -1 | -8 |
| [lib/features/map\_events/presentation/bloc/manage\_event/bloc.dart](/lib/features/map_events/presentation/bloc/manage_event/bloc.dart) | Dart | -3 | 3 | 0 | 0 |
| [lib/features/map\_events/presentation/bloc/manage\_event/event.dart](/lib/features/map_events/presentation/bloc/manage_event/event.dart) | Dart | 1 | 4 | 0 | 5 |
| [lib/features/map\_events/presentation/pages/map\_event\_attendees\_page.dart](/lib/features/map_events/presentation/pages/map_event_attendees_page.dart) | Dart | 20 | 2 | 0 | 22 |
| [lib/features/map\_events/presentation/pages/map\_event\_detail\_page.dart](/lib/features/map_events/presentation/pages/map_event_detail_page.dart) | Dart | 3 | -2 | 0 | 1 |
| [lib/features/map\_events/presentation/utils/map\_event\_formatting.dart](/lib/features/map_events/presentation/utils/map_event_formatting.dart) | Dart | -4 | 2 | -1 | -3 |
| [lib/features/map\_events/presentation/widgets/create/organizer\_search\_sheet.dart](/lib/features/map_events/presentation/widgets/create/organizer_search_sheet.dart) | Dart | 19 | 2 | 0 | 21 |
| [lib/features/map\_events/presentation/widgets/detail/map\_event\_hero.dart](/lib/features/map_events/presentation/widgets/detail/map_event_hero.dart) | Dart | -9 | 0 | -1 | -10 |
| [lib/features/map\_events/presentation/widgets/manage/decline\_entry\_dialog.dart](/lib/features/map_events/presentation/widgets/manage/decline_entry_dialog.dart) | Dart | 155 | 10 | 11 | 176 |
| [lib/features/map\_events/presentation/widgets/manage/manage\_event\_sections.dart](/lib/features/map_events/presentation/widgets/manage/manage_event_sections.dart) | Dart | 13 | 2 | 1 | 16 |
| [lib/features/map\_events/presentation/widgets/popup/map\_event\_popup.dart](/lib/features/map_events/presentation/widgets/popup/map_event_popup.dart) | Dart | -2 | 1 | -2 | -3 |
| [lib/features/map\_events/presentation/widgets/shared/map\_event\_actions\_row.dart](/lib/features/map_events/presentation/widgets/shared/map_event_actions_row.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/features/map\_events/presentation/widgets/shared/map\_event\_organizer\_row.dart](/lib/features/map_events/presentation/widgets/shared/map_event_organizer_row.dart) | Dart | 27 | 4 | 2 | 33 |
| [lib/features/map\_events/presentation/widgets/shared/map\_event\_participation\_strip.dart](/lib/features/map_events/presentation/widgets/shared/map_event_participation_strip.dart) | Dart | 31 | -2 | 1 | 30 |
| [lib/features/map\_events/presentation/widgets/shared/withdraw\_event\_dialog.dart](/lib/features/map_events/presentation/widgets/shared/withdraw_event_dialog.dart) | Dart | 36 | 4 | 1 | 41 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 1 | 4 | 1 | 6 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 10 | 0 | 1 | 11 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 12 | 0 | 1 | 13 |
| [test/features/map\_events/map\_event\_models\_test.dart](/test/features/map_events/map_event_models_test.dart) | Dart | 88 | 3 | 9 | 100 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details