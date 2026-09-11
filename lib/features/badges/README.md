# badges

Achievements shown as a circular strip on a profile, under the follow/edit
actions. **Only earned badges are ever shown** — there is no locked catalogue
anywhere in the app, so a profile with nothing earned draws no strip at all.
Tapping a badge circle opens that badge on its own screen (`BadgeDetailPage`,
route `/badge`, presented as a modal) — the artwork blown up, its title and its
"how you get it" copy.

The strip is laid out for five slots. Up to five badges are drawn outright and
there is **no `ALL` button** — the whole collection is already on screen. Only a
sixth badge makes the strip give up its last slot to an `ALL` circle (`+N`),
which opens a sheet listing every earned badge, newest unlock first; each row
there opens the same detail screen. Badges repeat: a top-3 finish is earned once
per contest, so a regular is expected to overflow while most profiles never do.

## Where the data comes from

**Earned badges are not fetched here.** They come embedded in the profile
payload (`badges` on both `GET /profile/me` and
`GET /profile/by-username/{username}`), so the strip paints in the same round
trip as the header — `ProfileEntity.badges`, typed as `List<UserBadgeEntity>`.
`BadgeStrip` is handed that list; it has no bloc, no loading state and no error
state.

`BadgeStrip` and the sheet are handed that list — no bloc, no loading state, no
error state, and no request of their own.

This feature owns one call:

- **`POST /badges/me/pending-celebration/{badgeId}`** — acknowledges that the
  one-time unlock animation for a badge has played. Fired once per badge as the
  celebration is dismissed. Returns `{ "celebrated": bool }`; the flag isn't
  surfaced (a repeat ack is a no-op, never an error).

Several endpoints exist and are **not used**: `GET /badges/me` and
`GET /profile/by-username/{u}/badges` refetch a badge row after an unlock
animation, `GET /badges/catalogue` returns everything earnable, and
`GET /badges/me/locked` returns what the caller hasn't earned. Refreshing the
profile already re-reads the badges, and locked badges are not a thing the UI
shows. `GET /badges/me/pending-celebration` is wired
(`GetPendingBadgeCelebrationsUseCase`) but not called on launch — the list
rides on the feed instead (below).

## Unlock celebration (the Duolingo-style animation)

On launch the first page of `GET /feed/global` carries
`pending_badge_celebrations` — a `UserBadgeDto[]` of badges the viewer has
unlocked but not yet seen animate, oldest first (see the **feed** feature).
`FeedPage` hands that list to **`BadgeCelebrationCubit`**, an app-level
singleton provided at the root (`main.dart`) and reset on sign-out. It holds a
queue and a "already shown this run" set so a feed refresh before the ack lands
can't replay anything.

**`BadgeCelebrationOverlay`** is mounted in `MaterialApp.router`'s `builder`,
so it can take over from whatever page is on screen. Per queued badge it fills
the screen with its own **opaque white surface** — `BadgeArt` popping in on an
elastic curve, a hand-rolled confetti burst (`CustomPainter`, no package, dark
status-bar icons via `AnnotatedRegion`), the badge title + description, a haptic
on reveal — and a **Continue** button that acknowledges the badge
(`MarkBadgeCelebratedUseCase` → the POST above, fire-and-forget) and advances
the queue. It appears as a hard cut and fades back out over the dismiss. Modal:
a system back gesture is swallowed (`PopScope`), so it only leaves through
Continue. A failed ack just means the badge reappears on the next launch's feed
payload.

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
- `description` is **nullable** — no description → the sheet row is the title
  alone. `locked_url` is parsed off the payload but never drawn.
- `available: false` is a retired badge. It never comes back from the
  catalogue, but a holder still sees it, so the app renders it normally.
- The artwork is **remote SVG**, drawn by `presentation/widgets/badge_art.dart`
  (`flutter_svg`). A missing or unparseable file falls back to a generic medal,
  so a broken asset can never blank a profile.

The profile's `badges` and the badge-row endpoints return
`{ badge, earned_at }` — `UserBadgeModel`.

Display order is the backend's: newest unlock first.
