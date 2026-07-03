# Diff Details

Date : 2026-07-03 21:48:49

Directory /Users/mbpro/Developer/Apps/Car-Social-Media-App

Total : 46 files,  5365 codes, 130 comments, 487 blanks, all 5982 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [.claude/settings.local.json](/.claude/settings.local.json) | JSON | 1 | 0 | 0 | 1 |
| [FORUMS\_PROGRESS.md](/FORUMS_PROGRESS.md) | Markdown | 9 | 0 | 1 | 10 |
| [lib/config/routes/app\_router.dart](/lib/config/routes/app_router.dart) | Dart | 67 | 3 | 1 | 71 |
| [lib/core/shared/widgets/app\_bottom\_nav.dart](/lib/core/shared/widgets/app_bottom_nav.dart) | Dart | 10 | 0 | 0 | 10 |
| [lib/features/forums/presentation/bloc/browse/bloc.dart](/lib/features/forums/presentation/bloc/browse/bloc.dart) | Dart | 35 | 2 | 8 | 45 |
| [lib/features/forums/presentation/bloc/browse/event.dart](/lib/features/forums/presentation/bloc/browse/event.dart) | Dart | 9 | 1 | 4 | 14 |
| [lib/features/forums/presentation/bloc/browse/state.dart](/lib/features/forums/presentation/bloc/browse/state.dart) | Dart | 28 | 0 | 12 | 40 |
| [lib/features/forums/presentation/bloc/composer/bloc.dart](/lib/features/forums/presentation/bloc/composer/bloc.dart) | Dart | 180 | 10 | 27 | 217 |
| [lib/features/forums/presentation/bloc/composer/event.dart](/lib/features/forums/presentation/bloc/composer/event.dart) | Dart | 45 | 8 | 17 | 70 |
| [lib/features/forums/presentation/bloc/composer/state.dart](/lib/features/forums/presentation/bloc/composer/state.dart) | Dart | 96 | 5 | 11 | 112 |
| [lib/features/forums/presentation/bloc/hub/bloc.dart](/lib/features/forums/presentation/bloc/hub/bloc.dart) | Dart | 148 | 7 | 17 | 172 |
| [lib/features/forums/presentation/bloc/hub/event.dart](/lib/features/forums/presentation/bloc/hub/event.dart) | Dart | 37 | 6 | 13 | 56 |
| [lib/features/forums/presentation/bloc/hub/state.dart](/lib/features/forums/presentation/bloc/hub/state.dart) | Dart | 100 | 6 | 10 | 116 |
| [lib/features/forums/presentation/bloc/thread/bloc.dart](/lib/features/forums/presentation/bloc/thread/bloc.dart) | Dart | 380 | 5 | 33 | 418 |
| [lib/features/forums/presentation/bloc/thread/event.dart](/lib/features/forums/presentation/bloc/thread/event.dart) | Dart | 71 | 14 | 24 | 109 |
| [lib/features/forums/presentation/bloc/thread/state.dart](/lib/features/forums/presentation/bloc/thread/state.dart) | Dart | 166 | 8 | 15 | 189 |
| [lib/features/forums/presentation/pages/forum\_hub\_page.dart](/lib/features/forums/presentation/pages/forum_hub_page.dart) | Dart | 336 | 0 | 20 | 356 |
| [lib/features/forums/presentation/pages/forum\_thread\_page.dart](/lib/features/forums/presentation/pages/forum_thread_page.dart) | Dart | 397 | 1 | 27 | 425 |
| [lib/features/forums/presentation/pages/forums\_browse\_page.dart](/lib/features/forums/presentation/pages/forums_browse_page.dart) | Dart | 152 | 0 | 19 | 171 |
| [lib/features/forums/presentation/pages/forums\_home\_page.dart](/lib/features/forums/presentation/pages/forums_home_page.dart) | Dart | 227 | 2 | 17 | 246 |
| [lib/features/forums/presentation/pages/new\_thread\_page.dart](/lib/features/forums/presentation/pages/new_thread_page.dart) | Dart | 242 | 1 | 16 | 259 |
| [lib/features/forums/presentation/widgets/browse/browse\_tab\_toggle.dart](/lib/features/forums/presentation/widgets/browse/browse_tab_toggle.dart) | Dart | 71 | 1 | 8 | 80 |
| [lib/features/forums/presentation/widgets/browse/forum\_brand\_card.dart](/lib/features/forums/presentation/widgets/browse/forum_brand_card.dart) | Dart | 81 | 2 | 7 | 90 |
| [lib/features/forums/presentation/widgets/browse/forum\_topic\_card.dart](/lib/features/forums/presentation/widgets/browse/forum_topic_card.dart) | Dart | 55 | 2 | 6 | 63 |
| [lib/features/forums/presentation/widgets/composer/car\_tag\_picker.dart](/lib/features/forums/presentation/widgets/composer/car_tag_picker.dart) | Dart | 253 | 2 | 16 | 271 |
| [lib/features/forums/presentation/widgets/composer/topic\_selector.dart](/lib/features/forums/presentation/widgets/composer/topic_selector.dart) | Dart | 56 | 2 | 9 | 67 |
| [lib/features/forums/presentation/widgets/home/forum\_shortcuts\_row.dart](/lib/features/forums/presentation/widgets/home/forum_shortcuts_row.dart) | Dart | 197 | 2 | 9 | 208 |
| [lib/features/forums/presentation/widgets/home/forums\_empty\_view.dart](/lib/features/forums/presentation/widgets/home/forums_empty_view.dart) | Dart | 206 | 2 | 14 | 222 |
| [lib/features/forums/presentation/widgets/home/forums\_top\_bar.dart](/lib/features/forums/presentation/widgets/home/forums_top_bar.dart) | Dart | 49 | 2 | 5 | 56 |
| [lib/features/forums/presentation/widgets/hub/save\_shortcut\_sheet.dart](/lib/features/forums/presentation/widgets/hub/save_shortcut_sheet.dart) | Dart | 225 | 2 | 11 | 238 |
| [lib/features/forums/presentation/widgets/shared/forum\_avatar.dart](/lib/features/forums/presentation/widgets/shared/forum_avatar.dart) | Dart | 45 | 2 | 5 | 52 |
| [lib/features/forums/presentation/widgets/shared/forum\_chips.dart](/lib/features/forums/presentation/widgets/shared/forum_chips.dart) | Dart | 94 | 4 | 8 | 106 |
| [lib/features/forums/presentation/widgets/shared/forum\_error\_view.dart](/lib/features/forums/presentation/widgets/shared/forum_error_view.dart) | Dart | 46 | 1 | 5 | 52 |
| [lib/features/forums/presentation/widgets/shared/forum\_pill\_button.dart](/lib/features/forums/presentation/widgets/shared/forum_pill_button.dart) | Dart | 23 | 2 | 5 | 30 |
| [lib/features/forums/presentation/widgets/shared/forum\_section\_label.dart](/lib/features/forums/presentation/widgets/shared/forum_section_label.dart) | Dart | 18 | 1 | 5 | 24 |
| [lib/features/forums/presentation/widgets/shared/forum\_sort\_tabs.dart](/lib/features/forums/presentation/widgets/shared/forum_sort_tabs.dart) | Dart | 72 | 2 | 8 | 82 |
| [lib/features/forums/presentation/widgets/shared/forum\_sub\_top\_bar.dart](/lib/features/forums/presentation/widgets/shared/forum_sub_top_bar.dart) | Dart | 62 | 3 | 5 | 70 |
| [lib/features/forums/presentation/widgets/shared/forum\_thread\_card.dart](/lib/features/forums/presentation/widgets/shared/forum_thread_card.dart) | Dart | 191 | 3 | 13 | 207 |
| [lib/features/forums/presentation/widgets/shared/forum\_thread\_skeleton.dart](/lib/features/forums/presentation/widgets/shared/forum_thread_skeleton.dart) | Dart | 90 | 3 | 13 | 106 |
| [lib/features/forums/presentation/widgets/thread/forum\_edit\_sheet.dart](/lib/features/forums/presentation/widgets/thread/forum_edit_sheet.dart) | Dart | 166 | 2 | 11 | 179 |
| [lib/features/forums/presentation/widgets/thread/reply\_input\_bar.dart](/lib/features/forums/presentation/widgets/thread/reply_input_bar.dart) | Dart | 163 | 3 | 7 | 173 |
| [lib/features/forums/presentation/widgets/thread/reply\_tile.dart](/lib/features/forums/presentation/widgets/thread/reply_tile.dart) | Dart | 250 | 2 | 10 | 262 |
| [lib/features/forums/presentation/widgets/thread/thread\_header.dart](/lib/features/forums/presentation/widgets/thread/thread_header.dart) | Dart | 211 | 2 | 12 | 225 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 1 | 4 | 1 | 6 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 2 | 0 | 1 | 3 |
| [lib/l10n/app\_localizations\_ro.dart](/lib/l10n/app_localizations_ro.dart) | Dart | 2 | 0 | 1 | 3 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details