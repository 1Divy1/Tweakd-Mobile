# Map Events — Progress

> Repo-root checkpoint file for the **map events** feature (user-created events on
> the virtual map: car meets first, more categories later). The backend + DB are
> **done** (Spring + Supabase Postgres); this file tracks the **Flutter client**.
>
> **This file is the single source of truth for the implementing session.** The
> owner's screenshots and backend contract exist only here — not in the repo, not
> in any other doc. Read §8 (implementation notes) before writing code. Update the
> checklist (§6) and progress log (§7) after every completed chunk.
>
> Admin review endpoints (`/api/v1/admin/map-events/*`) exist but are for the admin
> web dashboard — **out of scope for this app**, ignore them.

**Branch:** `virtual-map`
**Status:** **implemented** — Phases 1–6 complete. `flutter analyze` clean,
17 model/enum tests pass. Not yet run on a device by the owner.
Backend gaps found during implementation are logged in
**`MAP_EVENTS_NOTES.md`** (the review queue) — read that next.
**Last updated:** 2026-08-14

---

## 1. What the feature is

Users create events (car meets) pinned to a location on the Mapbox map. Every new
event goes to the **admin team for approval** (`approval_status: pending → accepted |
rejected` + `rejection_reason`). Once accepted it appears as a pin on the map for
everyone nearby.

Other users can:
- **RSVP as spectators** — `attending` or `interested` (PUT/DELETE attendance).
- **Participate with a car** — register one of their garage cars for the entry
  list. If the event has `requires_participant_approval`, the request sits
  `pending` until an **event organizer** (not admin) accepts/rejects it.
- **Withdraw** an accepted car via a *request* flow: the withdrawal itself needs
  organizer approval (see §3.4).

Events have a lifecycle `status`: `upcoming | live | previous | hidden | canceled`,
organizer actions cancel / finish / delete, co-organizers (individual users or
certified businesses), an optional participant capacity, an ordered rules list, a
cover image (R2, presigned upload), and for car meets a required
`registration_deadline`.

---

## 2. Design reference (from owner's screenshots, 2026-08-12)

**If the owner has attached the actual screenshots to your session, THEY are the
design authority — build from the images.** This section is a textual backup (the
shots aren't in the repo) plus the ⚠-marked corrections where the backend contract
diverges from what the shots show; those corrections apply on top of the images.
Visual language matches the existing app: `AppColors` palette, cream `bg`, white
cards with rounded corners, orange `accent` CTAs, uppercase micro-labels.

### 2.1 Map popup (preview card, like the business popup)
Floating card over the map (map stays visible behind):
- Cover image header with status chip (**UPCOMING** black / **LIVE NOW** orange dot),
  share + close buttons overlaid top-right.
- Title, 2-line truncated description.
- 📍 location name (e.g. "Port Hercule — Level 2") and 🕐 date + time range.
- Three stat tiles: **attendees**, **cars**, **distance away** — distance is
  **computed client-side** (straight-line, from the pin's lat/lng vs the center
  point sent to `/nearby`); the API returns no distance (§3.6).
- Avatar stack + "247 going".
- Organizer rows: avatar, name, `@username · organizer`, chip `INDIVIDUAL` /
  `BUSINESS` (businesses show the blue verified check). Chevron → their profile.
- RSVP row: **Attending** / **Interested** toggle buttons (active = filled black).
- Participation strip below RSVP: either "**Want to participate?**" (tap → register
  car) or "**Your BMW M4 Competition is on the entry list**".
- Bottom pinned bar: navigate (paper-plane) square button + full-width orange
  **VIEW EVENT >** CTA.

### 2.2 Event detail page
- Hero cover image, back + share buttons, status chip, big title,
  📍 location — level · distance (client-computed, §3.6).
- Stat tiles: attendees / cars (orange when viewer has a car in) / start time
  (label "STARTS" for upcoming, "STARTED" for live).
- Action row: **Interested** / **Attending** toggles + participation button with
  states: `🚗 Participate?` → `⏳ Pending` (orange) → `✓ Participating` (grey,
  filled) + separate **Withdraw** button.
- Segmented tabs: **Overview** | **Cars · N**.

**Overview tab:**
- Date card: calendar tile (AUG 16), "Sun, 16 Aug · 09:00 – 13:00", full address,
  and for car meets "⏳ Register your car before **Fri, 14 Aug, 23:59**".
- Viewer's participation status strips:
  - `⏳ Request pending · Nissan Skyline R34 GT-R` — "@jdm_jules will approve or
    decline your entry."
  - `✕ Entry declined · Mazda RX-7 FD` — rejection reason + **TRY ANOTHER CAR**
    button. (Shown on Cars tab in the shots, above the entry list.)
- **About this meet** — description card.
- **Organizers** — same rows as popup.
- **Notes from the organizer** — numbered rule list (1, 2, 3…), from the event's
  `rules` (§3.5). Order is the backend's order.
- **Contests** — placeholder card with `SOON` chip ("Organizers will be able to run
  votes inside a meet — best build, cleanest bay, loudest exhaust."). UI-only stub.
- **Attendees** — avatar row + "+241" overflow + **SEE ALL** / **SEE ALL ATTENDEES**.
- **🚗 SEE ALL 34 CARS >** button → Cars tab.

**Cars tab:** "On the entry list" header + "N APPROVED" count; car cards with cover
photo, model name + year, `@owner`, **GARAGE >** link (→ owner's garage/car).

### 2.3 Withdraw dialog
"Withdraw from this meet?" — removed from entry list **and from any contests running
inside this meet**; can request entry again later. Optional "note for organizers"
textarea → `WithdrawParticipationRequest.note`. Cancel / orange **Withdraw**.
⚠ Copy nuance: withdrawal is now a **request** the organizers approve (§3.4), so
the dialog copy "You'll be removed" should soften to request phrasing. After
submitting, the UI shows a withdrawal-pending state — and it's **one-way**: there
is no endpoint for the user to cancel their own withdrawal request, so don't build
an "undo" affordance.

### 2.4 Create event flow ("NEW EVENT", full-screen modal, one long scroll)
Order top→bottom:
1. Cover photo picker (dashed box, "1600 × 900 recommended").
2. Event title.
3. Category chips: **Car Meet** (selectable, from `/categories`) + Track Day /
   Car Show / Cruise shown locked with 🔒 `SOON` — **hardcoded client-side**
   (owner-confirmed; `/categories` only returns enabled ones, and car_meet is the
   only DB category today).
4. Description (multiline).
5. Location: venue-name text field + dashed "📍 SET LOCATION ON MAP" button
   (→ pick lat/lng on a map).
6. Date & time: start date+time, end date+time — "Leave the end blank for an
   open-ended meet."
7. Max capacity (optional) — "No limit — e.g. 40 spots" → `max_participant_capacity`.
8. **Require approval to join** toggle (default ON in shots) + nested
   **Registration deadline** date+time. The shots label it OPTIONAL but the API
   **requires it for car_meet** — owner confirmed API wins: enforce as required
   in validation (keep or fix the OPTIONAL label; treat as required either way).
9. Rules & guidelines (optional) — "+ ADD A RULE" repeating rows → `rules: [string]`
   sent in the create call, order preserved.
10. Organizers: creator row ("YOU · CREATOR") + "+ ADD ORGANIZER" → search picker
    over `/map-events/organizers/search` (§3.3), individuals + businesses merged.
11. Bottom pinned CTA, disabled until valid: "ADD TITLE, LOCATION & START TIME".

### 2.5 Map top bar (context)
The map screenshots show a search bar ("Search meets, shops, cities…") and an
orange **+** button. Owner-confirmed: the search bar is **pure UI, no behavior**
for now; the **+** opens the create-event flow. **My events** lives in the user's
own profile page (placement TBD in Phase 5).

---

## 3. Backend contract (owner-provided 2026-08-12, two rounds — persisted here, chat was the only copy)

Base: `${API_BASE_URL}/api/v1/map-events`, JWT via `AuthInterceptor`, **snake_case
on the wire** (Jackson global SNAKE_CASE — some of the owner's examples show
camelCase like `referenceId`/`userId`; that is illustrative only, per the
long-standing project convention; the wire is `reference_id`/`user_id`).
`instant` = ISO-8601 UTC timestamp.

### 3.1 Reads
```
GET /map-events/nearby?lat=&lng=&radius_km=25&category={category_id}&limit=200
  → MapEventPinDto[]  (flat array)
  { id, title, category_id, category_label, lat, lng, location_name,
    cover_image_url|null, starts_at, ends_at|null, status: "upcoming|live",
    attendees_count, attending_cars_count, max_participant_capacity|null }
  ⚠ NO distance_km (removed — §3.6). The owner's two statements on array order
  conflict (round 2: "arbitrary, by id"; round 3: "nearest-first") — treat order
  as UNSPECIFIED: never rely on it, place/sort by each pin's own lat/lng.

GET /map-events/categories
  → [{ id: "car_meet", label: "Car meet" }]   // enabled categories only

GET /map-events/mine?cursor=&size=20        → MapEventPageDto<MapEventSummaryDto>
  items[]: { id, title, category_id, category_label, location_name, lat, lng,
    starts_at, ends_at|null, cover_image_url|null,
    status: "upcoming|live|previous|hidden|canceled",
    approval_status: "pending|accepted|rejected", rejection_reason|null,
    attendees_count, attending_cars_count, max_participant_capacity|null,
    creator: { id, username, avatar_url|null }, created_at }
  + next_cursor|null

GET /map-events/{event_id}                  → MapEventDto
  { id, title, description, category_id, category_label, location_name, lat, lng,
    starts_at, ends_at|null, cover_image_url|null,
    status, approval_status, rejection_reason|null, requires_participant_approval,
    attendees_count, attending_cars_count, max_participant_capacity|null,
    rules: [{ id: uuid, rule: "string", sort_order: int }],   // MapEventRuleDto, ordered
    organizers: [{ id, type: "individual|business", role: "creator|organizer",
                   reference_id, name, image_url|null }],
    car_meet: { registration_deadline } | null   // null for non-car-meet categories
    viewer: { is_creator, is_organizer, can_edit,
              attendance_status: "attending|interested"|null,
              can_rsvp, can_register_cars, my_registered_car_ids: [uuid] },
    created_at }
  // viewer.my_registered_car_ids = the caller's cars in this event WHATEVER their
  // status (pending/accepted/rejected/withdrawn — withdrawn stays included).
  // There is NO per-car status on the viewer object: to learn each car's status,
  // cross-reference the ids against GET /{event_id}/cars rows.

GET /map-events/{event_id}/attendees?status={attending|interested}&cursor=&size=20
  → page of { profile: { id, username, avatar_url|null }, status }

GET /map-events/{event_id}/cars?status={pending|accepted|rejected|withdrawn}&cursor=&size=20
  Visibility: "accepted" and "withdrawn" are PUBLIC ("a withdrawal request does
  not carry stigma — the participant asked to leave themselves"); only "pending"
  and "rejected" are organizer-only. NO status param = accepted + withdrawn
  together — so for the design's "N APPROVED" entry list, query
  ?status=accepted explicitly.
  → page of MapEventParticipantDto:
  { car: { id, brand, model,
           cover_image: { key|null, url|null },
           status: { id, type },                 // CarStatusOptionDto
           owner: { id, username } },
    status: "pending|accepted|rejected|withdrawn", registered_at }
```

### 3.2 Event writes (all return MapEventDto unless noted)
```
POST   /map-events                       → 201, approval_status "pending"
  { category_id, title, description, location_name, lat, lng, starts_at,
    ends_at|null, requires_participant_approval, registration_deadline,
    max_participant_capacity|null,       // positive int; omit/null = no cap
    rules: ["string", ...]|null }        // optional; inserted transactionally,
                                         // response comes back with rules populated,
                                         // order = exactly the list's order
  // registration_deadline REQUIRED when category_id == "car_meet"
  // (even though the design labels it optional — owner-confirmed)

PATCH  /map-events/{id}                  // only while pending/rejected
  all fields optional, null = unchanged: { title, description, location_name,
    lat, lng, starts_at, ends_at, requires_participant_approval,
    registration_deadline, max_participant_capacity }
  // null/omitted capacity = keep current; a cap CANNOT be cleared back to
  // unlimited via PATCH (only by recreating the event)

PUT    /map-events/{id}/rules            // full-replace rules later (reorder/add/clear)
  { rules: ["string", ...] }             // plain strings: max 50 items, each ≤300
                                         // chars, non-blank. sort_order assigned
                                         // server-side from list position — you
                                         // cannot send ids/positions. Wholesale
                                         // delete + re-insert; [] clears all.
  → MapEventDto (with the new rules)
  // Same lock as PATCH: organizer only, pending/rejected only.

PATCH  /map-events/{id}/cover            { key: "events/{id}/{uuid}.webp" }
POST   /map-events/{id}/cancel           (no body)
POST   /map-events/{id}/finish           (no body)
DELETE /map-events/{id}                  → 204, creator only
```

### 3.3 Organizers
```
GET  /map-events/organizers/search?q={prefix}
  Any authenticated user. q = name/username prefix, case-insensitive;
  blank/missing q → []. Individuals + businesses merged, unsorted between groups.
  → OrganizerCandidateDto[]:
  { type: "individual|business", reference_id, name, image_url|null }

POST   /map-events/{id}/organizers       → MapEventDto. Creator-only.
  { user_id|null, business_id|null }     // exactly one set — feed the candidate's
                                         // reference_id into the matching field.
  // 400 if both/neither set, or target already organizes the event.

DELETE /map-events/{id}/organizers/{organizer_id}   → MapEventDto
```

### 3.4 Attendance & car participation
```
PUT    /map-events/{id}/attendance       { status: "attending|interested" }  → MapEventDto
DELETE /map-events/{id}/attendance       (no body)                           → MapEventDto

POST   /map-events/{id}/cars             { car_id }   → 201 MapEventParticipantDto
  // 409 Conflict cases: "event finished", "deadline passed", and now
  // "This event has reached its participant capacity". Show the server's
  // message; additionally grey out the register button client-side when
  // attending_cars_count >= max_participant_capacity (when capacity non-null).

DELETE /map-events/{id}/cars/{car_id}    → 204
  // PENDING-ONLY: cancels a not-yet-accepted registration. Calling it on an
  // accepted row errors ("an accepted entry must go through a withdrawal
  // request"). Accepted rows leave via the withdrawal flow below.

PATCH  /map-events/{id}/cars/{car_id}    { status: "accepted|rejected" }  // organizer only
                                         → MapEventParticipantDto
```

**Withdrawal flow (round-2 addition — request-based, NOT immediate removal):**
```
POST /map-events/{event_id}/withdraw
  Caller = a participant. Flags ALL the caller's ACCEPTED rows for this event as
  "withdrawn" (not deleted) pending organizer review.
  { note: "string|null" }                // the dialog's optional note
  → MapEventParticipantDto[]  (caller's rows, status "withdrawn")
  // ONE-WAY: no endpoint exists for the user to cancel their own withdrawal
  // request — it stays "withdrawn" until an organizer approves or rejects.
  // Withdrawn cars remain on the public car list (no-filter + ?status=withdrawn).

GET /map-events/{event_id}/withdrawals   // organizer-only
  Pending withdrawal requests, grouped by owner.
  → MapEventWithdrawalRequestDto[]:
  [{ owner: { id, username, avatar_url|null },
     cars: [ CarSummaryDto ],            // same car shape as participant rows
     note: "string|null" }]

POST /map-events/{event_id}/withdrawals/{owner_id}/approve   // organizer-only, no body
  Hard-deletes the owner's rows for this event.  → 204

POST /map-events/{event_id}/withdrawals/{owner_id}/reject    // organizer-only, no body
  Reverts the owner's rows back to "accepted".
  → MapEventParticipantDto[]  (status "accepted")
```

### 3.5 Rules
- Sent at creation via `rules: List<String>` on `POST /map-events` (optional);
  response returns the full event with rules populated — no follow-up call.
- In responses, `rules` = `[{ id, rule, sort_order }]` (already ordered).
- `PUT /{event_id}/rules` for later edits — plain string array, full replace
  (§3.2); limits: ≤50 rules, ≤300 chars each, non-blank.
- Ordering is backend-managed and equals the submitted list order.

### 3.6 distance_km is GONE (breaking change, affects businesses too)
`distance_km` was **removed** from `GET /map-events/nearby` *and*
`GET /businesses/nearby` (it was straight-line distance, deemed worthless as a
server field). URLs/params/auth unchanged; radius filtering (ST_DWithin)
unchanged; but:
- Array order: treat as **unspecified** (owner's statements conflicted — see
  §3.1). Never rely on it.
- **Distance shown in UI is computed client-side** (owner-confirmed): straight-
  line from the pin's `lat`/`lng` vs the center point the app sent as the
  `/nearby` query params. `geolocator`'s `Geolocator.distanceBetween` does this.
  Use **km** (the app's unit; the shots' "mi" is mock).
- **Client action:** audit the existing businesses layer for `distance_km`
  consumption — the pin collision priority (`symbol-sort-key` = distance) and any
  "x km away" UI — and switch it to the same client-side computation.

### 3.8 Geocoding (owner-provided 2026-08-14) — Mapbox v6, structured input

```
GET /map-events/geocode
  Auth required (JWT, like every other map-events call).
  All params optional; at least one of the 10 address fields must be
  non-blank or the backend returns [] WITHOUT calling Mapbox.

  address_line1   street number + name combined ("1600 Pennsylvania Ave")
                  — use this OR address_number+street, never both
  address_number  house/building number, when sent separately from street
  street          street name
  block           sub-division used in some countries (Japan) — unlikely ever
  place           city / village / municipality
  region          state / province
  postcode        postal code
  locality        sub-city administrative area
  neighborhood    colloquial sub-city area
  country         ISO 3166-1 alpha-2 code, or full country name
  proximity_lat   optional bias latitude   ⚠ deliberately unused, see below
  proximity_lng   optional bias longitude  — only applied when both are
                  present and valid, otherwise silently ignored

  → 200, GeocodeCandidateDto[], best match first, up to 5 items
  { lat, lng,
    place_name,     // Mapbox full_address → place_formatted → name
    feature_type,   // address | street | place | postcode | region |
                    // country | … (open set — client falls back to `other`)
    accuracy }      // rooftop | parcel | point | interpolated | approximate |
                    // intersection — ONLY on address-level hits, null otherwise

  Blank / all-empty query → [] (200, not an error).
```

**The client sends three of the ten fields** — `place`, `street`,
`address_number` — because that's what the picker's mini-form collects.

**`proximity_lat`/`proximity_lng` are deliberately never sent** (owner's call,
2026-08-14). Biasing toward the picker's camera would drag results toward
wherever the *user* is, so someone in Bucharest creating an event in Cluj
would get Bucharest matches. The required city field disambiguates correctly
instead.

**Nothing in the response is ever persisted** — see §5's licence entry and
`MAP_EVENTS_NOTES.md` §1.7. The coordinates aim the camera; the event's own
`lat`/`lng` comes from the user's tap and its `location_name` from the user's
typed fields.

### 3.7 Cover upload (storage module — same two-step WebP flow as posts/garage)
```
GET /api/storage/events/{event_id}/cover   → { key: "events/{id}/{uuid}.webp", upload_url }
```
Flow: POST event → GET presigned URL → client PUTs WebP to R2 → PATCH
`/map-events/{id}/cover` with the key. The GET has no ownership check (any JWT);
enforcement happens on the PATCH (organizer-scoped).

---

## 4. Open questions

**None blocking.** Rounds 1–4 are all answered and folded into §3/§5.

Implementation surfaced four **backend** gaps that are not questions so much as
follow-up work — they're written up with proposed fixes in
**`MAP_EVENTS_NOTES.md`** §1:

1. 🔴 organizers carry no `username` (breaks the designed organizer row);
2. 🔴 a participant cannot read their **own** pending/rejected entry (the only
   endpoint that would show it is organizer-only), which makes two of the
   design's status strips unbuildable for the person they're aimed at;
3. 🟠 no rejection reason on a declined car entry;
4. 🟠 a participant has no way to see that their withdrawal request exists.

(1) and (2) are worth fixing; the app degrades gracefully without them today.

## 5. Decisions log (owner-confirmed — do NOT "improve" these without asking)

- **Scope:** mobile app consumes user-facing `/map-events/*` only; admin endpoints
  ignored (admin web dashboard).
- **Location picking is user-generated, by licence (2026-08-14):** the geocoder
  aims the camera and nothing more. The event's `lat`/`lng` is the point the
  user **taps** on the map — confirm stays disabled until they do — and its
  `location_name` is composed from the address fields they typed, never from
  the response's `place_name`. Persisting Mapbox's coordinates would require
  their paid permanent-geocoding licence. Do not "simplify" this by defaulting
  the pin to the chosen candidate.
- **Entry points:** map's orange **+** button → create flow directly. **My events**
  (`/mine`) → user's own profile page (exact placement decided in Phase 5).
- **Map search bar** ("Search meets, shops, cities…") is **pure UI, no behavior**.
- **Event pins:** cover image in a circle, same white-ring treatment as business
  logo pins (reuse the marker-factory pattern); consider a status accent for LIVE.
- **Categories:** enabled ones from `/categories` (today: only `car_meet`). The
  Track Day / Car Show / Cruise `SOON` chips are **hardcoded client-side**.
- **Registration deadline:** required for car_meet (API wins over the design's
  OPTIONAL label).
- **Capacity / rules / withdraw note:** backend fields landed in round 2 (§3) —
  build them. Capacity display: show alongside counts where designed; register
  button greys out when full (plus handle the 409 message).
- **Distance:** `distance_km` removed backend-side; all displayed distances are
  computed client-side, straight-line, in **km** (§3.6). The businesses layer must
  be audited and switched to the same computation.
- **Entry list = accepted only:** the "N APPROVED" list queries
  `?status=accepted`; the no-filter default mixes in withdrawn rows (§3.1).
- **Withdrawal is one-way for the user** (no self-cancel endpoint) and withdrawn
  cars stay publicly visible until an organizer approves (hard delete) or rejects
  (back to accepted).
- **Viewer's per-car status** (pending/accepted/withdrawn/rejected strips) comes
  from cross-referencing `viewer.my_registered_car_ids` against
  `GET /{id}/cars` rows — the viewer object itself carries no per-car status.
- **Module placement (proposed, unobjected):** new feature module
  `lib/features/map_events/` owning everything (entities → pages). The `map`
  feature adds an events pin layer + preview popup by consuming `map_events`'
  domain (same cross-feature package-import pattern as feed→posts). Pin layer
  copies the businesses reference pattern (`MapLayerController`, radius fetch on
  camera-settled — `lib/features/map/README.md` §6.0).
- **Reuse:** WebP + presigned-PUT upload machinery from posts/garage
  (`ImageService`); `NavigateButton` / `showNavigationAppSheet`
  (`lib/features/map/presentation/widgets/navigation/`, takes bare `GeoPosition` +
  label — designed for this); garage's "my cars" data for the register-car picker
  (NOT the tagging `car_picker_sheet` — that picks another person's car).

## 6. Task checklist

Phases roughly follow dependency order. Each chunk gets checked off + a line in §7.

### Phase 0 — Planning
- [x] Progress file with design record + backend contract
- [x] Round-1 owner answers (entry points, pins, missing fields)
- [x] Round-2 owner answers (withdraw flow, organizer search, capacity, rules,
      distance_km removal, categories, map search)
- [x] Round-3 owner answers (rules DTO + PUT contract, pending-only DELETE,
      one-way withdrawal, viewer cross-reference, client-side distance,
      starts_at, withdrawn filter visibility) — planning **complete**

### Phase 1 — Domain + data (`lib/features/map_events/`)
- [x] Entities: `MapEventPinEntity`, `MapEventEntity` (+ organizers, viewer,
      car_meet detail, rules), `MapEventSummaryEntity`, `MapEventAttendeeEntity`,
      `MapEventParticipantEntity` (+ car summary; status incl. `withdrawn`),
      `MapEventWithdrawalRequestEntity`, `MapEventCategoryEntity`,
      `OrganizerCandidateEntity`
- [x] Failures + exceptions (standard pipeline; surface the 409 capacity/deadline/
      finished messages distinctly for the register-car flow)
- [x] Models with snake_case `fromJson` → `toEntity`
- [x] `MapEventsApiDataSource` (every endpoint in §3) + storage cover upload call
- [x] Repository interface + impl, use cases (one per consumed endpoint)
- [x] DI annotations + build_runner
- [x] Audit & strip `distance_km` from the businesses layer (§3.6) — pin ordering
      no longer nearest-first there either

### Phase 2 — Map integration (pins + preview popup)
- [x] Events GeoJSON source + layer(s) in `MapLayerController` — cover-image
      circle markers via the business marker-factory pattern
- [x] `MapBloc`: fetch events alongside businesses on camera-settled
- [x] Tap → event preview popup (§2.1) incl. RSVP + participation strip + navigate
- [x] "View event" → detail route

### Phase 3 — Event detail page
- [x] Route `/map-events/:id` + bloc (detail state incl. viewer perms)
- [x] Hero header, stat tiles (incl. capacity display), status chips
- [x] RSVP actions (PUT/DELETE attendance) with optimistic UI
- [x] Overview tab (§2.2): date card + deadline, rules list, organizers,
      pending/declined strips, contests stub, attendees row
- [x] Cars tab: accepted entry list (paginated) + garage link
- [x] Attendees see-all page (paginated, attending/interested)
- [x] Register car flow: my-garage picker → POST /cars; 409 handling; grey-out
      when at capacity
- [x] Withdraw request flow: dialog (+ note) → POST /withdraw; post-submit
      pending-withdrawal state via the my_registered_car_ids ↔ /cars
      cross-reference; no undo affordance (one-way)
- [x] Cancel a still-pending registration: DELETE /cars/{car_id} (pending-only)
- [x] Error mapper + l10n (EN + RO)

### Phase 4 — Create event
- [x] Full-screen create flow (§2.4): validation (deadline required for car_meet),
      category chips (live + hardcoded SOON), set-location-on-map picker,
      date/times, approval toggle + deadline, max capacity, rules editor
- [x] Cover image: pick → WebP → presigned PUT → PATCH cover
- [x] Add organizer picker: search via `/organizers/search`, both types, then
      POST /organizers with the right field
- [x] Post-submit state: "pending admin approval" explainer

### Phase 5 — My events + organizer tools
- [x] My events list (`/mine`) reachable from own profile: status + approval
      badges, rejection reason
- [x] Edit while pending/rejected (PATCH + PUT /rules), cancel / finish / delete
      with confirms
- [x] Organizer review UI: pending/rejected car lists + accept/reject
- [x] Organizer withdrawal review: GET /withdrawals grouped by owner (cars + note)
      → approve (hard delete) / reject (revert to accepted)
- [x] Manage organizers (add/remove)

### Phase 6 — Polish
- [x] Date formatting, empty states, pull-to-refresh where applicable
- [x] `flutter analyze` clean; tests for blocs/mappers as per repo norm

## 7. Progress log

- **2026-08-12** — Created this file. Recorded design from 11 screenshots + the
  full backend contract. Asked round-1 questions; owner answered (entry points,
  pin design, hold on missing fields).
- **2026-08-12** — Round 2: owner shipped the missing backend pieces and answered
  everything — withdrawal request flow (§3.4), organizer search (§3.3),
  `max_participant_capacity` (+409 when full), `rules` on create + PUT /rules,
  `distance_km` removed from both nearby endpoints (pins now arbitrary order),
  deadline required, SOON chips hardcoded, map search is UI-only. File rewritten
  as the self-contained implementation brief.
- **2026-08-12** — **Implemented, Phases 1–6.** Round-4 owner answers first:
  organizer rows show *name only, no navigation* (the DTO carries no username),
  and **My events lives as a 4th profile tab** ("Events", own profile only,
  lazy-loaded like Tags).

  Shipped:
  * `lib/features/map_events/` — 10 entity files, 4 model files, 2 data sources,
    repository (+ a single `_guard` doing the whole exception→Failure ladder),
    26 use cases across 6 grouped files, 5 blocs, 6 pages, ~25 widgets, error
    mapper, date/distance formatting. Feature `README.md` written.
  * **Businesses distance audit (§3.6) done**: `distance_km` stripped from
    `BusinessPinModel`/`BusinessPinEntity`; `MapLayerController.setBusinesses`
    now takes the fetch centre and computes `symbol-sort-key` client-side; the
    popup's "x km away" pill likewise. ⚠️ shipped code touched — worth a look.
  * `BusinessMarkerFactory` generalised into `MapMarkerFactory` (per-call ring
    colour + placeholder glyph) so events reuse it; `MapLayerController` now
    carries both pin layers, events on top and winning a shared tap.
  * `MapBloc` fetches both layers on one camera-settled trigger, folding them
    independently — one dead endpoint no longer empties the other's layer.
  * Map top bar added: inert search row + orange **+** → create flow.
  * 175 l10n keys in EN **and** RO (+2 later), `flutter gen-l10n` run.
  * `test/features/map_events/map_event_models_test.dart` — 17 tests, passing.
    (The repo had no tests before; this is the first file under `test/`.)

  Deviations from the design, all deliberate and recorded in
  `MAP_EVENTS_NOTES.md`: no `@username`/chevron on organizer rows (§1.1); the
  declined-entry strip has no organizer reason (§1.3); the share button copies
  the event to the clipboard rather than opening an OS share sheet (§4.4 — no
  share plugin, and no public URL to share).

- **2026-08-13** — **Round-5 backend fixes consumed.** The owner shipped
  §§1.1–1.5 of `MAP_EVENTS_NOTES.md`; the app now uses all of them.

  Contract deltas (this supersedes §3.4 and the organizer shapes in §3.1/§3.3):
  * `MapEventOrganizerDto` and `OrganizerCandidateDto` gained `username`
    (null for `type: "business"`); their `name` is now a real display name, not
    a mislabeled username. Same change to the shared `ProfileSearchResultDto`,
    so map-event **attendees** carry `name` too.
  * **New:** `GET /{eventId}/cars/mine` — auth, no params, unpaginated
    `List<ParticipantDto>`, every status the caller has.
  * `ParticipantDto` gained `rejection_reason` (null unless rejected).
  * `PATCH /{eventId}/cars/{carId}` **requires** `reason` to reject (400
    otherwise); ignored on accept.
  * All six participation writes now return the full `MapEventDto`.
    `DELETE /{eventId}/cars/{carId}` and
    `POST /{eventId}/withdrawals/{ownerId}/approve` changed **204 → 200**.

  Shipped in the app:
  * Organizer rows render `@handle · role` and link individuals into
    `/users/:username`; businesses stay inert (no handle, no route yet).
  * `GET /cars/mine` replaced the cross-referencing resolver — ~60 lines and up
    to three extra requests deleted, along with `unresolvedRegisteredCarIds`,
    `hasUnresolvedRegistration` and the "Registration in progress" strip. A
    pending request now survives a cold open.
  * Declined strip quotes the organizer's reason; the console collects it in
    `showDeclineEntryDialog` (confirm disabled until typed).
  * The withdraw dialog states the all-or-nothing rule and counts the cars.
  * `MapEventDetailBloc` refetches two lists instead of the whole page after a
    participation write; `ManageMapEventBloc` refetches nothing at all.
  * Attendee rows show display name over handle.
  * 5 new l10n keys EN + RO, 2 deleted; 4 new model tests (21 total, passing).
    `flutter analyze` clean.

- **2026-08-13** — **Distances removed from the UI entirely (owner call).**
  A straight-line "x km away" is unactionable and road distance isn't worth the
  effort yet, so nothing in the app shows a distance any more: the business
  popup's pill is gone, the event popup's distance tile became the start time
  (matching the detail page), the event hero shows the place name alone, and
  `MapEventFormat.distance` plus the `mapDistanceKm` / `mapEventsDistanceKm` /
  `mapEventsStatAway` keys are deleted. `GeoPosition.distanceKmTo` stays for the
  two invisible consumers — pin collision priority and the 12 km refetch
  threshold. This supersedes §5's "distances read 0.6 km, computed client-side"
  and §3.6's popup note.

  Still open from the notes: §1.6 (capacity can't be cleared) and the §4 product
  gaps.

- **2026-08-14** — **Bug fixes from device testing, round 1.** Two reported
  issues in the create-event location picker (`pick_event_location_page.dart`):

  1. **Map reset to Cluj-Napoca old town on every pan.** Root cause: the page
     rebuilt on every `onMapIdle` (to update the coordinate readout), and its
     `MapWidget`'s `viewport` was constructed fresh inside `build()` each time.
     `CameraViewportState` has no `==` override, so the Mapbox plugin saw a
     "new" viewport on every rebuild and replayed it — snapping the camera
     back to the start position right after the user finished panning. Fixed
     by hoisting `viewport` into a `late final` field built once; matches the
     pattern `map_view.dart` already documented for exactly this reason. All
     further camera moves (the new search feature below) go through the
     imperative `MapboxMap` controller instead of the widget's `viewport` prop.
  2. **No way to search an address.** Added a text field + search button to
     the picker; on submit it geocodes the typed address and flies the camera
     there, after which the user can still nudge the pin. This needed a new
     backend endpoint that doesn't exist yet (`GET /map-events/geocode`) — the
     full client-side path shipped anyway (entity, model, data source,
     repository, use case, DI, l10n EN+RO, a model test) so it lights up the
     moment the backend adds it. Per the architecture note in §8, geocoding is
     proxied through Spring rather than called directly from Flutter with the
     public Mapbox token — contract + rationale written up in
     `MAP_EVENTS_NOTES.md` §1.7.

  `flutter analyze` clean, all 23 model tests pass (2 new).

- **2026-08-14** — **Location picker rebuilt for structured geocoding.** The
  owner shipped `GET /map-events/geocode` against Mapbox v6 (§3.8), which
  replaced the same-day free-text version above wholesale.

  **The mechanic changed, and it's a licensing constraint, not a UX tweak**
  (§5, `MAP_EVENTS_NOTES.md` §1.7): the old picker had a fixed crosshair at
  screen centre with an always-enabled confirm, so flying to a result and
  confirming would have persisted Mapbox's own coordinate — exactly what the
  paid permanent-geocoding licence covers. Now the user **taps** the map, a
  pin annotation drops on the tapped point, and confirm is disabled until one
  exists. `location_name` is likewise composed from the typed fields rather
  than the response's `place_name` — same clause, and the tempting mistake.

  Client:
  * `PickEventLocationPage` rewritten as three stages — **form** (city,
    street, number; search enabled only when all three are filled) →
    **results** (up to 5, tappable) → **placing** (camera flown to the chosen
    candidate, `DropPinHint` animating on the centre, "RESULTS" to go back).
    Results are cached in `State` for the screen's lifetime, so rejecting a
    location and picking another costs no request; leaving the picker drops
    them.
  * New: `DropPinMarker` (rasterises the teardrop pin as PNG for the
    annotation — single path, not circle+triangle, so the outline has no
    seam), `AddressFormSheet`, `GeocodeResultList`, `DropPinHint`.
  * `GeocodeCandidateEntity` gained `feature_type` + `accuracy` as enums with
    the repo's usual `fromApi` fallback. The results list shows a precision
    badge off them — Mapbox regularly returns several hits with an identical
    `place_name`, and without the badge those rows are indistinguishable.
  * `showPickEventLocation` now returns `PickedEventLocation` (position +
    composed address label). The create form prefills its venue field from
    that label **only when empty**, so a typed "Port Hercule — Level 2"
    survives.
  * The `late final CameraViewportState` fix from earlier today is load-
    bearing here: this page `setState`s on every keystroke.
  * 26 l10n keys EN + RO (3 orphans deleted), 4 model tests.

  `flutter analyze` clean, 25 model tests pass.

- **2026-08-12** — Round 3 answers folded in: rules are `{id, rule, sort_order}`
  objects in responses / plain strings (≤50 × ≤300 chars) in PUT; DELETE
  /cars/{car_id} is pending-only; withdrawal is one-way (no self-cancel) and
  withdrawn rows are public (`?status=withdrawn` valid; default list = accepted +
  withdrawn, so the entry list queries accepted explicitly); viewer per-car status
  via cross-reference; distance computed client-side in km; starts_at confirmed in
  MapEventDto. **All open questions resolved — implementation can start.** No code yet.

- **2026-08-14** — **Five bug fixes / refactors from the owner's device-testing pass.**

  1. **Cover image is now mandatory.** `CreateMapEventState.hasCover` (a fresh
     pick, or — in edit mode — the event's existing `cover_image_url`) gates
     `isComplete`; the CTA names it specifically ("ADD A COVER IMAGE") via a
     new `isMissingCoverOnly`, and the cover section got a "REQUIRED" label
     like the other required fields.
  2. **Multi-car registration.** The backend already supported it — a viewer
     can hold more than one accepted row per event (`POST /withdraw` flags
     *all* their accepted rows; `/cars/mine` returns every row they have) —
     but there's no bulk endpoint and the old UI hard-blocked a second car
     once one was accepted. `event_car_picker_sheet.dart` is now a
     multi-select list (select-all/clear, capacity-clamped via the new
     `MapEventEntity.remainingCapacity`, cars already pending/accepted for
     this event shown disabled so a resend can't duplicate a row).
     `RegisterCarsForEvent(List<String>)` replaces the single-car event; the
     bloc submits sequentially and stops at the first failure. Per the
     owner's call: **all-or-nothing**, with a caveat that's a real API
     constraint, not a choice — `DELETE /cars/{car_id}` only cancels a still
     *pending* row, so on a no-approval event (rows land `accepted`
     immediately) a row that got in before a mid-batch failure can't be
     undone. The picker's capacity clamp makes that race rare; when it still
     happens, the app says so plainly (`mapEventsBulkRegisterPartial`)
     instead of pretending the rollback was clean. "Participating" is now
     tappable to add more cars any time (blocked only when the event is full
     or registration is closed), shows a count once >1, and the picker
     excludes cars with a live entry so the same car can't get a duplicate
     row — a rejected/withdrawn car stays selectable, which is also how
     "try another car" works.
  3. **Fixed: a resent-then-accepted car still showed "Entry declined".**
     Root cause — the backend never deletes a superseded row, so after
     reject → resend → accept, `/cars/mine` had both the old rejected row and
     the new accepted one for the same car, and the declined strip picked
     the rejected one with no awareness a newer row existed. Fixed by
     `MapEventDetailState._effectiveParticipations`: group the viewer's rows
     by car id, keep only the one with the latest `registered_at`. All the
     `my*Entry` getters (and the new `my*Entries` lists) read from that
     instead of the raw list. The participation strip now renders one card
     per *distinct* live pending/rejected/withdrawn car rather than just the
     first match, since with multi-car registration more than one can be
     true at once.
  4. **Profile Events tab padding.** `MyMapEventsList`'s embedded branch had
     no horizontal padding at all (the standalone page's `ListView` supplied
     its own, but the profile tab's plain `Column` didn't). Wrapped in
     `Padding(horizontal: 16)` to match the standalone page's margins.
  5. **Blurred backdrop behind map popups.** `MapFlutterOverlays` gained
     `_MapPopupBackdrop`, a `BackdropFilter` + dark scrim, first child in the
     Stack (so it blurs the map underneath but not the chrome/popup painted
     after it), gated on `MapState.isPopupOpen` and only mounted while
     visible or fading out (a `BackdropFilter` costs a blur pass every frame
     it's in the tree). `IgnorePointer`, so tapping empty map still dismisses
     the popup exactly as before.

  New l10n: `mapEventsFieldCover`, `mapEventsCreateCtaCover`,
  `mapEventsParticipatingCount`, `mapEventsBulkRegisterPartial`, and six
  `mapEventsPickCar*` picker-sheet keys — EN + RO. One orphan deleted
  (`mapEventsCarOnEntryList`: the popup's single-car accepted line was
  replaced by the same `MapEventParticipationButtons` the detail page uses,
  for consistency and because it now needs to show a count).

  `flutter analyze` clean, all 25 existing model tests still pass (no model
  changes in this pass, so no new tests).

---

## 8. Implementation notes for the next session (read before coding)

- **Conventions:** everything in `CLAUDE.md` applies — clean architecture per
  feature, `UseCase<Type, Params>` + dartz `Either`, the exception→Failure→error-
  mapper pipeline, `@injectable` blocs / `@lazySingleton` everything else, then
  `dart run build_runner build --delete-conflicting-outputs` (never hand-edit
  `injection.config.dart`). BlocProviders are wired in
  `lib/core/routes/app_router.dart`, not in page files. Sub-widgets get their own
  files under `presentation/widgets/`.
- **Read `lib/features/map/README.md` §6.0/§6.0b first** — the businesses layer is
  the reference pattern for the pins (marker factory rasterising circular images,
  progressive logo loading, `onMapIdle` refetch at 12 km, tap via
  `queryRenderedFeatures`, popup over a still-pannable map, NavigateButton).
- **Wire format is snake_case everywhere**, whatever casing the examples in this
  file's sources showed. Never rename existing JSON keys.
- **l10n:** every user-facing string goes in `lib/l10n/app_en.arb` + `app_ro.arb`
  (RO mirrors EN keys), then `flutter gen-l10n` (no CLI args — config in
  `l10n.yaml`).
- **Pagination:** the standard cursor-bloc shape (Initial/Loading/Loaded{items,
  nextCursor, isLoadingMore}/Error; opaque cursor echoed back).
- **Don't launch the app to verify** — the owner runs it themselves; verify with
  `flutter analyze` + tests.
- **When unsure, ask the owner — never assume.** The decisions in §5 are explicit
  product calls.
- Keep this file current: tick §6 checkboxes and append to §7 after each chunk.
