# tags

The profile's third tab, next to **Posts** and **Garage**: everything a user (or
one of their cars) was tagged in — classic posts, post comments, forum threads
and forum replies. Private DMs never appear here.

Full clean architecture (`presentation → domain → data`), reusing the **posts**
and **forums** features heavily — a tags row *is* one of their items.

## Backend

Base URL already includes `/api/v1`; JWT via the shared `AuthInterceptor`.

| Method | Path | Notes |
|---|---|---|
| GET | `/tags/by-username/{username}` | `cursor`, `size` (default 20) |
| GET | `/tags/me` | same params — used on your own profile |
| DELETE | `/tags/{kind}/{targetId}` | untag yourself; 204; idempotent |

`kind` ∈ `post` \| `post_comment` \| `forum_thread` \| `forum_reply`.

- **`next_cursor: null` is the only end-of-feed signal.** A page can be shorter
  than `size` and still have more behind it — dedup happens after the four
  streams merge — so a short page must never be read as "last page".
- `TaggedItemDto { kind, tagged_at, target_id, post?, comment?, thread?, reply? }`,
  unset fields omitted. `post` is set for `post` *and* `post_comment` (the
  comment's parent); `thread` for `forum_thread` *and* `forum_reply`.
- The nested payloads are the **same DTOs the feed/forums screens already
  parse**, so they are decoded with those features' models — there are no
  tag-specific content models.
- Feed semantics: excludes your own content; a person-tag and a car-tag on the
  same item collapse into one row; soft-deleted comments/replies are dropped;
  anonymized threads still appear with `author: null`; ordered by `tagged_at`
  descending, so a fresh tag on an old post jumps to the top.
- Untag is a **hard delete for everyone**, not a personal hide, and it also
  removes your own cars' tags on that content (keeping the "a tagged car's owner
  is tagged too" invariant). The author can re-tag you afterwards.

## Layers

- **domain** — `TaggedItemEntity` (+ `TaggedItemKind`, whose `apiValue` is both
  the wire `kind` and the DELETE path segment), `TaggedItemPageEntity`;
  `TagsRepository`; `GetMyTagsUseCase`, `GetTagsByUsernameUseCase`,
  `RemoveTagUseCase`; failures `TaggedContentNotFoundFailure` (404 on untag),
  `InvalidTagCursorFailure` (400).
- **data** — `TagsApiDataSource`, `TaggedItemModel`/`TaggedItemPageModel`
  (delegating to `PostModel`, `PostCommentModel`, `ForumThreadModel`,
  `ForumReplyModel`), `TagsRepositoryImpl`.
- **presentation**
  - `TagsBloc` (`bloc/tags/`): events `LoadTags(username)` — null username means
    `/tags/me` — `RefreshTags`, `LoadMoreTags`, `RemoveTagFromItem`,
    `ClearTagRemoveError`. Merges are deduped by `kind:target_id`. An untag is
    tracked in `removingIds` and the row is dropped locally on the 204.
  - `TagsSection`: the tab body. **Fetches lazily** — the bloc is provided on the
    profile routes with no event, and the first `LoadTags` fires from
    `initState` the first time the tab is opened, so visiting a profile doesn't
    pay for the merged query. Pull-to-refresh on the profile only refreshes tags
    once they've been loaded.
  - `TaggedItemCard`: shared frame (kind label, "tagged x ago", and the `⋯`
    menu on your own profile) around a per-kind body — `TaggedPostCard`,
    `TaggedCommentCard`, `TaggedThreadCard`, `TaggedReplyCard`.
  - The bodies **reuse the feed/forum card look but are display-only**: the
    like/comment/share/save row is a static `TagStaticCounters` preview and the
    media doesn't zoom or swipe, so the whole card is one tap target that opens
    the real content (`/posts/{id}` for posts *and* comments, `/forums/threads/{id}`
    for threads *and* replies — there is no route to a single comment or reply).
    Nested chips keep their own taps: a tagged car opens that car read-only, an
    author opens their profile.
  - `showTagItemMenu` + `confirmRemoveTag` (`tag_item_menu.dart`): the `⋯` →
    "Remove tag" → confirmation flow. Own profile only — you can only untag
    yourself.

## l10n

`profileTabTags`, `tagsKind*`, `tagsOnPostBy`, `tagsEmpty*`, `tagsLoadMore`,
`tagsRemove*`, `tagsError*` in `app_en.arb` / `app_ro.arb`.
