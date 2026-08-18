# Map Events — notes, gaps & red flags

> Written during the Flutter implementation of the map-events feature
> (branch `virtual-map`). Everything here is something the owner should look at:
> backend gaps, contract ambiguities, decisions I had to make, and pre-existing
> issues I ran into on the way. Nothing here blocks the app from running.
>
> Companion to `MAP_EVENTS_PROGRESS.md` (the plan/checklist). This file is the
> **review queue**.

**Legend:** ✅ resolved · 🔴 needs a backend change · 🟠 needs a product
decision · 🟡 worth knowing / low risk · ⚪ pre-existing, unrelated to this
feature.

**2026-08-13:** §§1.1–1.5 were fixed on the backend and consumed in the app.
They're kept here (struck through as ✅) as the record of what changed, not as
outstanding work. §1.6 and everything from §2 down is still open.

**2026-08-14:** §1.7 opened and closed the same day — the owner shipped
`/map-events/geocode` (Mapbox v6, structured input) and the picker was
rebuilt against it. Read §1.7 before touching the location picker: the
"user must tap the pin" rule is a licensing constraint, not a UX preference.

---

## 1. Backend gaps

### ✅ 1.1 Organizers have no `username` — **fixed 2026-08-13**

Both organizer shapes now carry a real `name` **and** a `username`
(`MapEventOrganizerDto` on `GET /{eventId}`, `OrganizerCandidateDto` on
`GET /organizers/search`). `name` stopped being a mislabeled username.
`username` is null for `type: "business"`.

Shipped in the app:

- `MapEventOrganizerEntity` / `OrganizerCandidateEntity` gained a nullable
  `username`, plus `hasProfile` on the former.
- `MapEventOrganizerRow` renders the designed `@handle · role` line, and an
  individual organizer's row is now tappable into `/users/:username` with the
  chevron the design shows. `referenceId` rides along as the route's `extra`,
  so tapping your own row lands on `/profile`.
- The add-organizer search sheet shows the handle under the name — two people
  can share a display name.

**Businesses are still inert**, by your call: no username, and no
business-profile route in the app yet. When one exists, the row needs one
`onTap` branch keyed on `organizer.isBusiness` and nothing else.

Elsewhere in the app, the same shared `ProfileSearchResultDto` now carries
`name` on user search, DM peers, tagging pickers and map-event attendees. Only
the attendee list was picked up in this pass (`MapEventAttendeeEntity.name`,
shown above the handle). **The other three still show usernames only** — the
data is there whenever you want them switched over, and `RelationshipService`'s
`FollowProfileSearchResult` would need the same treatment for follower lists.

### ✅ 1.2 No way to read *my* per-car status directly — **fixed 2026-08-13**

`GET /{eventId}/cars/mine` (auth, no params, unpaginated) returns every one of
the caller's own entries whatever their status. That replaced the whole
cross-referencing dance:

- The bloc no longer walks `viewer.my_registered_car_ids` against the public
  car list, and no longer fires up to three extra status-filtered requests.
- `unresolvedRegisteredCarIds` / `hasUnresolvedRegistration` are **gone**, along
  with the "Registration in progress" strip that existed only to avoid guessing.
  Both l10n keys were deleted.
- A pending request now survives a cold open, on any device. The workaround
  that remembered a session-local registration is deleted with it.

`viewer.my_registered_car_ids` is still parsed and still on the entity, but
nothing in the UI reads it any more — `/cars/mine` is strictly better data.

### ✅ 1.3 No rejection reason on a declined car entry — **fixed 2026-08-13**

`ParticipantDto` gained `rejection_reason` (null unless `status: "rejected"`),
and `PATCH /{eventId}/cars/{carId}` now **requires** `reason` when rejecting —
400 on a missing or blank one.

- The declined strip quotes the organizer under a "WHY" heading, exactly as the
  design does.
- Declining an entry in the organizer console opens
  `showDeclineEntryDialog` first; its confirm button stays disabled until
  something is typed, so the 400 can't be reached from the UI.
- `ReviewEntry` and `ReviewCarRegistrationParams` carry the reason through.

### ✅ 1.4 Withdrawal requests can't be listed or counted for a participant — **fixed 2026-08-13**

Same fix as §1.2: a withdrawn row comes back from `/cars/mine` as the caller's
own, rather than being inferred from a public list.

The withdraw dialog also states the all-or-nothing rule now, which it never
did: `POST /withdraw` takes out **every** car the caller has in the event, and
an organizer has to approve it. The dialog counts the cars at stake
(`MapEventDetailState.withdrawableCarCount` — accepted + pending) and names the
number.

### ✅ 1.5 Writes returned a participant, not the event — **fixed 2026-08-13**

All six participation writes now answer with the full `MapEventDto`:

| Endpoint | Now |
|---|---|
| `POST /{eventId}/cars` | `MapEventDto`, 201 |
| `DELETE /{eventId}/cars/{carId}` | `MapEventDto`, **200** (was 204) |
| `PATCH /{eventId}/cars/{carId}` | `MapEventDto`, 200 |
| `POST /{eventId}/withdraw` | `MapEventDto`, 200 |
| `POST /{eventId}/withdrawals/{ownerId}/approve` | `MapEventDto`, **200** (was 204) |
| `POST /{eventId}/withdrawals/{ownerId}/reject` | `MapEventDto`, 200 |

What that removed from the app:

- `MapEventDetailBloc` no longer refetches the whole page after a registration,
  cancellation or withdrawal. It takes the returned event and re-reads only the
  two lists a write can move (the accepted entry list and `/cars/mine`) — two
  requests where there used to be four or more.
- `ManageMapEventBloc` no longer refetches at all after accept / decline /
  approve / reject: the returned event carries the new `attending_cars_count`
  and the reviewed row is dropped from its queue locally.
- The repository and use cases for all six now return `MapEventEntity`.

### 🟡 1.6 `PATCH /map-events/{id}` cannot clear a capacity

Per the contract, `null`/omitted `max_participant_capacity` means "keep
current", so a cap can never be lifted back to unlimited without recreating the
event. The edit form therefore shows capacity as **set-or-raise only**, with a
hint saying so. If you want it clearable, the API needs a sentinel (e.g. `0`) or
a `clear_capacity: true` flag.

### ✅ 1.7 Geocoding endpoint — **shipped both sides 2026-08-14**

`GET /map-events/geocode` exists (Mapbox Geocoding **v6**, structured input,
proxied through Spring per §8's rule about billable Mapbox REST APIs). Full
contract in `MAP_EVENTS_PROGRESS.md` §3.8.

**The licence workaround, written down because it constrains the code:**
Mapbox's standard geocoding licence is temporary-use — persisting the
coordinates it returns needs the *permanent geocoding* product, which costs
money. So the app treats every geocode response as **camera aim only**:

- The event's `lat`/`lng` is the coordinate the **user taps onto the map**.
  `PickEventLocationPage` will not let a candidate's coordinate become the
  answer — the confirm button is disabled until `_dropped != null`, and
  `_dropped` is only ever written from a `TapInteraction`.
- The event's `location_name` is composed from the **user's own form fields**
  (`"{street} {number}, {city}"`), never from the response's `place_name`.
  Same clause, and it would have been the easy thing to get wrong: the
  formatted address is right there and looks better.
- Nothing from a response is cached to disk. The results list is held in the
  picker's `State` and dies with the screen.

This is also just better data — the organizer knows whether the meet is in
the back yard or at the front entrance, and the geocoder doesn't.

**Deliberately not sent: `proximity_lat`/`proximity_lng`.** The endpoint
accepts them, but biasing toward the camera actively hurts here — the camera
starts on the *user's* location, so a Bucharest user creating a Cluj event
would get pulled toward Bucharest matches. The required city field does that
disambiguation correctly instead. (Owner's call.)

Also unsent: the other seven structured fields the endpoint accepts
(`address_line1`, `block`, `region`, `postcode`, `locality`, `neighborhood`,
`country`). The form collects three; adding a field is one param in
`MapEventsApiDataSource.searchLocation`.

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

### ✅ 2.3 Distances are gone entirely — **owner call, 2026-08-13**

The mockups showed "0.4 mi" / "2.3 mi" and the first pass rendered them as km,
computed on the client.

**"Computed client-side" meant** the app measured the great-circle distance
from the coordinates the map last queried around to the pin's own coordinates
(`GeoPosition.distanceKmTo`, one haversine, no request). Before `distance_km`
was removed, the backend computed the same kind of number and put it on the
wire. Dropping the field never fixed the accuracy problem — it only moved where
the straight line was measured.

**Owner's call: no distance anywhere.** A straight line is unactionable — you
can't drive one — and a real road distance needs a directions API, which isn't
worth the effort at this stage. So:

- The business popup's "x km away" pill is **removed**.
- The event popup's distance stat tile is **replaced** by the event's start
  time, matching the detail page's third tile — leaving a two-tile row would
  have looked like something failed to load.
- The event hero's location line is the place name alone.
- `MapEventFormat.distance` and the `mapDistanceKm` / `mapEventsDistanceKm` /
  `mapEventsStatAway` l10n keys are deleted; `MapEventPopup` and
  `BusinessPopupContent` no longer take a centre or a distance at all.

`GeoPosition.distanceKmTo` **stays**, used in exactly two invisible places:
pin collision priority (`symbol-sort-key` in `MapLayerController`) and the
map's 12 km refetch threshold (`MapBloc`). Straight-line is the correct input
for both — neither is shown to anyone.

If road distance is ever wanted, Mapbox Directions can return a driving-distance
matrix; it would be a per-camera-move request with a real cost and latency
budget, and it should replace nothing except the pill that no longer exists.

---

## 3. Things changed outside the map-events feature

### 🟠 3.1 `distance_km` removed from the businesses layer

Per §3.6 of the progress file, `distance_km` is gone from **both**
`/businesses/nearby` and `/map-events/nearby`. I audited and stripped it:

- `BusinessPinModel` / `BusinessPinEntity` no longer parse or carry it.
- `MapLayerController.setBusinesses` takes the fetch centre and computes the
  `symbol-sort-key` (collision priority) from it. **This stays** — see §2.3.
- The business popup briefly recomputed the "x km away" pill client-side. That
  pill is now **gone** on the owner's call (§2.3), and `BusinessPopupContent`
  no longer takes a distance at all.

⚠️ **Test the business popup and pin decluttering** — this touched shipped code
twice now.

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

1. **Business pins and popup** — the distance work touched shipped code twice.
   The popup should now show **no** distance pill at all, and pin decluttering
   in a dense area should still favour the nearest business (that still uses the
   straight-line number internally — see §2.3).
2. **Event pin images** — covers are rasterised into circular markers with a
   ring that turns orange while an event is live. Watch for pins stuck on the
   car-glyph placeholder (cover URL unreachable) or a live event keeping a white
   ring (would mean the image-id variant isn't taking).
3. **Tap arbitration** — an event pin overlapping a business pin should open the
   event. Tapping empty map should dismiss whichever card is open.
4. **RSVP optimism** — the Attending/Interested pair flips instantly and the
   attendee counter moves with it; a failure rolls both back and shows a
   snackbar.
5. **Register a car on an approval-required event** — the "Request pending"
   strip should appear right after registering **and survive a kill/reopen**,
   since it now comes from `GET /{id}/cars/mine`. Then have an organizer decline
   it with a reason and check the declined strip quotes that reason back.
6. **Create flow** — the CTA names what's missing ("ADD TITLE, LOCATION & START
   TIME" → "ADD A REGISTRATION DEADLINE" → "CREATE EVENT"), the location picker
   returns coordinates, and the cover survives the WebP → R2 → PATCH round trip.
7. **Organizer console** — accept/decline an entry, then approve/reject a
   withdrawal; both lists should empty as you go and the counts should update.
   Nothing refetches any more, so a count that goes stale here means the
   returned `MapEventDto` is stale, not that the client forgot to reload.
8. **Withdrawing with more than one car entered** — the dialog should name the
   number, and all of them should go at once.
9. **Location picker panning (2026-08-14 fix)** — drag the map around; it
   should stay wherever you leave it instead of snapping back to the start
   position (was: every `onMapIdle` rebuilt `MapWidget` with a freshly
   constructed `viewport`, and since `CameraViewportState` has no `==`
   override, the plugin treated that as a new camera command and replayed it).
10. **Location picker, full flow (2026-08-14 rewrite)** — the riskiest thing
    in this pass, and mostly unverifiable without a device:
    - Search enables only with all three fields filled; results list shows up
      to 5 with sensible precision badges (check a known address returns a
      `rooftop` hit labelled EXACT ADDRESS).
    - Tapping a result flies the camera and starts the drop-pin hint
      animation; **confirm must stay disabled** until you tap the map.
    - The dropped pin must stay glued to its spot while you pan and zoom — if
      it drifts, the annotation isn't anchoring (`IconAnchor.BOTTOM`).
    - Tapping again moves the pin rather than adding a second one.
    - "RESULTS" returns to the cached list with no new request (watch the
      network log — a refetch here means the cache isn't holding).
    - Re-opening the picker on an event that already has a pin should start
      in the placing stage with that pin visible.
    - The venue field should prefill with `"{street} {number}, {city}"` only
      when you left it blank.
11. **Multi-car registration (2026-08-14, new)** — the biggest untested
    surface in the app:
    - The picker should cap selection at the event's remaining capacity
      (when capped) and grey out cars already pending/accepted for this
      event; SELECT ALL should respect both.
    - Submit with 2+ selected cars on an approval-required event: all should
      land `pending` together, and the Overview/Cars tab should show a
      separate declined/pending strip per car if their fates later diverge
      (accept one, decline another).
    - The genuinely hard-to-trigger path: force a mid-batch 409 (e.g. set
      capacity to 1 less than the selection count) and confirm the succeeded
      car(s) get silently cancelled back out on an approval-required event.
      On a **no-approval** event this can't roll back — confirm the app shows
      the "couldn't be automatically removed" message rather than claiming
      success or silently under-reporting.
    - "Participating" should stay tappable to add more cars once you already
      have one accepted, and go inert (with the existing capacity/deadline
      notice) once the event is full or closed.
12. **Declined-strip regression (2026-08-14 fix)** — reject a car, resend the
    *same* car through "TRY ANOTHER CAR", have an organizer accept it, then
    close and reopen the event. The declined strip must be gone and
    "Participating" must show instead — this was the exact bug reported.
13. **Blurred map backdrop (2026-08-14, new)** — opening any popup (business
    or event) should blur/dim the map behind it without affecting the top
    bar, back button or the popup itself; tapping empty map should still
    close the popup (the blur layer is `IgnorePointer`, so this should be
    unaffected, but it's a new layer sitting over the native map texture and
    worth a real-device check on both platforms).
