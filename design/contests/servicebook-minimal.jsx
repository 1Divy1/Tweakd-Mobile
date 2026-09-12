// Service Book (Minimal) — Tweakd
// Stripped-down version: mostly monochrome, color only for overdue,
// flat rows, no numbered kickers, no stats band, no status pills.

const { useState: useStateM } = React;
const KEm = window.KE;
const F_DISP = window.KE_FONT_DISPLAY;
const F_BODY = window.KE_FONT_BODY;
const F_MONO = `"Space Mono", ui-monospace, monospace`;
const OVER = "#D93A26";

function MIco({ name, size = 20, color = KEm.ink, sw = 2 }) {
  const p = {
    back:   <path d="M15 6l-6 6 6 6" />,
    x:      <path d="M6 6l12 12M18 6L6 18" />,
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
    doc:    <path d="M7 3h7l4 4v14H7V3zm7 0v4h4" />,
    filter: <path d="M4 5h16l-6 8v6l-4-2v-4L4 5z" />,
  }[name];
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{p}</svg>
  );
}

function MIconBtn({ name, onClick, size = 14 }) {
  return (
    <div onClick={onClick} style={{ width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center", border: `1px solid ${KEm.line}`, background: KEm.surface, cursor: "pointer", flexShrink: 0 }}>
      <MIco name={name} size={size} sw={2.2} />
    </div>
  );
}

function MTopBar({ title, leading = "back", onLeading }) {
  return (
    <div style={{ height: 56, padding: "0 16px", display: "flex", alignItems: "center", justifyContent: "space-between", background: KEm.bg, borderBottom: `1px solid ${KEm.line}` }}>
      {leading ? <MIconBtn name={leading} onClick={onLeading} size={leading === "x" ? 12 : 14} /> : <div style={{ width: 36 }} />}
      <div style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KEm.ink }}>{title}</div>
      <div style={{ width: 36 }} />
    </div>
  );
}

// Minimal car header — name + plate + km in one quiet line.
function MCarLine() {
  return (
    <div style={{ padding: "18px 20px 0", display: "flex", alignItems: "baseline", justifyContent: "space-between", cursor: "pointer" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
        <span style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 17, letterSpacing: -0.4, color: KEm.ink }}>BMW M4 Competition</span>
        <MIco name="chevD" size={13} color={KEm.mute} />
      </div>
      <span style={{ fontFamily: F_MONO, fontSize: 11, color: KEm.mute }}>CJ 24 TWK · 28,400 km</span>
    </div>
  );
}

const M_UPCOMING = [
  { icon: "gauge",  label: "ITP inspection",  due: "4 days overdue", over: true },
  { icon: "shield", label: "CASCO · Groupama", due: "12 days" },
  { icon: "oil",    label: "Oil & filter",    due: "1,600 km" },
  { icon: "shield", label: "RCA · Allianz-Țiriac", due: "7 Dec" },
  { icon: "ticket", label: "Rovinietă",       due: "14 Oct" },
];

const M_HISTORY = [
  { icon: "tire",   title: "Tire rotation & balance",  shop: "Anvelope Expert", date: "12 Jun 2026", km: "26,900", cost: "240" },
  { icon: "shield", title: "RCA renewed · 12 months",  shop: "Allianz-Țiriac",  date: "3 Mar 2026",  km: "24,100", cost: "1,180" },
  { icon: "oil",    title: "Oil & filter · Mobil 1",   shop: "Bavaria Service", date: "18 Jan 2026", km: "23,050", cost: "890" },
  { icon: "chip",   title: "ECU Stage 1 tune",         shop: "TunerWorks",      date: "5 Nov 2025",  km: "20,400", cost: "3,500" },
  { icon: "gauge",  title: "ITP inspection · passed",  shop: "RAR Cluj",        date: "11 Aug 2025", km: "18,200", cost: "145" },
  { icon: "disc",   title: "Brake pads & discs · F+R", shop: "Bavaria Service", date: "2 Jun 2025",  km: "15,600", cost: "2,650" },
  { icon: "wrench", title: "Major service · Insp. II", shop: "Bavaria Service", date: "20 Mar 2025", km: "12,300", cost: "1,940" },
  { icon: "shield", title: "CASCO purchased",          shop: "Groupama",        date: "4 Feb 2025",  km: "9,800",  cost: "4,200" },
];

function MRow({ icon, left, sub, right, rightSub, over, onClick, isLast }) {
  return (
    <div onClick={onClick} style={{ display: "flex", alignItems: "center", gap: 12, padding: "14px 0", borderBottom: isLast ? "none" : `1px solid ${KEm.line}`, cursor: onClick ? "pointer" : "default" }}>
      <MIco name={icon} size={18} color={over ? OVER : KEm.ink2} sw={1.8} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: F_BODY, fontWeight: 600, fontSize: 14, color: KEm.ink, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{left}</div>
        {sub && <div style={{ fontFamily: F_BODY, fontSize: 11.5, color: KEm.mute, marginTop: 2 }}>{sub}</div>}
      </div>
      <div style={{ textAlign: "right", flexShrink: 0 }}>
        <div style={{ fontFamily: F_MONO, fontWeight: 700, fontSize: 12.5, color: over ? OVER : KEm.ink }}>{right}</div>
        {rightSub && <div style={{ fontFamily: F_BODY, fontSize: 10.5, color: KEm.mute, marginTop: 2 }}>{rightSub}</div>}
      </div>
    </div>
  );
}

function MSectionTitle({ children, action, onAction }) {
  return (
    <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 2 }}>
      <div style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1.8, color: KEm.mute }}>{children}</div>
      {action && <div onClick={onAction} style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KEm.ink, cursor: "pointer", borderBottom: `1px solid ${KEm.ink}` }}>{action}</div>}
    </div>
  );
}

// ─── Overview ───
function MOverviewScreen({ onSchedule, onDocument, onHistory }) {
  return (
    <div style={{ width: 390, height: 844, background: KEm.bg, fontFamily: F_BODY, color: KEm.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <MTopBar title="SERVICE BOOK" />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", paddingBottom: 96 }}>
        <MCarLine />
        {/* One-line status — only speaks when something is overdue */}
        <div style={{ padding: "6px 20px 0", fontFamily: F_BODY, fontSize: 13, color: KEm.mute }}>
          <span style={{ color: OVER, fontWeight: 700 }}>1 overdue</span> · 2 due soon
        </div>

        <div style={{ padding: "26px 20px 0" }}>
          <MSectionTitle>COMING UP</MSectionTitle>
          {M_UPCOMING.map((u, i, a) => (
            <MRow key={i} icon={u.icon} left={u.label} right={u.due} over={u.over} isLast={i === a.length - 1} />
          ))}
        </div>

        <div style={{ padding: "28px 20px 0" }}>
          <MSectionTitle action="ALL" onAction={onHistory}>HISTORY</MSectionTitle>
          {M_HISTORY.slice(0, 3).map((h, i, a) => (
            <MRow key={i} icon={h.icon} left={h.title} sub={h.date} right={`${h.cost} RON`} isLast={i === a.length - 1} />
          ))}
        </div>
      </div>

      {/* Two quiet actions pinned at the bottom */}
      <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, padding: "14px 20px 34px", background: `linear-gradient(to top, ${KEm.bg} 70%, transparent)`, display: "flex", gap: 10 }}>
        <button onClick={onSchedule} style={{ flex: 1, height: 50, borderRadius: 12, border: "none", background: KEm.ink, color: KEm.surface, cursor: "pointer", fontFamily: F_DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1.6 }}>SCHEDULE</button>
        <button onClick={onDocument} style={{ flex: 1, height: 50, borderRadius: 12, border: `1px solid ${KEm.line}`, background: KEm.surface, color: KEm.ink, cursor: "pointer", fontFamily: F_DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1.6 }}>ADD DOCUMENT</button>
      </div>
    </div>
  );
}

// ─── History ───
function MHistoryScreen({ onBack }) {
  const filters = ["ALL", "SERVICE", "INSURANCE", "ITP", "TUNING", "TIRES"];
  const [active, setActive] = useStateM("ALL");
  return (
    <div style={{ width: 390, height: 844, background: KEm.bg, fontFamily: F_BODY, color: KEm.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <MTopBar title="HISTORY" onLeading={onBack} />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", paddingBottom: 32 }}>
        <MCarLine />
        <div style={{ display: "flex", gap: 6, padding: "18px 20px 2px", overflowX: "auto" }}>
          {filters.map(f => {
            const on = f === active;
            return (
              <div key={f} onClick={() => setActive(f)} style={{ flexShrink: 0, padding: "6px 12px", borderRadius: 999, cursor: "pointer", background: on ? KEm.ink : "transparent", border: `1px solid ${on ? KEm.ink : KEm.line}`, color: on ? KEm.surface : KEm.ink2, fontFamily: F_DISP, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, whiteSpace: "nowrap" }}>{f}</div>
            );
          })}
        </div>
        <div style={{ padding: "12px 20px 0" }}>
          {M_HISTORY.map((h, i, a) => (
            <MRow key={i} icon={h.icon} left={h.title} sub={`${h.date} · ${h.shop}`} right={`${h.cost} RON`} rightSub={`${h.km} km`} isLast={i === a.length - 1} />
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Form primitives ───
function MLabel({ children, optional }) {
  return (
    <div style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 10, letterSpacing: 1.4, color: KEm.ink, marginBottom: 8, display: "flex", gap: 6 }}>
      {children}{optional && <span style={{ color: KEm.mute }}>(OPTIONAL)</span>}
    </div>
  );
}
function MField({ placeholder, suffix, icon }) {
  return (
    <div style={{ height: 48, borderRadius: 10, background: KEm.surface, border: `1px solid ${KEm.line}`, display: "flex", alignItems: "center", padding: "0 14px", gap: 10 }}>
      {icon && <MIco name={icon} size={16} color={KEm.mute} sw={2} />}
      <span style={{ flex: 1, fontFamily: F_BODY, fontSize: 14, color: KEm.muteSoft }}>{placeholder}</span>
      {suffix && <span style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KEm.mute }}>{suffix}</span>}
    </div>
  );
}
function MSeg({ options, value, onChange }) {
  return (
    <div style={{ display: "flex", gap: 6 }}>
      {options.map(o => {
        const on = o === value;
        return (
          <div key={o} onClick={() => onChange(o)} style={{ flex: 1, height: 42, borderRadius: 8, cursor: "pointer", background: on ? KEm.ink : KEm.surface, border: `1px solid ${on ? KEm.ink : KEm.line}`, color: on ? KEm.surface : KEm.ink, display: "grid", placeItems: "center", fontFamily: F_DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1 }}>{o}</div>
        );
      })}
    </div>
  );
}
function MPills({ options, value, onChange }) {
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 7 }}>
      {options.map(o => {
        const on = o.k === value;
        return (
          <div key={o.k} onClick={() => onChange(o.k)} style={{ display: "flex", alignItems: "center", gap: 6, padding: "9px 13px", borderRadius: 999, cursor: "pointer", background: on ? KEm.ink : KEm.surface, border: `1px solid ${on ? KEm.ink : KEm.line}`, color: on ? KEm.surface : KEm.ink, fontFamily: F_DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1, whiteSpace: "nowrap" }}>
            {o.icon && <MIco name={o.icon} size={14} color={on ? KEm.surface : KEm.ink} sw={2} />}
            {o.label}
          </div>
        );
      })}
    </div>
  );
}
function MSecTitle({ children }) {
  return <div style={{ fontFamily: F_DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1.8, color: KEm.mute, marginTop: 26, marginBottom: 14 }}>{children}</div>;
}
function MGroup({ children }) {
  return <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>{children}</div>;
}
function MRow2({ children }) {
  return <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>{children}</div>;
}
function MSubmit({ label, onClick }) {
  return (
    <button onClick={onClick} style={{ marginTop: 28, width: "100%", height: 54, borderRadius: 12, border: "none", background: KEm.ink, color: KEm.surface, cursor: "pointer", fontFamily: F_DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 1.8 }}>{label}</button>
  );
}
function MForCar() {
  return (
    <div style={{ margin: "16px 20px 0", padding: "11px 14px", borderRadius: 10, background: KEm.surface, border: `1px solid ${KEm.line}`, display: "flex", alignItems: "center", justifyContent: "space-between", cursor: "pointer" }}>
      <span style={{ fontFamily: F_BODY, fontWeight: 600, fontSize: 13.5, color: KEm.ink }}>BMW M4 Competition · CJ 24 TWK</span>
      <MIco name="chevD" size={13} color={KEm.mute} />
    </div>
  );
}

// ─── Schedule ───
function MScheduleScreen({ onClose }) {
  const [task, setTask] = useStateM("oil");
  const [dueBy, setDueBy] = useStateM("DATE");
  const [remind, setRemind] = useStateM("2 WEEKS");
  const tasks = [
    { k: "oil", label: "OIL & FILTER", icon: "oil" },
    { k: "itp", label: "ITP", icon: "gauge" },
    { k: "service", label: "SERVICE", icon: "wrench" },
    { k: "tuning", label: "TUNING", icon: "chip" },
    { k: "brakes", label: "BRAKES", icon: "disc" },
    { k: "tires", label: "TIRES", icon: "tire" },
  ];
  return (
    <div style={{ width: 390, height: 844, background: KEm.bg, fontFamily: F_BODY, color: KEm.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <MTopBar title="SCHEDULE" leading="x" onLeading={onClose} />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        <MForCar />
        <div style={{ padding: "0 20px 36px" }}>
          <MSecTitle>TASK</MSecTitle>
          <MGroup>
            <MPills options={tasks} value={task} onChange={setTask} />
            <div>
              <MLabel optional>TITLE</MLabel>
              <MField placeholder="e.g. Oil & filter · Mobil 1 0W-40" />
            </div>
          </MGroup>

          <MSecTitle>DUE BY</MSecTitle>
          <MGroup>
            <MSeg options={["DATE", "MILEAGE", "BOTH"]} value={dueBy} onChange={setDueBy} />
            <MRow2>
              <div>
                <MLabel>DUE DATE</MLabel>
                <MField placeholder="15 Aug 2026" icon="cal" />
              </div>
              <div>
                <MLabel>AT ODOMETER</MLabel>
                <MField placeholder="30,000" suffix="KM" />
              </div>
            </MRow2>
          </MGroup>

          <MSecTitle>REMIND ME BEFORE</MSecTitle>
          <MSeg options={["1 WEEK", "2 WEEKS", "1 MONTH"]} value={remind} onChange={setRemind} />

          <MSubmit label="SCHEDULE TASK" onClick={onClose} />
        </div>
      </div>
    </div>
  );
}

// ─── Add document ───
function MDocumentScreen({ onClose }) {
  const [type, setType] = useStateM("casco");
  const [remind, setRemind] = useStateM("2 WEEKS");
  const types = [
    { k: "rca", label: "RCA", icon: "shield" },
    { k: "casco", label: "CASCO", icon: "shield" },
    { k: "itp", label: "ITP", icon: "gauge" },
    { k: "rov", label: "ROVINIETĂ", icon: "ticket" },
    { k: "other", label: "OTHER", icon: "doc" },
  ];
  return (
    <div style={{ width: 390, height: 844, background: KEm.bg, fontFamily: F_BODY, color: KEm.ink, overflow: "hidden", display: "flex", flexDirection: "column" }}>
      <div style={{ height: 54, flexShrink: 0 }} />
      <MTopBar title="ADD DOCUMENT" leading="x" onLeading={onClose} />
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        <MForCar />
        <div style={{ padding: "0 20px 36px" }}>
          <MSecTitle>DOCUMENT</MSecTitle>
          <MGroup>
            <MPills options={types} value={type} onChange={setType} />
            <div>
              <MLabel>PROVIDER / ISSUER</MLabel>
              <MField placeholder="e.g. Groupama" />
            </div>
            <div>
              <MLabel optional>POLICY NUMBER</MLabel>
              <MField placeholder="e.g. RO-CASCO-8842190" icon="doc" />
            </div>
          </MGroup>

          <MSecTitle>VALIDITY</MSecTitle>
          <MGroup>
            <MRow2>
              <div>
                <MLabel>START DATE</MLabel>
                <MField placeholder="30 Jul 2025" icon="cal" />
              </div>
              <div>
                <MLabel>EXPIRY DATE</MLabel>
                <MField placeholder="30 Jul 2026" icon="cal" />
              </div>
            </MRow2>
            <div>
              <MLabel optional>COST</MLabel>
              <MField placeholder="4,200" suffix="RON" />
            </div>
          </MGroup>

          <MSecTitle>REMIND ME BEFORE EXPIRY</MSecTitle>
          <MSeg options={["1 WEEK", "2 WEEKS", "1 MONTH"]} value={remind} onChange={setRemind} />

          <MSubmit label="SAVE DOCUMENT" onClick={onClose} />
        </div>
      </div>
    </div>
  );
}

window.SBM_OverviewScreen = MOverviewScreen;
window.SBM_HistoryScreen  = MHistoryScreen;
window.SBM_ScheduleScreen = MScheduleScreen;
window.SBM_DocumentScreen = MDocumentScreen;
