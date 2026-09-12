// Feedback flow — Kinetic Edge
// Entry: profile "⋯" menu → Feedback → interactive feedback form.
// Type dropdown (Bug / Feature / General) drives a conditional
// "Reproduction steps" field that appears only for bug reports.
// Reuses window.KEFlow tokens; dropdowns + textareas are fully interactive.

const F = window.KEFlow;
const { T, DISP, BODY, MONO } = F;
const { useState, useRef, useEffect } = React;

// ── Glyphs ───────────────────────────────────────────────────
const GChat = ({ c, w = 18 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M4 5h16v11H9l-5 4z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>
);
const GBug = ({ c, w = 18 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M12 4l9 16H3L12 4z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M12 10v4.5" stroke={c} strokeWidth="2.2" strokeLinecap="round"/><circle cx="12" cy="17.4" r="1.15" fill={c}/></svg>
);
const GSpark = ({ c, w = 18 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M12 3l1.9 5.6L19.5 10l-5.6 1.9L12 17.5l-1.9-5.6L4.5 10l5.6-1.4L12 3z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>
);
const GCheck = ({ c = "#fff", w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4 10-11" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GChevron = ({ c = T.mute, w = 14, up = false }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none" style={{ transform: up ? "rotate(180deg)" : "none", transition: "transform .22s" }}><path d="M6 9l6 6 6-6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GClose = ({ c = T.ink, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2.4" strokeLinecap="round"/></svg>
);
const GArrow = ({ c = "#fff", w = 16 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M5 12h13M13 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
);

// ── Data ─────────────────────────────────────────────────────
const TYPES = [
  { key: "general", label: "General",         desc: "Thoughts, praise or an idea",  Icon: GChat  },
  { key: "bug",     label: "Bug",             desc: "Something is broken",          Icon: GBug   },
  { key: "feature", label: "Feature request", desc: "Something you wish existed",   Icon: GSpark },
];
const TYPE_MAP = Object.fromEntries(TYPES.map(t => [t.key, t]));

const FEATURES = [
  "Feed", "Search", "Map", "Reels", "Contests",
  "Profile", "Garage", "Followers",
  "Creating posts", "Posts", "Comments", "Likes", "Shares",
  "Notifications", "Direct messages", "Settings", "Something else",
];

// ── Field label ──────────────────────────────────────────────
function FieldLabel({ children, optional }) {
  return (
    <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink, marginBottom: 9, display: "flex", gap: 6, alignItems: "center" }}>
      {children}
      {optional && <span style={{ color: T.muteSoft, fontWeight: 700 }}>OPTIONAL</span>}
    </div>
  );
}

// ── Type dropdown (3 options, inline-expanding) ──────────────
function TypeSelect({ value, onChange, open, onToggle }) {
  const sel = value ? TYPE_MAP[value] : null;
  return (
    <div>
      <button onClick={onToggle} style={{
        width: "100%", height: 56, borderRadius: 14, cursor: "pointer",
        background: T.surface, border: `1.5px solid ${open ? T.accent : T.line}`,
        boxShadow: open ? `0 0 0 4px ${T.accentWash}` : T.shadowCard,
        display: "flex", alignItems: "center", gap: 12, padding: "0 13px 0 12px", textAlign: "left",
      }}>
        <div style={{
          width: 34, height: 34, borderRadius: 11, flexShrink: 0, display: "grid", placeItems: "center",
          background: sel ? T.accent : T.bgSoft, border: `1px solid ${sel ? T.accent : T.line}`,
        }}>
          {sel ? <sel.Icon c="#fff"/> : <GChat c={T.muteSoft}/>}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: BODY, fontWeight: 600, fontSize: 15, color: sel ? T.ink : T.muteSoft }}>
            {sel ? sel.label : "Choose a type…"}
          </div>
          {sel && <div style={{ fontFamily: BODY, fontSize: 11.5, color: T.mute, marginTop: 1 }}>{sel.desc}</div>}
        </div>
        <GChevron up={open}/>
      </button>

      {open && (
        <div className="ke-anim" style={{
          marginTop: 8, borderRadius: 14, background: T.surface, border: `1px solid ${T.line}`,
          boxShadow: "0 8px 24px rgba(11,11,12,0.08)", overflow: "hidden",
          animation: "keRise .22s ease both",
        }}>
          {TYPES.map((t, i) => {
            const on = t.key === value;
            return (
              <button key={t.key} onClick={() => onChange(t.key)} style={{
                width: "100%", display: "flex", alignItems: "center", gap: 12, padding: "12px 13px",
                background: on ? T.accentWash : "transparent", border: "none", cursor: "pointer", textAlign: "left",
                borderTop: i === 0 ? "none" : `1px solid ${T.line2}`,
              }}>
                <div style={{
                  width: 32, height: 32, borderRadius: 10, flexShrink: 0, display: "grid", placeItems: "center",
                  background: on ? T.accent : T.bgSoft, border: `1px solid ${on ? T.accent : T.line}`,
                }}>
                  <t.Icon c={on ? "#fff" : T.ink}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 14.5, color: T.ink, letterSpacing: -0.2 }}>{t.label}</div>
                  <div style={{ fontFamily: BODY, fontSize: 11.5, color: T.mute, marginTop: 1 }}>{t.desc}</div>
                </div>
                {on && <GCheck c={T.accent} w={16}/>}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

// ── Feature dropdown (long list, scrollable) ─────────────────
function FeatureSelect({ value, onChange, open, onToggle }) {
  return (
    <div>
      <button onClick={onToggle} style={{
        width: "100%", height: 52, borderRadius: 14, cursor: "pointer",
        background: T.surface, border: `1.5px solid ${open ? T.accent : T.line}`,
        boxShadow: open ? `0 0 0 4px ${T.accentWash}` : T.shadowCard,
        display: "flex", alignItems: "center", gap: 10, padding: "0 14px", textAlign: "left",
      }}>
        <span style={{ flex: 1, fontFamily: BODY, fontWeight: 500, fontSize: 15, color: value ? T.ink : T.muteSoft }}>
          {value || "Select a feature…"}
        </span>
        <GChevron up={open}/>
      </button>

      {open && (
        <div className="ke-anim" style={{
          marginTop: 8, borderRadius: 14, background: T.surface, border: `1px solid ${T.line}`,
          boxShadow: "0 8px 24px rgba(11,11,12,0.08)", overflow: "hidden",
          animation: "keRise .22s ease both",
        }}>
          <div style={{ maxHeight: 232, overflowY: "auto" }}>
            {FEATURES.map((f, i) => {
              const on = f === value;
              return (
                <button key={f} onClick={() => onChange(f)} style={{
                  width: "100%", display: "flex", alignItems: "center", gap: 10, padding: "12px 14px",
                  background: on ? T.accentWash : "transparent", border: "none", cursor: "pointer", textAlign: "left",
                  borderTop: i === 0 ? "none" : `1px solid ${T.line2}`,
                }}>
                  <span style={{ flex: 1, fontFamily: BODY, fontWeight: on ? 700 : 500, fontSize: 14.5, color: on ? T.ink : T.ink2 }}>{f}</span>
                  {on && <GCheck c={T.accent} w={16}/>}
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

// ── Auto-growing textarea ────────────────────────────────────
function AutoTextarea({ value, onChange, placeholder, minHeight = 112, max }) {
  const ref = useRef(null);
  const [focus, setFocus] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (el) { el.style.height = "auto"; el.style.height = Math.max(minHeight, el.scrollHeight) + "px"; }
  }, [value, minHeight]);
  return (
    <div style={{
      position: "relative", borderRadius: 14, background: T.surface,
      border: `1.5px solid ${focus ? T.accent : T.line}`,
      boxShadow: focus ? `0 0 0 4px ${T.accentWash}` : T.shadowCard,
      transition: "border-color .15s, box-shadow .15s",
    }}>
      <textarea
        ref={ref}
        value={value}
        placeholder={placeholder}
        onChange={(e) => onChange(max ? e.target.value.slice(0, max) : e.target.value)}
        onFocus={() => setFocus(true)}
        onBlur={() => setFocus(false)}
        style={{
          width: "100%", minHeight, resize: "none", border: "none", outline: "none", background: "transparent",
          padding: max ? "13px 15px 28px" : "13px 15px", fontFamily: BODY, fontSize: 14.5, fontWeight: 500,
          lineHeight: 1.55, color: T.ink, boxSizing: "border-box", display: "block",
        }}
      />
      {max && (
        <div style={{ position: "absolute", right: 12, bottom: 9, fontFamily: MONO, fontSize: 10, letterSpacing: 0.4, color: value.length > max * 0.9 ? T.accent : T.mute }}>
          {value.length} / {max}
        </div>
      )}
    </div>
  );
}

// ── Header ───────────────────────────────────────────────────
function FeedbackHeader({ onClose }) {
  return (
    <div style={{ height: 48, padding: "0 16px", display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
      <button onClick={onClose} style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center", cursor: "pointer",
        background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard,
      }}><GClose/></button>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 13.5, letterSpacing: 3, color: T.ink }}>TWEAKD</div>
      <div style={{ width: 36 }}/>
    </div>
  );
}

// ── Sent / thank-you view ────────────────────────────────────
function SentView({ type, feature, onReset }) {
  const t = TYPE_MAP[type];
  const chips = [t ? t.label.toUpperCase() : null, feature ? feature.toUpperCase() : null].filter(Boolean);
  return (
    <div className="ke-anim" style={{
      flex: 1, minHeight: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      padding: "20px 30px", textAlign: "center", animation: "keRise .4s ease both",
    }}>
      <div style={{
        width: 76, height: 76, borderRadius: 24, background: T.accent, display: "grid", placeItems: "center",
        boxShadow: "0 14px 30px rgba(255,77,0,0.32)", marginBottom: 22,
      }}><GCheck w={34}/></div>
      <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 11, letterSpacing: 1, color: T.accent, marginBottom: 8 }}>— RECEIVED</div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.8, color: T.ink }}>Thanks for the signal</div>
      <p style={{ margin: "12px 0 0", maxWidth: 300, fontFamily: BODY, fontSize: 14, lineHeight: 1.55, color: T.mute, textWrap: "pretty" }}>
        Your feedback lands straight with the crew building Tweakd. We read every one.
      </p>
      {chips.length > 0 && (
        <div style={{ marginTop: 20, display: "flex", flexWrap: "wrap", gap: 8, justifyContent: "center" }}>
          {chips.map(c => (
            <span key={c} style={{ padding: "7px 12px", borderRadius: 8, background: T.bgSoft, border: `1px solid ${T.line2}`, fontFamily: MONO, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.5, color: T.mute }}>{c}</span>
          ))}
        </div>
      )}
      <button onClick={onReset} style={{
        marginTop: 30, width: "100%", maxWidth: 300, height: 52, borderRadius: 16, border: `1.5px solid ${T.line}`,
        background: T.surface, color: T.ink, cursor: "pointer", boxShadow: T.shadowCard,
        fontFamily: DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 1.6,
      }}>DONE</button>
    </div>
  );
}

// ── Feedback screen (interactive form) ───────────────────────
function FeedbackScreen({
  onClose = () => {},
  initialType = null, initialFeature = null,
  initialMessage = "", initialRepro = "",
  demoOpen = null, initialSubmitted = false,
}) {
  const [type, setType] = useState(initialType);
  const [feature, setFeature] = useState(initialFeature);
  const [message, setMessage] = useState(initialMessage);
  const [repro, setRepro] = useState(initialRepro);
  const [openKey, setOpenKey] = useState(demoOpen);
  const [submitted, setSubmitted] = useState(initialSubmitted);

  const toggle = (k) => setOpenKey(prev => (prev === k ? null : k));
  const isBug = type === "bug";
  const canSend = !!type && message.trim().length > 0;

  const reset = () => { setType(null); setFeature(null); setMessage(""); setRepro(""); setOpenKey(null); setSubmitted(false); };

  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column", fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <FeedbackHeader onClose={onClose}/>
      <div style={{ height: 1, background: T.line }}/>

      {submitted ? (
        <SentView type={type} feature={feature} onReset={reset}/>
      ) : (
        <React.Fragment>
          <div className="ke-anim" style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 18px 24px", animation: "keRise .4s ease both" }}>
            {/* section header */}
            <div style={{ marginBottom: 22 }}>
              <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>— FEEDBACK</div>
              <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.9, color: T.ink, marginTop: 7, lineHeight: 1.05 }}>Tell us what's up</div>
              <p style={{ margin: "9px 0 0", fontFamily: BODY, fontSize: 13.5, lineHeight: 1.5, color: T.mute, textWrap: "pretty" }}>
                Report a bug, request a feature, or just share a thought — it goes straight to the team.
              </p>
            </div>

            {/* TYPE */}
            <div style={{ marginBottom: 18 }}>
              <FieldLabel>FEEDBACK TYPE</FieldLabel>
              <TypeSelect value={type} onChange={(v) => { setType(v); setOpenKey(null); }} open={openKey === "type"} onToggle={() => toggle("type")}/>
            </div>

            {/* FEATURE */}
            <div style={{ marginBottom: 18 }}>
              <FieldLabel optional>RELATED TO AN EXISTING FEATURE ?</FieldLabel>
              <FeatureSelect value={feature} onChange={(v) => { setFeature(v); setOpenKey(null); }} open={openKey === "feature"} onToggle={() => toggle("feature")}/>
            </div>

            {/* MESSAGE */}
            <div style={{ marginBottom: 18 }}>
              <FieldLabel>{isBug ? "WHAT HAPPENED" : "YOUR FEEDBACK"}</FieldLabel>
              <AutoTextarea
                value={message}
                onChange={setMessage}
                max={600}
                minHeight={124}
                placeholder={isBug ? "Describe the problem — what you expected vs. what actually happened…" : "Share as much detail as you like…"}
              />
            </div>

            {/* REPRODUCTION STEPS — bug only */}
            {isBug && (
              <div className="ke-anim" key="repro" style={{ marginBottom: 18, animation: "keRise .3s ease both" }}>
                <FieldLabel>REPRODUCTION STEPS</FieldLabel>
                <AutoTextarea
                  value={repro}
                  onChange={setRepro}
                  minHeight={112}
                  placeholder={"1. Open the Garage tab\n2. Tap a car card\n3. …"}
                />
                <div style={{ marginTop: 10, display: "flex", gap: 11, alignItems: "flex-start", padding: "12px 14px", borderRadius: 14, background: T.accentWash, border: `1px solid ${T.accentSoft}` }}>
                  <div style={{ width: 7, height: 7, borderRadius: 99, background: T.accent, marginTop: 6, flexShrink: 0 }}/>
                  <div style={{ fontFamily: BODY, fontSize: 12.5, lineHeight: 1.5, color: T.ink2 }}>
                    Number each step so we can reproduce it exactly. The more precise, the faster we can fix it.
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* footer */}
          <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${T.line}`, background: T.bg }}>
            <button
              onClick={() => canSend && setSubmitted(true)}
              style={{
                width: "100%", height: 54, borderRadius: 16, border: "none", cursor: canSend ? "pointer" : "default",
                background: canSend ? T.accent : T.muteSoft, color: "#fff",
                fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
                display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
                boxShadow: canSend ? "0 10px 24px rgba(255,77,0,0.30)" : "none",
                transition: "background .2s, box-shadow .2s",
              }}
            >
              SEND FEEDBACK<GArrow/>
            </button>
          </div>
        </React.Fragment>
      )}
    </div>
  );
}

// ── Profile "⋯" menu — entry point (bottom sheet) ────────────
function MenuRow({ Icon, title, sub, accent, danger, last, onClick }) {
  const tint = danger ? "#C8341F" : accent ? T.accent : T.ink;
  return (
    <button onClick={onClick} style={{
      width: "100%", display: "flex", alignItems: "center", gap: 13, padding: "13px 14px", cursor: "pointer",
      background: "transparent", border: "none", textAlign: "left",
      borderTop: last === "first" ? "none" : `1px solid ${T.line2}`,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 12, flexShrink: 0, display: "grid", placeItems: "center",
        background: accent ? T.accentWash : T.bgSoft, border: `1px solid ${accent ? T.accentSoft : T.line}`,
      }}><Icon c={tint} w={19}/></div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 15, color: tint, letterSpacing: -0.2 }}>{title}</div>
        {sub && <div style={{ fontFamily: BODY, fontSize: 12, color: T.mute, marginTop: 1 }}>{sub}</div>}
      </div>
      <svg width="8" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" stroke={T.muteSoft} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
    </button>
  );
}

const MShare = ({ c, w = 19 }) => <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M4 12v7h16v-7M12 3v13M7 8l5-5 5 5" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>;
const MLink  = ({ c, w = 19 }) => <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M9 15l6-6M8 13l-2 2a3.5 3.5 0 005 5l2-2M16 11l2-2a3.5 3.5 0 00-5-5l-2 2" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>;
const MGear  = ({ c, w = 19 }) => <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3.2" stroke={c} strokeWidth="2"/><path d="M12 2.5v3M12 18.5v3M21.5 12h-3M5.5 12h-3M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1M18.4 18.4l-2.1-2.1M7.7 7.7L5.6 5.6" stroke={c} strokeWidth="2" strokeLinecap="round"/></svg>;

function ProfileMenuSheet({ onFeedback = () => {}, onClose = () => {} }) {
  return (
    <div style={{ width: 390, height: 844, position: "relative", overflow: "hidden", fontFamily: BODY, color: T.ink }}>
      {/* dimmed profile backdrop stand-in */}
      <div style={{ position: "absolute", inset: 0, background: "#2A2724" }}/>
      <div style={{ position: "absolute", inset: 0, background: "rgba(11,11,12,0.5)" }} onClick={onClose}/>
      {/* sheet */}
      <div className="ke-anim" style={{
        position: "absolute", left: 0, right: 0, bottom: 0, background: T.bg, borderRadius: "26px 26px 0 0",
        boxShadow: "0 -16px 50px rgba(0,0,0,0.4)", paddingBottom: 30, animation: "keRise .3s ease both",
      }}>
        <div style={{ padding: "12px 0 0" }}>
          <div style={{ width: 44, height: 5, borderRadius: 99, background: T.muteSoft, margin: "0 auto 14px" }}/>
          <div style={{ padding: "0 20px 14px", display: "flex", alignItems: "flex-start", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 11, letterSpacing: 1, color: T.accent }}>— @marcus_vlox</div>
              <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 24, letterSpacing: -0.8, color: T.ink, marginTop: 6 }}>Options</div>
            </div>
            <button onClick={onClose} style={{ width: 36, height: 36, borderRadius: 12, background: T.surface, border: `1px solid ${T.line}`, display: "grid", placeItems: "center", boxShadow: T.shadowCard, cursor: "pointer" }}>
              <GClose/>
            </button>
          </div>
          <div style={{ height: 1, background: T.line }}/>
        </div>
        <div style={{ padding: "6px 12px 0" }}>
          <MenuRow last="first" Icon={MShare} title="Share profile" sub="Send this garage to a friend"/>
          <MenuRow Icon={MLink} title="Copy link" sub="tweakd.app/marcus_vlox"/>
          <MenuRow accent Icon={GChat} title="Feedback" sub="Report a bug or request a feature" onClick={onFeedback}/>
          <MenuRow Icon={MGear} title="Settings" sub="Account, privacy & notifications"/>
        </div>
      </div>
    </div>
  );
}

// ── Full entry flow: menu → form (interactive) ───────────────
function FeedbackFlow() {
  const [stage, setStage] = useState("menu"); // "menu" | "form"
  return stage === "menu"
    ? <ProfileMenuSheet onFeedback={() => setStage("form")} onClose={() => setStage("form")}/>
    : <FeedbackScreen onClose={() => setStage("menu")}/>;
}

Object.assign(window, { FeedbackScreen, ProfileMenuSheet, FeedbackFlow });
