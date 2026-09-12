// Add-to-Garage flow — Kinetic Edge (premium redesign)
// Windowed 3-step progress bar (prev · current · next), refined inputs,
// premium spacing & motion. Space Grotesk / Manrope / Space Mono.

// ── Premium tokens (warm-neutral, deeper contrast) ───────────
const T = {
  bg:        "#F2EFE9",
  bgSoft:    "#FAF8F4",
  surface:   "#FFFFFF",
  ink:       "#0B0B0C",
  ink2:      "#39393F",
  mute:      "#857F77",
  muteSoft:  "#B6B0A7",
  line:      "#E6E1D9",
  line2:     "#EFEBE3",
  accent:    "#FF4D00",
  accentHot: "#E64500",
  accentSoft:"#FFE6D8",
  accentWash:"rgba(255,77,0,0.07)",
  onAccent:  "#FFFFFF",
  shadowCard:"0 1px 3px rgba(11,11,12,0.05), 0 8px 20px rgba(11,11,12,0.06)",
};
const DISP = `"Space Grotesk", system-ui, sans-serif`;
const BODY = `"Manrope", system-ui, sans-serif`;
const MONO = `"Space Mono", ui-monospace, "SF Mono", monospace`;

// One-time keyframes
if (typeof document !== "undefined" && !document.getElementById("ke-flow-css")) {
  const s = document.createElement("style");
  s.id = "ke-flow-css";
  s.textContent = `
    @keyframes keSlideIn { from { opacity:0; transform: translateX(14px); } to { opacity:1; transform:none; } }
    @keyframes keRise { from { opacity:0; transform: translateY(8px); } to { opacity:1; transform:none; } }
    @media (prefers-reduced-motion: reduce){
      .ke-anim, .ke-anim * { animation: none !important; }
    }
  `;
  document.head.appendChild(s);
}

// ── Small inline glyphs ──────────────────────────────────────
const Check = ({ c = "#fff", w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none">
    <path d="M5 13l4 4 10-11" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);
const Chevron = ({ c = T.mute, w = 13, dir = "down" }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none" style={{
    transform: dir === "down" ? "none" : dir === "right" ? "rotate(-90deg)" : "rotate(90deg)",
  }}>
    <path d="M6 9l6 6 6-6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);
const Arrow = ({ c = "#fff", w = 17 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none">
    <path d="M5 12h13M13 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
  </svg>
);

const STEPS = ["IDENTITY", "PERFORMANCE", "DRIVETRAIN", "STORY", "GALLERY", "MODS"];

// ─────────────────────────────────────────────────────────────
// PROGRESS WINDOW — prev · current · next, current large & bold.
// Ends use START / FINISH markers so 3 slots always read cleanly.
// ─────────────────────────────────────────────────────────────
function ProgressWindow({ current }) {
  const total = STEPS.length;
  const X = { prev: 17, cur: 50, next: 83 };
  const ROW_H = 46;        // node row height
  const NODE_CY = 22;      // node-center y within row

  // slot definitions
  const prevSlot = current > 1
    ? { kind: "done", n: current - 1, label: STEPS[current - 2] }
    : { kind: "start", label: "START" };
  const nextSlot = current < total
    ? { kind: "upcoming", n: current + 1, label: STEPS[current] }
    : { kind: "finish", label: "FINISH" };
  const curSlot = { kind: "current", n: current, label: STEPS[current - 1] };

  const Node = ({ slot }) => {
    if (slot.kind === "current") {
      return (
        <div style={{
          width: 46, height: 46, borderRadius: 16, background: T.ink,
          display: "grid", placeItems: "center",
          boxShadow: `0 0 0 5px ${T.accentSoft}, 0 8px 18px rgba(11,11,12,0.20)`,
        }}>
          <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 16, color: "#fff" }}>
            {String(slot.n).padStart(2, "0")}
          </span>
        </div>
      );
    }
    if (slot.kind === "done") {
      return (
        <div style={{
          width: 28, height: 28, borderRadius: 9, background: T.accent,
          display: "grid", placeItems: "center",
          boxShadow: "0 2px 6px rgba(255,77,0,0.30)",
        }}><Check w={13}/></div>
      );
    }
    if (slot.kind === "upcoming") {
      return (
        <div style={{
          width: 28, height: 28, borderRadius: 9, background: T.surface,
          boxShadow: T.shadowCard, display: "grid", placeItems: "center",
        }}>
          <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, color: T.muteSoft }}>
            {String(slot.n).padStart(2, "0")}
          </span>
        </div>
      );
    }
    // start / finish marker
    const finish = slot.kind === "finish";
    return (
      <div style={{
        width: 24, height: 24, borderRadius: 8, background: T.bgSoft,
        display: "grid", placeItems: "center",
      }}>
        {finish
          ? <svg width="11" height="11" viewBox="0 0 12 12"><path d="M1 1h10v10H1z" fill="none" stroke={T.muteSoft} strokeWidth="1.4"/><path d="M1 1h2.5v2.5H6V6H3.5v2.5H1zM6 3.5h2.5V6H11v2.5H8.5V11H6V8.5H3.5V6H6z" fill={T.muteSoft} opacity=".55"/></svg>
          : <div style={{ width: 7, height: 7, borderRadius: 99, background: T.muteSoft }}/>}
      </div>
    );
  };

  const Cell = ({ slot, x }) => {
    const isCur = slot.kind === "current";
    const labelColor = isCur ? T.ink
      : slot.kind === "done" ? T.ink2
      : slot.kind === "upcoming" ? T.mute : T.muteSoft;
    return (
      <div style={{
        position: "absolute", left: `${x}%`, top: 0, transform: "translateX(-50%)",
        display: "flex", flexDirection: "column", alignItems: "center",
        opacity: isCur ? 1 : (slot.kind === "start" || slot.kind === "finish") ? 0.5 : 0.62,
      }}>
        <div style={{ height: ROW_H, display: "flex", alignItems: "center" }}><Node slot={slot}/></div>
        <div style={{
          marginTop: isCur ? 11 : 9, whiteSpace: "nowrap",
          fontFamily: DISP, fontWeight: 700,
          fontSize: isCur ? 14.5 : 9.5,
          letterSpacing: isCur ? 0.2 : 1.1,
          color: labelColor,
        }}>{slot.label}</div>
        {isCur && (
          <div style={{
            marginTop: 4, fontFamily: MONO, fontSize: 8.5, letterSpacing: 1,
            color: T.mute, whiteSpace: "nowrap",
          }}>STEP {current} / {total}</div>
        )}
      </div>
    );
  };

  // track fill fraction (from prev x to current x => "you've arrived")
  return (
    <div className="ke-anim" key={current} style={{
      position: "relative", height: 92, padding: "8px 18px 0",
      animation: "keSlideIn .5s cubic-bezier(.2,.7,.3,1) both",
    }}>
      {/* base track */}
      <div style={{
        position: "absolute", left: `${X.prev}%`, right: `${100 - X.next}%`,
        top: 8 + NODE_CY - 1, height: 2.5, borderRadius: 2, background: T.line,
      }}/>
      {/* orange progress fill: start → current */}
      <div style={{
        position: "absolute", left: `${X.prev}%`,
        width: `${X.cur - X.prev}%`, top: 8 + NODE_CY - 1, height: 2.5, borderRadius: 2,
        background: T.accent,
      }}/>
      <Cell slot={prevSlot} x={X.prev}/>
      <Cell slot={curSlot} x={X.cur}/>
      <Cell slot={nextSlot} x={X.next}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Flow header (close · wordmark · counter)
// ─────────────────────────────────────────────────────────────
function FlowHeader({ step, total = 6 }) {
  return (
    <div style={{
      height: 48, padding: "0 16px", display: "flex", alignItems: "center",
      justifyContent: "space-between", flexShrink: 0,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        background: T.surface, boxShadow: T.shadowCard,
      }}>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none">
          <path d="M6 6l12 12M18 6L6 18" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 13.5, letterSpacing: 3, color: T.ink, whiteSpace: "nowrap", flexShrink: 0 }}>
        KINETIC EDGE
      </div>
      <div style={{
        minWidth: 36, height: 36, padding: "0 10px", borderRadius: 12,
        display: "grid", placeItems: "center", background: "transparent",
        fontFamily: MONO, fontWeight: 700, fontSize: 12, letterSpacing: 0.5, color: T.mute,
      }}>{String(step).padStart(2, "0")}<span style={{ color: T.muteSoft }}>/{String(total).padStart(2, "0")}</span></div>
    </div>
  );
}

// ── Section header ───────────────────────────────────────────
function SectionHeader({ step, kicker, title }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>
        {String(step).padStart(2, "0")} — {kicker}
      </div>
      <div style={{
        fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.9,
        color: T.ink, marginTop: 7, lineHeight: 1.05,
      }}>{title}</div>
    </div>
  );
}

// ── Form primitives ──────────────────────────────────────────
function Label({ children, optional }) {
  return (
    <div style={{
      fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3,
      color: T.ink, marginBottom: 9, display: "flex", gap: 6,
    }}>
      {children}
      {optional && <span style={{ color: T.muteSoft, fontWeight: 700 }}>OPTIONAL</span>}
    </div>
  );
}

function Field({ label, optional, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <Label optional={optional}>{label}</Label>
      {children}
    </div>
  );
}
function FieldRow({ children }) {
  return <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>{children}</div>;
}

function Input({ value, placeholder, mono, suffix, prefix, focus }) {
  const filled = value != null && value !== "";
  return (
    <div style={{
      height: 52, borderRadius: 14, background: T.surface,
      boxShadow: focus ? `0 0 0 3px ${T.accentSoft}, ${T.shadowCard}` : T.shadowCard,
      display: "flex", alignItems: "center", padding: "0 15px", gap: 10,
    }}>
      {prefix}
      <span style={{
        flex: 1, fontFamily: mono ? MONO : BODY,
        fontSize: mono ? 15 : 15, fontWeight: mono ? 700 : 500,
        color: filled ? T.ink : T.muteSoft, letterSpacing: mono ? 0.3 : 0,
      }}>{filled ? value : placeholder}</span>
      {focus && <div style={{ width: 2, height: 20, background: T.accent, borderRadius: 2 }}/>}
      {suffix && (
        <span style={{
          fontFamily: MONO, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.8,
          color: T.mute, padding: "4px 8px", borderRadius: 7, background: T.bgSoft,
          border: `1px solid ${T.line2}`,
        }}>{suffix}</span>
      )}
    </div>
  );
}

function Dropdown({ value, placeholder, swatch, disabled }) {
  const filled = value != null && value !== "";
  return (
    <div style={{
      height: 52, borderRadius: 14,
      background: disabled ? T.bgSoft : T.surface,
      boxShadow: disabled ? "none" : T.shadowCard,
      display: "flex", alignItems: "center", padding: "0 15px", gap: 10,
      opacity: disabled ? 0.7 : 1,
    }}>
      {swatch && <div style={{
        width: 18, height: 18, borderRadius: 6, background: swatch,
        boxShadow: "inset 0 0 0 1px rgba(0,0,0,0.12)", flexShrink: 0,
      }}/>}
      <span style={{
        flex: 1, fontFamily: BODY, fontSize: 15, fontWeight: 500,
        color: filled ? T.ink : T.muteSoft,
      }}>{filled ? value : placeholder}</span>
      <Chevron/>
    </div>
  );
}

function Segmented({ options, value }) {
  return (
    <div style={{
      display: "flex", gap: 4, padding: 4, borderRadius: 14,
      background: T.bgSoft, border: `1px solid ${T.line}`,
    }}>
      {options.map(o => {
        const on = o === value;
        return (
          <div key={o} style={{
            flex: 1, height: 44, borderRadius: 10,
            background: on ? T.ink : "transparent",
            color: on ? "#fff" : T.ink2,
            display: "grid", placeItems: "center",
            boxShadow: on ? "0 2px 8px rgba(11,11,12,0.18)" : "none",
            fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.4,
            transition: "all .2s",
          }}>{o}</div>
        );
      })}
    </div>
  );
}

function Textarea({ value, placeholder }) {
  const filled = value != null && value !== "";
  return (
    <div style={{
      minHeight: 92, borderRadius: 14, background: T.surface,
      boxShadow: T.shadowCard,
      padding: "13px 15px", fontFamily: BODY, fontSize: 14.5, fontWeight: 500,
      lineHeight: 1.5, color: filled ? T.ink : T.muteSoft,
    }}>{filled ? value : placeholder}</div>
  );
}

function StatusChip({ label, on }) {
  return (
    <div style={{
      padding: "11px 17px", borderRadius: 999,
      background: on ? T.ink : T.surface,
      color: on ? "#fff" : T.ink,
      boxShadow: on ? "0 3px 10px rgba(11,11,12,0.18)" : T.shadowCard,
      fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 0.6,
      whiteSpace: "nowrap",
    }}>{label}</div>
  );
}

// ── Footer ───────────────────────────────────────────────────
function Footer({ showBack, label, dark }) {
  return (
    <div style={{
      flexShrink: 0, padding: "14px 18px 14px",
      borderTop: `1px solid ${T.line}`, background: T.bg,
      display: "flex", gap: 12,
    }}>
      {showBack && (
        <button style={{
          width: 108, height: 54, borderRadius: 16, border: "none",
          background: T.surface, color: T.ink, cursor: "pointer",
          fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.6,
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          boxShadow: T.shadowCard,
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M19 12H6M11 6l-6 6 6 6" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
          BACK
        </button>
      )}
      <button style={{
        flex: 1, height: 54, borderRadius: 16, border: "none",
        background: T.accent, color: "#fff", cursor: "pointer",
        fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
        display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
        boxShadow: "0 10px 24px rgba(255,77,0,0.30)",
      }}>
        {label}<Arrow/>
      </button>
    </div>
  );
}

// ── Screen shell ─────────────────────────────────────────────
function Shell({ step, kicker, title, children, showBack, primaryLabel }) {
  return (
    <div style={{
      width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column",
      fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden",
    }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <FlowHeader step={step}/>
      <ProgressWindow current={step}/>
      <div style={{ height: 1, background: T.line, margin: "4px 0 0" }}/>
      <div className="ke-anim" key={step} style={{
        flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 18px 22px",
        animation: "keRise .45s ease both",
      }}>
        <SectionHeader step={step} kicker={kicker} title={title}/>
        {children}
      </div>
      <Footer showBack={showBack} label={primaryLabel || "NEXT"}/>
    </div>
  );
}

window.KEFlow = { T, DISP, BODY, MONO, STEPS, ProgressWindow, FlowHeader, SectionHeader,
  Label, Field, FieldRow, Input, Dropdown, Segmented, Textarea, StatusChip, Footer, Shell,
  Check, Chevron, Arrow };
