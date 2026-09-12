// forums-data.jsx — Kinetic Edge · Forums
// Mock dataset shaped to the real data model: one shared pool of threads,
// each tagged with an optional car (brand/model) and one or more topics.
// Both browse lenses (by car / by topic) converge on the same threads.

// ─────────────────────────────────────────────────────────
// Brands & models
// ─────────────────────────────────────────────────────────
const BRANDS = [
  { name: "BMW",     mono: "BM", threads: 1240, models: ["M3", "M4", "M2", "M5", "1M", "Z4"] },
  { name: "Porsche", mono: "PO", threads: 980,  models: ["911 Turbo S", "911 GT3", "Cayman GT4", "718", "Taycan"] },
  { name: "Toyota",  mono: "TO", threads: 870,  models: ["Supra MK5", "Supra MK4", "GR86", "GR Yaris", "AE86"] },
  { name: "Nissan",  mono: "NI", threads: 760,  models: ["GT-R R35", "GT-R R34", "370Z", "Silvia S15"] },
  { name: "Mazda",   mono: "MA", threads: 540,  models: ["RX-7 FD", "MX-5 ND", "RX-8", "Mazda3"] },
  { name: "Audi",    mono: "AU", threads: 610,  models: ["RS6", "RS3", "R8", "TT RS"] },
  { name: "Honda",   mono: "HO", threads: 720,  models: ["Civic Type R", "S2000", "NSX", "Integra DC5"] },
  { name: "Subaru",  mono: "SU", threads: 430,  models: ["WRX STI", "Impreza 22B", "BRZ"] },
];

// ─────────────────────────────────────────────────────────
// Topics — grouped by kind (component / format)
// ─────────────────────────────────────────────────────────
const TOPICS_COMPONENT = [
  { name: "Engine",         threads: 3200 },
  { name: "Suspension",     threads: 2100 },
  { name: "Brakes",         threads: 1400 },
  { name: "Wheels & tyres", threads: 1850 },
  { name: "Exhaust",        threads: 1600 },
  { name: "Drivetrain",     threads: 980  },
  { name: "Electronics",    threads: 1120 },
  { name: "Interior",       threads: 740  },
  { name: "Exterior",       threads: 890  },
];
const TOPICS_FORMAT = [
  { name: "Tuning",         threads: 4100 },
  { name: "Project cars",   threads: 2600 },
  { name: "DIY & tools",    threads: 2200 },
  { name: "Detailing",      threads: 1300 },
  { name: "Buy / Sell",     threads: 3050 },
  { name: "Events & meets", threads: 1750 },
  { name: "Help",           threads: 2400 },
  { name: "General",        threads: 5200 },
];
const ALL_TOPICS = [...TOPICS_COMPONENT, ...TOPICS_FORMAT];

// ─────────────────────────────────────────────────────────
// Threads — the repeating unit. `age` = last_activity_at (human).
// ─────────────────────────────────────────────────────────
const THREADS = [
  {
    id: "t1", pinned: true,
    title: "DIY: replacing the charge pipe on the S58 — with torque specs & photos",
    body: "Did this over the weekend on my Comp. Full walkthrough below, took about 90 minutes with basic tools. The OEM pipe is a known failure point above stage 2…",
    author: { username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true },
    brand: "BMW", model: "M4", topics: ["DIY & tools", "Engine"],
    likes: 302, replies: 87, age: "20m",
  },
  {
    id: "t2",
    title: "M4 Comp — best coilover setup for daily comfort + occasional track?",
    body: "Running stock adaptive right now. Torn between KW V3 and MCS 2-way. Anyone daily a set of 2-ways without hating their life on the motorway?",
    author: { username: "torque_sasha", avatar: "assets/av-1.svg", verified: true },
    brand: "BMW", model: "M4", topics: ["Suspension", "Tuning"],
    likes: 128, replies: 43, age: "2h",
  },
  {
    id: "t3",
    title: "Stage 2 dyno results — 612 whp on pump, full graph inside",
    body: "MHD stage 2 + downpipes + intake. Cool day, corrected numbers. Spool is genuinely violent now.",
    author: { username: "kenji_apex", avatar: "assets/av-4.svg", verified: true },
    brand: "BMW", model: "M4", topics: ["Tuning", "Engine"],
    likes: 210, replies: 56, age: "5h",
  },
  {
    id: "t4", locked: true,
    title: "OEM++ vs aftermarket exhaust — the definitive sound clip thread",
    body: "Locked after 400 replies — please post new clips in the weekly thread. Archive of every M4 exhaust we could find below.",
    author: { username: "noctis_nico", avatar: "assets/av-6.svg" },
    brand: "BMW", model: "M4", topics: ["Exhaust"],
    likes: 540, replies: 402, age: "1d",
  },
  {
    id: "t5",
    title: "911 Turbo S — is the PDK worth the tune before warranty runs out?",
    body: "Thinking about a TCU flash. Curious what everyone's launch numbers look like after.",
    author: { username: "vroom_valeria", avatar: "assets/av-2.svg" },
    brand: "Porsche", model: "911 Turbo S", topics: ["Tuning", "Drivetrain"],
    likes: 96, replies: 31, age: "3h",
  },
  {
    id: "t6",
    title: "Supra MK5 single-turbo builds — who's actually daily-driving one?",
    body: "Planning a full single-turbo swap over winter. Reliability stories welcome, horror stories more welcome.",
    author: { username: "jdm_jules", avatar: "assets/av-2.svg", verified: true },
    brand: "Toyota", model: "Supra MK5", topics: ["Tuning", "Project cars"],
    likes: 174, replies: 62, age: "6h",
  },
  {
    id: "t7",
    title: "GT-R R34 — sourcing genuine Brembos in 2026 without getting scammed",
    body: "Prices are insane and fakes are everywhere. Sharing the vendors I've verified so far.",
    author: { username: "kenji_apex", avatar: "assets/av-4.svg", verified: true },
    brand: "Nissan", model: "GT-R R34", topics: ["Brakes", "Buy / Sell"],
    likes: 143, replies: 38, age: "9h",
  },
  {
    id: "t8",
    title: "The ceramic coating megathread — 12-month durability check-ins",
    body: "Post your product, prep, and how it's holding up. Trying to build a real longevity table across brands.",
    author: { username: "turbo_tess", avatar: "assets/av-7.svg" },
    brand: null, model: null, topics: ["Detailing", "General"],
    likes: 288, replies: 121, age: "4h",
  },
  {
    id: "t9",
    title: "RX-7 FD — which fuel system for a reliable 400hp street setup?",
    body: "Rebuilding the whole fuel system. Want to leave rotary anxiety behind for good.",
    author: { username: "low_n_slow_leo", avatar: "assets/av-3.svg" },
    brand: "Mazda", model: "RX-7 FD", topics: ["Engine", "Help"],
    likes: 88, replies: 29, age: "11h",
  },
  {
    id: "t10",
    title: "Coilover buyer's guide 2026 — every major brand ranked by tier",
    body: "Cross-brand write-up. Budget, mid, and money-no-object picks with the trade-offs of each.",
    author: { username: "rallyrider_rae", avatar: "assets/av-5.svg" },
    brand: null, model: null, topics: ["Suspension", "Tuning"],
    likes: 361, replies: 94, age: "7h",
  },
  {
    id: "t11",
    title: "WRX STI — retrofitting Apple CarPlay into the old head unit",
    body: "Full electronics writeup with the harness part numbers. No cut wires.",
    author: { username: "rallyrider_rae", avatar: "assets/av-5.svg" },
    brand: "Subaru", model: "WRX STI", topics: ["Electronics", "DIY & tools"],
    likes: 74, replies: 22, age: "14h",
  },
  {
    id: "t12",
    title: "Civic Type R FL5 — square wheel setup for track, tyre recs?",
    body: "Going 18x10 square. What's actually clearing without rubbing on stock arches?",
    author: { username: "macro_mark", avatar: "assets/av-1.svg" },
    brand: "Honda", model: "Civic Type R", topics: ["Wheels & tyres", "Tuning"],
    likes: 112, replies: 47, age: "1d",
  },
];

// ─────────────────────────────────────────────────────────
// Saved shortcuts (forum_shortcuts) — pinned filters on the home screen.
// unread = new activity since last visit.
// ─────────────────────────────────────────────────────────
const SHORTCUTS = [
  { id: "s1", name: "BMW M4",            brand: "BMW",    model: "M4",             topic: null,        unread: 12, notify: true },
  { id: "s2", name: "Tuning",           brand: null,     model: null,             topic: "Tuning",    unread: 34, notify: true },
  { id: "s3", name: "911 Turbo S",      brand: "Porsche",model: "911 Turbo S",    topic: null,        unread: 3,  notify: false },
  { id: "s4", name: "M4 · Suspension",  brand: "BMW",    model: "M4",             topic: "Suspension",unread: 0,  notify: false },
  { id: "s5", name: "Detailing",        brand: null,     model: null,             topic: "Detailing", unread: 8,  notify: true },
];

// Popular hubs suggested to brand-new users (cold start).
const POPULAR_HUBS = [
  { name: "Tuning",      kind: "topic", meta: "4.1k threads" },
  { name: "BMW M4",      kind: "car",   meta: "1.2k threads" },
  { name: "Project cars",kind: "topic", meta: "2.6k threads" },
  { name: "Supra MK5",   kind: "car",   meta: "540 threads" },
  { name: "Detailing",   kind: "topic", meta: "1.3k threads" },
  { name: "GT-R R34",    kind: "car",   meta: "480 threads" },
];

// ─────────────────────────────────────────────────────────
// Reply tree for the detail screen (forum_posts, Reddit-style nesting).
// ─────────────────────────────────────────────────────────
const REPLY_TREE = [
  {
    id: "r1", author: { username: "kenji_apex", avatar: "assets/av-4.svg", verified: true },
    age: "18m", likes: 42, content: "This is the writeup I wish I had 6 months ago. Did mine blind and cracked the OEM pipe within a week of stage 2. The billet one has been flawless since.",
    children: [
      {
        id: "r2", author: { username: "torque_sasha", avatar: "assets/av-1.svg", verified: true },
        age: "12m", likes: 15, content: "Which billet pipe did you land on? There are three that look identical and one of them is garbage.",
        children: [
          {
            id: "r3", author: { username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true },
            age: "9m", likes: 21, content: "The one with the reinforced coupler — part number's in the last photo. Avoid the raw aluminium one, the flange warps.",
            children: [],
          },
        ],
      },
      {
        id: "r4", author: { username: "[deleted]", avatar: null }, deleted: true,
        age: "8m", likes: 0, content: "",
        children: [
          {
            id: "r5", author: { username: "low_n_slow_leo", avatar: "assets/av-3.svg" },
            age: "6m", likes: 4, content: "For anyone finding this later — the torque spec they're replying about is 8Nm on the clamp, not 12. Over-torqued mine and split the coupler.",
            children: [],
          },
        ],
      },
    ],
  },
  {
    id: "r6", author: { username: "turbo_tess", avatar: "assets/av-7.svg" },
    age: "34m", likes: 9, content: "Saving this. Booked the same job at an indie for £400 labour — now I'm doing it myself for the cost of the pipe. Thank you.",
    children: [],
  },
];

Object.assign(window, {
  FORUM_BRANDS: BRANDS,
  FORUM_TOPICS_COMPONENT: TOPICS_COMPONENT,
  FORUM_TOPICS_FORMAT: TOPICS_FORMAT,
  FORUM_ALL_TOPICS: ALL_TOPICS,
  FORUM_THREADS: THREADS,
  FORUM_SHORTCUTS: SHORTCUTS,
  FORUM_POPULAR_HUBS: POPULAR_HUBS,
  FORUM_REPLY_TREE: REPLY_TREE,
});
