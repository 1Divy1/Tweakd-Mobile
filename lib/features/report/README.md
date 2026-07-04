# report

Cross-cutting reporting for **posts, comments, profiles, forum threads and
forum replies**. One clean-arch feature (`presentation → domain → data`) drives
the same reason-picker sheet from every entry point; the owning features (feed,
posts, profile, forums) only host the "⋯" menus and decide what to do after a
successful report.

## Flow

1. Entry point opens an options menu (or, for a comment, the Report button
   directly) → the report reason sheet (`showReportSheet`).
2. The sheet loads the preset reasons for the target, lets the user pick exactly
   one, and enables the (otherwise greyed-out) submit button.
3. On submit it shows a spinner, then either a success confirmation (check +
   message + Close) or an inline error message with submit re-enabled.
4. `showReportSheet` resolves to `true` iff a report went through (captured the
   moment it succeeds, so it survives a swipe-down dismiss). The caller then
   hides the reported post/comment or redirects away from the profile.

## Backend

Base URL already includes `/api/v1`; JWT via the shared `AuthInterceptor`.
Request bodies are snake_case (`{ "reason_id": "…" }`); the report POSTs return
`204 No Content`.

| Target        | Reasons (GET)                     | Report (POST)                                  |
|---------------|-----------------------------------|------------------------------------------------|
| post          | `/posts/report-reasons`           | `/posts/{postId}/report`                       |
| comment       | `/posts/comments/report-reasons`  | `/posts/{postId}/comments/{commentId}/report`  |
| profile       | `/profile/report-reasons`         | `/profile/{username}/report`                   |
| forum thread  | `/forums/threads/report-reasons`  | `/forums/threads/{threadId}/report`            |
| forum reply   | `/forums/posts/report-reasons`    | `/forums/posts/{postId}/report`                |

`GET report-reasons` returns `[{ id, reason }]`; `id` is echoed back as
`reason_id`.

**My reports** — `GET /reports/mine` (reporter from the JWT) returns a single
newest-first list across all three types, each item snake_case:
`{ target_type, target_id, reason, status, created_at }`. `target_type` ∈
`post|comment|profile|forum_thread|forum_thread_reply`; `status` ∈
`pending|in_progress|resolved|dismissed`;
`reason` is null when no preset reason was picked. Empty ⇒ `[]`.

Error mapping (`ReportRepositoryImpl` → `ReportErrorMapper`):
- `409` → `AlreadyReportedFailure` ("already reported").
- `400` → `SelfReportFailure` for post/profile, `InvalidReportReasonFailure` for
  a comment (a 400 means different things per target).
- `404` → `ReportTargetNotFoundFailure`.

## Layers

- **domain** — `ReportReasonEntity`; `ReportTarget` (sealed:
  `PostReportTarget` / `CommentReportTarget` / `ProfileReportTarget`);
  `MyReportEntity` (+ `ReportTargetType` / `MyReportStatus` enums);
  `ReportRepository.getReasons` / `submitReport` / `getMyReports`;
  `GetReportReasonsUseCase`, `SubmitReportUseCase`, `GetMyReportsUseCase`;
  failures in `domain/failures/`.
- **data** — `ReportReasonModel`, `MyReportModel`, `ReportApiDataSource`
  (7 endpoints), `ReportRepositoryImpl` (switches on `ReportTarget`).
- **presentation**
  - `ReportBloc` (`bloc/report/`): events `LoadReportReasons`,
    `SelectReportReason`, `SubmitReportPressed`; state carries the reasons,
    the single `selectedReasonId`, a `ReportStatus`, and an optional
    `ReportErrorCode`. `report_reason_sheet.dart` exposes `showReportSheet`.
    `report_error_mapper.dart` maps failures → localized copy.
  - `MyReportsBloc` (`bloc/my_reports/`): one-shot `LoadMyReports` →
    loading / loaded (list, or empty) / error. `MyReportsPage` (route
    `/reports`, reached from Settings → "My reports") renders it via the
    `widgets/my_reports/` views (`MyReportTile` + `MyReportStatusChip`).

## Entry points (owned by other features)

- **Post** — `showPostOptionsSheet` (posts feature) from two places:
  - `FeedPostCard`'s `⋯` → report → `FeedBloc.HideFeedPost` removes the card so
    the next post takes its place.
  - `PostDetailPage`'s top-bar `⋯` (shown to non-owners; owners get edit/delete)
    → report → the page pops, leaving the reported post.
- **Comment** — `commentsSheet`'s per-comment **Report** button (shown to
  everyone but the comment's author) → report → `CommentsBloc.HideComment`
  drops it from the viewer's list.
- **Profile** — `PublicProfileDataView`'s top-bar `⋯` →
  `showProfileOptionsSheet` (profile feature) → report → `context.go('/feed')`,
  which clears the back stack so the viewer can't return to the reported
  profile.

Reports never delete anything — the reported item is only hidden client-side.
