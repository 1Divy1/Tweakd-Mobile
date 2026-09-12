// Profile screen — Kinetic Edge
// Minimalist: warm-neutral white surfaces, near-black ink, orange used sparingly.
// Instagram-style profile: tab switcher between Posts (grid) and Garage.

const { useState } = React;
const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Chrome
// ─────────────────────────────────────────────────────────
function TopBar() {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface,
      }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink,
      }}>PROFILE</div>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface,
      }}>
        <svg width="16" height="4" viewBox="0 0 16 4">
          <circle cx="2" cy="2" r="1.5" fill={KE.ink}/>
          <circle cx="8" cy="2" r="1.5" fill={KE.ink}/>
          <circle cx="14" cy="2" r="1.5" fill={KE.ink}/>
        </svg>
      </div>
    </div>
  );
}

function TabBar({ active = "PROFILE" }) {
  const tabs = [
    { k: "FEED",     icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/></svg> },
    { k: "MAP",      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "REELS",    href: "Reels Page.html", icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
    { k: "CONTESTS", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { k: "PROFILE",  icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0",
      background: KE.surface, borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center",
    }}>
      {tabs.map((t) => {
        const on = t.k === active;
        return (
          <div key={t.k} onClick={() => t.href && window.location.assign(t.href)} style={{
            display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
            cursor: t.href ? "pointer" : "default",
            color: on ? KE.ink : KE.muteSoft,
          }}>
            {t.icon}
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1 }}>{t.k}</span>
            {on && <div style={{ width: 16, height: 2, borderRadius: 2, background: KE.ink, marginTop: 2 }}/>}
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Car cards — pure white, hairline borders, no shadows
// ─────────────────────────────────────────────────────────
function CarCardA({ make, model, image, hp, year, primary }) {
  // Magazine card
  return (
    <div style={{
      borderRadius: 16, background: KE.surface, border: `1px solid ${KE.line}`,
      overflow: "hidden",
    }}>
      <div style={{
        position: "relative", height: 170, background: KE.bgSoft,
        display: "grid", placeItems: "center",
      }}>
        <img src={image} style={{ width: "108%", height: "100%", objectFit: "contain", marginTop: 8 }}/>
        {primary && (
          <div style={{
            position: "absolute", top: 12, left: 12,
            padding: "4px 8px", borderRadius: 999, background: KE.ink, color: KE.surface,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2,
          }}>DAILY DRIVE</div>
        )}
        <div style={{
          position: "absolute", top: 12, right: 12,
          padding: "4px 8px", borderRadius: 999,
          background: KE.surface, border: `1px solid ${KE.line}`, color: KE.ink,
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 0.8,
        }}>{hp} HP</div>
      </div>
      <div style={{ padding: "14px 16px 16px", borderTop: `1px solid ${KE.line}` }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontSize: 10, letterSpacing: 1.2, color: KE.mute, fontWeight: 700 }}>{year}</div>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginTop: 2 }}>
          <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 18, color: KE.ink, letterSpacing: -0.3 }}>
            {make} {model}
          </div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/></svg>
        </div>
      </div>
    </div>
  );
}

function CarCardB({ make, model, image, hp, year, primary }) {
  // Inset frame — full-width image box + name pill below
  return (
    <div style={{
      borderRadius: 22, background: KE.surface, border: `1px solid ${KE.line}`,
      padding: 12, display: "flex", flexDirection: "column", gap: 10,
    }}>
      {/* ── Image in its own rounded box — covers full width ── */}
      <div style={{
        borderRadius: 14, background: KE.bgSoft, height: 172,
        position: "relative", overflow: "hidden", border: `1px solid ${KE.line}`,
        flexShrink: 0,
      }}>
        <img src={image} style={{
          position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        }}/>
        {primary && (
          <div style={{
            position: "absolute", top: 10, left: 10,
            padding: "4px 9px", borderRadius: 7, background: KE.ink, color: KE.surface,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2,
          }}>PRIMARY</div>
        )}
      </div>

      {/* ── Car name pill ── */}
      <div style={{
        borderRadius: 12, background: KE.bgSoft, border: `1px solid ${KE.line}`,
        padding: "12px 16px",
        display: "flex", justifyContent: "space-between", alignItems: "center",
      }}>
        <div style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15,
          letterSpacing: 0.2, color: KE.ink,
        }}>
          {make} {model}
        </div>
        <div style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
          letterSpacing: 1, color: KE.mute,
        }}>{hp} HP</div>
      </div>
    </div>
  );
}

function CarCardC({ make, model, image, hp, year, primary }) {
  // Trading card (grid)
  return (
    <div style={{
      borderRadius: 14, overflow: "hidden", background: KE.surface,
      border: `1px solid ${KE.line}`,
    }}>
      <div style={{ height: 130, position: "relative", background: KE.bgSoft }}>
        <img src={image} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "contain" }}/>
        {primary && (
          <div style={{
            position: "absolute", top: 8, right: 8, width: 22, height: 22, borderRadius: 999,
            background: KE.accent, display: "grid", placeItems: "center",
          }}>
            <svg width="11" height="11" viewBox="0 0 24 24" fill={KE.onAccent}>
              <path d="M12 2l3 7h7l-5.5 4.5L18.5 21 12 16.5 5.5 21l2-7.5L2 9h7z"/>
            </svg>
          </div>
        )}
      </div>
      <div style={{ padding: "10px 12px 12px", borderTop: `1px solid ${KE.line}` }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.mute }}>{year}</div>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, color: KE.ink, marginTop: 2, letterSpacing: -0.2 }}>
          {make} {model}
        </div>
        <div style={{
          marginTop: 8, display: "flex", justifyContent: "space-between", alignItems: "center",
          paddingTop: 8, borderTop: `1px dashed ${KE.line}`,
        }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1, color: KE.ink }}>{hp} HP</span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/></svg>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Posts — Instagram-style grid tile (first image only, rounded)
// ─────────────────────────────────────────────────────────
function PostCard({ image, count = 1, perRow = 2 }) {
  const radius = perRow === 3 ? 12 : 16;
  return (
    <div style={{
      position: "relative", borderRadius: radius, overflow: "hidden",
      aspectRatio: "1 / 1", background: KE.bgSoft, border: `1px solid ${KE.line}`,
    }}>
      <img src={image} style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
      }}/>
      {count > 1 && (
        <div style={{
          position: "absolute", top: 8, right: 8,
          width: 22, height: 22, borderRadius: 7,
          background: "rgba(10,10,10,0.55)", backdropFilter: "blur(4px)",
          display: "grid", placeItems: "center",
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
            <rect x="7" y="3" width="14" height="14" rx="2.5" stroke="#fff" strokeWidth="2"/>
            <path d="M4 7v12a2 2 0 002 2h12" stroke="#fff" strokeWidth="2" strokeLinecap="round"/>
          </svg>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Tab switcher — Posts | Garage (only one section visible)
// ─────────────────────────────────────────────────────────
function ProfileTabs({ tab, onChange }) {
  const items = [
    { k: "posts", label: "POSTS", icon: (c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="2" stroke={c} strokeWidth="2"/><path d="M9 3v18M15 3v18M3 9h18M3 15h18" stroke={c} strokeWidth="2"/></svg>
    ) },
    { k: "garage", label: "GARAGE", icon: (c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 10l9-6 9 6v10H3V10z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M7 20v-6h10v6M7 16h10" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>
    ) },
    { k: "tags", label: "TAGS", icon: (c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M11.5 3H19a2 2 0 012 2v7.5a2 2 0 01-.6 1.4l-8 8a2 2 0 01-2.8 0l-6.5-6.5a2 2 0 010-2.8l8-8A2 2 0 0111.5 3z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><circle cx="15.5" cy="7.5" r="1.4" fill={c}/></svg>
    ) },
    { k: "service", label: "SERVICE", icon: (c) => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M5 4h11a2 2 0 012 2v14H7a2 2 0 01-2-2V4z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M5 18a2 2 0 002 2h11" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M9.5 9.5l1.6 1.6 3-3" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
    ) },
  ];
  return (
    <div style={{
      display: "flex", borderTop: `1px solid ${KE.line}`, borderBottom: `1px solid ${KE.line}`,
      background: KE.bg,
    }}>
      {items.map((it) => {
        const on = tab === it.k;
        const c = on ? KE.ink : KE.muteSoft;
        return (
          <button key={it.k} onClick={() => onChange(it.k)} style={{
            flex: 1, height: 48, border: "none", background: "transparent", cursor: "pointer",
            position: "relative",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 5,
          }}>
            {it.icon(c)}
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1, color: c }}>{it.label}</span>
            {on && <div style={{ position: "absolute", left: 0, right: 0, bottom: -1, height: 2, background: KE.ink }}/>}
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Tags tab — where the user (or one of their cars) got tagged:
// threads, thread replies, posts, and post comments.
// ─────────────────────────────────────────────────────────
const TAG_TYPE_META = {
  thread:        { label: "THREAD",  icon: (c) => <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><path d="M4 5h13a2 2 0 012 2v6a2 2 0 01-2 2H9l-4 3v-3H4a1 1 0 01-1-1V6a1 1 0 011-1z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg> },
  thread_reply:  { label: "THREAD REPLY", icon: (c) => <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><path d="M9 10L4 15l5 5M4 15h11a4 4 0 004-4V7" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
  post:          { label: "POST", icon: (c) => <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="3" stroke={c} strokeWidth="2"/><circle cx="8.5" cy="8.5" r="1.4" fill={c}/><path d="M21 15.5l-5.5-5-9 8.5" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg> },
  post_comment:  { label: "POST COMMENT", icon: (c) => <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg> },
};

function TagRow({ type, by, avatar, car, excerpt, time, href }) {
  const meta = TAG_TYPE_META[type];
  const verb = type === "thread" ? "tagged your" : type === "thread_reply" ? "tagged your" : type === "post" ? "tagged your" : "tagged your";
  const place = type === "thread" ? "in a thread" : type === "thread_reply" ? "in a thread reply" : type === "post" ? "in a post" : "in a post comment";
  return (
    <div onClick={() => href && window.location.assign(href)} style={{
      display: "flex", alignItems: "flex-start", gap: 12, padding: 14, borderRadius: 16,
      background: KE.surface, border: `1px solid ${KE.line}`, cursor: href ? "pointer" : "default",
    }}>
      <div style={{ position: "relative", width: 48, height: 48, flexShrink: 0 }}>
        <div style={{ width: 48, height: 48, borderRadius: 12, overflow: "hidden", background: KE.bgSoft, border: `1px solid ${KE.line}` }}>
          <img src={car.image} style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
        </div>
        <div style={{
          position: "absolute", right: -5, bottom: -5, width: 20, height: 20, borderRadius: 999,
          background: KE.surface, border: `1px solid ${KE.line}`, display: "grid", placeItems: "center",
        }}>
          {meta.icon(KE.ink2)}
        </div>
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_BODY, fontSize: 13, color: KE.ink2, lineHeight: 1.45 }}>
          <span style={{ fontWeight: 700, color: KE.ink }}>@{by}</span> {verb}{" "}
          <span style={{ fontWeight: 700, color: KE.ink }}>{car.make} {car.model}</span> {place}
        </div>
        <div style={{
          marginTop: 6, fontFamily: FONT_BODY, fontSize: 12.5, fontStyle: "italic", color: KE.mute,
          overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap",
        }}>"{excerpt}"</div>
        <div style={{ marginTop: 8, display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.muteSoft }}>{meta.label}</span>
          <div style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }}/>
          <span style={{ fontFamily: FONT_BODY, fontSize: 11, color: KE.muteSoft }}>{time}</span>
        </div>
      </div>

      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0, marginTop: 4 }}><path d="M9 6l6 6-6 6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/></svg>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Service tab — per-car list, each row opens that car's service book
// ─────────────────────────────────────────────────────────
function ServiceCarRow({ make, model, year, image, plate, statusText, statusTone }) {
  const tone = { ok: "#1F8A5B", warn: KE.accent, over: "#D93A26" }[statusTone];
  return (
    <div onClick={() => window.location.assign("Service Book.html")} style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: 12, borderRadius: 16, background: KE.surface, border: `1px solid ${KE.line}`, cursor: "pointer",
    }}>
      <div style={{
        width: 62, height: 50, borderRadius: 11, overflow: "hidden", background: KE.bgSoft,
        border: `1px solid ${KE.line}`, flexShrink: 0,
      }}>
        <img src={image} style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.3, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{make} {model}</span>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.mute, flexShrink: 0 }}>{year}</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 5 }}>
          <div style={{ width: 6, height: 6, borderRadius: 999, background: tone, flexShrink: 0 }}/>
          <span style={{ fontFamily: FONT_BODY, fontSize: 12, fontWeight: 600, color: tone }}>{statusText}</span>
        </div>
      </div>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/></svg>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Profile screen
// ─────────────────────────────────────────────────────────
function ProfileScreen({ postsPerRow = 2, screenHeight = 844 }) {
  const [tab, setTab] = useState("posts");

  const posts = [
    { image: "assets/car-2.png", count: 3 },
    { image: "assets/car-3.png", count: 1 },
    { image: "assets/car-1.png", count: 4 },
    { image: "assets/car-4.png", count: 2 },
    { image: "assets/car-2.png", count: 1 },
    { image: "assets/car-1.png", count: 5 },
    { image: "assets/car-3.png", count: 1 },
    { image: "assets/car-4.png", count: 2 },
    { image: "assets/car-2.png", count: 1 },
  ];

  const cars = [
    { make: "BMW",     model: "M4",         year: "2024", hp: 503, image: "assets/car-2.png", primary: true },
    { make: "PORSCHE", model: "911 GT3",    year: "2022", hp: 502, image: "assets/car-3.png" },
    { make: "TOYOTA",  model: "GR SUPRA",   year: "2023", hp: 382, image: "assets/car-4.png" },
    { make: "NISSAN",  model: "SKYLINE R34",year: "2001", hp: 280, image: "assets/car-1.png" },
    { make: "HONDA",   model: "NSX TYPE R", year: "2002", hp: 290, image: "assets/car-3.png" },
    { make: "AUDI",    model: "RS6 AVANT",  year: "2024", hp: 591, image: "assets/car-4.png" },
  ];

  const tags = [
    { type: "post_comment", by: "jdm_jules",     avatar: "assets/av-2.svg", car: { make: "BMW",     model: "M4",          image: "assets/car-2.png" }, excerpt: "That red interior is unreal 🔥", time: "1h",  href: "Feed Page.html" },
    { type: "post",         by: "torque_sasha",   avatar: "assets/av-1.svg", car: { make: "BMW",     model: "M4",          image: "assets/car-2.png" }, excerpt: "Golden hour by the marina with the Comp.", time: "5h",  href: "Feed Page.html" },
    { type: "thread",       by: "kenji_apex",     avatar: "assets/av-4.svg", car: { make: "BMW",     model: "M4",          image: "assets/car-2.png" }, excerpt: "Stage 2 dyno results — 612 whp on pump", time: "20h", href: "Forums.html" },
    { type: "thread_reply", by: "torque_sasha",   avatar: "assets/av-1.svg", car: { make: "PORSCHE", model: "911 GT3",    image: "assets/car-3.png" }, excerpt: "Anyone daily a set of 2-ways without hating their life?", time: "1d", href: "Forums.html" },
    { type: "post",         by: "vroom_valeria",  avatar: "assets/av-2.svg", car: { make: "PORSCHE", model: "911 GT3",    image: "assets/car-3.png" }, excerpt: "Track day lineup, GT3 held its own.", time: "2d",  href: "Feed Page.html" },
    { type: "post_comment", by: "noctis_nico",    avatar: "assets/av-6.svg", car: { make: "TOYOTA",  model: "GR Supra",   image: "assets/car-4.png" }, excerpt: "Single-turbo swap looks clean, what shop did this?", time: "3d",  href: "Feed Page.html" },
    { type: "thread",       by: "jdm_jules",      avatar: "assets/av-2.svg", car: { make: "NISSAN",  model: "Skyline R34",image: "assets/car-1.png" }, excerpt: "Sourcing genuine Brembos in 2026 without getting scammed", time: "5d", href: "Forums.html" },
  ];

  const serviceCars = [
    { make: "BMW",     model: "M4 Competition", year: "2024", plate: "CJ 24 TWK", image: "assets/car-2.png", statusText: "1 overdue · 2 due soon", statusTone: "over" },
    { make: "PORSCHE", model: "911 GT3",        year: "2022", plate: "CJ 91 GT3", image: "assets/car-3.png", statusText: "RCA due in 21 days",     statusTone: "warn" },
    { make: "TOYOTA",  model: "GR Supra",       year: "2023", plate: "CJ 82 SUP", image: "assets/car-4.png", statusText: "All up to date",        statusTone: "ok" },
  ];

  const gap = postsPerRow === 3 ? 8 : 12;

  return (
    <div style={{
      width: 390, height: screenHeight, background: KE.bg, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <TopBar/>

      <div style={{ flex: 1, display: "flex", flexDirection: "column", minHeight: 0 }}>
        {/* Identity block */}
        <div style={{ padding: "24px 20px 8px", flexShrink: 0 }}>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
            <div style={{ position: "relative", width: 96, height: 96, marginBottom: 14 }}>
              <div style={{
                width: "100%", height: "100%", borderRadius: 28,
                border: `1px solid ${KE.line}`, padding: 3, background: KE.surface,
              }}>
                <img src="assets/avatar.jpg" style={{
                  width: "100%", height: "100%", borderRadius: 25, objectFit: "cover",
                }}/>
              </div>
              {/* verified dot — orange accent */}
              <div style={{
                position: "absolute", right: -2, bottom: -2, width: 26, height: 26, borderRadius: 999,
                background: KE.accent, display: "grid", placeItems: "center",
                border: `2px solid ${KE.bg}`,
              }}>
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                  <path d="M5 12l4 4 10-10" stroke={KE.onAccent} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </div>
            </div>

            <div style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 22, color: KE.ink, letterSpacing: -0.4,
            }}>Marcus Vlox</div>
            <div style={{
              fontFamily: FONT_BODY, fontSize: 13, color: KE.mute, marginTop: 2,
            }}>@marcus_vlox</div>

            <div style={{
              marginTop: 6, fontFamily: FONT_BODY, fontSize: 11, color: KE.mute,
              display: "flex", alignItems: "center", gap: 6,
            }}>
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none"><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={KE.mute} strokeWidth="2"/><circle cx="12" cy="10" r="2.5" stroke={KE.mute} strokeWidth="2"/></svg>
              MONACO, MC
            </div>

            <p style={{
              margin: "12px 4px 0", textAlign: "center", textWrap: "pretty",
              fontFamily: FONT_BODY, fontSize: 13, lineHeight: 1.55, color: KE.ink2,
              maxWidth: 320,
            }}>
              Apex hunter from the principality. Cold starts, mountain switchbacks,
              and a soft spot for naturally aspirated straight-sixes.
            </p>
          </div>

          {/* stats + follow */}
          <div style={{
            marginTop: 18, display: "flex", alignItems: "stretch", gap: 10,
          }}>
            <div style={{
              flex: 1, padding: "12px 14px", borderRadius: 12, background: KE.surface,
              border: `1px solid ${KE.line}`,
              display: "flex", flexDirection: "column", alignItems: "flex-start",
            }}>
              <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 22, color: KE.ink, letterSpacing: -0.5 }}>1,500</div>
              <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, color: KE.mute, letterSpacing: 1.3, marginTop: 2 }}>FOLLOWERS</div>
            </div>
            <div style={{
              flex: 1, padding: "12px 14px", borderRadius: 12, background: KE.surface,
              border: `1px solid ${KE.line}`,
              display: "flex", flexDirection: "column", alignItems: "flex-start",
            }}>
              <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 22, color: KE.ink, letterSpacing: -0.5 }}>53</div>
              <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, color: KE.mute, letterSpacing: 1.3, marginTop: 2 }}>FOLLOWING</div>
            </div>
          </div>

          {/* Follow CTA — orange accent */}
          <button style={{
            marginTop: 10, width: "100%", height: 48, borderRadius: 12, border: "none",
            background: KE.accent, color: KE.onAccent,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            cursor: "pointer",
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M12 5v14m-7-7h14" stroke={KE.onAccent} strokeWidth="2.5" strokeLinecap="round"/></svg>
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.6 }}>FOLLOW</span>
          </button>
        </div>

        {/* Tab switcher — Posts | Garage */}
        <div style={{ marginTop: 18, flexShrink: 0 }}>
          <ProfileTabs tab={tab} onChange={setTab}/>
        </div>

        {/* scroll region — only the active section is shown */}
        <div style={{
          flex: 1, minHeight: 0, overflowY: "auto", padding: "16px 16px 20px",
          WebkitMaskImage: "linear-gradient(180deg, transparent 0, #000 12px, #000 calc(100% - 16px), transparent 100%)",
          maskImage: "linear-gradient(180deg, transparent 0, #000 12px, #000 calc(100% - 16px), transparent 100%)",
        }}>
          {tab === "posts" ? (
            <div style={{
              display: "grid",
              gridTemplateColumns: `repeat(${postsPerRow}, 1fr)`,
              gap,
            }}>
              {posts.map((p, i) => <PostCard key={i} {...p} perRow={postsPerRow}/>)}
            </div>
          ) : tab === "garage" ? (
            <div style={{ display: "flex", flexDirection: "column", gap: 14, padding: "0 4px" }}>
              {cars.map((c, i) => <CarCardA key={i} {...c}/>)}
            </div>
          ) : tab === "tags" ? (
            <div style={{ display: "flex", flexDirection: "column", gap: 10, padding: "0 4px" }}>
              <div style={{ fontFamily: FONT_BODY, fontSize: 12.5, color: KE.mute, lineHeight: 1.5, padding: "0 2px 4px" }}>
                Where you and your cars have been tagged — threads, replies, posts and comments.
              </div>
              {tags.map((t, i) => <TagRow key={i} {...t}/>)}
            </div>
          ) : tab === "service" ? (
            <div style={{ display: "flex", flexDirection: "column", gap: 10, padding: "0 4px" }}>
              <div style={{ fontFamily: FONT_BODY, fontSize: 12.5, color: KE.mute, lineHeight: 1.5, padding: "0 2px 4px" }}>
                Pick a car to open its digital service book — maintenance schedule, insurance and full history.
              </div>
              {serviceCars.map((c, i) => <ServiceCarRow key={i} {...c}/>)}
            </div>
          ) : null}
        </div>
      </div>

      <TabBar/>
    </div>
  );
}

window.ProfileScreen = ProfileScreen;
