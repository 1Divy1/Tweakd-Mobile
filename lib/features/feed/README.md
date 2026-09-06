# feed

The app's home tab: a global, virality-ranked feed of posts ("Tweakd.").

Full clean architecture (`presentation → domain → data`), reusing the **posts**
feature heavily — a feed item *is* a post.

## Backend

`GET /feed/global?size=&cursor=` (base URL already includes `/api/v1`; JWT via the
shared `AuthInterceptor`).

- Ranked most-viral-first; **opaque cursor** — echo `next_cursor` back as `cursor`.
- `size` default 20, hard-capped at 50.
- `next_cursor: null` ⇒ last page. Empty feed ⇒ `{ items: [], next_cursor: null }`.
- Eventually consistent: an occasional duplicate/gap across pages is expected
  (the bloc dedups appended pages by id).
- Body is the posts endpoints' `PostPageDto` (`items`/`next_cursor`, snake_case)
  **plus one key**: `pending_badge_celebrations` — a `UserBadgeDto[]` of unlock
  animations the viewer is still owed, populated on the first page only
  (`cursor` omitted) and `[]` on every paged request. Parsed by the thin
  feed-owned `FeedPageModel` (post fields delegated to `PostPageModel`); the
  badge list feeds the app-level `BadgeCelebrationCubit` (see the **badges**
  feature), which the overlay above the router animates. Acknowledged one at a
  time via `POST /badges/me/pending-celebration/{badgeId}` once each animation
  finishes.

## Layers

- **domain** — `FeedRepository.getGlobalFeed` → `FeedPageEntity` (post items
  reuse the posts feature's `PostEntity`, plus `pendingBadgeCelebrations`);
  `GetGlobalFeedUseCase`.
- **data** — `FeedApiDataSource` (`/feed/global`), `FeedRepositoryImpl`,
  `FeedPageModel` (delegates post parsing to `PostPageModel`).
- **presentation**
  - `FeedBloc` (`bloc/feed/`): events `LoadFeed`, `RefreshFeed`, `LoadMoreFeed`,
    `ToggleLikeFeedPost`, `ToggleSaveFeedPost`, `UpdateFeedPostCommentCount`,
    `SubmitFeedComment`. Injects `GetGlobalFeedUseCase` plus the posts feature's
    `LikePostUseCase`/`UnlikePostUseCase`/`SavePostUseCase`/`UnsavePostUseCase`
    for optimistic inline like/save toggles, and `AddCommentUseCase` for the
    card's inline comment composer (optimistic counter bump, reverted on error).
  - `FeedPage`: standard scaffold (`FeedTopBar` → paged list → `AppBottomNav`).
    Pull-to-refresh + scroll paging.
  - `FeedPostCard`: the design card — `PostAuthorHeader` (ring + `⋯`) → rounded,
    pinch-zoomable `PostMediaCarousel` (cover, with the next-image "peek") →
    action row (like/comment/share + save icons) → "x likes" line (opens the
    likers sheet) → caption → `PostTags` (tagged cars + people) → inline comment
    composer. Tapping empty space does nothing; the comment icon opens the
    comments sheet (`showCommentsSheet`, count synced back via
    `UpdateFeedPostCommentCount`); the composer reveals a send button once text
    is entered and posts via `SubmitFeedComment`. The shared `post_card/`
    widgets (`PostAuthorHeader`, `PostMediaCarousel`, `PostTags`) live in
    `features/posts/presentation/widgets/post_card/` and are also used by
    `PostDetailView`.

## Route

`/feed` (in `app_router.dart`) provides `FeedBloc..add(LoadFeed())`. Reached via the
`AppBottomNav` feed tab.

## UI-only / not yet implemented

- `FeedTopBar` likes + DMs buttons → "coming soon" snackbar (no screens yet).
- Card `⋯` opens the post options sheet (report — see the **report** feature); a
  successful report fires `HideFeedPost`. The card body itself doesn't navigate
  on tap, and there's no "open post detail" affordance from the feed anymore.
- A like/save toggled on the detail screen isn't mirrored back into the feed
  list without a refresh (comment counts *are* mirrored, via the shared sheet).
