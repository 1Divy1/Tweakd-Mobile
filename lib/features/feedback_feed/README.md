# feedback_feed

The **public feedback board** — a bottom-nav tab where anyone posts a bug /
feature request / feature improvement, everyone up- or down-votes it, and staff
move it along a roadmap (`sent → under_development → completed`).

Not to be confused with the older **`feedback`** feature, which is the *private*
Settings flow ("Send feedback" / "My feedback", routes `/feedback` and
`/feedback/mine`). That one is a one-way note to the team; this one is a public
board with votes. They share nothing but the word "feedback" and one reused
widget (`FeedbackTopBar`, the ✕ + wordmark header on the composer).

## Screens

| Route | Screen | Bloc |
|-------|--------|------|
| `/feedback-feed` | `FeedbackFeedPage` — the board (nav tab) | `FeedbackBoardBloc` |
| `/feedback-feed/completed` | `CompletedFeedbackPage` — shipped requests | `CompletedFeedbackBloc` |
| `/feedback-feed/new` | `ComposeFeedbackPage` — "Share feedback" | `ComposeFeedbackBloc` |

The board pins its header, the NEWEST / POPULAR / OLDEST tabs and the
completed-requests banner above the list; only the list swaps between
loading / error / empty / loaded. The composer pops with `true` on success, and
the board refreshes on that result so the new card appears.

## Rules the UI enforces

- **Delete** — hard, author-only, and only while the status is still `sent`
  (`FeedbackMessageEntity.canDelete`). Confirmed with a dialog. If the backend
  answers **409** (staff picked it up in the meantime) the card is put back, a
  "we've already picked this up" message shows, and the list refreshes so the
  stale status corrects itself.
- **Voting** — tapping the arrow already selected withdraws the vote
  (`DELETE /{id}/vote`); the opposite arrow switches sides. Applied optimistically
  via `withVote`, then replaced with the DTO the vote endpoint returns, so the
  server's tallies always win. **Authors may vote on their own message**
  (owner's call) — nothing is disabled for them.
- **Completed cards are read-only** (owner's call, matching the design): net
  score as plain text, no vote buttons, no delete.
- **Status labels come from the backend, verbatim** — the badge shows
  "Under development", not the mock's "IN PROGRESS". Only the badge *colour* and
  icon are client-side, keyed off well-known ids with a neutral fallback, so an
  unfamiliar status still renders sensibly.
- **`sent` gets no status badge** — it's the resting state.

## Backend — `/api/v1/feedback-feed`

Base URL already includes `/api/v1`; JWT via the shared `AuthInterceptor`. Wire
JSON is snake_case.

| Method + path | Purpose |
|---------------|---------|
| `GET /types` | `[{id,label}]` — compose categories |
| `GET /statuses` | `[{id,label}]` — roadmap stages, in order |
| `GET /` | board, **excludes completed**; `?sort=newest\|popular\|oldest&cursor=&size=` |
| `GET /completed` | completed only, `completed_at` desc; `?cursor=&size=` |
| `GET /{id}` | one card |
| `POST /` | `{type, message}` (≤ 500 chars) → 201 (response body ignored) |
| `DELETE /{id}` | hard delete own message → 204; **409** once past `sent` |
| `POST /{id}/vote` | `{value: 1 \| -1}` → updated DTO |
| `DELETE /{id}/vote` | withdraw, idempotent → updated DTO |

`GET /statuses` and `GET /{id}` are **wired through every layer but unused by
any screen** — users can't change a status and the design has no status filter
or detail page. Both were kept deliberately (owner: "keep it, just in case").

## Layers

- **domain** — `FeedbackMessageEntity` (+ `FeedbackAuthorEntity`,
  `FeedbackOptionEntity` for the `{id,label}` pairs, `FeedbackMessagePageEntity`
  for a cursor page), `FeedbackSort`; `FeedbackFeedRepository`; use cases grouped
  by concern (`get_feedback_board`, `get_feedback_options`,
  `manage_feedback_message`, `vote_feedback_message`); failures
  `FeedbackMessageLockedFailure` (409) and `FeedbackMessageNotFoundFailure` (404).
- **data** — `feedback_feed_models.dart` (all four models + `toEntity`),
  `FeedbackFeedApiDataSource`, `FeedbackFeedRepositoryImpl` (one `_guard` helper
  maps exceptions → failures for every method).
  - `my_vote` is parsed leniently (number *or* numeric string), and anything
    that isn't ±1 becomes "no vote".
  - Pages drop `deleted: true` items on the way to entities — defensive only,
    since deletes are hard.
- **presentation** — three blocs (`bloc/board`, `bloc/completed`,
  `bloc/compose`); widgets split `board/`, `completed/`, `compose/`, `shared/`;
  `utils/` holds the error mapper, the badge colours
  (`feedback_feed_visuals.dart`) and the time/count formatting
  (`feedback_feed_format.dart`).
  - Vote and delete failures surface as one-shot snackbars keyed on
    `actionErrorTick`, so the same error twice in a row still shows.
  - Sorting refetches from scratch — the cursor is scoped to one ordering.
  - Pages repeat across `popular` while paging (scores shift under you), so
    appended pages are de-duplicated by id.
