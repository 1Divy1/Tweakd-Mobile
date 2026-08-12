# Map Events — notes, gaps & red flags

> Written during the Flutter implementation of the map-events feature
> (branch `virtual-map`). Everything here is something the owner should look at:
> backend gaps, contract ambiguities, decisions I had to make, and pre-existing
> issues I ran into on the way. Nothing here blocks the app from running.
>
> Companion to `MAP_EVENTS_PROGRESS.md` (the plan/checklist). This file is the
> **review queue**.

**Legend:** 🔴 needs a backend change · 🟠 needs a product decision · 🟡 worth
knowing / low risk · ⚪ pre-existing, unrelated to this feature.

---

## 1. Backend gaps

### 🔴 1.1 Organizers have no `username`

`MapEventDto.organizers[]` and `OrganizerCandidateDto` are both
`{ type, reference_id, name, image_url }` (+ `id`, `role` on the former). There
is **no `username`**.

The designs show organizer rows as:

```
[avatar] Sasha Petrov                  >
         @torque_sasha · organizer   [INDIVIDUAL]
```

Without a username the app can't render the `@handle` line, and can't navigate
anywhere — the profile route is `/users/:username` and we only hold a user id
(`reference_id`), for which no by-id profile route or endpoint exists.

**Your call (2026-08-12): "Name only, no navigation."** So the organizer rows
ship as `name` + role + type chip, no `@handle`, no chevron, not tappable.

If you later add `username` to both DTOs, the change is small and localised:
`MapEventOrganizerEntity` / `OrganizerCandidateEntity` gain a nullable
`username`, and `MapEventOrganizerRow` re-enables the handle line + chevron.
Everything else stays.

### 🔴 1.2 No way to read *my* per-car status directly

`viewer.my_registered_car_ids` lists the caller's cars in an event **regardless
of status** (pending / accepted / rejected / withdrawn all included), and the
viewer object carries no per-car status. So to draw the designed strips —
"⏳ Request pending · Nissan Skyline", "✕ Entry declined · Mazda RX-7" — the app
has to cross-reference those ids against `GET /{id}/cars` rows.

That's what I built, but it costs extra round trips and it can only see what the
list endpoint will show the caller:

- `?status=accepted` and `?status=withdrawn` are public → fine.
- `?status=pending` and `?status=rejected` are **organizer-only**.

So a plain participant **cannot see their own pending or rejected entry** — the
one call that would reveal it is forbidden to them. The "Request pending" and
"Entry declined" strips in the design are therefore unbuildable for the person
they're aimed at.

**Workaround shipped:** after the viewer registers a car in this session, the app
remembers it locally and shows the pending strip optimistically. On a cold open
of an event where a pending request already exists, the strip cannot be shown —
the participation button falls back to a neutral state.

**The fix (pick one):**
1. Add `viewer.my_participations: [{ car_id, status, rejection_reason }]` to
   `MapEventDto` — cleanest, one call, no extra requests. *(recommended)*
2. Or let a caller see **their own** pending/rejected rows via
   `GET /{id}/cars?status=pending&mine=true`.

### 🟠 1.3 No rejection reason on a declined car entry

The design's "Entry declined · Mazda RX-7 FD" strip quotes the organizer's
reason ("Wrong category for a JDM-only meet — bring the Skyline instead.").
`MapEventParticipantDto` is `{ car, status, registered_at }` — there is no
reason field, and `PATCH /{id}/cars/{car_id}` takes only
`{ status: accepted|rejected }`, so an organizer has nowhere to type one.

Shipped without it: the declined strip shows a generic line and the
**TRY ANOTHER CAR** button. Add `note` to the PATCH body and `rejection_reason`
to the participant DTO if you want the designed copy.

### 🟠 1.4 Withdrawal requests can't be listed or counted for a participant

`GET /{event_id}/withdrawals` is organizer-only. A participant who has submitted
a withdrawal has no endpoint that says so; the only trace is their car appearing
with `status: "withdrawn"` in the public car list. That happens to work (the app
reads it from `?status=withdrawn`), but it means the participant's
"withdrawal pending" state is inferred from a public list rather than told to
them. Same fix as 1.2 (`viewer.my_participations`) would cover this cleanly.

### 🟡 1.5 `POST /{id}/cars` returns the participant, not the event

Every other write in the module returns `MapEventDto`, so the app can refresh
counts and viewer flags from one response. `POST /{id}/cars` returns a
`MapEventParticipantDto` instead, so registering a car needs a follow-up
`GET /map-events/{id}` to pick up the new `attending_cars_count` and
`my_registered_car_ids`. Same for `DELETE /{id}/cars/{car_id}` (204) and
`POST /{id}/withdraw` (participant array). Not wrong — just an extra round trip
each. Returning the event too would remove three refetches.

### 🟡 1.6 `PATCH /map-events/{id}` cannot clear a capacity

Per the contract, `null`/omitted `max_participant_capacity` means "keep
current", so a cap can never be lifted back to unlimited without recreating the
event. The edit form therefore shows capacity as **set-or-raise only**, with a
hint saying so. If you want it clearable, the API needs a sentinel (e.g. `0`) or
a `clear_capacity: true` flag.

---

## 2. Contract ambiguities I resolved by choosing

### 🟡 2.1 `/nearby` array order

The two rounds of answers conflict ("arbitrary, by id" vs "nearest-first"). As
the progress file instructs, the client treats order as **unspecified**: pins are
placed by their own lat/lng, and the collision `symbol-sort-key` is the
**client-computed** distance from the query centre, not the array index.

### 🟡 2.2 Registration deadline is required, but labelled OPTIONAL in the design

API wins (owner-confirmed). The create form enforces it for `car_meet` and the
label reads *required*; the design's "OPTIONAL" tag was dropped rather than kept
as a lie.

### 🟡 2.3 Distances are in km, not miles

The mockups say "0.4 mi" / "2.3 mi". The app is metric everywhere else, and the
owner confirmed km. Distances read "0.6 km", computed client-side.

---

## 3. Things changed outside the map-events feature

### 🟠 3.1 `distance_km` removed from the businesses layer

Per §3.6 of the progress file, `distance_km` is gone from **both**
`/businesses/nearby` and `/map-events/nearby`. I audited and stripped it:

- `BusinessPinModel` / `BusinessPinEntity` no longer parse or carry it.
- `MapLayerController.setBusinesses` now takes the fetch centre and computes the
  `symbol-sort-key` (collision priority) from it.
- The business popup's "x km away" pill is computed client-side the same way.

⚠️ **Test the business popup and pin decluttering** — this touched shipped code.

### ⚪ 3.2 Pre-existing debug logging left in the map/garage data sources

`BusinessApiDataSource.getById` has a `// TODO: debug only` `debugPrint` of the
logo URL, and `GarageApiDataSource.getCar` prints raw car JSON. Unrelated to
this feature and left alone, but worth removing before a release build — they
log user data to the device console.

---

## 4. Product gaps the design implies but nothing implements

### 🟠 4.1 Contests are a stub

The Overview tab's "Contests · SOON" card is UI-only, exactly as the design
shows. No endpoint, no state. The withdraw dialog's copy still mentions being
removed "from any contests running inside this meet" — kept, since it's
forward-looking, but it currently refers to something that doesn't exist.

### 🟠 4.2 The map search bar does nothing

"Search meets, shops, cities…" is pure UI per your call. It's rendered
non-interactive (no cursor, no keyboard) rather than as a text field that
silently eats input — a dead-but-focusable field reads as a bug.

### 🟠 4.3 Admin approval has no user-facing feedback loop

A user creating an event sees "pending admin approval" and then… nothing. There
is no notification when it flips to accepted or rejected — the map-events module
doesn't emit notifications, and the app's notification feed has no event types
for it. The only way to find out is to open My events and look. Worth wiring
into the notifications feature.

### 🟠 4.4 The share button copies instead of sharing

The design's hero has a share icon. Two things are missing for a real share:

1. **No share plugin.** `share_plus` isn't a dependency, and adding one is a
   platform-config change (iOS activity types, Android intent filters), not a
   UI change — out of scope for this pass.
2. **More importantly, there's nothing to share.** Events live behind the app's
   auth with no universal-link host configured, so a `/map-events/{id}` URL
   would be dead for whoever received it.

Shipped: the button copies `title / location / maps.google.com?q=lat,lng` to the
clipboard and confirms with a snackbar. Coordinates a maps app can open are the
useful thing to hand someone today. When deep links exist, swapping this for a
real share sheet is a few lines in `map_event_hero.dart`.

### 🟡 4.5 409 messages are shown in English to Romanian users

The backend separates "this event has finished", "the registration deadline has
passed" and "this event has reached its participant capacity" **only in prose** —
there's no error code to branch on. Per the progress file the app shows the
server's sentence verbatim, which means an RO user sees English for exactly
those three cases. Everything else in the feature is localized.

Fix whenever convenient: add a stable `error` code to those 409 bodies (e.g.
`event_finished`, `deadline_passed`, `capacity_reached`) and the client will
map them to localized copy — `MapEventParticipationConflictFailure` already
carries `errorCode` through for this.

---

## 5. Things to test on device

Ordered by how likely they are to be wrong.

1. **Business pins and popup** — the `distance_km` removal touched shipped code.
   Check the "x km away" pill still reads sensibly and that pin decluttering in
   a dense area still favours the nearest business.
2. **Event pin images** — covers are rasterised into circular markers with a
   ring that turns orange while an event is live. Watch for pins stuck on the
   car-glyph placeholder (cover URL unreachable) or a live event keeping a white
   ring (would mean the image-id variant isn't taking).
3. **Tap arbitration** — an event pin overlapping a business pin should open the
   event. Tapping empty map should dismiss whichever card is open.
4. **RSVP optimism** — the Attending/Interested pair flips instantly and the
   attendee counter moves with it; a failure rolls both back and shows a
   snackbar.
5. **Register a car on an approval-required event** — you should see the
   "Request pending" strip immediately after registering (it's tracked locally),
   but it will **disappear if you kill and reopen the app** until gap §1.2 is
   fixed. That's the known limitation, not a bug in the client.
6. **Create flow** — the CTA names what's missing ("ADD TITLE, LOCATION & START
   TIME" → "ADD A REGISTRATION DEADLINE" → "CREATE EVENT"), the location picker
   returns coordinates, and the cover survives the WebP → R2 → PATCH round trip.
7. **Organizer console** — accept/decline an entry, then approve/reject a
   withdrawal; both lists should empty as you go and the counts should update.
