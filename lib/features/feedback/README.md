# feedback

In-app feedback: the user files a **bug / feature request / general** note from
**Settings → Send feedback**, and can review everything they've sent from
**Settings → My feedback**. One clean-arch feature (`presentation → domain →
data`).

## Flow

1. Settings → "Send feedback" pushes `/feedback`. On open the screen loads the
   two pickers (`GET /feedback/types`, `GET /feedback/features`) in parallel.
2. The user picks a **type** (required), optionally a **related feature**, and
   writes the **body** (required, ≤ 600 chars). Picking the **bug** type reveals
   an extra **reproduction steps** field (`state.isBug`, keyed off the type id
   `bug` — see `kBugFeedbackTypeId`).
3. Submit POSTs to `/feedback` (204). On success the screen pops and a
   confirmation SnackBar shows; on failure an inline message appears and submit
   re-enables.
4. Settings → "My feedback" pushes `/feedback/mine`, a one-shot list of the
   caller's feedback (`GET /feedback/mine`, newest first).

## Backend

Base URL already includes `/api/v1`; JWT via the shared `AuthInterceptor`. All
endpoints are auth-scoped to the JWT subject. Wire JSON is snake_case.

| Method + path             | Purpose                          |
|---------------------------|----------------------------------|
| `POST /feedback`          | submit → 204 No Content          |
| `GET /feedback/types`     | `[{ id, type }]` — type picker   |
| `GET /feedback/features`  | `[{ id, name }]` — feature picker|
| `GET /feedback/mine`      | `[{ id, content, type, feature, reproduction_steps, response, status, created_at }]` |

**Submit body** — `{ content, type, feature?, reproduction_steps? }`. `content`
and `type` are required (`@NotBlank`); `feature` / `reproduction_steps` are only
put on the wire when present. `type` and `feature` carry the **ids** from the
pickers (not the display labels); reproduction steps are only sent for bug
reports.

`GET /feedback/mine`'s `type` and `feature` are already-resolved display labels
(not ids); `feature` / `reproduction_steps` may be null. `response` and `status`
are **server-managed** (assigned by moderators/admins — the client never sends
them); both are always in the payload. `response` is null until a moderator
replies; `status` is `{ id, name, color }` where `color` is an optional hex
string (null ⇒ use the app default) for the status badge.

## Layers

- **domain** — `FeedbackTypeEntity { id, label }`, `FeedbackFeatureEntity
  { id, name }`, `MyFeedbackEntity`; `FeedbackSubmission` (submit draft);
  `FeedbackRepository.getTypes / getFeatures / submitFeedback / getMyFeedback`;
  use cases `GetFeedbackTypesUseCase`, `GetFeedbackFeaturesUseCase`,
  `SubmitFeedbackUseCase`, `GetMyFeedbackUseCase`.
- **data** — the three models (+ `toEntity`), `FeedbackApiDataSource` (4
  endpoints), `FeedbackRepositoryImpl` (exceptions → base `Failure`s).
- **presentation**
  - `FeedbackBloc` (`bloc/feedback/`): loads both pickers (types required —
    failure ⇒ `optionsError`; features optional — failure ⇒ empty list), tracks
    the selected type/feature, submits. Free-text fields live in the form's
    `TextEditingController`s and arrive on `SubmitFeedbackPressed`.
  - `MyFeedbackBloc` (`bloc/my_feedback/`): one-shot `LoadMyFeedback`.
  - `FeedbackPage` (route `/feedback`) + `FeedbackForm` and the picker sheets
    (`feedback_type_picker` / `feedback_feature_picker`, sharing
    `FeedbackPickerSheet`). `feedback_type_visuals.dart` maps a type id → icon +
    description (bug / feature_request / general, with a graceful fallback).
  - `MyFeedbackPage` (route `/feedback/mine`) renders via `widgets/my_feedback/`.
  - `feedback_error_mapper.dart` maps failures → `network` / `generic` copy.
