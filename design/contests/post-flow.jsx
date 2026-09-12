// Post Composer flow — Kinetic Edge
// Reuses KEFlow tokens + primitives; adds a 5-step windowed progress bar,
// iOS-style switches, tag chips, photo tiles, a manage sheet shell.
const PF_BASE = window.KEFlow;
const { T, DISP, BODY, MONO, Field, FieldRow, Input, Textarea } = PF_BASE;

const POST_STEPS = ["PHOTOS", "CAPTION", "TAGS", "VISIBILITY", "REVIEW"];

// glyphs
const PCheck = ({ c = "#fff", w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none">
    <path d="M5 13l4 4 10-11" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);
const PArrow = ({ c = "#fff", w = 17 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none">
    <path d="M5 12h13M13 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);
const PClose = ({ c = T.ink, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none">
    <path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2.4" strokeLinecap="round"/>
  </svg>
);

// ─────────────────────────────────────────────────────────────
// Windowed progress — prev · current · next (post flow, 5 steps)
// ─────────────────────────────────────────────────────────────
function PostProgress({ current, mode = "create" }) {
  const total = POST_STEPS.length;
  const X = { prev: 17, cur: 50, next: 83 };
  const ROW_H = 46, NODE_CY = 22;

  const prevSlot = current > 1
    ? { kind: "done", n: current - 1, label: POST_STEPS[current - 2] }
    : { kind: "start", label: mode === "edit" ? "EDIT" : "START" };
  const nextSlot = current < total
    ? { kind: "upcoming", n: current + 1, label: POST_STEPS[current] }
    : { kind: "finish", label: "PUBLISH" };
  const curSlot = { kind: "current", n: current, label: POST_STEPS[current - 1] };

  const Node = ({ slot }) => {
    if (slot.kind === "current") return (
      <div style={{ width: 46, height: 46, borderRadius: 16, background: T.ink, display: "grid", placeItems: "center",
        boxShadow: `0 0 0 5px ${T.accentSoft}, 0 8px 18px rgba(11,11,12,0.20)` }}>
        <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 16, color: "#fff" }}>{String(slot.n).padStart(2,"0")}</span>
      </div>);
    if (slot.kind === "done") return (
      <div style={{ width: 28, height: 28, borderRadius: 9, background: T.accent, display: "grid", placeItems: "center",
        boxShadow: "0 2px 6px rgba(255,77,0,0.30)" }}><PCheck w={13}/></div>);
    if (slot.kind === "upcoming") return (
      <div style={{ width: 28, height: 28, borderRadius: 9, background: T.surface, border: `1.5px solid ${T.line}`, display: "grid", placeItems: "center" }}>
        <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, color: T.muteSoft }}>{String(slot.n).padStart(2,"0")}</span>
      </div>);
    const finish = slot.kind === "finish";
    return (
      <div style={{ width: 24, height: 24, borderRadius: 8, background: T.bgSoft, border: `1.5px dashed ${T.muteSoft}`, display: "grid", placeItems: "center" }}>
        {finish
          ? <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M5 12h13M13 6l6 6-6 6" stroke={T.muteSoft} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          : <div style={{ width: 7, height: 7, borderRadius: 99, background: T.muteSoft }}/>}
      </div>);
  };

  const Cell = ({ slot, x }) => {
    const isCur = slot.kind === "current";
    const labelColor = isCur ? T.ink : slot.kind === "done" ? T.ink2 : slot.kind === "upcoming" ? T.mute : T.muteSoft;
    return (
      <div style={{ position: "absolute", left: `${x}%`, top: 0, transform: "translateX(-50%)",
        display: "flex", flexDirection: "column", alignItems: "center",
        opacity: isCur ? 1 : (slot.kind === "start" || slot.kind === "finish") ? 0.5 : 0.62 }}>
        <div style={{ height: ROW_H, display: "flex", alignItems: "center" }}><Node slot={slot}/></div>
        <div style={{ marginTop: isCur ? 11 : 9, whiteSpace: "nowrap", fontFamily: DISP, fontWeight: 700,
          fontSize: isCur ? 14.5 : 9.5, letterSpacing: isCur ? 0.2 : 1.1, color: labelColor }}>{slot.label}</div>
        {isCur && (
          <div style={{ marginTop: 4, fontFamily: MONO, fontSize: 8.5, letterSpacing: 1, color: T.mute, whiteSpace: "nowrap" }}>
            STEP {current} / {total}
          </div>)}
      </div>);
  };

  return (
    <div className="ke-anim" key={current} style={{ position: "relative", height: 92, padding: "8px 18px 0",
      animation: "keSlideIn .5s cubic-bezier(.2,.7,.3,1) both" }}>
      <div style={{ position: "absolute", left: `${X.prev}%`, right: `${100 - X.next}%`, top: 8 + NODE_CY - 1, height: 2.5, borderRadius: 2, background: T.line }}/>
      <div style={{ position: "absolute", left: `${X.prev}%`, width: `${X.cur - X.prev}%`, top: 8 + NODE_CY - 1, height: 2.5, borderRadius: 2, background: T.accent }}/>
      <Cell slot={prevSlot} x={X.prev}/>
      <Cell slot={curSlot} x={X.cur}/>
      <Cell slot={nextSlot} x={X.next}/>
    </div>);
}

// ── Flow header (close · title · counter) ────────────────────
function PostHeader({ step, total = 5, mode = "create" }) {
  return (
    <div style={{ height: 48, padding: "0 16px", display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
      <div style={{ width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center", background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard }}>
        <PClose/>
      </div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 2.4, color: T.ink, whiteSpace: "nowrap" }}>
        {mode === "edit" ? "EDIT POST" : "NEW POST"}
      </div>
      <div style={{ minWidth: 36, height: 36, padding: "0 10px", borderRadius: 12, display: "grid", placeItems: "center",
        fontFamily: MONO, fontWeight: 700, fontSize: 12, letterSpacing: 0.5, color: T.mute }}>
        {String(step).padStart(2,"0")}<span style={{ color: T.muteSoft }}>/{String(total).padStart(2,"0")}</span>
      </div>
    </div>);
}

function PostSectionHeader({ step, kicker, title, sub }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>
        {String(step).padStart(2,"0")} — {kicker}
      </div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 26, letterSpacing: -0.9, color: T.ink, marginTop: 7, lineHeight: 1.05 }}>{title}</div>
      {sub && <div style={{ fontFamily: BODY, fontSize: 13, color: T.mute, lineHeight: 1.5, marginTop: 8 }}>{sub}</div>}
    </div>);
}

// ── iOS-style switch ─────────────────────────────────────────
function Switch({ on }) {
  return (
    <div style={{ width: 50, height: 30, borderRadius: 99, padding: 3, flexShrink: 0,
      background: on ? T.accent : "#D8D2C9", transition: "background .2s",
      boxShadow: on ? "inset 0 0 0 1px rgba(255,77,0,0.2)" : "inset 0 0 0 1px rgba(0,0,0,0.05)",
      display: "flex", justifyContent: on ? "flex-end" : "flex-start" }}>
      <div style={{ width: 24, height: 24, borderRadius: 99, background: "#fff", boxShadow: "0 2px 5px rgba(0,0,0,0.18)" }}/>
    </div>);
}

// ── Toggle row (visibility) ──────────────────────────────────
function ToggleRow({ icon, title, sub, on, last }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 13, padding: "16px 16px",
      borderBottom: last ? "none" : `1px solid ${T.line2}` }}>
      <div style={{ width: 38, height: 38, borderRadius: 11, background: on ? T.accentWash : T.bgSoft,
        border: `1px solid ${on ? T.accentSoft : T.line}`, display: "grid", placeItems: "center", flexShrink: 0 }}>{icon}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 15, color: T.ink, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontFamily: BODY, fontSize: 12, color: T.mute, marginTop: 2, lineHeight: 1.4 }}>{sub}</div>
      </div>
      <Switch on={on}/>
    </div>);
}

// ── Tag chip (person or car) ─────────────────────────────────
function TagChip({ kind, label, sub, img }) {
  return (
    <div style={{ display: "inline-flex", alignItems: "center", gap: 9, paddingLeft: 5, paddingRight: 10, height: 42,
      borderRadius: 99, background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard }}>
      <div style={{ width: 32, height: 32, borderRadius: kind === "car" ? 9 : 99, overflow: "hidden", flexShrink: 0, background: T.bgSoft }}>
        <img src={img} style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
      </div>
      <div style={{ display: "flex", flexDirection: "column", lineHeight: 1.1 }}>
        <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 13, color: T.ink, letterSpacing: -0.2 }}>{label}</span>
        {sub && <span style={{ fontFamily: MONO, fontSize: 8.5, letterSpacing: 0.4, color: T.mute, marginTop: 2 }}>{sub}</span>}
      </div>
      <div style={{ width: 20, height: 20, borderRadius: 99, background: T.bgSoft, display: "grid", placeItems: "center", marginLeft: 2 }}>
        <PClose c={T.mute} w={10}/>
      </div>
    </div>);
}

// ── Footer (Back + primary) ──────────────────────────────────
function PostFooter({ showBack, label, accentLabel = true }) {
  return (
    <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${T.line}`, background: T.bg, display: "flex", gap: 12 }}>
      {showBack && (
        <button style={{ width: 100, height: 54, borderRadius: 16, border: `1.5px solid ${T.line}`, background: T.surface, color: T.ink, cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.6, display: "flex", alignItems: "center", justifyContent: "center", gap: 8, boxShadow: T.shadowCard }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M19 12H6M11 6l-6 6 6 6" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
          BACK
        </button>)}
      <button style={{ flex: 1, height: 54, borderRadius: 16, border: "none", background: T.accent, color: "#fff", cursor: "pointer",
        fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6, display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
        boxShadow: "0 10px 24px rgba(255,77,0,0.30)", whiteSpace: "nowrap" }}>
        {label}<PArrow/>
      </button>
    </div>);
}

// ── Screen shell ─────────────────────────────────────────────
function PostShell({ step, kicker, title, sub, children, showBack, primaryLabel, mode = "create" }) {
  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column",
      fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <PostHeader step={step} mode={mode}/>
      <PostProgress current={step} mode={mode}/>
      <div style={{ height: 1, background: T.line, margin: "4px 0 0" }}/>
      <div className="ke-anim" key={step} style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 18px 22px", animation: "keRise .45s ease both" }}>
        <PostSectionHeader step={step} kicker={kicker} title={title} sub={sub}/>
        {children}
      </div>
      <PostFooter showBack={showBack} label={primaryLabel || "NEXT"}/>
    </div>);
}

window.KEPost = {
  POST_STEPS, PostProgress, PostHeader, PostSectionHeader, PostShell, PostFooter,
  Switch, ToggleRow, TagChip, PCheck, PArrow, PClose,
};
