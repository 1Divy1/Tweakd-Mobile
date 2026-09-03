# badges

Achievements shown as a circular strip on a profile, under the follow/edit
actions. Tapping a badge circle opens that badge on its own screen
(`BadgeDetailPage`, route `/badge`, presented as a modal) — the artwork blown
up, its title and its "how you get it" copy. The trailing `ALL` slot opens a
sheet listing every badge — unlocked first, then, on your own profile, the
locked ones; each row in that sheet opens the same detail screen.

## Where the data comes from

**Earned badges are not fetched here.** They come embedded in the profile
payload (`badges` on both `GET /profile/me` and
`GET /profile/by-username/{username}`), so the strip paints in the same round
trip as the header — `ProfileEntity.badges`, typed as `List<UserBadgeEntity>`.
`BadgeStrip` is handed that list; it has no bloc, no loading state and no error
state.

This feature owns exactly one call: **`GET /badges/me/locked`**, the badges the
signed-in user hasn't earned. It fires the first time the sheet is opened, not
on profile load, and only on your own profile — there is deliberately no public
locked list, so a visitor's sheet is the earned half alone.

Two other endpoints exist and are **not used**: `GET /badges/me` and
`GET /profile/by-username/{u}/badges` refetch a badge row after an unlock
animation, and `GET /badges/catalogue` returns everything earnable. Refreshing
the profile already re-reads the badges, and `/me` + `/me/locked` partition the
catalogue between them.

## The payload

```json
{
  "id": "pioneer",
  "title": "Pioneer",
  "description": "One of the first members of the community.",
  "unlocked_url": "https://<assets>/badges/pioneer/badge-unlocked.svg",
  "locked_url":   "https://<assets>/badges/pioneer/badge-locked.svg",
  "available": true,
  "created_at": "2026-09-03T16:22:34Z"
}
```

- `id` is the stable code, not a uuid.
- `description` and `locked_url` are **nullable**. No description → the sheet
  row is the title alone. No locked art → `BadgeArt` desaturates and dims the
  unlocked art itself.
- `available: false` is a retired badge. It never comes back from the
  catalogue, but a holder still sees it, so the app renders it normally.
- The artwork is **remote SVG**, drawn by `presentation/widgets/badge_art.dart`
  (`flutter_svg`). A missing or unparseable file falls back to a generic medal,
  so a broken asset can never blank a profile.

`GET /badges/me/locked` returns the bare badge object (nothing was earned, so
there is no `earned_at`); the profile's `badges` and the badge-row endpoints
return `{ badge, earned_at }` — `UserBadgeModel`.

Display order is the backend's: newest unlock first.
