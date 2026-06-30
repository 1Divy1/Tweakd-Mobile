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
- Response is the **same `PostDto` shape as the posts endpoints** (snake_case),
  so it is parsed with the posts feature's `PostPageModel`/`PostModel` — there are
  no feed-specific models.

## Layers

- **domain** — `FeedRepository.getGlobalFeed` → `PostPageEntity` (from posts);
  `GetGlobalFeedUseCase`.
- **data** — `FeedApiDataSource` (`/feed/global`), `FeedRepositoryImpl`.
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
- Card `⋯` opens `/posts/{id}` (no dedicated feed-post menu yet). The card body
  itself no longer navigates on tap.
- A like/save toggled on the detail screen isn't mirrored back into the feed
  list without a refresh (comment counts *are* mirrored, via the shared sheet).
