# FEEDBACK FEED — progress checkpoint

Public feedback board: users post bug / feature-request / feature-improvement
messages, everyone up/down votes them, staff move them through a roadmap
(`sent → under_development → completed`). New bottom-nav tab.

Delete this file when the feature ships.

## Owner decisions (asked 2026-08-17 — do not re-litigate)

1. **Bottom nav** — feedback becomes a **6th tab**; nothing is replaced. Icons
   shrink slightly to fit.
2. **Completed page** — **read-only**, exactly as designed: net-vote total as
   plain text, no vote buttons, no delete.
3. **Status label** — render the **backend `status.label` verbatim**
   ("Under development"), *not* the design's "IN PROGRESS". The mock was
   informative, not literal.
4. **Self-voting** — **allowed**. The author's own card keeps working vote
   buttons; the backend is the final authority.

## Backend contract — `/api/v1/feedback-feed` (base already has `/api/v1`)

Wire JSON is snake_case. JWT via the shared `AuthInterceptor`.

| Method + path        | Purpose |
|----------------------|---------|
| `GET /types`         | `[{id,label}]` — compose categories |
| `GET /statuses`      | `[{id,label}]` — roadmap stages, ordered (wired but unused, see below) |
| `GET /`              | main feed, **excludes completed**; `?sort=newest\|popular\|oldest&cursor=&size=` |
| `GET /completed`     | completed only, `completed_at` desc; `?cursor=&size=` |
| `GET /{id}`          | one card |
| `POST /`             | `{type, message}` (≤500 chars) → 201 + DTO |
| `DELETE /{id}`       | hard delete own message, **only while status = `sent`** → 204; **409** once it moved on |
| `POST /{id}/vote`    | `{value: 1 \| -1}` — same value again withdraws, opposite switches → DTO |
| `DELETE /{id}/vote`  | withdraw, idempotent → DTO |

`FeedbackMessageDto`: `id, author{id,name,username,avatar_url}, message,
type{id,label}, status{id,label}, staff_response, up_votes, down_votes,
net_votes, my_vote (1|-1|null), viewer_is_author, deleted, created_at,
completed_at`.

**Vote calls return the full updated DTO** → the bloc updates optimistically,
then reconciles the card with the server's numbers.

**`GET /statuses` is wired through every layer but has no UI consumer** — users
can't change a status and the design has no status filter. Kept per the owner's
explicit "keep it, just in case".

## Non-obvious client decisions

- **`deleted: true` items are filtered out** of both lists when mapping a page.
  Deletes are hard, so this only ever fires defensively.
- **`my_vote` is parsed leniently** (`num` *or* `String`) — the contract writes
  it as `"1 | -1 | null"`, which reads ambiguously.
- **Withdrawing a vote uses `DELETE /{id}/vote`**, not a repeat `POST` — both
  work per the contract, the explicit idempotent one is easier to reason about.
- Type/status **labels come from the backend**; only the *colour* of the badge is
  client-side, keyed off the well-known ids (`bug`, `feature_request`,
  `feature_improvement`, `under_development`, `completed`) with a neutral
  fallback so unknown ids still render.
- Sort changes **refetch from scratch** (cursor is sort-scoped).
- 409 on delete maps to a dedicated `FeedbackMessageLockedFailure` → its own
  "this has already moved on" copy, and the list refreshes so the stale card
  updates.

## File map — `lib/features/feedback_feed/`

Routes: `/feedback-feed` (tab), `/feedback-feed/completed`, `/feedback-feed/new`.
Existing `/feedback` + `/feedback/mine` (the private Settings feature) are
untouched — different feature, different route prefix.

## Status

- [x] Owner decisions captured
- [x] domain layer
- [x] data layer
- [x] DI codegen (3 blocs + repo + 8 use cases registered)
- [x] blocs (board / completed / compose)
- [x] pages + widgets (board / completed / compose)
- [x] l10n (EN + RO — 35 keys each, mirrored)
- [x] bottom nav (6th tab, campaign icon) + 3 routes
- [x] `flutter analyze` clean (only 2 pre-existing infos remain)
- [x] tests: 14 new model/vote-math tests; full suite 39/39 green
- [x] README (`lib/features/feedback_feed/README.md`)

## Open questions for the backend (verify before shipping)

1. **Trailing slash on the collection endpoints.** The contract writes the main
   feed and the create call as path `"/"` under base `/api/v1/feedback-feed`.
   The client calls `/feedback-feed` (no trailing slash), which is the
   conventional mapping. If the controller literally declares `@GetMapping("/")`
   and trailing-slash matching is off (the Spring Boot 3 default), those two
   calls 404 — the fix is one character on either side.
2. **`POST /` response body — handled, no action needed.** The contract
   documents a `FeedbackMessageDto` on create. Nothing consumes it (the board
   refetches), so the client now ignores the body entirely rather than risking a
   spurious "failed to post" if the 201 comes back empty.
3. **`staff_response` on non-completed cards.** The DTO carries it at every
   status, but only completed cards render it. If the team starts replying to
   messages still in progress, those replies are invisible on the board today.
