// Onboarding flow — Tweakd
// Reuses the Add-to-Garage premium system (KEFlow tokens + form primitives).
// Custom: TWEAKD header, animated continuous progress bar (starts at 20% —
// credit for auth already done), Shell, Toggle + RadiusSlider primitives.

const F = window.KEFlow;
const { T, DISP, BODY, MONO, Field, FieldRow, Input, Dropdown, Segmented,
  StatusChip, Footer, Check, Chevron, Arrow } = F;

const ONB_TOTAL = 4;

// keyframes are already injected by add-flow.jsx (#ke-flow-css)

// ─────────────────────────────────────────────────────────────
// PROGRESS BAR — single continuous fill, animates from → to on mount.
// Baseline credit (20%) already banked from email/social auth.
// ─────────────────────────────────────────────────────────────
function OnbProgressBar({ from, to }) {
  const [w, setW] = React.useState(from);
  React.useEffect(() => {
    const raf1 = requestAnimationFrame(() => {
      const raf2 = requestAnimationFrame(() => setW(to));
      return () => cancelAnimationFrame(raf2);
    });
    return () => cancelAnimationFrame(raf1);
  }, [to]);
  return (
    <div style={{ padding: "16px 18px 0" }}>
      <div style={{ height: 5, borderRadius: 3, background: T.line, overflow: "hidden" }}>
        <div style={{
          height: "100%", width: `${w}%`, borderRadius: 3, background: T.accent,
          transition: "width .8s cubic-bezier(.2,.7,.3,1)",
        }}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Header — TWEAKD wordmark
// ─────────────────────────────────────────────────────────────
function OnbHeader({ showBack }) {
  return (
    <div style={{
      height: 48, padding: "0 16px", display: "flex", alignItems: "center",
      justifyContent: "space-between", flexShrink: 0,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        background: T.surface, boxShadow: T.shadowCard, visibility: showBack ? "visible" : "hidden",
      }}>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none">
          <path d="M19 12H6M11 6l-6 6 6 6" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <path d="M13 2L4 13h6l-1 9 9-12h-6l1-8z" fill={T.accent}/>
        </svg>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 14, letterSpacing: 2.5, color: T.ink, whiteSpace: "nowrap" }}>
          TWEAKD
        </div>
      </div>
      <div style={{ width: 36, height: 36 }}/>
    </div>
  );
}

// ── Section header (kicker + title + optional sub) ────────────
function OnbSectionHeader({ step, kicker, title, sub }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>
        {String(step).padStart(2, "0")} — {kicker}
      </div>
      <div style={{
        fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.9,
        color: T.ink, marginTop: 7, lineHeight: 1.08,
      }}>{title}</div>
      {sub && (
        <div style={{ fontFamily: BODY, fontSize: 13.5, color: T.mute, lineHeight: 1.5, marginTop: 9 }}>
          {sub}
        </div>
      )}
    </div>
  );
}

// ── Shell ─────────────────────────────────────────────────────
function OnbShell({ step, total = ONB_TOTAL, kicker, title, sub, children, showBack, primaryLabel }) {
  const from = 20 + (step - 1) * (80 / total);
  const to = 20 + step * (80 / total);
  return (
    <div style={{
      width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column",
      fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden",
    }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <OnbHeader showBack={showBack}/>
      <OnbProgressBar key={`bar-${step}`} from={from} to={to}/>
      <div className="ke-anim" key={`content-${step}`} style={{
        flex: 1, minHeight: 0, overflowY: "auto", padding: "24px 18px 22px",
        animation: "keRise .45s ease both",
      }}>
        <OnbSectionHeader step={step} kicker={kicker} title={title} sub={sub}/>
        {children}
      </div>
      <Footer showBack={showBack} label={primaryLabel || "NEXT"}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Toggle — iOS-style switch
// ─────────────────────────────────────────────────────────────
function Toggle({ on }) {
  return (
    <div style={{
      width: 48, height: 28, borderRadius: 999, flexShrink: 0,
      background: on ? T.accent : T.line, position: "relative",
      transition: "background .2s", boxShadow: on ? "inset 0 1px 3px rgba(255,77,0,0.35)" : "inset 0 1px 2px rgba(0,0,0,0.06)",
    }}>
      <div style={{
        position: "absolute", top: 3, left: on ? 23 : 3,
        width: 22, height: 22, borderRadius: 999, background: "#fff",
        boxShadow: "0 1px 3px rgba(0,0,0,0.25)", transition: "left .2s",
      }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// RadiusSlider — discovery radius for meets/events
// ─────────────────────────────────────────────────────────────
function RadiusSlider({ value = 40, min = 10, max = 100 }) {
  const pct = Math.max(0, Math.min(1, (value - min) / (max - min)));
  return (
    <div>
      <div style={{
        borderRadius: 16, background: T.ink, padding: "15px 18px",
        display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 18,
      }}>
        <div>
          <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.6, color: "rgba(255,255,255,0.55)" }}>
            DISCOVERY RADIUS
          </div>
          <div style={{ display: "flex", alignItems: "baseline", gap: 6, marginTop: 6 }}>
            <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 30, color: "#fff", letterSpacing: -0.5 }}>{value}</span>
            <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, color: T.accent, letterSpacing: 1 }}>KM</span>
          </div>
        </div>
        <div style={{ width: 46, height: 46, borderRadius: 14, background: "rgba(255,77,0,0.16)", display: "grid", placeItems: "center" }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="9" stroke={T.accent} strokeWidth="2" strokeDasharray="3 3"/>
            <circle cx="12" cy="12" r="2.6" fill={T.accent}/>
          </svg>
        </div>
      </div>
      <div style={{ position: "relative", height: 26, display: "flex", alignItems: "center" }}>
        <div style={{ position: "absolute", left: 0, right: 0, height: 6, borderRadius: 99, background: T.line }}/>
        <div style={{ position: "absolute", left: 0, width: `${pct * 100}%`, height: 6, borderRadius: 99, background: T.accent }}/>
        <div style={{
          position: "absolute", left: `calc(${pct * 100}% - 13px)`,
          width: 26, height: 26, borderRadius: 999, background: "#fff",
          border: `2px solid ${T.accent}`, boxShadow: "0 3px 8px rgba(11,11,12,0.18)",
          display: "grid", placeItems: "center",
        }}>
          <div style={{ width: 9, height: 9, borderRadius: 99, background: T.accent }}/>
        </div>
      </div>
      <div style={{ display: "flex", justifyContent: "space-between", marginTop: 8 }}>
        <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: T.muteSoft, letterSpacing: 0.5 }}>{min} KM</span>
        <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, color: T.muteSoft, letterSpacing: 0.5 }}>{max} KM</span>
      </div>
    </div>
  );
}

window.ONB = {
  ONB_TOTAL, OnbProgressBar, OnbHeader, OnbSectionHeader, OnbShell, Toggle, RadiusSlider,
};
