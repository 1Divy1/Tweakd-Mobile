# Forums feature — implementation progress

Working doc so context survives session resets. Delete when the feature ships.
Branch: `feedback`. Started 2026-07-03.

## What is being built

Full end-to-end forums feature (user confirmed: domain + data + blocs + UI in one
pass), clean architecture under `lib/features/forums/`, matching the mocks:

1. **Forums home** (`/forums`, new bottom-nav tab) — "Forums / Your paddock" header
   with browse (compass) + new-thread (+) buttons; empty state (pin explainer,
   popular hubs from topics, start-first-thread CTA) or shortcuts state
   (horizontal shortcut cards + EDIT mode with delete/reorder, "HOT IN YOUR
   FORUMS" list = `GET /forums/feed` with Hot/New/Active sort + cursor paging).
2. **Browse** (`/forums/browse`) — By car (garage brand catalog) / By topic
   (component + format groups from `GET /forums/topics`).
3. **Hub** (`/forums/hub`, extra = `ForumFilter{brand?, model?, topic?}`) — brand
   hub shows MODELS chips (garage `GetModelsByBrand`) + refine-by-topic; refined
   hub (model/topic) shows "Save shortcut" button + topic chip row (All + topics);
   thread list with sort tabs, skeleton loading, cursor paging. Save-shortcut
   bottom sheet (filter chips, name prefilled "M4 · Tuning", notify toggle).
4. **Thread** (`/forums/threads/:id`) — pinned/locked banner, title, author,
   body, tag chips, like/reply-count/share actions, lazy level-by-level replies
   (top-level oldest-first, "show N replies" expands children via
   `GET /forums/posts/{id}/replies`), reply input bar (locked bar when locked),
   author-only edit/delete via ⋯ menus, [deleted] placeholders.
5. **New thread** (`/forums/new`) — title/body, TAG A CAR (garage cars chip +
   model autocomplete across brand catalog, brand auto-derived), TOPICS
   (component + format chips), Post → `POST /forums/threads`.

## Decisions (user-confirmed 2026-07-03)

- Bottom nav: **add FORUMS tab**, keep existing tabs → FEED, MAP, FORUMS, +, SEARCH, PROFILE.
- Browse entry: compass icon button in forums home top bar.
- Counts (threads-per-brand/topic, "142 THREADS"): **render only when available**
  — entities/UI have optional count slots, hidden when null (backend has none today).
- Omit (no backend): thread Save/bookmark, shortcut unread badges, reply sort tabs.
- Popular hubs on empty home: derived from `GET /forums/topics` (by sortOrder).
- Wire format is **snake_case** (contract examples are camelCase but illustrative
  only — owner reconfirmed 2026-06-30; see memory `project_backend_camelcase`).

## ⚠️ Features NOT implementable yet (missing backend) — REMIND THE USER

- Thread **Save/bookmark** action (mock shows Save on thread page + cards).
- **Unread count badges** on shortcut cards (mock: 12 / 34 badges).
- **Reply sorting** (mock has Hot/New/Active on replies; API is oldest-first only).
- **Thread counts** anywhere (brand/topic browse cards, hub subtitles "BMW · 1.2k
  threads", "142 THREADS" header) — no endpoint returns counts; UI slots exist
  and auto-show once entities get counts.
- **Popular hubs** curation (mock mixes cars + topics, e.g. "BMW M4", "Supra
  MK5") — no suggestion endpoint; home derives suggestions from topics only.
- Forum threads/replies are **not report targets** (report feature covers posts/
  comments/accounts only).

## Backend contract (condensed)

Base: dio baseUrl already ends in `/api/v1` → paths start `/forums/...`.
Errors: `{status, message, field_errors, timestamp}`; 400 bad cursor/sort/ids,
401 auth, 403 not-owner, 404 missing, 409 locked thread / deleted thread on
edit / deleted reply on reply/like/edit. Lists: `{items, next_cursor}` (opaque
cursor, echo back with same sort; null = last page; size default 20 max 50).

- `GET /forums/topics` → `[{kind: component|format, topics: [{id(slug), name, kind, sort_order, color}]}]`
- Thread lists (`sort=hot|new|active`, `cursor`, `size`) → CursorPage<ThreadCard>:
  - `GET /forums/feed`
  - `GET /forums/brands/{brandId}/threads`
  - `GET /forums/models/{modelId}/threads?topic=<slug>`
  - `GET /forums/topics/{topicId}/threads?brand=<uuid>&model=<uuid>`
- ThreadCard: `{id, title, author{id,username,avatar_url}|null, brand{id,name}|null,
  model{id,brand_id,model}|null, topics[], likes_count, reply_count,
  last_activity_at, pinned, locked, deleted}` (deleted ⇒ author null → "[deleted]").
- `GET /forums/threads/{id}` → card + `content?`, `created_at`, `viewer_has_liked`
  (deleted returned normally, not 404).
- Replies: `GET /forums/threads/{id}/replies` (top-level, oldest first),
  `GET /forums/posts/{postId}/replies` (direct children page). Reply:
  `{id, author|null, content|null, likes_count, reply_count, deleted,
  viewer_has_liked, created_at}`.
- Writes: `POST /forums/threads {title(≤200 req), content(≤20000 opt), model_id
  (brand auto), brand_id (only if model null), topic_ids(≤10 slugs)}` → 201 detail.
  `PATCH /forums/threads/{id} {content req, "" clears}` (OP body only).
  `POST /forums/threads/{id}/replies {content, parent_post_id?}`.
  `PATCH /forums/posts/{id} {content req non-blank}`.
- Likes (204, idempotent): `POST/DELETE /forums/threads/{id}/like`,
  `POST/DELETE /forums/posts/{id}/like` (POST 409 on deleted reply).
- Deletes (204, author-only): `DELETE /forums/threads/{id}`,
  `DELETE /forums/posts/{id}` — with children ⇒ anonymized/[deleted]; else gone.
- Shortcuts `/forums/shortcuts`: GET (pinned order), POST `{name req ≤100,
  brand_id?, model_id?, topic_id?, notify}` (≥1 of the three), PATCH /{id}
  partial (name/notify; filter immutable), PATCH /reorder `{ordered_ids: [all]}`,
  DELETE /{id}.

## Reuse

- Brand/model catalog: garage `GetReferenceDataUseCase` (brands),
  `GetModelsByBrandUseCase`, entities `CarBrandEntity{id,name}` /
  `CarModelEntity{id,brandId,model}` — same shapes as forum thread payloads.
- "From your garage" chip: `GetMyGarageUseCase` (CarEntity has brandId/brandName/
  modelId/modelName).
- Time-ago: `postTimeAgo` (posts feature) wrapped as "active {t} ago".
- Patterns: FollowTabSwitcher (segmented), feedback form fields, FeedPage
  scaffold + cursor paging, feed skeleton→replaced by card skeletons.

## Status

- [x] Decisions asked & answered
- [x] Progress doc
- [x] Domain layer (contract-shaped entities, failures, repo interface, 10 use case files)
- [x] Data layer (forum_models.dart snake_case, ForumsApiDataSource, ForumsRepositoryImpl with shared `_run` guard)
- [x] l10n EN/RO merged (`forums*` + `navForums` keys) + `flutter gen-l10n` ran
- [x] Blocs: home (shortcuts pin/remove/reorder + feed paging), browse, hub
      (models/topics refs, in-page topic refine, save shortcut), thread
      (lazy ReplyNode tree in `bloc/thread/state.dart`, optimistic likes,
      submit/edit/delete), composer (lazy all-brand model cache for search,
      garage car resolved by name → catalog ids)
- [x] Widgets (shared/, home/, browse/, hub/, thread/, composer/) + all 5 pages
- [x] Router (`/forums` + browse/hub/new/threads/:threadId subroutes) + FORUMS
      nav tab between MAP and + (compass button in home top bar → /forums/browse)
- [x] DI codegen (72 forum registrations in injection.config.dart)
- [x] `flutter analyze` clean (1 pre-existing info in core/usecases only)

**DONE 2026-07-03.** Not yet exercised against a running backend — first
end-to-end run should watch for: snake_case assumption on the wire, the
`/forums/topics` group shape, and cursor echo semantics.

### Conventions picked up mid-build
- One-shot bloc signals via tick counters (`actionErrorTick`, `savedTick`,
  `replySentTick`, `createdThreadId`); pages listen with BlocListener on tick change.
- Null-aware map elements (`'key': ?value`) required by analyzer for optional wire fields.
- Parallel Either loads: fire futures first, await individually (keeps types).

## File map (planned)

```
lib/features/forums/
├── domain/
│   ├── entities/ forum_topic.dart forum_author.dart forum_thread.dart
│   │             forum_reply.dart forum_pages.dart forum_filter.dart forum_shortcut.dart
│   ├── failures/forum_failures.dart
│   ├── repositories/forums_repository.dart
│   └── usecases/ get_forum_topics.dart get_forum_threads.dart get_forum_thread.dart
│                 get_forum_replies.dart create_forum_thread.dart modify_forum_thread.dart
│                 create_forum_reply.dart modify_forum_reply.dart toggle_forum_likes.dart
│                 forum_shortcuts.dart
├── data/
│   ├── models/forum_models.dart
│   ├── datasources/forums_api_data_source.dart
│   └── repositories/forums_repository_impl.dart
└── presentation/
    ├── bloc/ home/ browse/ hub/ thread/ composer/   (bloc, event, state each)
    ├── utils/ forum_error_mapper.dart forum_format.dart
    ├── pages/ forums_home_page.dart forums_browse_page.dart forum_hub_page.dart
    │          forum_thread_page.dart new_thread_page.dart
    └── widgets/ shared/ home/ browse/ hub/ thread/ composer/
```
