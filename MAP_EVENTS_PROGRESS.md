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
**Last updated:** 2026-08-12

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

- **2026-08-12** — Round 3 answers folded in: rules are `{id, rule, sort_order}`
  objects in responses / plain strings (≤50 × ≤300 chars) in PUT; DELETE
  /cars/{car_id} is pending-only; withdrawal is one-way (no self-cancel) and
  withdrawn rows are public (`?status=withdrawn` valid; default list = accepted +
  withdrawn, so the entry list queries accepted explicitly); viewer per-car status
  via cross-reference; distance computed client-side in km; starts_at confirmed in
  MapEventDto. **All open questions resolved — implementation can start.** No code yet.

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
