// event-data.jsx — Kinetic Edge
// Shared car-meet dataset + helpers. Mirrors the Supabase schema:
// car_events (+ event_car_meet.registration_deadline), car_event_organizers,
// car_event_attendees_list, car_event_participants.

const KEV_KE = window.KE;

const STATUS_META = {
  live: { id: "live", label: "LIVE NOW", tone: "accent", verb: "Happening now" },
  upcoming: { id: "upcoming", label: "UPCOMING", tone: "ink", verb: "Starts" },
  previous: { id: "previous", label: "ENDED", tone: "mute", verb: "Ended" }
};

const D = (s) => new Date(s);
const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function fmtTime(d) {
  return String(d.getHours()).padStart(2, "0") + ":" + String(d.getMinutes()).padStart(2, "0");
}
function fmtDay(d) {
  return `${DAYS[d.getDay()]}, ${d.getDate()} ${MONTHS[d.getMonth()]}`;
}
// "Sat, 15 Aug · 18:00 – 23:00"  /  no ends_at → "Sat, 15 Aug · from 18:00"
function fmtRange(startsAt, endsAt) {
  const s = D(startsAt);
  if (!endsAt) return `${fmtDay(s)} · from ${fmtTime(s)}`;
  const e = D(endsAt);
  const sameDay = s.toDateString() === e.toDateString();
  return sameDay ?
  `${fmtDay(s)} · ${fmtTime(s)} – ${fmtTime(e)}` :
  `${fmtDay(s)} ${fmtTime(s)} – ${fmtDay(e)} ${fmtTime(e)}`;
}
// short form for the widget / list rows
function fmtShort(ev) {
  const s = D(ev.starts_at);
  if (ev.status === "live") return ev.ends_at ? `Until ${fmtTime(D(ev.ends_at))}` : "Happening now";
  if (ev.status === "previous") return `${fmtDay(s)} · ended`;
  return `${fmtDay(s)} · ${fmtTime(s)}`;
}
function fmtDeadline(iso) {
  const d = D(iso);
  return `${fmtDay(d)}, ${fmtTime(d)}`;
}
function fmtCount(n) {
  if (n >= 1000) return (n % 1000 === 0 ? n / 1000 : (n / 1000).toFixed(1)) + "k";
  return String(n);
}

const AV = (n) => `assets/av-${n}.svg`;
const CARPIC = (n) => typeof n === "string" ? `assets/${n}` : `assets/car-${n}.png`;

// participant rows: car_event_participants joined to cars/profiles
const car = (id, year, brand, model, pic, handle, av, status) => ({
  id, year, brand, model, photo: CARPIC(pic),
  owner: { handle, avatar: AV(av) }, status: status || "accepted"
});

const EVENTS = [
{
  id: "m1", city: "monaco", x: 40, y: 38,
  event_type: "car_meet", status: "live",
  title: "Casino Square Cars & Coffee",
  description:
  "Monthly evening gathering on the Casino terrace. Bring the car, park where the marshals point you, stay for coffee. Everything welcome — from a clean daily to a full build.",
  location_name: "Place du Casino",
  address: "Place du Casino, 98000 Monaco",
  distance: "0.4 mi",
  starts_at: "2026-08-11T18:00:00",
  ends_at: "2026-08-11T23:00:00",
  cover: CARPIC(2),
  attendees_count: 247, attending_cars_count: 34,
  requires_participant_approval: true,
  registration_deadline: "2026-08-10T20:00:00",
  organizers: [
  { kind: "profile", name: "Sasha Petrov", handle: "torque_sasha", avatar: AV(1), verified: false },
  { kind: "business", name: "Apex Detailing Studio", handle: "apexdetailing", avatar: CARPIC(3), verified: true, business_type: "Detailing" }],

  attendees: [AV(1), AV(2), AV(3), AV(4), AV(5), AV(6), AV(7)],
  rules: [
  "Park where the marshals point you — no double parking on the terrace.",
  "No revving or burnouts. One noise complaint ends the meet.",
  "Leave the square as you found it."],

  my_attendance: "attending",
  my_participation: { status: "accepted", car: "BMW M4 Competition" },
  cars: [
  car("c1", 2023, "BMW", "M4 Competition", "car-m5.webp", "torque_sasha", 1),
  car("c2", 2021, "Porsche", "911 GT3", 3, "noctis_nico", 6),
  car("c3", 1994, "Toyota", "Supra MK4", 4, "jdm_jules", 2),
  car("c4", 2020, "Audi", "RS6 Avant", "car-rsq8.webp", "kenji_apex", 4),
  car("c5", 2018, "Nissan", "GT-R Nismo", 3, "turbo_tess", 7),
  car("c6", 2022, "Mercedes-AMG", "GT 63 S", "car-g63.jpg", "macro_mark", 3)]

},
{
  id: "m2", city: "monaco", x: 27, y: 60,
  event_type: "car_meet", status: "upcoming",
  title: "Sunday JDM Linkup",
  description:
  "Japanese metal only. Static show in the port car park, coffee from the corner van, prize for the cleanest engine bay voted by the room.",
  location_name: "Port Hercule — Level 2",
  address: "Quai Antoine 1er, 98000 Monaco",
  distance: "2.3 mi",
  starts_at: "2026-08-16T09:00:00",
  ends_at: "2026-08-16T13:00:00",
  cover: CARPIC(4),
  attendees_count: 112, attending_cars_count: 21,
  requires_participant_approval: true,
  registration_deadline: "2026-08-14T23:59:00",
  organizers: [
  { kind: "profile", name: "Jules Marchand", handle: "jdm_jules", avatar: AV(2), verified: true }],

  attendees: [AV(2), AV(4), AV(5), AV(1), AV(7), AV(3)],
  rules: [
  "JDM only — everything else gets turned away at the ramp.",
  "Arrive before 09:30, the ramp closes after that.",
  "Registration closes 48h before the meet."],

  my_attendance: "interested",
  my_participation: null,
  cars: [
  car("c7", 1999, "Nissan", "Skyline R34 GT-R", 3, "jdm_jules", 2),
  car("c8", 1994, "Mazda", "RX-7 FD", 4, "kenji_apex", 4),
  car("c9", 2002, "Subaru", "Impreza WRX STI", 2, "turbo_tess", 7),
  car("c10", 1992, "Honda", "NSX", 1, "macro_mark", 3),
  car("c11", 1997, "Toyota", "Chaser JZX100", 4, "vroom_valeria", 5)]

},
{
  id: "m3", city: "monaco", x: 70, y: 30,
  event_type: "car_meet", status: "previous",
  title: "Hillclimb Breakfast Meet",
  description:
  "Early start above the city, croissants at the top, convoy back down the old rally road. Ran clean — see you next month.",
  location_name: "La Turbie viewpoint",
  address: "Route de la Turbie, 06320 La Turbie",
  distance: "3.0 mi",
  starts_at: "2026-08-02T07:30:00",
  ends_at: "2026-08-02T11:00:00",
  cover: CARPIC(1),
  attendees_count: 64, attending_cars_count: 19,
  requires_participant_approval: false,
  registration_deadline: "2026-08-01T12:00:00",
  organizers: [
  { kind: "profile", name: "Nico Berger", handle: "noctis_nico", avatar: AV(6), verified: false }],

  attendees: [AV(6), AV(3), AV(1), AV(5)],
  rules: ["Convoy discipline on the descent — no overtaking inside the group."],
  gallery: [CARPIC(1), CARPIC(3), CARPIC(2), CARPIC(4), CARPIC(1), CARPIC(3)],
  my_attendance: null,
  my_participation: null,
  cars: [
  car("c12", 2021, "Porsche", "718 Cayman GT4", 3, "noctis_nico", 6),
  car("c13", 2016, "Ford", "Mustang GT", 2, "macro_mark", 3),
  car("c14", 2019, "Alpine", "A110", 4, "vroom_valeria", 5),
  car("c15", 2023, "BMW", "M4 Competition", 1, "torque_sasha", 1)]

},
{
  id: "l1", city: "london", x: 45, y: 45,
  event_type: "car_meet", status: "live",
  title: "Ace Café Late Linkup",
  description: "The usual late one. Roll in, park up, keep it civil on the North Circular.",
  location_name: "Ace Café London",
  address: "Ace Corner, Old N Circular Rd, London",
  distance: "0.9 mi",
  starts_at: "2026-08-11T20:00:00",
  ends_at: "2026-08-12T00:30:00",
  cover: CARPIC(1),
  attendees_count: 389, attending_cars_count: 58,
  requires_participant_approval: false,
  registration_deadline: "2026-08-11T18:00:00",
  organizers: [{ kind: "profile", name: "Tess Okonkwo", handle: "turbo_tess", avatar: AV(7), verified: true }],
  attendees: [AV(7), AV(1), AV(2), AV(3), AV(4)],
  rules: ["No revving in the car park after 22:00."],
  my_attendance: null, my_participation: null,
  cars: [
  car("c16", 2018, "Nissan", "GT-R Nismo", 3, "turbo_tess", 7),
  car("c17", 2020, "Audi", "RS6 Avant", 2, "kenji_apex", 4),
  car("c18", 1994, "Toyota", "Supra MK4", 4, "jdm_jules", 2)]

},
{
  id: "l2", city: "london", x: 64, y: 38,
  event_type: "car_meet", status: "upcoming",
  title: "Shoreditch Coffee Run",
  description: "Sunday morning roll-out through the City, coffee stop at the end. Slow pace, all builds welcome.",
  location_name: "Shoreditch High St",
  address: "Shoreditch High St, London E1",
  distance: "2.1 mi",
  starts_at: "2026-08-16T08:00:00",
  ends_at: null,
  cover: CARPIC(3),
  attendees_count: 156, attending_cars_count: 27,
  requires_participant_approval: true,
  registration_deadline: "2026-08-15T20:00:00",
  organizers: [{ kind: "profile", name: "Mark Ellis", handle: "macro_mark", avatar: AV(3), verified: false }],
  attendees: [AV(3), AV(5), AV(2), AV(6)],
  rules: ["Keep the convoy tight through the City.", "Meet point closes at 08:15."],
  my_attendance: null, my_participation: null,
  cars: [
  car("c19", 2022, "Mercedes-AMG", "GT 63 S", 1, "macro_mark", 3),
  car("c20", 2019, "Alpine", "A110", 4, "vroom_valeria", 5)]

}];


const eventById = (id) => EVENTS.find((e) => e.id === id) || null;
const eventsByCity = (city) => EVENTS.filter((e) => e.city === city);

// The current user's own garage — offered when requesting to bring a car to a meet.
const MY_GARAGE = [
  { id: "g1", year: 2023, brand: "BMW", model: "M4 Competition", photo: CARPIC(1) },
  { id: "g2", year: 2021, brand: "Porsche", model: "911 GT3", photo: CARPIC(3) },
  { id: "g3", year: 1994, brand: "Toyota", model: "Supra MK4", photo: CARPIC(4) }
];

Object.assign(window, {
  KE_EVENTS: EVENTS,
  EV: { STATUS_META, fmtRange, fmtShort, fmtTime, fmtDay, fmtDeadline, fmtCount, eventById, eventsByCity, MY_GARAGE }
});
