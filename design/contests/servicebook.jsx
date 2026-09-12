// Service Book — Tweakd
// Per-car digital service book: overview (upcoming + expiring at a glance),
// full history timeline, schedule-maintenance form, add-document form.
// Warm-neutral palette + Space Grotesk / Manrope, mirrors Profile + Garage.
// Space Mono used for logbook numerals (mileage, cost, countdowns).

const { useState } = React;
const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;
const FONT_MONO    = `"Space Mono", ui-monospace, monospace`;

// Status colours — harmonious with the orange accent, used only on small
// dots / numerals / pills. Never large fills.
const SB = {
  ok:   "#1F8A5B", okSoft:  "#E6F1EA",
  warn: KE.accent, warnSoft: KE.accentSoft,
  over: "#D93A26", overSoft: "#FBE7E2",
};
const STAT = {
  ok:   { c: SB.ok,   soft: SB.okSoft,   label: "VALID" },
  warn: { c: SB.warn, soft: SB.warnSoft, label: "DUE SOON" },
  over: { c: SB.over, soft: SB.overSoft, label: "OVERDUE" },
};

// The car this book belongs to (matches the profile's primary chassis).
const CAR = {
  name: "BMW M4 Competition",
  spec: "G82 · 2024",
  plate: "CJ 24 TWK",
  odo: "28,400",
  image: "assets/car-2.png",
  home: "CLUJ-NAPOCA, RO",
};

// ─────────────────────────────────────────────────────────
// Icon set — simple strokes
// ─────────────────────────────────────────────────────────
function Ico({ name, size = 20, color = KE.ink, sw = 2 }) {
  const p = {
    back:   <path d="M15 6l-6 6 6 6" />,
    x:      <path d="M6 6l12 12M18 6L6 18" />,
    menu:   <path d="M4 12h16M4 6h16M4 18h10" />,
    plus:   <path d="M12 5v14m-7-7h14" />,
    chevD:  <path d="M6 9l6 6 6-6" />,
    chevR:  <path d="M9 6l6 6-6 6" />,
    bell:   <path d="M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 01-3.4 0" />,
    cal:    <path d="M4 7a2 2 0 012-2h12a2 2 0 012 2v12a2 2 0 01-2 2H6a2 2 0 01-2-2V7zm0 4h16M8 3v4M16 3v4" />,
    gauge:  <><path d="M12 13l4-3" /><path d="M4 18a8 8 0 1116 0" /><circle cx="12" cy="13" r="1.4" fill={color} stroke="none" /></>,
    oil:    <path d="M12 3s6 7 6 11a6 6 0 01-12 0c0-4 6-11 6-11z" />,
    shield: <path d="M12 3l7 3v6c0 4.4-3 7.6-7 9-4-1.4-7-4.6-7-9V6l7-3z" />,
    wrench: <path d="M14.7 6.3a4 4 0 00-5.2 5.2L4 17v3h3l5.5-5.5a4 4 0 005.2-5.2l-2.6 2.6-2.4-.6-.6-2.4 2.6-2.6z" />,
    chip:   <><rect x="6" y="6" width="12" height="12" rx="2" /><path d="M9 3v3M15 3v3M9 18v3M15 18v3M3 9h3M3 15h3M18 9h3M18 15h3" /></>,
    tire:   <><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="3.2" /></>,
    disc:   <><circle cx="12" cy="12" r="8" /><circle cx="12" cy="12" r="2" /><path d="M12 4v3M12 17v3M4 12h3M17 12h3" /></>,
    ticket: <path d="M4 7a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 000 6v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2a2 2 0 000-6V7z" />,
    check:  <path d="M5 12l4 4L19 7" />,
    clock:  <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    doc:    <path d="M7 3h7l4 4v14H7V3zm7 0v4h4" />,
    filter: <path d="M4 5h16l-6 8v6l-4-2v-4L4 5z" />,
    pin:    <><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" /><circle cx="12" cy="10" r="2.5" /></>,
  }[name];
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      {p}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────
// Chrome
// ─────────────────────────────────────────────────────────
function IconBtn({ name, onClick, size = 14 }) {
  return (
    <div onClick={onClick} style={{
      width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
      border: `1px solid ${KE.line}`, background: KE.surface, cursor: "pointer", flexShrink: 0,
    }}>
      <Ico name={name} size={size} sw={2.2} />
    </div>
  );
}

function TopBar({ title, leading = "back", trailing = "menu", onLeading }) {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      {leading ? <IconBtn name={leading} onClick={onLeading} /> : <div style={{ width: 36 }} />}
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink }}>{title}</div>
      {trailing ? <IconBtn name={trailing} /> : <div style={{ width: 36 }} />}
    </div>
  );
}

// Car identity strip with "switch car" affordance
function CarStrip({ compact }) {
  return (
    <div style={{
      margin: compact ? "14px 20px 4px" : "16px 20px 4px",
      display: "flex", alignItems: "center", gap: 12,
      padding: 10, borderRadius: 14, background: KE.surface, border: `1px solid ${KE.line}`,
      cursor: "pointer",
    }}>
      <div style={{
        width: 52, height: 44, borderRadius: 9, overflow: "hidden", background: KE.bgSoft,
        border: `1px solid ${KE.line}`, flexShrink: 0,
      }}>
        <img src={CAR.image} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.3 }}>{CAR.name}</div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 3 }}>
          <span style={{
            fontFamily: FONT_MONO, fontSize: 10, fontWeight: 700, letterSpacing: 0.5,
            color: KE.ink, background: KE.bgSoft, border: `1px solid ${KE.line}`,
            padding: "2px 6px", borderRadius: 5,
          }}>{CAR.plate}</span>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.mute }}>{CAR.spec}</span>
        </div>
      </div>
      <div style={{ textAlign: "right", flexShrink: 0 }}>
        <div style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 14, color: KE.ink }}>{CAR.odo}</div>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 1.4, color: KE.mute, marginTop: 1 }}>KM</div>
      </div>
      <Ico name="chevD" size={14} color={KE.mute} />
    </div>
  );
}

function SectionHead({ kicker, title, action, onAction }) {
  return (
    <div style={{
      display: "flex", alignItems: "flex-end", justifyContent: "space-between",
      padding: "0 20px", marginBottom: 12,
    }}>
      <div>
        {kicker && <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 2, color: KE.accent }}>{kicker}</div>}
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, letterSpacing: 1.4, color: KE.ink, marginTop: kicker ? 3 : 0 }}>{title}</div>
      </div>
      {action && (
        <div onClick={onAction} style={{ display: "flex", alignItems: "center", gap: 4, cursor: "pointer" }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.mute }}>{action}</span>
          <Ico name="chevR" size={12} color={KE.mute} />
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────
const UPCOMING = [
  { icon: "gauge",  label: "ITP INSPECTION",  sub: "RAR Cluj · expired 14 Jul 2026",   n: "4",   unit: "DAYS AGO", status: "over" },
  { icon: "shield", label: "CASCO INSURANCE", sub: "Groupama · expires 30 Jul 2026",   n: "12",  unit: "DAYS",     status: "warn" },
  { icon: "oil",    label: "OIL & FILTER",    sub: "Service due at 30,000 km",          n: "1,600", unit: "KM",     status: "warn" },
  { icon: "shield", label: "RCA INSURANCE",   sub: "Allianz-Țiriac · exp. 7 Dec 2026", n: "142", unit: "DAYS",     status: "ok" },
  { icon: "ticket", label: "ROVINIETĂ",       sub: "Vignette · expires 14 Oct 2026",   n: "88",  unit: "DAYS",     status: "ok" },
];

const HISTORY = [
  { icon: "tire",   type: "TIRES",     title: "Tire Rotation & Balance",   shop: "Anvelope Expert",  date: "12 JUN 2026", km: "26,900", cost: "240",   year: "2026" },
  { icon: "shield", type: "INSURANCE", title: "RCA Renewed · 12 months",   shop: "Allianz-Țiriac",   date: "03 MAR 2026", km: "24,100", cost: "1,180", year: "2026" },
  { icon: "oil",    type: "SERVICE",   title: "Oil & Filter · Mobil 1",    shop: "Bavaria Service",  date: "18 JAN 2026", km: "23,050", cost: "890",   year: "2026" },
  { icon: "chip",   type: "TUNING",    title: "ECU Stage 1 Tune",          shop: "TunerWorks",       date: "05 NOV 2025", km: "20,400", cost: "3,500", year: "2025" },
  { icon: "gauge",  type: "ITP",       title: "ITP Inspection · Passed",   shop: "RAR Cluj",         date: "11 AUG 2025", km: "18,200", cost: "145",   year: "2025" },
  { icon: "disc",   type: "SERVICE",   title: "Brake Pads & Discs · F+R",  shop: "Bavaria Service",  date: "02 JUN 2025", km: "15,600", cost: "2,650", year: "2025" },
  { icon: "wrench", type: "SERVICE",   title: "Major Service · Insp. II",  shop: "Bavaria Service",  date: "20 MAR 2025", km: "12,300", cost: "1,940", year: "2025" },
  { icon: "shield", type: "INSURANCE", title: "CASCO Purchased",           shop: "Groupama",         date: "04 FEB 2025", km: "9,800",  cost: "4,200", year: "2025" },
];

// ─────────────────────────────────────────────────────────
// Overview
// ─────────────────────────────────────────────────────────
function UpcomingCard({ icon, label, sub, n, unit, status }) {
  const s = STAT[status];
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 12,
      padding: 12, borderRadius: 14, background: KE.surface, border: `1px solid ${KE.line}`,
    }}>
      <div style={{ width: 40, height: 40, borderRadius: 11, background: s.soft, display: "grid", placeItems: "center", flexShrink: 0 }}>
        <Ico name={icon} size={20} color={s.c} sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 0.2, color: KE.ink }}>{label}</div>
        <div style={{ fontFamily: FONT_BODY, fontSize: 11.5, color: KE.mute, marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{sub}</div>
      </div>
      <div style={{ textAlign: "right", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "baseline", gap: 3, justifyContent: "flex-end" }}>
          <span style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 17, color: s.c, letterSpacing: -0.5 }}>{n}</span>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 0.8, color: KE.mute }}>{unit}</span>
        </div>
        <div style={{
          display: "inline-block", marginTop: 4, padding: "2px 7px", borderRadius: 999,
          background: s.soft, color: s.c,
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 1,
        }}>{s.label}</div>
      </div>
    </div>
  );
}

function ActionBtn({ icon, label, primary, onClick }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, height: 52, borderRadius: 12, cursor: "pointer",
      border: primary ? "none" : `1px solid ${KE.line}`,
      background: primary ? KE.accent : KE.surface,
      color: primary ? KE.onAccent : KE.ink,
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 3,
    }}>
      <Ico name={icon} size={17} color={primary ? KE.onAccent : KE.ink} sw={2.2} />
      <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.2 }}>{label}</span>
    </button>
  );
}

function MiniHistoryRow({ icon, title, date, km, cost, isLast }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 11, padding: "11px 14px",
      borderBottom: isLast ? "none" : `1px solid ${KE.line}`,
    }}>
      <div style={{ width: 30, height: 30, borderRadius: 8, background: KE.bgSoft, display: "grid", placeItems: "center", flexShrink: 0 }}>
        <Ico name={icon} size={15} color={KE.ink2} sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12.5, color: KE.ink, letterSpacing: -0.1, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{title}</div>
        <div style={{ fontFamily: FONT_MONO, fontSize: 9.5, color: KE.mute, marginTop: 2 }}>{date} · {km} KM</div>
      </div>
      <span style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 12, color: KE.ink, flexShrink: 0 }}>{cost}<span style={{ fontSize: 8, color: KE.mute, marginLeft: 2 }}>RON</span></span>
    </div>
  );
}

function OverviewScreen({ onSchedule, onDocument, onHistory }) {
  const attention = UPCOMING.filter(u => u.status !== "ok");
  const over = attention.filter(u => u.status === "over").length;
  const soon = attention.filter(u => u.status === "warn").length;
  return (
    <div style={{ width: 390, height: 844, background: KE.bg, fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }} />
      <TopBar title="SERVICE BOOK" trailing="bell" />

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", paddingBottom: 24 }}>
        <CarStrip />

        {/* Status banner */}
        <div style={{ padding: "12px 20px 4px" }}>
          <div style={{
            borderRadius: 16, padding: "16px 18px",
            background: over ? SB.overSoft : soon ? SB.warnSoft : SB.okSoft,
            border: `1px solid ${over ? "#F4CFC6" : soon ? "#FFD3BF" : "#CDE7D8"}`,
          }}>
            <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 2, color: over ? SB.over : soon ? SB.warn : SB.ok }}>MAINTENANCE STATUS</div>
            <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 24, letterSpacing: -0.6, color: KE.ink, marginTop: 6, lineHeight: 1.05 }}>
              {over ? "Action needed" : soon ? "Coming up soon" : "All up to date"}
            </div>
            <div style={{ display: "flex", gap: 16, marginTop: 12 }}>
              <div>
                <span style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 18, color: SB.over }}>{over}</span>
                <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1, color: KE.mute, marginLeft: 5 }}>OVERDUE</span>
              </div>
              <div style={{ width: 1, background: "rgba(0,0,0,0.08)" }} />
              <div>
                <span style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 18, color: SB.warn }}>{soon}</span>
                <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1, color: KE.mute, marginLeft: 5 }}>DUE SOON</span>
              </div>
            </div>
          </div>
        </div>

        {/* Quick actions */}
        <div style={{ padding: "14px 20px 6px", display: "flex", gap: 10 }}>
          <ActionBtn icon="cal" label="SCHEDULE" primary onClick={onSchedule} />
          <ActionBtn icon="shield" label="ADD DOCUMENT" onClick={onDocument} />
        </div>

        {/* Coming up */}
        <div style={{ marginTop: 18 }}>
          <SectionHead kicker="TRACKED" title="COMING UP" />
          <div style={{ padding: "0 20px", display: "flex", flexDirection: "column", gap: 10 }}>
            {UPCOMING.map((u, i) => <UpcomingCard key={i} {...u} />)}
          </div>
        </div>

        {/* Recent history */}
        <div style={{ marginTop: 26 }}>
          <SectionHead kicker="LOGBOOK" title="RECENT HISTORY" action="VIEW ALL" onAction={onHistory} />
          <div style={{ margin: "0 20px", borderRadius: 14, background: KE.surface, border: `1px solid ${KE.line}`, overflow: "hidden" }}>
            {HISTORY.slice(0, 3).map((h, i, a) => <MiniHistoryRow key={i} {...h} isLast={i === a.length - 1} />)}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Full history — the digital service book
// ─────────────────────────────────────────────────────────
function TypeTag({ label }) {
  return (
    <span style={{
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 1.2, color: KE.mute,
      border: `1px solid ${KE.line}`, borderRadius: 5, padding: "2px 6px", background: KE.bgSoft,
    }}>{label}</span>
  );
}

function HistoryEntry({ icon, type, title, shop, date, km, cost }) {
  return (
    <div style={{ position: "relative", paddingLeft: 30, paddingBottom: 16 }}>
      <div style={{
        position: "absolute", left: 3, top: 4, width: 26, height: 26, borderRadius: 8,
        background: KE.surface, border: `1px solid ${KE.line}`, display: "grid", placeItems: "center", zIndex: 1,
      }}>
        <Ico name={icon} size={14} color={KE.ink2} sw={2} />
      </div>
      <div style={{ background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14, padding: 14 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ fontFamily: FONT_MONO, fontSize: 10, fontWeight: 700, color: KE.mute }}>{date}</span>
          <TypeTag label={type} />
        </div>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.2, marginTop: 7 }}>{title}</div>
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 3 }}>
          <Ico name="pin" size={11} color={KE.mute} sw={2} />
          <span style={{ fontFamily: FONT_BODY, fontSize: 12, color: KE.ink2 }}>{shop}</span>
        </div>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 12, paddingTop: 11, borderTop: `1px dashed ${KE.line}` }}>
          <span style={{ fontFamily: FONT_MONO, fontSize: 11, fontWeight: 700, color: KE.ink2 }}>{km} KM</span>
          <span style={{ fontFamily: FONT_MONO, fontSize: 14, fontWeight: 700, color: KE.ink }}>{cost}<span style={{ fontSize: 9, color: KE.mute, marginLeft: 3 }}>RON</span></span>
        </div>
      </div>
    </div>
  );
}

function StatCell({ n, unit, label }) {
  return (
    <div style={{ flex: 1, textAlign: "center" }}>
      <div style={{ display: "flex", alignItems: "baseline", justifyContent: "center", gap: 3 }}>
        <span style={{ fontFamily: FONT_MONO, fontWeight: 700, fontSize: 19, color: KE.ink, letterSpacing: -0.5 }}>{n}</span>
        {unit && <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 0.8, color: KE.mute }}>{unit}</span>}
      </div>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8, letterSpacing: 1.2, color: KE.mute, marginTop: 4 }}>{label}</div>
    </div>
  );
}

function HistoryScreen({ onBack }) {
  const filters = ["ALL", "SERVICE", "INSURANCE", "ITP", "TUNING", "TIRES"];
  const [active, setActive] = useState("ALL");
  const years = [...new Set(HISTORY.map(h => h.year))];
  return (
    <div style={{ width: 390, height: 844, background: KE.bg, fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }} />
      <TopBar title="SERVICE HISTORY" onLeading={onBack} />

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", paddingBottom: 24 }}>
        <CarStrip compact />

        {/* Summary band */}
        <div style={{ margin: "14px 20px 0", padding: "16px 8px", borderRadius: 14, background: KE.surface, border: `1px solid ${KE.line}`, display: "flex", alignItems: "center" }}>
          <StatCell n="8" label="RECORDS" />
          <div style={{ width: 1, height: 30, background: KE.line }} />
          <StatCell n="14,745" unit="RON" label="TOTAL SPENT" />
          <div style={{ width: 1, height: 30, background: KE.line }} />
          <StatCell n="FEB '25" label="FIRST LOG" />
        </div>

        {/* Filters */}
        <div style={{ display: "flex", gap: 7, padding: "16px 20px 4px", overflowX: "auto" }}>
          {filters.map(f => {
            const on = f === active;
            return (
              <div key={f} onClick={() => setActive(f)} style={{
                flexShrink: 0, padding: "7px 13px", borderRadius: 999, cursor: "pointer",
                background: on ? KE.ink : KE.surface, border: `1px solid ${on ? KE.ink : KE.line}`,
                color: on ? KE.surface : KE.ink,
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, whiteSpace: "nowrap",
              }}>{f}</div>
            );
          })}
        </div>

        {/* Timeline grouped by year */}
        <div style={{ padding: "16px 20px 0" }}>
          {years.map(yr => (
            <div key={yr}>
              <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
                <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 22, letterSpacing: -0.5, color: KE.ink }}>{yr}</span>
                <div style={{ flex: 1, height: 1, background: KE.line }} />
                <span style={{ fontFamily: FONT_MONO, fontSize: 10, fontWeight: 700, color: KE.mute }}>{HISTORY.filter(h => h.year === yr).length} ENTRIES</span>
              </div>
              <div style={{ position: "relative" }}>
                <div style={{ position: "absolute", left: 15, top: 4, bottom: 12, width: 2, background: `repeating-linear-gradient(to bottom, ${KE.line} 0 4px, transparent 4px 8px)` }} />
                {HISTORY.filter(h => h.year === yr).map((h, i) => <HistoryEntry key={i} {...h} />)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Form primitives
// ─────────────────────────────────────────────────────────
function ModalBar({ title, onClose }) {
  return (
    <div style={{ height: 56, padding: "0 16px", display: "flex", alignItems: "center", justifyContent: "space-between", background: KE.bg, borderBottom: `1px solid ${KE.line}` }}>
      <IconBtn name="x" size={12} onClick={onClose} />
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink }}>{title}</div>
      <div style={{ width: 36 }} />
    </div>
  );
}

function ForChassis() {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10, margin: "16px 20px 0", padding: "10px 12px", borderRadius: 10, background: KE.surface, border: `1px solid ${KE.line}` }}>
      <div style={{ width: 32, height: 28, borderRadius: 7, overflow: "hidden", background: KE.bgSoft, flexShrink: 0 }}>
        <img src={CAR.image} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.mute }}>FOR VEHICLE</div>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, color: KE.ink, letterSpacing: -0.2, marginTop: 1 }}>{CAR.name} · {CAR.plate}</div>
      </div>
      <Ico name="chevD" size={13} color={KE.mute} />
    </div>
  );
}

function FormHeader({ kicker, title, sub }) {
  return (
    <div style={{ padding: "20px 20px 4px" }}>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 2, color: KE.accent }}>{kicker}</div>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 32, lineHeight: 1.05, letterSpacing: -1, color: KE.ink, marginTop: 6, whiteSpace: "pre-line" }}>{title}</div>
      {sub && <div style={{ fontFamily: FONT_BODY, fontSize: 13.5, color: KE.ink2, marginTop: 10, lineHeight: 1.5 }}>{sub}</div>}
    </div>
  );
}

function Sec({ kicker, title }) {
  return (
    <div style={{ marginTop: 24, marginBottom: 14 }}>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 2, color: KE.accent }}>{kicker}</div>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 18, color: KE.ink, letterSpacing: -0.3, marginTop: 4 }}>{title}</div>
    </div>
  );
}

function Label({ children, optional }) {
  return (
    <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4, color: KE.ink, marginBottom: 8, display: "flex", gap: 6 }}>
      {children}{optional && <span style={{ color: KE.mute }}>(OPTIONAL)</span>}
    </div>
  );
}

function Field({ placeholder, value, suffix, icon }) {
  return (
    <div style={{ height: 48, borderRadius: 10, background: KE.surface, border: `1px solid ${KE.line}`, display: "flex", alignItems: "center", padding: "0 14px", gap: 10 }}>
      {icon && <Ico name={icon} size={16} color={KE.mute} sw={2} />}
      <span style={{ flex: 1, fontFamily: FONT_BODY, fontSize: 14, color: value ? KE.ink : KE.muteSoft }}>{value || placeholder}</span>
      {suffix && <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.mute }}>{suffix}</span>}
    </div>
  );
}

function Row({ children }) {
  return <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>{children}</div>;
}
function Group({ children }) {
  return <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>{children}</div>;
}

function Pills({ options, value, onChange, wrap = true }) {
  return (
    <div style={{ display: "flex", flexWrap: wrap ? "wrap" : "nowrap", gap: 7, overflowX: wrap ? "visible" : "auto" }}>
      {options.map(o => {
        const on = o.k === value;
        return (
          <div key={o.k} onClick={() => onChange(o.k)} style={{
            display: "flex", alignItems: "center", gap: 6, padding: "9px 13px", borderRadius: 999, cursor: "pointer",
            background: on ? KE.ink : KE.surface, border: `1px solid ${on ? KE.ink : KE.line}`, color: on ? KE.surface : KE.ink,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10.5, letterSpacing: 1, whiteSpace: "nowrap", flexShrink: 0,
          }}>
            {o.icon && <Ico name={o.icon} size={14} color={on ? KE.surface : KE.ink} sw={2} />}
            {o.label}
          </div>
        );
      })}
    </div>
  );
}

function Seg({ options, value, onChange }) {
  return (
    <div style={{ display: "flex", gap: 6 }}>
      {options.map(o => {
        const on = o === value;
        return (
          <div key={o} onClick={() => onChange(o)} style={{
            flex: 1, height: 42, borderRadius: 8, cursor: "pointer",
            background: on ? KE.ink : KE.surface, border: `1px solid ${on ? KE.ink : KE.line}`, color: on ? KE.surface : KE.ink,
            display: "grid", placeItems: "center",
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1,
          }}>{o}</div>
        );
      })}
    </div>
  );
}

function RemindNote() {
  return (
    <div style={{ display: "flex", gap: 10, marginTop: 12, padding: "11px 13px", borderRadius: 10, background: KE.accentWash, border: `1px solid ${KE.accentSoft}` }}>
      <Ico name="bell" size={16} color={KE.accent} sw={2} />
      <div style={{ fontFamily: FONT_BODY, fontSize: 11.5, color: KE.ink2, lineHeight: 1.45 }}>
        You'll get a push notification on the chosen day, plus a reminder the morning it's due.
      </div>
    </div>
  );
}

function Submit({ label, onClick }) {
  return (
    <button onClick={onClick} style={{
      marginTop: 28, width: "100%", height: 56, borderRadius: 12, border: "none", background: KE.accent, color: KE.onAccent,
      display: "flex", alignItems: "center", justifyContent: "center", gap: 10, cursor: "pointer",
    }}>
      <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.8 }}>{label}</span>
      <Ico name="check" size={17} color={KE.onAccent} sw={2.6} />
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// Schedule maintenance
// ─────────────────────────────────────────────────────────
function ScheduleScreen({ onClose }) {
  const [task, setTask] = useState("oil");
  const [dueBy, setDueBy] = useState("DATE");
  const [remind, setRemind] = useState("2 WEEKS");
  const [recur, setRecur] = useState(true);
  const tasks = [
    { k: "oil", label: "OIL & FILTER", icon: "oil" },
    { k: "itp", label: "ITP", icon: "gauge" },
    { k: "service", label: "MAJOR SERVICE", icon: "wrench" },
    { k: "tuning", label: "TUNING", icon: "chip" },
    { k: "brakes", label: "BRAKES", icon: "disc" },
    { k: "tires", label: "TIRES", icon: "tire" },
    { k: "filters", label: "FILTERS", icon: "filter" },
  ];
  return (
    <div style={{ width: 390, height: 844, background: KE.bg, fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }} />
      <ModalBar title="SCHEDULE" onClose={onClose} />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        <FormHeader kicker="MAINTENANCE · NEW TASK" title={"Schedule a\nService"} sub="Set a reminder before your next service, inspection or renewal is due." />
        <ForChassis />

        <div style={{ padding: "0 20px 32px" }}>
          <Sec kicker="01 — TASK" title="What needs doing?" />
          <Group>
            <div>
              <Label>SERVICE TYPE</Label>
              <Pills options={tasks} value={task} onChange={setTask} />
            </div>
            <div>
              <Label>TITLE</Label>
              <Field placeholder="e.g. Oil & filter change · Mobil 1 0W-40" />
            </div>
          </Group>

          <Sec kicker="02 — WHEN" title="Due by" />
          <Group>
            <div>
              <Label>TRIGGER</Label>
              <Seg options={["DATE", "MILEAGE", "BOTH"]} value={dueBy} onChange={setDueBy} />
            </div>
            <Row>
              <div>
                <Label>DUE DATE</Label>
                <Field placeholder="15 Aug 2026" icon="cal" />
              </div>
              <div>
                <Label>AT ODOMETER</Label>
                <Field placeholder="30,000" suffix="KM" />
              </div>
            </Row>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 14px", borderRadius: 10, background: KE.surface, border: `1px solid ${KE.line}` }}>
              <div>
                <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1, color: KE.ink }}>REPEAT</div>
                <div style={{ fontFamily: FONT_BODY, fontSize: 11, color: KE.mute, marginTop: 2 }}>Every 12 months / 10,000 km</div>
              </div>
              <div onClick={() => setRecur(r => !r)} style={{ width: 46, height: 28, borderRadius: 999, background: recur ? KE.accent : KE.muteSoft, position: "relative", cursor: "pointer", transition: "background .15s" }}>
                <div style={{ position: "absolute", top: 3, left: recur ? 21 : 3, width: 22, height: 22, borderRadius: 999, background: "#fff", transition: "left .15s" }} />
              </div>
            </div>
          </Group>

          <Sec kicker="03 — REMIND ME" title="Notify me before" />
          <Seg options={["1 WEEK", "2 WEEKS", "1 MONTH"]} value={remind} onChange={setRemind} />
          <RemindNote />

          <div style={{ marginTop: 22 }}>
            <Label optional>NOTES</Label>
            <div style={{ minHeight: 84, borderRadius: 10, background: KE.surface, border: `1px solid ${KE.line}`, padding: "12px 14px", fontFamily: FONT_BODY, fontSize: 14, color: KE.muteSoft, lineHeight: 1.5 }}>
              Preferred shop, parts, or anything to remember…
            </div>
          </div>

          <Submit label="SCHEDULE TASK" onClick={onClose} />
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Add document / insurance
// ─────────────────────────────────────────────────────────
function DocumentScreen({ onClose }) {
  const [type, setType] = useState("casco");
  const [remind, setRemind] = useState("2 WEEKS");
  const types = [
    { k: "rca",   label: "RCA",       icon: "shield" },
    { k: "casco", label: "CASCO",     icon: "shield" },
    { k: "itp",   label: "ITP",       icon: "gauge" },
    { k: "rov",   label: "ROVINIETĂ", icon: "ticket" },
    { k: "other", label: "OTHER",     icon: "doc" },
  ];
  return (
    <div style={{ width: 390, height: 844, background: KE.bg, fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }} />
      <ModalBar title="ADD DOCUMENT" onClose={onClose} />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        <FormHeader kicker="DOCUMENTS · NEW ENTRY" title={"Track a\nDocument"} sub="Log an insurance policy or inspection and get reminded before it expires." />
        <ForChassis />

        <div style={{ padding: "0 20px 32px" }}>
          <Sec kicker="01 — TYPE" title="What are you adding?" />
          <Group>
            <div>
              <Label>DOCUMENT TYPE</Label>
              <Pills options={types} value={type} onChange={setType} />
            </div>
            <div>
              <Label>PROVIDER / ISSUER</Label>
              <Field placeholder="e.g. Groupama" />
            </div>
            <div>
              <Label optional>POLICY / DOCUMENT NUMBER</Label>
              <Field placeholder="e.g. RO-CASCO-8842190" icon="doc" />
            </div>
          </Group>

          <Sec kicker="02 — VALIDITY" title="Dates & cost" />
          <Group>
            <Row>
              <div>
                <Label>START DATE</Label>
                <Field placeholder="30 Jul 2025" icon="cal" />
              </div>
              <div>
                <Label>EXPIRY DATE</Label>
                <Field placeholder="30 Jul 2026" icon="cal" />
              </div>
            </Row>
            <div>
              <Label optional>COST</Label>
              <Field placeholder="4,200" suffix="RON" />
            </div>
          </Group>

          <Sec kicker="03 — REMIND ME" title="Notify me before expiry" />
          <Seg options={["1 WEEK", "2 WEEKS", "1 MONTH"]} value={remind} onChange={setRemind} />
          <RemindNote />

          <div style={{ marginTop: 22, display: "flex", alignItems: "center", gap: 10, padding: "12px 14px", borderRadius: 10, background: KE.surface, border: `1px solid ${KE.line}` }}>
            <Ico name="check" size={16} color={SB.ok} sw={2.6} />
            <div style={{ fontFamily: FONT_BODY, fontSize: 12, color: KE.ink2, lineHeight: 1.45 }}>
              Saved documents are added to this car's service book and travel with it.
            </div>
          </div>

          <Submit label="SAVE DOCUMENT" onClick={onClose} />
        </div>
      </div>
    </div>
  );
}

window.SB_OverviewScreen = OverviewScreen;
window.SB_HistoryScreen  = HistoryScreen;
window.SB_ScheduleScreen = ScheduleScreen;
window.SB_DocumentScreen = DocumentScreen;
