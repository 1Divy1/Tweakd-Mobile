// map.jsx — Kinetic Edge
// Virtual community map — car meet events (live / upcoming / previous) + car businesses.
// Event data comes from event-data.jsx (mirrors car_events + event_car_meet).
// Instagram/Google-maps feel, warm-neutral palette, orange reserved for LIVE + CTAs.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY = window.KE_FONT_BODY;

// Map surface tones (muted, warm — kept in the KE family)
const MAP = {
  land: "#ECE7DF",
  block: "#F3EFE8",
  block2: "#F7F4EE",
  park: "#DDE4D2",
  water: "#CFDADF",
  road: "#FFFFFF",
  casing: "#E2DBD0",
  label: "#A9A299"
};

// Category meta for businesses
const CAT = {
  detailing: { label: "DETAILING", tint: "#2D6CD6", icon: (c) =>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 3s5 5.5 5 9a5 5 0 01-10 0c0-3.5 5-9 5-9z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>
  },
  carwash: { label: "CAR WASH", tint: "#1C9E86", icon: (c) =>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M7 9l1.5-4h7L17 9M4 9h16v6a1 1 0 01-1 1h-1a2 2 0 11-4 0H10a2 2 0 11-4 0H5a1 1 0 01-1-1V9z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>
  },
  tuning: { label: "TUNING", tint: "#C2410C", icon: (c) =>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M14.5 6a3.5 3.5 0 00-4.6 4.3L4 16.2 6.8 19l5.9-5.9A3.5 3.5 0 0018 8.5l-2.3 2.3-2-2L16 6.4A3.5 3.5 0 0014.5 6z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>
  },
  parts: { label: "PARTS", tint: "#7C3AED", icon: (c) =>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3" stroke={c} strokeWidth="2" /><path d="M12 2v3m0 14v3M2 12h3m14 0h3M5 5l2 2m10 10l2 2M19 5l-2 2M5 19l2-2" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>
  }
};

// ─────────────────────────────────────────────────────────
// Datasets — two cities to show near + far browsing
// x/y are percentages of the 520×980 map canvas
// ─────────────────────────────────────────────────────────
const CITIES = {
  monaco: {
    name: "Monaco", region: "MC", distanceTag: "Nearby",
    pins: [
    { id: "b1", type: "business", cat: "detailing", x: 52, y: 24, title: "Apex Detailing Studio",
      subtitle: "Ceramic · PPF · Paint correction", rating: 4.9, reviewCount: 312, followerCount: 2400,
      verified: true, thumb: "assets/car-3.png", is_closed: false, distance: "0.7 mi",
      phone: "+377 9 205 1122", website: "apexdetailing.mc",
      address: "12 Avenue des Spélugues, Monaco",
      description: "Ceramic coatings, PPF, and concours-level paint correction for collector cars." },
    { id: "b2", type: "business", cat: "tuning", x: 33, y: 44, title: "Riviera Tuning Works",
      subtitle: "ECU remap · Dyno · Exhaust", rating: 4.8, reviewCount: 198, followerCount: 5100,
      verified: true, thumb: "assets/car-2.png", is_closed: false, distance: "1.5 mi",
      phone: "+377 9 305 8890", email: "info@rivieratuning.mc",
      address: "8 Rue Grimaldi, Monaco",
      description: "ECU remapping, dyno tuning, and custom exhaust for performance builds." },
    { id: "b3", type: "business", cat: "carwash", x: 58, y: 70, title: "Larvotto Hand Wash",
      subtitle: "Hand wash · Foam · Interior", rating: 4.6, reviewCount: 87, followerCount: 640,
      verified: false, thumb: "assets/car-4.png", is_closed: true, distance: "1.9 mi",
      address: "Plage du Larvotto, Monaco" },
    { id: "b4", type: "business", cat: "parts", x: 22, y: 32, title: "GrandPrix Parts Co.",
      subtitle: "OEM · Performance · Wheels", rating: 4.7, reviewCount: 421, followerCount: 3300,
      verified: true, thumb: "assets/car-1.png", is_closed: false, distance: "2.6 mi",
      phone: "+377 9 777 2233", email: "sales@grandprixparts.mc", website: "grandprixparts.mc",
      address: "45 Boulevard Albert 1er, Monaco",
      description: "OEM and performance parts, wheels, and hard-to-find imports." }]

  },
  london: {
    name: "London", region: "UK", distanceTag: "1,038 mi away",
    pins: [
    { id: "l4", type: "business", cat: "tuning", x: 55, y: 64, title: "Camden Performance",
      subtitle: "Stage 2 · Mapping · Brakes", rating: 4.9, reviewCount: 264, followerCount: 8900,
      verified: true, thumb: "assets/car-4.png", is_closed: false, distance: "1.2 mi",
      phone: "+44 20 7946 0891", website: "camdenperformance.co.uk",
      address: "112 Camden High St, London",
      description: "Stage 2 tuning, mapping, and big-brake conversions." },
    { id: "l5", type: "business", cat: "detailing", x: 38, y: 30, title: "Mayfair Detail Lab",
      subtitle: "Concours prep · Coatings", rating: 5.0, reviewCount: 156, followerCount: 4200,
      verified: true, thumb: "assets/car-3.png", is_closed: false, distance: "2.0 mi",
      email: "hello@mayfairdetail.co.uk",
      address: "22 Mount St, Mayfair, London" }]

  }
};

// ─────────────────────────────────────────────────────────
// Stylized map background (SVG)
// ─────────────────────────────────────────────────────────
function MapCanvas() {
  return (
    <svg width="520" height="980" viewBox="0 0 520 980" style={{ display: "block" }}>
      <rect width="520" height="980" fill={MAP.land} />

      {/* water — bay bottom-right + a channel */}
      <path d="M520 620 L360 980 L520 980 Z" fill={MAP.water} />
      <path d="M0 760 C120 720 200 820 300 800 C400 780 460 880 520 850 L520 980 L0 980 Z" fill={MAP.water} />

      {/* parks / green blocks */}
      <path d="M70 120 L210 90 L240 200 L120 250 Z" fill={MAP.park} />
      <rect x="300" y="150" width="120" height="90" rx="14" fill={MAP.park} />
      <circle cx="150" cy="560" r="70" fill={MAP.park} />

      {/* subtle city blocks */}
      <g fill={MAP.block}>
        <rect x="250" y="280" width="90" height="70" rx="8" />
        <rect x="360" y="300" width="80" height="60" rx="8" />
        <rect x="60" y="320" width="100" height="80" rx="8" />
        <rect x="280" y="420" width="110" height="80" rx="8" />
        <rect x="120" y="660" width="90" height="70" rx="8" />
        <rect x="380" y="500" width="90" height="80" rx="8" />
      </g>
      <g fill={MAP.block2}>
        <rect x="180" y="300" width="60" height="60" rx="8" />
        <rect x="200" y="440" width="70" height="70" rx="8" />
        <rect x="330" y="640" width="80" height="70" rx="8" />
      </g>

      {/* roads — casing then white */}
      <g stroke={MAP.casing} fill="none" strokeLinecap="round">
        <path d="M-20 240 L540 180" strokeWidth="22" />
        <path d="M-20 470 L540 430" strokeWidth="18" />
        <path d="M60 -20 L120 1000" strokeWidth="20" />
        <path d="M330 -20 L380 1000" strokeWidth="18" />
        <path d="M-20 660 C160 600 360 760 540 690" strokeWidth="16" />
        <path d="M40 60 L500 560" strokeWidth="14" />
      </g>
      <g stroke={MAP.road} fill="none" strokeLinecap="round">
        <path d="M-20 240 L540 180" strokeWidth="16" />
        <path d="M-20 470 L540 430" strokeWidth="12" />
        <path d="M60 -20 L120 1000" strokeWidth="14" />
        <path d="M330 -20 L380 1000" strokeWidth="12" />
        <path d="M-20 660 C160 600 360 760 540 690" strokeWidth="11" />
        <path d="M40 60 L500 560" strokeWidth="9" />
      </g>

      {/* minor streets */}
      <g stroke={MAP.road} fill="none" strokeWidth="5" strokeLinecap="round" opacity="0.9">
        <path d="M200 -10 L230 1000" />
        <path d="M430 -10 L470 1000" />
        <path d="M-10 360 L540 320" />
        <path d="M-10 560 L540 520" />
      </g>
    </svg>);

}

// ─────────────────────────────────────────────────────────
// Pins
// ─────────────────────────────────────────────────────────
function MeetPin({ pin, selected, onSelect }) {
  const live = pin.status === "live";
  const past = pin.status === "previous";
  const ring = live ? KE.accent : past ? KE.muteSoft : KE.ink;
  return (
    <button
      onClick={(e) => {e.stopPropagation();onSelect(pin.id);}}
      style={{
        position: "absolute", left: `${pin.x}%`, top: `${pin.y}%`,
        transform: `translate(-50%,-100%) scale(${selected ? 1.14 : 1})`,
        transformOrigin: "bottom center", transition: "transform 160ms ease",
        border: "none", background: "transparent", padding: 0, cursor: "pointer",
        opacity: past ? 0.82 : 1,
        zIndex: selected ? 40 : live ? 30 : past ? 14 : 20
      }}>

      <div style={{ position: "relative", width: 52, display: "flex", flexDirection: "column", alignItems: "center" }}>
        {live &&
        <span className="ke-pulse" style={{
          position: "absolute", top: 4, left: "50%", marginLeft: -23,
          width: 46, height: 46, borderRadius: 999, background: KE.accent
        }} />
        }
        {/* attendee badge */}
        <span style={{
          position: "absolute", top: -8, right: 2, zIndex: 3,
          background: live ? KE.accent : past ? KE.mute : KE.ink, color: "#fff",
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 0.2,
          padding: "2px 6px", borderRadius: 999, outline: "2px solid #fff",
          display: "flex", alignItems: "center", gap: 3
        }}>
          {live && <span style={{ width: 5, height: 5, borderRadius: 999, background: "#fff" }} />}
          {window.EV.fmtCount(pin.attendees_count)}
        </span>
        {/* cover */}
        <span style={{
          width: 48, height: 48, borderRadius: 999, background: "#fff",
          outline: `3px solid ${ring}`, overflow: "hidden", position: "relative", zIndex: 2,
          boxShadow: "0 6px 16px rgba(0,0,0,0.18)"
        }}>
          <img src={pin.cover} alt="" style={{
            width: "100%", height: "100%", objectFit: "cover", background: KE.bgSoft,
            filter: past ? "grayscale(0.55)" : "none"
          }} />
        </span>
        {/* pointer */}
        <span style={{
          width: 0, height: 0, marginTop: 1, zIndex: 1,
          borderLeft: "6px solid transparent", borderRight: "6px solid transparent",
          borderTop: `9px solid ${ring}`,
          filter: "drop-shadow(0 3px 2px rgba(0,0,0,0.15))"
        }} />
      </div>
    </button>);

}

function BusinessPin({ pin, selected, onSelect }) {
  const cat = CAT[pin.cat];
  return (
    <button
      onClick={(e) => {e.stopPropagation();onSelect(pin.id);}}
      style={{
        position: "absolute", left: `${pin.x}%`, top: `${pin.y}%`,
        transform: `translate(-50%,-100%) scale(${selected ? 1.14 : 1})`,
        transformOrigin: "bottom center", transition: "transform 160ms ease",
        border: "none", background: "transparent", padding: 0, cursor: "pointer",
        zIndex: selected ? 40 : 15
      }}>
      
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <span style={{
          width: 40, height: 40, borderRadius: 13, background: "#fff",
          border: `2px solid ${selected ? KE.accent : "#fff"}`,
          display: "grid", placeItems: "center", position: "relative",
          boxShadow: "0 5px 14px rgba(0,0,0,0.16)"
        }}>
          {cat.icon(cat.tint)}
          <span style={{
            position: "absolute", bottom: -3, right: -3, width: 12, height: 12,
            borderRadius: 999, background: cat.tint, border: "2px solid #fff"
          }} />
        </span>
        <span style={{
          width: 0, height: 0, marginTop: -1,
          borderLeft: "5px solid transparent", borderRight: "5px solid transparent",
          borderTop: "8px solid #fff",
          filter: "drop-shadow(0 3px 2px rgba(0,0,0,0.12))"
        }} />
      </div>
    </button>);

}

// "You are here" dot
function MeDot() {
  return (
    <div style={{ position: "absolute", left: "47%", top: "49%", transform: "translate(-50%,-50%)", zIndex: 10 }}>
      <span className="ke-accuracy" style={{
        position: "absolute", left: "50%", top: "50%", transform: "translate(-50%,-50%)",
        width: 80, height: 80, borderRadius: 999, background: "rgba(45,108,214,0.14)"
      }} />
      <span style={{
        position: "relative", display: "block", width: 16, height: 16, borderRadius: 999,
        background: "#2D6CD6", border: "3px solid #fff", boxShadow: "0 2px 8px rgba(0,0,0,0.3)"
      }} />
    </div>);

}

// ─────────────────────────────────────────────────────────
// Filter chips
// ─────────────────────────────────────────────────────────
function FilterChips({ active, onChange, counts }) {
  const chips = [
  { k: "all", label: "All" },
  { k: "live", label: "Live", dot: KE.accent },
  { k: "upcoming", label: "Upcoming" },
  { k: "previous", label: "Previous" },
  { k: "business", label: "Businesses" }];

  return (
    <div style={{
      display: "flex", gap: 6, overflowX: "auto", padding: "0 16px 2px",
      scrollbarWidth: "none"
    }}>
      {chips.map((c) => {
        const on = active === c.k;
        return (
          <button key={c.k} onClick={() => onChange(c.k)} style={{
            flexShrink: 0, border: "none",
            background: on ? KE.ink : KE.surface, color: on ? "#fff" : KE.ink,
            borderRadius: 999, padding: "9px 12px", cursor: "pointer",
            display: "flex", alignItems: "center", gap: 6,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 0.4,
            boxShadow: on ? "0 3px 10px rgba(10,10,10,0.22)" : "0 2px 8px rgba(10,10,10,0.1)",
            transition: "all 140ms ease"
          }}>
            {c.dot && <span className={on ? "" : "ke-blink"} style={{ width: 7, height: 7, borderRadius: 999, background: on ? "#fff" : c.dot }} />}
            {c.label}
            <span style={{
              fontSize: 10, opacity: on ? 0.7 : 0.55, fontWeight: 700
            }}>{counts[c.k]}</span>
          </button>);

      })}
    </div>);

}

// ─────────────────────────────────────────────────────────
// Floating controls
// ─────────────────────────────────────────────────────────
function CircleBtn({ children, onClick, style }) {
  return (
    <button onClick={onClick} style={{
      width: 44, height: 44, borderRadius: 14, background: KE.surface,
      border: "none", display: "grid", placeItems: "center",
      cursor: "pointer", boxShadow: "0 4px 14px rgba(0,0,0,0.1)", ...style
    }}>{children}</button>);

}

// ─────────────────────────────────────────────────────────
// Bottom sheet — list + detail
// ─────────────────────────────────────────────────────────
function TypeChip({ pin }) {
  if (pin.type === "meet") return <window.EvStatusChip status={pin.status} size="sm" />;
  const c = CAT[pin.cat];
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 5,
      background: `${c.tint}14`, color: c.tint,
      borderRadius: 999, padding: "3px 9px",
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8.5, letterSpacing: 1
    }}>
      <span style={{ width: 6, height: 6, borderRadius: 999, background: c.tint }} />
      {c.label}
    </span>);

}

function ListCard({ pin, onSelect }) {
  const meet = pin.type === "meet";
  return (
    <button onClick={() => onSelect(pin.id)} style={{
      width: "100%", textAlign: "left", border: "none", background: KE.surface,
      borderRadius: 16, padding: 10, display: "flex", gap: 12, alignItems: "center", cursor: "pointer",
      boxShadow: "0 2px 10px rgba(10,10,10,0.06)"
    }}>
      <span style={{
        width: 60, height: 60, borderRadius: 12, overflow: "hidden", flexShrink: 0,
        background: KE.bgSoft, position: "relative"
      }}>
        <img src={meet ? pin.cover : pin.thumb} alt="" style={{
          width: "100%", height: "100%", objectFit: "cover",
          filter: meet && pin.status === "previous" ? "grayscale(0.5)" : "none"
        }} />
      </span>
      <span style={{ flex: 1, minWidth: 0 }}>
        <TypeChip pin={pin} />
        <span style={{
          display: "block", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14,
          color: KE.ink, letterSpacing: -0.2, marginTop: 6,
          whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
        }}>{pin.title}</span>
        <span style={{
          display: "flex", alignItems: "center", gap: 8, marginTop: 3,
          fontFamily: FONT_BODY, fontSize: 12, color: KE.mute
        }}>
          <span style={{ display: "inline-flex", alignItems: "center", gap: 3 }}>
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={KE.mute} strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke={KE.mute} strokeWidth="2" /></svg>
            {pin.distance}
          </span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }} />
          <span style={{ whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
            {meet ? window.EV.fmtShort(pin) : pin.is_closed ? "Closed" : "Open now"}
          </span>
        </span>
      </span>
      {meet &&
      <span style={{ flexShrink: 0, textAlign: "center", paddingLeft: 4 }}>
          <span style={{ display: "block", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 16, color: KE.ink }}>
            {window.EV.fmtCount(pin.attendees_count)}
          </span>
          <span style={{ display: "block", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 1, color: KE.mute }}>GOING</span>
        </span>
      }
    </button>);

}

// ─────────────────────────────────────────────────────────
// Business widget — floating popup with full business info
// ─────────────────────────────────────────────────────────
function fmtCount(n) {
  if (n >= 1000) return (n % 1000 === 0 ? n / 1000 : (n / 1000).toFixed(1)) + "k";
  return String(n);
}

function VerifiedBadge() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
      <path d="M12 2l2.4 2.1 3.1-.5 1 3 2.9 1.4-.9 3.1 1.7 2.8-2.4 2.1.4 3.1-3.1.5-1.7 2.7-3-1.2-3 1.2-1.7-2.7-3.1-.5.4-3.1-2.4-2.1 1.7-2.8-.9-3.1 2.9-1.4 1-3 3.1.5z" fill={KE.accent} />
      <path d="M8.5 12.2l2.3 2.3 4.5-4.9" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>);

}

const CONTACT_ICONS = {
  address: (c) => <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={c} strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke={c} strokeWidth="2" /></svg>,
  phone: (c) => <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M6.5 3h3l1.5 4.5-2 1.5a12 12 0 006 6l1.5-2L21 14.5v3a2 2 0 01-2 2C10.5 19.5 4.5 13.5 4.5 5a2 2 0 012-2z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>,
  website: (c) => <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={c} strokeWidth="2" /><path d="M3 12h18M12 3c2.5 2.7 3.8 6 3.8 9s-1.3 6.3-3.8 9c-2.5-2.7-3.8-6-3.8-9s1.3-6.3 3.8-9z" stroke={c} strokeWidth="2" /></svg>,
  email: (c) => <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2.5" stroke={c} strokeWidth="2" /><path d="M4 7l8 6 8-6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>
};

function ContactRow({ kind, label }) {
  return (
    <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
      <span style={{
        width: 28, height: 28, borderRadius: 9, background: KE.bgSoft,
        display: "grid", placeItems: "center", flexShrink: 0
      }}>{CONTACT_ICONS[kind](KE.ink2)}</span>
      <span style={{ fontFamily: FONT_BODY, fontSize: 13, color: KE.ink2, lineHeight: 1.4, paddingTop: 5, wordBreak: "break-word" }}>{label}</span>
    </div>);

}

function BusinessWidget({ pin, onClose }) {
  if (!pin) return null;
  const cat = CAT[pin.cat];
  const closed = pin.is_closed;
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 90, background: "rgba(10,10,10,0.34)",
      display: "flex", alignItems: "center", justifyContent: "center", padding: "0 20px"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", maxWidth: 336, maxHeight: "76%", overflowY: "auto",
        background: KE.surface, borderRadius: 24,
        boxShadow: "0 30px 70px rgba(0,0,0,0.38)", padding: 20, position: "relative"
      }}>
        <button onClick={onClose} style={{
          position: "absolute", top: 14, right: 14, width: 30, height: 30, borderRadius: 999,
          border: "none", background: KE.bgSoft, display: "grid", placeItems: "center", cursor: "pointer", zIndex: 2
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={KE.ink} strokeWidth="2.4" strokeLinecap="round" /></svg>
        </button>

        <div style={{ display: "flex", gap: 12, alignItems: "flex-start", paddingRight: 26 }}>
          <span style={{
            width: 56, height: 56, borderRadius: 16, flexShrink: 0, background: `${cat.tint}14`,
            display: "grid", placeItems: "center"
          }}>{cat.icon(cat.tint)}</span>
          <div style={{ flex: 1, minWidth: 0, paddingTop: 2 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 17, color: KE.ink,
                letterSpacing: -0.3, lineHeight: 1.2
              }}>{pin.title}</span>
              {pin.verified && <VerifiedBadge />}
            </div>
            <div style={{ marginTop: 7 }}><TypeChip pin={pin} /></div>
          </div>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 10, flexWrap: "wrap", marginTop: 14 }}>
          <span style={{
            display: "inline-flex", alignItems: "center", gap: 5,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12, color: closed ? KE.mute : KE.accent
          }}>
            <span style={{ width: 6, height: 6, borderRadius: 999, background: closed ? KE.muteSoft : KE.accent }} />
            {closed ? "Closed now" : "Open now"}
          </span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }} />
          <span style={{ display: "inline-flex", alignItems: "center", gap: 4, fontFamily: FONT_BODY, fontSize: 12, color: KE.ink2 }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill={KE.accent}><path d="M12 2l2.9 6 6.6.8-4.9 4.5 1.3 6.5L12 16.9 6.1 19.8l1.3-6.5-4.9-4.5 6.6-.8z" /></svg>
            {pin.rating.toFixed(1)} <span style={{ color: KE.mute }}>({fmtCount(pin.reviewCount)})</span>
          </span>
          <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }} />
          <span style={{ fontFamily: FONT_BODY, fontSize: 12, color: KE.ink2 }}>
            {fmtCount(pin.followerCount)} <span style={{ color: KE.mute }}>followers</span>
          </span>
        </div>

        {pin.description &&
        <p style={{ margin: "14px 0 0", fontFamily: FONT_BODY, fontSize: 13, color: KE.ink2, lineHeight: 1.55 }}>
            {pin.description}
          </p>}


        <div style={{ display: "flex", flexDirection: "column", gap: 10, marginTop: 16 }}>
          <ContactRow kind="address" label={pin.address} />
          {pin.phone && <ContactRow kind="phone" label={pin.phone} />}
          {pin.website && <ContactRow kind="website" label={pin.website} />}
          {pin.email && <ContactRow kind="email" label={pin.email} />}
        </div>

        <button style={{
          width: "100%", height: 48, borderRadius: 14, border: "none", cursor: "pointer",
          background: KE.accent, color: KE.onAccent, marginTop: 18,
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.2
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M3 11l18-8-8 18-2-8-8-2z" stroke="#fff" strokeWidth="2.2" strokeLinejoin="round" /></svg>
          GET DIRECTIONS
        </button>
      </div>
    </div>);

}

// ─────────────────────────────────────────────────────────
// City switcher overlay
// ─────────────────────────────────────────────────────────
function CitySwitcher({ open, current, onPick, onClose }) {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 80, background: "rgba(10,10,10,0.28)",
      display: "flex", alignItems: "flex-start", justifyContent: "center", paddingTop: 116
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: 300, background: KE.surface, borderRadius: 20,
        boxShadow: "0 24px 60px rgba(0,0,0,0.22)", overflow: "hidden"
      }}>
        <div style={{ padding: "14px 16px 8px", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4, color: KE.mute }}>
          JUMP TO A CITY
        </div>
        {Object.entries(CITIES).map(([key, c], i) => {
          const on = key === current;
          return (
            <button key={key} onClick={() => onPick(key)} style={{
              width: "100%", textAlign: "left", border: "none", cursor: "pointer",
              background: on ? KE.bgSoft : "#fff", padding: "13px 16px",
              display: "flex", alignItems: "center", gap: 12
            }}>
              <span style={{
                width: 34, height: 34, borderRadius: 10, background: on ? KE.ink : KE.bgSoft,
                display: "grid", placeItems: "center"
              }}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={on ? "#fff" : KE.ink} strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke={on ? "#fff" : KE.ink} strokeWidth="2" /></svg>
              </span>
              <span style={{ flex: 1 }}>
                <span style={{ display: "block", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink }}>{c.name}</span>
                <span style={{ display: "block", fontFamily: FONT_BODY, fontSize: 12, color: KE.mute }}>{c.distanceTag} · {c.pins.length + window.EV.eventsByCity(key).length} spots</span>
              </span>
              {on && <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke={KE.accent} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" /></svg>}
            </button>);

        })}
      </div>
    </div>);

}

// ─────────────────────────────────────────────────────────
// TabBar
// ─────────────────────────────────────────────────────────
function MapTabBar() {
  const tabs = [
  { k: "FEED", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2" /><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2" /><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2" /><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2" /></svg> },
  { k: "MAP", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round" /></svg> },
  { k: "REELS", href: "Reels Page.html", icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
  { k: "CONTESTS", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg> },
  { k: "PROFILE", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2" /><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" /></svg> }];

  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0",
      background: KE.surface, borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center", flexShrink: 0
    }}>
      {tabs.map((t) => {
        const on = t.k === "MAP";
        return (
          <div key={t.k} onClick={() => t.href && window.location.assign(t.href)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, cursor: t.href ? "pointer" : "default", color: on ? KE.ink : KE.muteSoft }}>
            {t.icon}
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1 }}>{t.k}</span>
            {on && <div style={{ width: 16, height: 2, borderRadius: 2, background: KE.ink, marginTop: 2 }} />}
          </div>);

      })}
    </div>);

}

// ─────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────
function MapScreen({ initCity = "monaco", initFilter = "all", initSelected = null, initSheet = "peek", initShowCreate = false }) {
  const [cityKey, setCityKey] = React.useState(initCity);
  const [filter, setFilter] = React.useState(initFilter);
  const [selected, setSelected] = React.useState(initSelected);
  const [sheet, setSheet] = React.useState(initSheet); // peek | open
  const [cityOpen, setCityOpen] = React.useState(false);
  const [showCreate, setShowCreate] = React.useState(initShowCreate);
  const [pan, setPan] = React.useState({ x: -68, y: -150 });

  const city = CITIES[cityKey];
  // events (car_events) + businesses share the pin layer
  const pins = React.useMemo(
    () => [...window.EV.eventsByCity(cityKey).map((e) => ({ ...e, type: "meet" })), ...city.pins],
    [cityKey]);

  // pan drag
  const drag = React.useRef(null);
  const onDown = (e) => {
    const p = e.touches ? e.touches[0] : e;
    drag.current = { sx: p.clientX, sy: p.clientY, ox: pan.x, oy: pan.y, moved: false };
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const p = e.touches ? e.touches[0] : e;
    const dx = p.clientX - drag.current.sx;
    const dy = p.clientY - drag.current.sy;
    if (Math.abs(dx) + Math.abs(dy) > 4) drag.current.moved = true;
    const nx = Math.min(0, Math.max(390 - 520, drag.current.ox + dx));
    const ny = Math.min(0, Math.max(700 - 980, drag.current.oy + dy));
    setPan({ x: nx, y: ny });
  };
  const onUp = () => {drag.current = null;};

  const meets = pins.filter((p) => p.type === "meet");
  const counts = {
    all: pins.length,
    live: meets.filter((p) => p.status === "live").length,
    upcoming: meets.filter((p) => p.status === "upcoming").length,
    previous: meets.filter((p) => p.status === "previous").length,
    business: pins.filter((p) => p.type === "business").length
  };
  const visible = pins.filter((p) =>
  filter === "all" ? true :
  filter === "business" ? p.type === "business" :
  p.type === "meet" && p.status === filter);

  const selPin = pins.find((p) => p.id === selected) || null;
  const handleSelect = (id) => setSelected(id);
  const closeDetail = () => {setSelected(null);};

  // sheet heights
  const sheetH = sheet === "open" ? 470 : 240;

  return (
    <div style={{
      width: 390, height: 844, background: MAP.land, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column"
    }}>
      {/* ── MAP LAYER ── */}
      <div
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}
        onClick={() => {if (!drag.current?.moved) closeDetail();}}
        style={{ position: "absolute", inset: 0, overflow: "hidden", cursor: "grab", touchAction: "none" }}>
        
        <div style={{
          position: "absolute", width: 520, height: 980,
          transform: `translate(${pan.x}px, ${pan.y}px)`
        }}>
          <MapCanvas />
          <MeDot />
          {visible.map((p) =>
          p.type === "business" ?
          <BusinessPin key={p.id} pin={p} selected={p.id === selected} onSelect={handleSelect} /> :
          <MeetPin key={p.id} pin={p} selected={p.id === selected} onSelect={handleSelect} />
          )}
        </div>
      </div>

      {/* ── TOP OVERLAY ── */}
      <div style={{ position: "relative", zIndex: 50, pointerEvents: "none" }}>
        <div style={{ height: 54 }} />
        {/* search + city */}
        <div style={{ padding: "6px 16px 0", display: "flex", gap: 10, pointerEvents: "auto" }}>
          <div style={{
            flex: 1, height: 48, borderRadius: 14, background: KE.surface,
            border: "none", boxShadow: "0 4px 14px rgba(0,0,0,0.08)",
            display: "flex", alignItems: "center", padding: "0 14px", gap: 10
          }}>
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="7" stroke={KE.mute} strokeWidth="2" /><path d="M20 20l-3.5-3.5" stroke={KE.mute} strokeWidth="2" strokeLinecap="round" /></svg>
            <span style={{ flex: 1, fontFamily: FONT_BODY, fontSize: 14, color: KE.mute }}>Search meets, shops, cities…</span>
          </div>
          <button onClick={() => setCityOpen(true)} style={{
            height: 48, borderRadius: 14, background: KE.ink, border: "none", cursor: "pointer",
            padding: "0 14px", display: "flex", alignItems: "center", gap: 7,
            boxShadow: "0 4px 14px rgba(0,0,0,0.16)"
          }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke="#fff" strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke="#fff" strokeWidth="2" /></svg>
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12, letterSpacing: 0.5, color: "#fff" }}>{city.name}</span>
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><path d="M6 9l6 6 6-6" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>
          </button>
          <button onClick={() => setShowCreate(true)} title="Create event" style={{
            width: 48, height: 48, borderRadius: 14, background: KE.accent, border: "none", cursor: "pointer",
            display: "grid", placeItems: "center", boxShadow: "0 4px 14px rgba(255,77,0,0.32)", flexShrink: 0
          }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" /></svg>
          </button>
        </div>
        {/* filter chips */}
        <div style={{ marginTop: 12, pointerEvents: "auto" }}>
          <FilterChips active={filter} onChange={(f) => {setFilter(f);}} counts={counts} />
        </div>
      </div>

      {/* ── FLOATING CONTROLS (right) ── */}
      <div style={{
        position: "absolute", right: 16, zIndex: 45,
        bottom: sheetH + 16, display: "flex", flexDirection: "column", gap: 10,
        transition: "bottom 240ms cubic-bezier(.4,0,.2,1)"
      }}>
        <CircleBtn>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 2v3m0 14v3m10-10h-3M5 12H2" stroke={KE.ink} strokeWidth="2" strokeLinecap="round" /><circle cx="12" cy="12" r="6" stroke={KE.ink} strokeWidth="2" /><circle cx="12" cy="12" r="1.6" fill={KE.ink} /></svg>
        </CircleBtn>
        <CircleBtn>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 11l18-8-8 18-2-8-8-2z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round" /></svg>
        </CircleBtn>
      </div>

      {/* "live now" banner pill */}
      {counts.live > 0 &&
      <div style={{
        position: "absolute", left: 16, zIndex: 45, bottom: sheetH + 16,
        transition: "bottom 240ms cubic-bezier(.4,0,.2,1)"
      }}>
          <div style={{
          display: "inline-flex", alignItems: "center", gap: 7,
          background: KE.ink, color: "#fff", borderRadius: 999, padding: "9px 13px",
          boxShadow: "0 4px 14px rgba(0,0,0,0.18)"
        }}>
            <span className="ke-blink" style={{ width: 7, height: 7, borderRadius: 999, background: KE.accent }} />
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 0.6 }}>
              {counts.live} live now
            </span>
          </div>
        </div>
      }

      {/* ── BOTTOM SHEET ── */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0, zIndex: 60,
        height: sheetH, background: KE.surface,
        borderRadius: "22px 22px 0 0",
        boxShadow: "0 -10px 40px rgba(0,0,0,0.12)",
        display: "flex", flexDirection: "column",
        transition: "height 240ms cubic-bezier(.4,0,.2,1)"
      }}>
        {/* grabber */}
        <button onClick={() => {setSheet((s) => s === "open" ? "peek" : "open");}} style={{
          border: "none", background: "transparent", cursor: "pointer",
          padding: "10px 0 6px", display: "flex", justifyContent: "center"
        }}>
          <span style={{ width: 38, height: 5, borderRadius: 999, background: KE.line }} />
        </button>

        <div style={{ padding: "2px 20px 10px", display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 17, color: KE.ink, letterSpacing: -0.3 }}>
            {filter === "business" ? "Car businesses" :
            filter === "live" ? "Live right now" :
            filter === "upcoming" ? "Upcoming meets" :
            filter === "previous" ? "Meets that ended" : "What's going on"}
          </span>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 0.5, color: KE.mute }}>
            {visible.length} in {city.name}
          </span>
        </div>
        <div style={{
          flex: 1, minHeight: 0, overflowY: "auto", padding: "0 16px 22px",
          display: "flex", flexDirection: "column", gap: 10
        }}>
          {visible.map((p) => <ListCard key={p.id} pin={p} onSelect={handleSelect} />)}
          {visible.length === 0 &&
          <div style={{
            padding: "26px 0", textAlign: "center", fontFamily: FONT_BODY, fontSize: 13, color: KE.mute
          }}>Nothing here yet in {city.name}.</div>
          }
        </div>
      </div>

      <CitySwitcher
        open={cityOpen} current={cityKey}
        onPick={(k) => {setCityKey(k);setCityOpen(false);setSelected(null);setFilter("all");setPan({ x: -68, y: -150 });}}
        onClose={() => setCityOpen(false)} />
      

      <BusinessWidget pin={selPin && selPin.type === "business" ? selPin : null} onClose={closeDetail} />

      <window.EventWidget
        ev={selPin && selPin.type === "meet" ? selPin : null}
        key={selPin ? selPin.id : "none"}
        onClose={closeDetail}
        onOpenEvent={() => window.location.assign("Car Meet Page.html")} />

      {showCreate && <window.CreateEventScreen onClose={() => setShowCreate(false)} />}
    </div>);

}

Object.assign(window, { MapScreen, MapCanvas, MAP_TONES: MAP });