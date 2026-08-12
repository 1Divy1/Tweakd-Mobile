# map_events

User-created events pinned to the virtual map — car meets today, more
categories later. Every new event goes to the **admin team for approval** before
it appears on the map for anyone else.

Backend: `${API_BASE_URL}/api/v1/map-events/*` (snake_case, JWT via
`AuthInterceptor`), plus one slot in the storage module for the cover image.
The admin review endpoints (`/api/v1/admin/map-events/*`) belong to the admin
web dashboard and are deliberately **not** consumed here.

> The full backend contract, the design record from the owner's screenshots and
> the phase checklist live in the repo-root **`MAP_EVENTS_PROGRESS.md`**.
> Backend gaps and open questions are in **`MAP_EVENTS_NOTES.md`**.

---

## 1. What a user can do

| Role | Actions |
|---|---|
| Anyone nearby | See the pin, open the preview popup, RSVP `attending` / `interested`, register a garage car for the entry list, navigate to it |
| Participant | Withdraw — a **request** organizers approve, not an instant removal |
| Organizer | Accept/decline car entries, review withdrawals, add/remove co-organizers, cancel / finish the event |
| Creator | Everything an organizer can, plus delete, and edit while the event is pending or rejected |

---

## 2. Where the pieces live

```
features/map_events/
├── domain/
│   ├── entities/          pin, event (+rules, organizers, viewer, car_meet),
│   │                      summary, attendee, participant, withdrawal request,
│   │                      category, organizer candidate, cursor page, enums
│   ├── failures/          not-found, forbidden, participation conflict, invalid input
│   ├── repositories/      MapEventsRepository — every endpoint in one interface
│   └── usecases/          grouped by concern (reads / manage / organizers /
│                          attendance / participation / withdrawals)
├── data/
│   ├── models/            snake_case fromJson → toEntity
│   ├── datasources/       MapEventsApiDataSource, MapEventStorageDataSource
│   └── repositories/      one `_guard` maps every exception → Failure
└── presentation/
    ├── bloc/              event_detail, create_event, my_events, attendees, manage_event
    ├── pages/             detail, attendees, create, pick-location, my events, manage
    ├── widgets/           shared/, detail/, create/, manage/, my_events/, popup/
    └── utils/             error mapper, date & distance formatting
```

The **map** feature owns the pin layer and hosts the popup; it imports this
feature's domain and the popup widget the same way `feed` imports `posts`.

---

## 3. The decisions that matter

### One bloc behind the popup *and* the page

`MapEventDetailBloc` backs both the map's preview card and `/map-events/:id`.
They look nothing alike but need the same data and the same actions, so RSVP,
car registration and withdrawal exist once. The map route provides it alongside
`MapBloc`; the detail route provides its own instance.

### Writes return the event — except the participation ones

`PUT`/`DELETE /attendance` answer with a fresh `MapEventDto`, so an RSVP is
optimistic-then-authoritative with no refetch. `POST /cars`, `DELETE
/cars/{id}` and `POST /withdraw` answer with participant rows (or 204), so
those **do** refetch to pick up the new counts and viewer flags.

### The viewer has no per-car status

`viewer.my_registered_car_ids` lists the caller's cars whatever their status,
with no status alongside. Working out which is which means cross-referencing
against `GET /{id}/cars` — and its `pending` / `rejected` slices are
**organizer-only**. So a participant's own pending request is unreadable on a
cold open. Anything unresolvable goes in `unresolvedRegisteredCarIds` and the UI
says "registration in progress" instead of guessing. `MAP_EVENTS_NOTES.md` §1.2
has the proposed fix.

### Withdrawal is one-way

`POST /withdraw` flags every accepted car as `withdrawn` and waits for an
organizer. There is **no endpoint to cancel it**, so nothing in the UI offers an
undo. Withdrawn cars stay publicly visible until an organizer approves (hard
delete) or rejects (back to accepted).

### The entry list queries `?status=accepted` explicitly

The unfiltered endpoint returns accepted **and** withdrawn rows together, which
is not the "N APPROVED" list the design asks for.

### Distances are computed on the client

`distance_km` was removed from `/map-events/nearby` (and `/businesses/nearby`).
Everything shown is a straight line from the centre the map queried around, via
`GeoPosition.distanceKmTo`, in **km**. Pin collision priority uses the same
number — see `MapLayerController`.

### 409s show the server's message

The backend distinguishes "event finished", "deadline passed" and "capacity
reached" only in prose. `MapEventParticipationConflictFailure` carries that
sentence through and the UI prints it verbatim rather than flattening three
causes into one vague string. (⚠️ those sentences are not localized.)

### Categories: live + hardcoded

`GET /categories` returns only what can actually be created (today:
`car_meet`). The greyed `SOON` chips for Track Day / Car Show / Cruise are
hardcoded in the create form, because there's nowhere else for them to come
from.

### Registration deadline is required for car meets

The design labels it OPTIONAL; the API rejects a car meet without one. The API
wins — the label reads REQUIRED and the CTA refuses to submit without it.

### Creating is a sequence, not a call

`POST /map-events` → presigned cover slot → `PUT` the WebP to R2 → `PATCH
/cover` → `POST /organizers` per queued co-organizer. Only the first step is
fatal: a cover that won't upload becomes a warning on the confirmation screen,
because discarding a created event over a failed photo would be strictly worse.

---

## 4. Map integration

`MapLayerController` (in the **map** feature) carries both pin layers on the
same machinery — a GeoJSON source plus a `SymbolLayer` whose `icon-image` comes
from a per-feature property, fed by rasterised circular markers from
`MapMarkerFactory`.

Event pins differ from business pins in two ways only:

- the image is the event's **cover photo**, not a logo;
- the ring turns **accent orange while the event is live**, so "happening now"
  reads at a glance. The ring colour is baked into the bitmap, so it's part of
  the style-image id (`map-event-cover-<id>-live`) — otherwise an event that
  goes live would keep its white-ringed image.

Events draw above businesses and win a tap that hits both. One map-wide
`TapInteraction` queries the event layer first, then the business layer, then
falls through to "dismiss".

Both layers are fetched on the same camera-settled trigger and **fail
independently**: one dead endpoint leaves the other's pins alone, and only a
failure of both raises the banner.

---

## 5. Entry points

| From | To |
|---|---|
| Map pin tap | Preview popup (RSVP, participate, navigate, VIEW EVENT) |
| Map's orange **+** | `/map-events/create` |
| Popup CTA | `/map-events/:id` |
| Own profile → **Events** tab | `GET /map-events/mine` (lazy, like the Tags tab) |
| Detail page → **Manage event** (organizers only) | `/map-events/:id/manage` |

The map's search bar ("Search meets, shops, cities…") is **pure UI** — an owner
call. It's a static row, not a disabled `TextField`, so it can't eat keystrokes
and look broken.

---

## 6. Testing

`test/features/map_events/map_event_models_test.dart` covers the JSON mapping,
the enum fallbacks and the instant round-trip — the parts most likely to break
silently, since a mistyped snake_case key yields a plausible entity full of
defaults rather than an error.
