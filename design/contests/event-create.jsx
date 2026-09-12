// event-create.jsx — Kinetic Edge
// Organizer flow: create a car-meet event from the map. Single scrolling form +
// an "add organizer" directory sheet + a publish confirmation screen.
// Reuses KEFlow tokens (add-flow.jsx) for the form language, EvIcon for glyphs.

const ECT = window.KEFlow.T;
const EC_DISP = window.KEFlow.DISP;
const EC_BODY = window.KEFlow.BODY;
const EC_MONO = window.KEFlow.MONO;
const { Field, Label } = window.KEFlow;

const ECAV = (n) => `assets/av-${n}.svg`;

const CREATOR = { kind: "profile", id: "torque_sasha", name: "Sasha Korev", handle: "torque_sasha", avatar: ECAV(1), verified: true };

// Mocked directory — individuals + certified business accounts (own accounts, not managed by a person)
const ORG_DIRECTORY = [
  { kind: "profile", id: "jdm_jules", name: "Jules Marchand", handle: "jdm_jules", avatar: ECAV(2), verified: true },
  { kind: "profile", id: "noctis_nico", name: "Nico Berger", handle: "noctis_nico", avatar: ECAV(6), verified: false },
  { kind: "profile", id: "turbo_tess", name: "Tess Okonkwo", handle: "turbo_tess", avatar: ECAV(7), verified: true },
  { kind: "profile", id: "macro_mark", name: "Mark Ellis", handle: "macro_mark", avatar: ECAV(3), verified: false },
  { kind: "profile", id: "kenji_apex", name: "Kenji Watanabe", handle: "kenji_apex", avatar: ECAV(4), verified: false },
  { kind: "profile", id: "vroom_valeria", name: "Valeria Cruz", handle: "vroom_valeria", avatar: ECAV(5), verified: false },
  { kind: "business", id: "apexdetailing", name: "Apex Detailing Studio", handle: "apexdetailing", avatar: "assets/car-3.png", verified: true, business_type: "Detailing" },
  { kind: "business", id: "rivieratuning", name: "Riviera Tuning Works", handle: "rivieratuning", avatar: "assets/car-2.png", verified: true, business_type: "Tuning" },
  { kind: "business", id: "grandprixparts", name: "GrandPrix Parts Co.", handle: "grandprixparts", avatar: "assets/car-1.png", verified: true, business_type: "Parts" },
  { kind: "business", id: "camdenperformance", name: "Camden Performance", handle: "camdenperformance", avatar: "assets/car-4.png", verified: true, business_type: "Tuning" },
  { kind: "business", id: "mayfairdetail", name: "Mayfair Detail Lab", handle: "mayfairdetail", avatar: "assets/car-3.png", verified: true, business_type: "Detailing" }
];

// ── small local glyphs ───────────────────────────────────────
function ECIcon({ k, c = ECT.ink, s = 15 }) {
  const p = { width: s, height: s, viewBox: "0 0 24 24", fill: "none" };
  if (k === "camera") return <svg {...p}><path d="M4 8h3l1.5-2.5h7L17 8h3a1 1 0 011 1v10a1 1 0 01-1 1H4a1 1 0 01-1-1V9a1 1 0 011-1z" stroke={c} strokeWidth="2" strokeLinejoin="round" /><circle cx="12" cy="13.5" r="3.6" stroke={c} strokeWidth="2" /></svg>;
  if (k === "search") return <svg {...p}><circle cx="11" cy="11" r="7" stroke={c} strokeWidth="2" /><path d="M20 20l-3.5-3.5" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "back") return <svg {...p}><path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "close") return <svg {...p}><path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2.4" strokeLinecap="round" /></svg>;
  if (k === "plus") return <svg {...p}><path d="M12 5v14M5 12h14" stroke={c} strokeWidth="2.4" strokeLinecap="round" /></svg>;
  if (k === "check") return <svg {...p}><path d="M5 12l4 4 10-10" stroke={c} strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "trash") return <svg {...p}><path d="M4 7h16M9 7V5a1 1 0 011-1h4a1 1 0 011 1v2m2 0-1 13a1 1 0 01-1 1H8a1 1 0 01-1-1L6 7" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "pin") return <svg {...p}><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={c} strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke={c} strokeWidth="2" /></svg>;
  if (k === "car") return <svg {...p}><path d="M5 16v-3.2L6.8 8h10.4L19 12.8V16" stroke={c} strokeWidth="2" strokeLinejoin="round" /><path d="M3 16h18" stroke={c} strokeWidth="2" strokeLinecap="round" /><circle cx="7.5" cy="17.5" r="1.6" stroke={c} strokeWidth="2" /><circle cx="16.5" cy="17.5" r="1.6" stroke={c} strokeWidth="2" /></svg>;
  if (k === "lock") return <svg {...p}><rect x="5" y="11" width="14" height="9" rx="2.5" stroke={c} strokeWidth="2" /><path d="M8 11V8a4 4 0 018 0v3" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  return null;
}

function ECSwitch({ on, onClick }) {
  return (
    <button onClick={onClick} style={{ border: "none", padding: 0, cursor: "pointer", background: "transparent", flexShrink: 0 }}>
      <div style={{
        width: 50, height: 30, borderRadius: 99, padding: 3, background: on ? ECT.accent : "#D8D2C9",
        boxShadow: on ? `inset 0 0 0 1px rgba(255,77,0,0.2)` : "inset 0 0 0 1px rgba(0,0,0,0.05)",
        display: "flex", justifyContent: on ? "flex-end" : "flex-start", transition: "background .2s"
      }}>
        <div style={{ width: 24, height: 24, borderRadius: 99, background: "#fff", boxShadow: "0 2px 5px rgba(0,0,0,0.18)" }} />
      </div>
    </button>);
}

function ECInput({ value, onChange, placeholder, prefix, type = "text" }) {
  return (
    <div style={{
      height: 52, borderRadius: 14, background: ECT.surface, border: `1.5px solid ${ECT.line}`,
      boxShadow: ECT.shadowCard, display: "flex", alignItems: "center", padding: "0 15px", gap: 10
    }}>
      {prefix}
      <input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} type={type} style={{
        flex: 1, minWidth: 0, border: "none", outline: "none", background: "transparent",
        fontFamily: EC_BODY, fontSize: 15, fontWeight: 500, color: ECT.ink
      }} />
    </div>);
}

function ECTextarea({ value, onChange, placeholder, rows = 3 }) {
  return (
    <textarea value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} rows={rows} style={{
      width: "100%", minHeight: 92, resize: "vertical", borderRadius: 14, background: ECT.surface,
      border: `1.5px solid ${ECT.line}`, boxShadow: ECT.shadowCard, padding: "13px 15px", boxSizing: "border-box",
      fontFamily: EC_BODY, fontSize: 14.5, fontWeight: 500, lineHeight: 1.5, color: ECT.ink, outline: "none"
    }} />);
}

function SectionLabel({ children, optional }) {
  return (
    <div style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: ECT.ink, marginBottom: 9, display: "flex", gap: 6 }}>
      {children}{optional && <span style={{ color: ECT.muteSoft, fontWeight: 700 }}>OPTIONAL</span>}
    </div>);
}

// ── Cover photo tile (visual placeholder) ────────────────────
function CoverTile() {
  return (
    <div style={{
      height: 150, borderRadius: 16, background: ECT.surface, border: `1.5px dashed ${ECT.muteSoft}`,
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 8, cursor: "pointer"
    }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, background: ECT.bgSoft, display: "grid", placeItems: "center" }}>
        <ECIcon k="camera" c={ECT.mute} s={18} />
      </div>
      <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6, color: ECT.ink2 }}>ADD COVER PHOTO</span>
      <span style={{ fontFamily: EC_MONO, fontSize: 9.5, color: ECT.muteSoft }}>1600 × 900 recommended</span>
    </div>);
}

// ── Organizer row (creator / added co-organizer) ─────────────
function OrgRow({ org, tag, onRemove }) {
  const isBiz = org.kind === "business";
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10, background: ECT.bgSoft, borderRadius: 14, padding: "10px 12px" }}>
      <img src={org.avatar} alt="" style={{ width: 36, height: 36, borderRadius: isBiz ? 10 : 999, objectFit: "cover", background: ECT.line2, flexShrink: 0 }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
          <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 13, color: ECT.ink, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{org.name}</span>
          {org.verified && <span style={{ width: 6, height: 6, borderRadius: 999, background: isBiz ? "oklch(65% 0.19 258)" : ECT.accent, flexShrink: 0 }} />}
        </div>
        <span style={{ fontFamily: EC_BODY, fontSize: 11.5, color: ECT.mute }}>{isBiz ? org.business_type : `@${org.handle}`}</span>
      </div>
      <span style={{
        flexShrink: 0, fontFamily: EC_DISP, fontWeight: 700, fontSize: 8, letterSpacing: 0.8,
        borderRadius: 999, padding: "3px 7px", background: ECT.surface, color: ECT.mute
      }}>{tag || (isBiz ? "BUSINESS" : "INDIVIDUAL")}</span>
      {onRemove && (
        <button onClick={onRemove} style={{ width: 26, height: 26, borderRadius: 999, border: "none", background: ECT.surface, cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
          <ECIcon k="close" c={ECT.mute} s={11} />
        </button>)}
    </div>);
}

// ── Add-organizer sheet — mocked directory search ────────────
function AddOrganizerSheet({ excludeIds, onClose, onAdd }) {
  const [query, setQuery] = React.useState("");
  const [picked, setPicked] = React.useState([]);
  const pool = ORG_DIRECTORY.filter((o) => !excludeIds.includes(o.id));
  const q = query.trim().toLowerCase();
  const results = pool.filter((o) => !q || o.name.toLowerCase().includes(q) || o.handle.toLowerCase().includes(q));
  const toggle = (id) => setPicked((p) => p.includes(id) ? p.filter((x) => x !== id) : [...p, id]);

  return (
    <div style={{ position: "absolute", inset: 0, zIndex: 130, background: ECT.bg, display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "0 18px 12px", flexShrink: 0 }}>
        <button onClick={onClose} style={{ width: 36, height: 36, borderRadius: 12, border: `1px solid ${ECT.line}`, background: ECT.surface, cursor: "pointer", display: "grid", placeItems: "center" }}>
          <ECIcon k="back" c={ECT.ink} s={15} />
        </button>
        <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 16, color: ECT.ink, letterSpacing: -0.3 }}>Add organizer</span>
      </div>
      <div style={{ padding: "0 18px 12px", flexShrink: 0 }}>
        <div style={{ height: 48, borderRadius: 14, background: ECT.surface, border: `1.5px solid ${ECT.line}`, boxShadow: ECT.shadowCard, display: "flex", alignItems: "center", padding: "0 14px", gap: 10 }}>
          <ECIcon k="search" c={ECT.mute} s={16} />
          <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search individuals or businesses…" style={{ flex: 1, border: "none", outline: "none", background: "transparent", fontFamily: EC_BODY, fontSize: 14, color: ECT.ink }} />
        </div>
      </div>
      <p style={{ margin: "0 18px 12px", fontFamily: EC_BODY, fontSize: 12, color: ECT.mute, lineHeight: 1.5 }}>
        Co-organizers can be individual accounts or certified business accounts. They'll be able to manage this event with you.
      </p>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "0 18px 18px", display: "flex", flexDirection: "column", gap: 8 }}>
        {results.map((o) => {
          const on = picked.includes(o.id);
          const isBiz = o.kind === "business";
          return (
            <button key={o.id} onClick={() => toggle(o.id)} style={{
              width: "100%", textAlign: "left", border: "none", cursor: "pointer", background: ECT.surface,
              borderRadius: 14, padding: "10px 12px", display: "flex", alignItems: "center", gap: 10,
              boxShadow: on ? `inset 0 0 0 2px ${ECT.ink}` : ECT.shadowCard
            }}>
              <img src={o.avatar} alt="" style={{ width: 38, height: 38, borderRadius: isBiz ? 10 : 999, objectFit: "cover", background: ECT.line2, flexShrink: 0 }} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                  <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 13.5, color: ECT.ink, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{o.name}</span>
                  {o.verified && <span style={{ width: 6, height: 6, borderRadius: 999, background: isBiz ? "oklch(65% 0.19 258)" : ECT.accent, flexShrink: 0 }} />}
                </div>
                <span style={{ fontFamily: EC_BODY, fontSize: 11.5, color: ECT.mute }}>{isBiz ? `${o.business_type} · business` : `@${o.handle}`}</span>
              </div>
              <div style={{
                width: 24, height: 24, borderRadius: 999, flexShrink: 0, display: "grid", placeItems: "center",
                background: on ? ECT.ink : ECT.bgSoft, border: on ? "none" : `1.5px solid ${ECT.line}`
              }}>{on ? <ECIcon k="check" c="#fff" s={12} /> : <ECIcon k="plus" c={ECT.mute} s={12} />}</div>
            </button>);
        })}
        {results.length === 0 && <div style={{ padding: "24px 0", textAlign: "center", fontFamily: EC_BODY, fontSize: 13, color: ECT.mute }}>No matches.</div>}
      </div>
      <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${ECT.line}`, background: ECT.bg }}>
        <button
          disabled={!picked.length}
          onClick={() => onAdd(ORG_DIRECTORY.filter((o) => picked.includes(o.id)))}
          style={{
            width: "100%", height: 52, borderRadius: 15, border: "none", cursor: picked.length ? "pointer" : "default",
            background: picked.length ? ECT.ink : ECT.bgSoft, color: picked.length ? "#fff" : ECT.muteSoft,
            fontFamily: EC_DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 1
          }}>{picked.length ? `ADD ${picked.length} ORGANIZER${picked.length > 1 ? "S" : ""}` : "SELECT ORGANIZERS TO ADD"}</button>
      </div>
    </div>);
}

// ── Publish confirmation ──────────────────────────────────────
function EventPublishedScreen({ ev, onDone }) {
  return (
    <div style={{ position: "absolute", inset: 0, zIndex: 140, background: ECT.bg, display: "flex", flexDirection: "column" }}>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "90px 24px 22px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{ width: 64, height: 64, borderRadius: 999, background: ECT.accent, display: "grid", placeItems: "center", boxShadow: "0 10px 24px rgba(255,77,0,0.3)" }}>
          <ECIcon k="check" c="#fff" s={28} />
        </div>
        <div style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 24, color: ECT.ink, letterSpacing: -0.6, marginTop: 20 }}>Event published</div>
        <p style={{ margin: "8px 0 26px", fontFamily: EC_BODY, fontSize: 13.5, color: ECT.mute, lineHeight: 1.5, maxWidth: 280 }}>
          It's live on the map now. {ev.organizers.length > 0 ? "Your co-organizers have been notified." : "Attendees can find it right away."}
        </p>
        <div style={{ width: "100%", background: ECT.surface, borderRadius: 18, boxShadow: ECT.shadowCard, textAlign: "left", overflow: "hidden" }}>
          <div style={{ height: 96, background: ECT.bgSoft, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <ECIcon k="camera" c={ECT.muteSoft} s={22} />
          </div>
          <div style={{ padding: 16 }}>
            <div style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 16, color: ECT.ink, letterSpacing: -0.3 }}>{ev.title || "Untitled event"}</div>
            <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 8 }}>
              <ECIcon k="pin" c={ECT.mute} s={13} />
              <span style={{ fontFamily: EC_BODY, fontSize: 12.5, color: ECT.ink2 }}>{ev.venue || "Location not set"}</span>
            </div>
            <div style={{ marginTop: 8, fontFamily: EC_BODY, fontSize: 12.5, color: ECT.ink2 }}>
              {ev.startDate || "Date TBD"} {ev.startTime && `· ${ev.startTime}`}
            </div>
            <div style={{ display: "flex", gap: 6, marginTop: 12, flexWrap: "wrap" }}>
              <span style={{ fontFamily: EC_MONO, fontSize: 9.5, letterSpacing: 0.5, color: ECT.mute, background: ECT.bgSoft, borderRadius: 999, padding: "4px 9px" }}>
                {ev.requiresApproval ? "APPROVAL REQUIRED" : "OPEN ENTRY"}
              </span>
              <span style={{ fontFamily: EC_MONO, fontSize: 9.5, letterSpacing: 0.5, color: ECT.mute, background: ECT.bgSoft, borderRadius: 999, padding: "4px 9px" }}>
                {1 + ev.organizers.length} ORGANIZER{ev.organizers.length ? "S" : ""}
              </span>
            </div>
          </div>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${ECT.line}` }}>
        <button onClick={onDone} style={{
          width: "100%", height: 54, borderRadius: 16, border: "none", cursor: "pointer",
          background: ECT.ink, color: "#fff", fontFamily: EC_DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.4
        }}>DONE</button>
      </div>
    </div>);
}

// ── Mocked geocoding + full-screen location picker ─────────────
if (typeof document !== "undefined" && !document.getElementById("ec-pin-css")) {
  const s = document.createElement("style");
  s.id = "ec-pin-css";
  s.textContent = `@keyframes ecPinDrop{0%{transform:translate(-50%,-100%) translateY(-22px) scale(.6);opacity:0}60%{transform:translate(-50%,-100%) translateY(4px) scale(1.08);opacity:1}100%{transform:translate(-50%,-100%) translateY(0) scale(1);opacity:1}}@keyframes ecSpin{to{transform:rotate(360deg)}}`;
  document.head.appendChild(s);
}

function ecHash(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) | 0;
  return Math.abs(h);
}
function ecGeocode(query) {
  const h = ecHash(query.trim().toLowerCase() || "monaco");
  const x = 10 + (h % 80);
  const y = 10 + ((h >> 4) % 80);
  const lat = 43.7384 + (y - 50) * 0.0009;
  const lng = 7.4246 + (x - 50) * 0.0012;
  return { x, y, lat, lng };
}
const EC_MAP_CANVAS = { w: 520, h: 980 };
const EC_VIEW = { w: 390, h: 844 };
function ecPanForPoint(x, y) {
  const mx = (x / 100) * EC_MAP_CANVAS.w, my = (y / 100) * EC_MAP_CANVAS.h;
  const nx = Math.min(0, Math.max(EC_VIEW.w - EC_MAP_CANVAS.w, EC_VIEW.w / 2 - mx));
  const ny = Math.min(0, Math.max(EC_VIEW.h - EC_MAP_CANVAS.h, EC_VIEW.h / 2 - my));
  return { x: nx, y: ny };
}

function LocationPickerScreen({ initialAddress, initialCoords, onClose, onSave }) {
  const [query, setQuery] = React.useState(initialAddress || "");
  const [pan, setPan] = React.useState(() => initialCoords ? ecPanForPoint(initialCoords.x, initialCoords.y) : { x: -68, y: -150 });
  const [resolved, setResolved] = React.useState(initialCoords ? { address: initialAddress, coords: initialCoords } : null);
  const [adjusted, setAdjusted] = React.useState(false);
  const [locating, setLocating] = React.useState(false);
  const [dropId, setDropId] = React.useState(0);
  const drag = React.useRef(null);

  const submit = () => {
    const q = query.trim();
    if (!q) return;
    setLocating(true);
    setTimeout(() => {
      const coords = ecGeocode(q);
      setPan(ecPanForPoint(coords.x, coords.y));
      setResolved({ address: q, coords });
      setAdjusted(false);
      setDropId((n) => n + 1);
      setLocating(false);
    }, 450);
  };

  const onDown = (e) => {
    const p = e.touches ? e.touches[0] : e;
    drag.current = { sx: p.clientX, sy: p.clientY, ox: pan.x, oy: pan.y, moved: false };
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const p = e.touches ? e.touches[0] : e;
    const dx = p.clientX - drag.current.sx, dy = p.clientY - drag.current.sy;
    if (Math.abs(dx) + Math.abs(dy) > 4) drag.current.moved = true;
    const nx = Math.min(0, Math.max(EC_VIEW.w - EC_MAP_CANVAS.w, drag.current.ox + dx));
    const ny = Math.min(0, Math.max(EC_VIEW.h - EC_MAP_CANVAS.h, drag.current.oy + dy));
    setPan({ x: nx, y: ny });
    if (resolved) setAdjusted(true);
  };
  const onUp = () => { drag.current = null; };

  return (
    <div style={{ position: "absolute", inset: 0, zIndex: 120, background: ECT.bg, display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <div
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}
        style={{ position: "absolute", inset: 0, overflow: "hidden", cursor: "grab", touchAction: "none" }}>
        <div style={{ position: "absolute", width: EC_MAP_CANVAS.w, height: EC_MAP_CANVAS.h, transform: `translate(${pan.x}px, ${pan.y}px)`, transition: locating ? "transform 500ms ease" : "none" }}>
          {window.MapCanvas ? <window.MapCanvas /> : <div style={{ width: "100%", height: "100%", background: "#ECE7DF" }} />}
        </div>
      </div>

      {/* center pin — fixed to the viewport; the map pans underneath it */}
      <div style={{ position: "absolute", left: "50%", top: "50%", zIndex: 30, pointerEvents: "none" }}>
        <div key={dropId} style={{ position: "relative", transform: "translate(-50%,-100%)", animation: resolved ? "ecPinDrop 480ms cubic-bezier(.3,1.4,.4,1) both" : "none" }}>
          <svg width="34" height="44" viewBox="0 0 34 44" style={{ filter: "drop-shadow(0 6px 8px rgba(0,0,0,0.28))" }}>
            <path d="M17 43S2 26 2 15.5C2 6.9 8.7 2 17 2s15 4.9 15 13.5C32 26 17 43 17 43z" fill={ECT.accent} />
            <circle cx="17" cy="15.5" r="6" fill="#fff" />
          </svg>
        </div>
        <div style={{ width: 10, height: 4, borderRadius: 99, background: "rgba(10,10,10,0.3)", marginTop: -2, filter: "blur(1px)" }} />
      </div>

      {/* header + floating search bar */}
      <div style={{ position: "relative", zIndex: 40 }}>
        <div style={{ height: 54 }} />
        <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "0 16px 10px" }}>
          <button onClick={onClose} style={{ width: 40, height: 40, borderRadius: 13, border: "none", background: ECT.surface, boxShadow: ECT.shadowCard, cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
            <ECIcon k="back" c={ECT.ink} s={16} />
          </button>
          <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 13.5, letterSpacing: 1.4, color: ECT.ink }}>SET LOCATION</span>
        </div>
        <div style={{ padding: "0 16px" }}>
          <div style={{ height: 50, borderRadius: 15, background: ECT.surface, boxShadow: "0 4px 14px rgba(0,0,0,0.1)", display: "flex", alignItems: "center", padding: "0 6px 0 15px", gap: 8 }}>
            <ECIcon k="search" c={ECT.mute} s={16} />
            <input
              value={query} onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => { if (e.key === "Enter") submit(); }}
              placeholder="Enter a street address…"
              style={{ flex: 1, border: "none", outline: "none", background: "transparent", fontFamily: EC_BODY, fontSize: 14.5, color: ECT.ink }} />
            <button onClick={submit} disabled={!query.trim()} style={{
              width: 38, height: 38, borderRadius: 11, border: "none", cursor: query.trim() ? "pointer" : "default",
              background: query.trim() ? ECT.ink : ECT.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
            }}>
              {locating
                ? <div style={{ width: 14, height: 14, borderRadius: 99, border: `2px solid rgba(255,255,255,0.35)`, borderTopColor: "#fff", animation: "ecSpin 700ms linear infinite" }} />
                : <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M5 12h13M13 6l6 6-6 6" stroke={query.trim() ? "#fff" : ECT.muteSoft} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>}
            </button>
          </div>
        </div>
      </div>

      {/* bottom sheet — resolved address + save */}
      <div style={{ marginTop: "auto", position: "relative", zIndex: 40, padding: "14px 16px 18px", background: "linear-gradient(180deg, rgba(242,239,233,0) 0%, " + ECT.bg + " 34%)" }}>
        <div style={{ background: ECT.surface, borderRadius: 16, boxShadow: "0 10px 30px rgba(0,0,0,0.14)", padding: "13px 14px", marginBottom: 10 }}>
          {resolved ? (
            <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
              <ECIcon k="pin" c={ECT.accent} s={16} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: EC_BODY, fontWeight: 600, fontSize: 13.5, color: ECT.ink, lineHeight: 1.35 }}>{resolved.address}</div>
                <div style={{ fontFamily: EC_MONO, fontSize: 9.5, color: ECT.mute, marginTop: 4 }}>
                  {resolved.coords.lat.toFixed(4)}, {resolved.coords.lng.toFixed(4)}{adjusted ? " · pin adjusted" : ""}
                </div>
              </div>
            </div>
          ) : (
            <div style={{ fontFamily: EC_BODY, fontSize: 12.5, color: ECT.mute, lineHeight: 1.5 }}>
              Search an address above, then drag the map to fine-tune the pin — it always stays centered.
            </div>
          )}
        </div>
        <button
          disabled={!resolved}
          onClick={() => resolved && onSave({ address: resolved.address, coords: resolved.coords })}
          style={{
            width: "100%", height: 52, borderRadius: 15, border: "none", cursor: resolved ? "pointer" : "default",
            background: resolved ? ECT.accent : ECT.bgSoft, color: resolved ? "#fff" : ECT.muteSoft,
            fontFamily: EC_DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 1,
            boxShadow: resolved ? "0 10px 24px rgba(255,77,0,0.28)" : "none"
          }}>SAVE LOCATION</button>
      </div>
    </div>);
}

const EVENT_CATEGORIES = [
  { id: "car_meet", label: "Car Meet", enabled: true },
  { id: "track_day", label: "Track Day", enabled: false },
  { id: "car_show", label: "Car Show", enabled: false },
  { id: "cruise", label: "Cruise", enabled: false }
];

function CategoryPicker({ value, onChange }) {
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
      {EVENT_CATEGORIES.map((c) => {
        const on = value === c.id;
        return (
          <button key={c.id} disabled={!c.enabled} onClick={() => c.enabled && onChange(c.id)} style={{
            display: "flex", alignItems: "center", gap: 7, height: 42, padding: "0 15px", borderRadius: 999,
            border: on ? "none" : `1.5px solid ${ECT.line}`, cursor: c.enabled ? "pointer" : "default",
            background: on ? ECT.ink : c.enabled ? ECT.surface : ECT.bgSoft,
            boxShadow: on ? "0 3px 10px rgba(11,11,12,0.18)" : "none", opacity: c.enabled ? 1 : 0.55
          }}>
            {c.enabled ? (on && <ECIcon k="check" c="#fff" s={12} />) : <ECIcon k="lock" c={ECT.muteSoft} s={12} />}
            <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 12, letterSpacing: 0.5, color: on ? "#fff" : c.enabled ? ECT.ink2 : ECT.muteSoft }}>{c.label}</span>
            {!c.enabled && <span style={{ fontFamily: EC_MONO, fontSize: 8, letterSpacing: 0.6, color: ECT.muteSoft }}>SOON</span>}
          </button>);
      })}
    </div>);
}

// ── Main create-event screen ──────────────────────────────────
function CreateEventScreen({ onClose }) {
  const [title, setTitle] = React.useState("");
  const [category, setCategory] = React.useState("car_meet");
  const [description, setDescription] = React.useState("");
  const [venue, setVenue] = React.useState("");
  const [address, setAddress] = React.useState("");
  const [coords, setCoords] = React.useState(null);
  const [showLocationPicker, setShowLocationPicker] = React.useState(false);
  const [startDate, setStartDate] = React.useState("");
  const [startTime, setStartTime] = React.useState("");
  const [endDate, setEndDate] = React.useState("");
  const [endTime, setEndTime] = React.useState("");
  const [capacity, setCapacity] = React.useState("");
  const [requiresApproval, setRequiresApproval] = React.useState(true);
  const [deadlineDate, setDeadlineDate] = React.useState("");
  const [deadlineTime, setDeadlineTime] = React.useState("");
  const [rules, setRules] = React.useState([]);
  const [organizers, setOrganizers] = React.useState([]);
  const [showAddOrg, setShowAddOrg] = React.useState(false);
  const [published, setPublished] = React.useState(false);

  const canPublish = title.trim() && category && venue.trim() && address && startDate && startTime;

  const ev = { title, venue, startDate, startTime, requiresApproval, organizers };

  if (published) return <EventPublishedScreen ev={ev} onDone={onClose} />;

  return (
    <div style={{ position: "absolute", inset: 0, zIndex: 100, background: ECT.bg, display: "flex", flexDirection: "column", fontFamily: EC_BODY, color: ECT.ink }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 18px 14px", flexShrink: 0 }}>
        <button onClick={onClose} style={{ width: 36, height: 36, borderRadius: 12, border: `1px solid ${ECT.line}`, background: ECT.surface, cursor: "pointer", display: "grid", placeItems: "center" }}>
          <ECIcon k="close" c={ECT.ink} s={13} />
        </button>
        <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 15, letterSpacing: 1.6, color: ECT.ink }}>NEW EVENT</span>
        <div style={{ width: 36 }} />
      </div>

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "0 18px 22px", display: "flex", flexDirection: "column", gap: 20 }}>
        <CoverTile />

        <Field label="EVENT TITLE">
          <ECInput value={title} onChange={setTitle} placeholder="Casino Square Cars & Coffee" />
        </Field>

        <div>
          <SectionLabel>EVENT CATEGORY</SectionLabel>
          <CategoryPicker value={category} onChange={setCategory} />
          <span style={{ display: "block", marginTop: 8, fontFamily: EC_MONO, fontSize: 10, color: ECT.muteSoft }}>More categories are coming soon.</span>
        </div>

        <Field label="DESCRIPTION">
          <ECTextarea value={description} onChange={setDescription} placeholder="What's the meet about, who's it for, anything people should know before showing up…" />
        </Field>

        <div>
          <SectionLabel>LOCATION</SectionLabel>
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <ECInput value={venue} onChange={setVenue} placeholder="Venue name — e.g. Place du Casino" />
            {address ? (
              <button onClick={() => setShowLocationPicker(true)} style={{
                width: "100%", textAlign: "left", border: `1.5px solid ${ECT.line}`, borderRadius: 14, background: ECT.surface,
                boxShadow: ECT.shadowCard, cursor: "pointer", padding: "12px 14px", display: "flex", alignItems: "flex-start", gap: 10
              }}>
                <ECIcon k="pin" c={ECT.accent} s={16} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: EC_BODY, fontWeight: 600, fontSize: 13.5, color: ECT.ink, lineHeight: 1.35 }}>{address}</div>
                  {coords && <div style={{ fontFamily: EC_MONO, fontSize: 9, color: ECT.mute, marginTop: 3 }}>{coords.lat.toFixed(4)}, {coords.lng.toFixed(4)}</div>}
                </div>
                <span style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 10, letterSpacing: 0.6, color: ECT.accent, flexShrink: 0, marginTop: 2 }}>EDIT</span>
              </button>
            ) : (
              <button onClick={() => setShowLocationPicker(true)} style={{
                height: 52, borderRadius: 14, border: `1.5px dashed ${ECT.muteSoft}`, background: "transparent", cursor: "pointer",
                display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
                fontFamily: EC_DISP, fontWeight: 700, fontSize: 12, letterSpacing: 0.6, color: ECT.ink2
              }}><ECIcon k="pin" c={ECT.ink2} s={14} />SET LOCATION ON MAP</button>
            )}
          </div>
        </div>

        <div>
          <SectionLabel>DATE & TIME</SectionLabel>
          <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
              <ECInput type="date" value={startDate} onChange={setStartDate} placeholder="Start date" />
              <ECInput type="time" value={startTime} onChange={setStartTime} placeholder="Start time" />
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
              <ECInput type="date" value={endDate} onChange={setEndDate} placeholder="End date" />
              <ECInput type="time" value={endTime} onChange={setEndTime} placeholder="End time" />
            </div>
            <span style={{ fontFamily: EC_MONO, fontSize: 10, color: ECT.muteSoft }}>Leave the end blank for an open-ended meet.</span>
          </div>
        </div>

        <Field label="MAX CAPACITY" optional>
          <ECInput type="number" value={capacity} onChange={setCapacity} placeholder="No limit — e.g. 40 spots" />
        </Field>

        <div style={{ background: ECT.surface, borderRadius: 16, boxShadow: ECT.shadowCard, padding: "14px 16px", display: "flex", flexDirection: "column", gap: 14 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: EC_DISP, fontWeight: 700, fontSize: 14, color: ECT.ink, letterSpacing: -0.2 }}>Require approval to join</div>
              <div style={{ fontFamily: EC_BODY, fontSize: 12, color: ECT.mute, marginTop: 3, lineHeight: 1.4 }}>
                You and your co-organizers review each request before a participant is added to the entry list.
              </div>
            </div>
            <ECSwitch on={requiresApproval} onClick={() => setRequiresApproval((v) => !v)} />
          </div>
          {requiresApproval && (
            <div style={{ borderTop: `1px solid ${ECT.line2}`, paddingTop: 14 }}>
              <SectionLabel optional>REGISTRATION DEADLINE</SectionLabel>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
                <ECInput type="date" value={deadlineDate} onChange={setDeadlineDate} placeholder="Date" />
                <ECInput type="time" value={deadlineTime} onChange={setDeadlineTime} placeholder="Time" />
              </div>
            </div>)}
        </div>

        <div>
          <SectionLabel optional>RULES & GUIDELINES</SectionLabel>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {rules.map((r, i) => (
              <div key={i} style={{ display: "flex", gap: 8, alignItems: "center" }}>
                <div style={{ flex: 1 }}>
                  <ECInput value={r} onChange={(v) => setRules((rs) => rs.map((x, j) => j === i ? v : x))} placeholder={`Rule ${i + 1}`} />
                </div>
                <button onClick={() => setRules((rs) => rs.filter((_, j) => j !== i))} style={{ width: 40, height: 40, borderRadius: 12, border: "none", background: ECT.bgSoft, cursor: "pointer", display: "grid", placeItems: "center", flexShrink: 0 }}>
                  <ECIcon k="trash" c={ECT.mute} s={15} />
                </button>
              </div>))}
            <button onClick={() => setRules((rs) => [...rs, ""])} style={{
              height: 46, borderRadius: 14, border: `1.5px dashed ${ECT.muteSoft}`, background: "transparent", cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 7, fontFamily: EC_DISP, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6, color: ECT.ink2
            }}><ECIcon k="plus" c={ECT.ink2} s={13} />ADD A RULE</button>
          </div>
        </div>

        <div>
          <SectionLabel>ORGANIZERS</SectionLabel>
          <p style={{ margin: "0 0 10px", fontFamily: EC_BODY, fontSize: 12, color: ECT.mute, lineHeight: 1.5 }}>
            You're the creator. Add other individual or certified business accounts to co-organize with you.
          </p>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <OrgRow org={CREATOR} tag="YOU · CREATOR" />
            {organizers.map((o) => (
              <OrgRow key={o.id} org={o} onRemove={() => setOrganizers((os) => os.filter((x) => x.id !== o.id))} />))}
            <button onClick={() => setShowAddOrg(true)} style={{
              height: 46, borderRadius: 14, border: `1.5px dashed ${ECT.muteSoft}`, background: "transparent", cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 7, fontFamily: EC_DISP, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6, color: ECT.ink2
            }}><ECIcon k="plus" c={ECT.ink2} s={13} />ADD ORGANIZER</button>
          </div>
        </div>
      </div>

      <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${ECT.line}`, background: ECT.bg }}>
        <button
          disabled={!canPublish}
          onClick={() => canPublish && setPublished(true)}
          style={{
            width: "100%", height: 54, borderRadius: 16, border: "none", cursor: canPublish ? "pointer" : "default",
            background: canPublish ? ECT.accent : ECT.bgSoft, color: canPublish ? "#fff" : ECT.muteSoft,
            fontFamily: EC_DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
            boxShadow: canPublish ? "0 10px 24px rgba(255,77,0,0.30)" : "none"
          }}>{canPublish ? "PUBLISH EVENT" : "ADD TITLE, LOCATION & START TIME"}</button>
      </div>

      {showAddOrg && (
        <AddOrganizerSheet
          excludeIds={[CREATOR.id, ...organizers.map((o) => o.id)]}
          onClose={() => setShowAddOrg(false)}
          onAdd={(picked) => { setOrganizers((os) => [...os, ...picked]); setShowAddOrg(false); }} />)}

      {showLocationPicker && (
        <LocationPickerScreen
          initialAddress={address}
          initialCoords={coords}
          onClose={() => setShowLocationPicker(false)}
          onSave={({ address: a, coords: c }) => { setAddress(a); setCoords(c); if (!venue.trim()) setVenue(a.split(",")[0]); setShowLocationPicker(false); }} />)}
    </div>);
}

window.CreateEventScreen = CreateEventScreen;
