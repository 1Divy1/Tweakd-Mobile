// contest-data.jsx — Kinetic Edge
// Contests that run inside a car event. Mirrors the intended schema:
// car_event_contests (title, category, opens_at, closes_at, status, finished_by)
// car_event_contest_entries (contest_id, car_id, status)   ← owners opt in
// car_event_contest_votes (contest_id, car_id, voter_id)   ← one row per voter, updatable

const CONTEST_CATS = {
  exhaust:  { key: "exhaust",  label: "Best exhaust system", short: "EXHAUST",  icon: "exhaust" },
  wheels:   { key: "wheels",   label: "Best wheels",         short: "WHEELS",   icon: "wheels" },
  paint:    { key: "paint",    label: "Best paint / wrap",   short: "PAINT",    icon: "paint" },
  interior: { key: "interior", label: "Best interior",       short: "INTERIOR", icon: "interior" },
  loudest:  { key: "loudest",  label: "Loudest",             short: "LOUDEST",  icon: "loud" },
  custom:   { key: "custom",   label: "Custom category",     short: "CUSTOM",   icon: "trophy" }
};

// Fixed "now" so the mock reads consistently: the Casino Square meet is 3h in.
const CT_NOW = new Date("2026-08-11T21:12:00");

const e = (car, votes) => ({ car, votes });

const CONTESTS = [
  {
    id: "k1", event_id: "m1", cat: "exhaust", status: "live",
    title: "Best exhaust system",
    criteria: "Judged on note and build quality — walk the row, listen, then vote. One vote each, change it any time before it closes.",
    opens_at: "2026-08-11T18:30:00", closes_at: "2026-08-11T22:30:00",
    voters: 186, my_vote: "c2", my_entry: "c1",
    entries: [e("c2", 61), e("c1", 48), e("c5", 37), e("c3", 24), e("c6", 11), e("c4", 5)]
  },
  {
    id: "k2", event_id: "m1", cat: "wheels", status: "live",
    title: "Best wheels",
    criteria: "Fitment, finish, and whether they suit the car. Curb rash counts against you.",
    opens_at: "2026-08-11T18:30:00", closes_at: "2026-08-11T22:30:00",
    voters: 142, my_vote: null, my_entry: "c1",
    entries: [e("c4", 44), e("c1", 39), e("c2", 31), e("c6", 18), e("c3", 10)]
  },
  {
    id: "k3", event_id: "m1", cat: "loudest", status: "live",
    title: "Loudest",
    criteria: "Marshals do one rev per car at 22:00 on the ramp. Vote for the one that set off a car alarm.",
    opens_at: "2026-08-11T21:00:00", closes_at: "2026-08-11T21:45:00",
    voters: 58, my_vote: null, my_entry: null,
    entries: [e("c5", 22), e("c3", 19), e("c6", 12), e("c2", 5)]
  },
  {
    id: "k4", event_id: "m1", cat: "paint", status: "finished",
    title: "Best paint / wrap",
    criteria: "Depth, prep, and panel gaps under the terrace lights.",
    opens_at: "2026-08-11T18:30:00", closes_at: "2026-08-11T20:30:00",
    finished_at: "2026-08-11T20:30:00", finished_early: false,
    voters: 204, my_vote: "c6", my_entry: "c1",
    entries: [e("c1", 78), e("c6", 55), e("c2", 41), e("c4", 21), e("c3", 9)]
  },
  {
    id: "k5", event_id: "m1", cat: "custom", status: "scheduled",
    title: "Best daily driver",
    criteria: "Has to be insured, plated, and actually driven here. Odometer photo on the windscreen.",
    opens_at: "2026-08-11T22:00:00", closes_at: "2026-08-11T22:50:00",
    voters: 0, my_vote: null, my_entry: null,
    entries: [e("c1", 0), e("c4", 0), e("c6", 0)]
  },
  {
    id: "k6", event_id: "m1", cat: "interior", status: "scheduled",
    title: "Best interior",
    criteria: "Doors open, no phones on the seats. Retrims and stock-perfect cabins both count.",
    opens_at: "2026-08-11T22:00:00", closes_at: "2026-08-11T22:50:00",
    voters: 0, my_vote: null, my_entry: null,
    entries: [e("c2", 0), e("c3", 0), e("c5", 0), e("c6", 0)]
  },

  // Upcoming meet — contests announced ahead of time, entry opt-in open
  {
    id: "j1", event_id: "m2", cat: "interior", status: "scheduled",
    title: "Cleanest cabin",
    criteria: "JDM interiors only. Judged with the doors open at the ramp.",
    opens_at: "2026-08-16T09:30:00", closes_at: "2026-08-16T12:30:00",
    voters: 0, my_vote: null, my_entry: null,
    entries: [e("c7", 0), e("c9", 0)]
  },
  {
    id: "j2", event_id: "m2", cat: "wheels", status: "scheduled",
    title: "Best wheels",
    criteria: "Period-correct or modern, both welcome. Fitment over diameter.",
    opens_at: "2026-08-16T09:30:00", closes_at: "2026-08-16T12:30:00",
    voters: 0, my_vote: null, my_entry: null,
    entries: [e("c8", 0), e("c10", 0), e("c11", 0)]
  }
];

// ── helpers ────────────────────────────────────────────
const contestsByEvent = (eventId) => CONTESTS.filter((c) => c.event_id === eventId);
const contestById = (id) => CONTESTS.find((c) => c.id === id) || null;
const catOf = (c) => CONTEST_CATS[c.cat] || CONTEST_CATS.custom;

// resolve entry car ids against the event's participant list
function resolveEntries(contest) {
  const ev = window.EV.eventById(contest.event_id);
  return contest.entries
    .map((en) => {
      const car = ev.cars.find((c) => c.id === en.car);
      return car ? { ...en, ...car } : null;
    })
    .filter(Boolean);
}

function ranked(entries) {
  return [...entries].sort((a, b) => b.votes - a.votes || a.id.localeCompare(b.id));
}

const totalVotes = (entries) => entries.reduce((s, e2) => s + e2.votes, 0);

// "1h 18m left" / "closes in 4m" / "closed 20:30"
function fmtLeft(iso, now = CT_NOW) {
  const ms = new Date(iso) - now;
  if (ms <= 0) return "closed";
  const m = Math.round(ms / 60000);
  if (m < 60) return `${m}m left`;
  return `${Math.floor(m / 60)}h ${m % 60}m left`;
}
function fmtOpensIn(iso, now = CT_NOW) {
  const ms = new Date(iso) - now;
  const m = Math.max(1, Math.round(ms / 60000));
  return m < 60 ? `opens in ${m}m` : `opens in ${Math.floor(m / 60)}h ${m % 60}m`;
}
const isClosingSoon = (c) => c.status === "live" && new Date(c.closes_at) - CT_NOW < 60 * 60000;

// Badge earned by a winning car — sits on the car profile + the owner's profile
function winnerBadge(contest) {
  const ev = window.EV.eventById(contest.event_id);
  const top = ranked(resolveEntries(contest))[0];
  return {
    contest_id: contest.id,
    title: contest.title,
    short: catOf(contest).short,
    icon: catOf(contest).icon,
    event: ev.title,
    date: contest.finished_at || contest.closes_at,
    votes: top.votes,
    of: totalVotes(resolveEntries(contest)),
    car: top
  };
}

Object.assign(window, {
  KE_CONTESTS: CONTESTS,
  CT: {
    CATS: CONTEST_CATS, NOW: CT_NOW,
    contestsByEvent, contestById, catOf, resolveEntries, ranked, totalVotes,
    fmtLeft, fmtOpensIn, isClosingSoon, winnerBadge
  }
});
