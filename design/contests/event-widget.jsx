// event-widget.jsx — Kinetic Edge
// Floating popup shown when a car-meet pin is tapped on the virtual map.
// Borderless: separation comes from soft fills + shadow only.

const EW_KE = window.KE;
const EW_FD = window.KE_FONT_DISPLAY;
const EW_FB = window.KE_FONT_BODY;

function EvStatusChip({ status, size = "md" }) {
  const K = EW_KE;
  const m = window.EV.STATUS_META[status];
  const tone =
  status === "live" ? { bg: K.accent, fg: "#fff" } :
  status === "upcoming" ? { bg: K.ink, fg: "#fff" } :
  { bg: "rgba(10,10,10,0.62)", fg: "#fff" };
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 5,
      background: tone.bg, color: tone.fg, borderRadius: 999,
      padding: size === "sm" ? "3px 8px" : "4px 10px",
      fontFamily: EW_FD, fontWeight: 700, fontSize: size === "sm" ? 8.5 : 9.5, letterSpacing: 1
    }}>
      {status === "live" && <span className="ke-blink" style={{ width: 5, height: 5, borderRadius: 999, background: "#fff" }} />}
      {m.label}
    </span>);

}

function EvIcon({ k, c, s = 14 }) {
  const p = { width: s, height: s, viewBox: "0 0 24 24", fill: "none" };
  if (k === "pin") return <svg {...p}><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z" stroke={c} strokeWidth="2" /><circle cx="12" cy="10" r="2.5" stroke={c} strokeWidth="2" /></svg>;
  if (k === "clock") return <svg {...p}><circle cx="12" cy="12" r="9" stroke={c} strokeWidth="2" /><path d="M12 7v5l3.5 2" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "people") return <svg {...p}><circle cx="9" cy="8" r="3.4" stroke={c} strokeWidth="2" /><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6M16 5.5a3.4 3.4 0 010 6.6M18 20c0-2.2-.7-3.9-2-5" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "car") return <svg {...p}><path d="M5 16v-3.2L6.8 8h10.4L19 12.8V16" stroke={c} strokeWidth="2" strokeLinejoin="round" /><path d="M3 16h18" stroke={c} strokeWidth="2" strokeLinecap="round" /><circle cx="7.5" cy="17.5" r="1.6" stroke={c} strokeWidth="2" /><circle cx="16.5" cy="17.5" r="1.6" stroke={c} strokeWidth="2" /></svg>;
  if (k === "nav") return <svg {...p}><path d="M3 11l18-8-8 18-2-8-8-2z" stroke={c} strokeWidth="2.2" strokeLinejoin="round" /></svg>;
  if (k === "share") return <svg {...p}><path d="M12 15V4m0 0L8 8m4-4l4 4M5 14v4a2 2 0 002 2h10a2 2 0 002-2v-4" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "check") return <svg {...p}><path d="M5 12l4 4 10-10" stroke={c} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "star") return <svg {...p}><path d="M12 4l2.5 5.2 5.5.7-4 3.9 1 5.4-5-2.7-5 2.7 1-5.4-4-3.9 5.5-.7z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  if (k === "heart") return <svg {...p}><path d="M12 20.5s-8-4.9-8-11A4.8 4.8 0 0112 6.3 4.8 4.8 0 0120 9.5c0 6.1-8 11-8 11z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  if (k === "comment") return <svg {...p}><path d="M4 12a8 8 0 1113.3 6L20 20l-3-1.4A8 8 0 014 12z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  if (k === "save") return <svg {...p}><path d="M6 4h12v16l-6-4-6 4V4z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  if (k === "chev") return <svg {...p}><path d="M9 5l7 7-7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "close") return <svg {...p}><path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2.4" strokeLinecap="round" /></svg>;
  if (k === "plus") return <svg {...p}><path d="M12 5v14M5 12h14" stroke={c} strokeWidth="2.4" strokeLinecap="round" /></svg>;
  if (k === "hourglass") return <svg {...p}><path d="M7 3h10M7 21h10M8 3c0 4 4 5 4 9s-4 5-4 9M16 3c0 4-4 5-4 9s4 5 4 9" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "verified") return (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
        <path d="M12 2l2.4 2.1 3.1-.5 1 3 2.9 1.4-.9 3.1 1.7 2.8-2.4 2.1.4 3.1-3.1.5-1.7 2.7-3-1.2-3 1.2-1.7-2.7-3.1-.5.4-3.1-2.4-2.1 1.7-2.8-.9-3.1 2.9-1.4 1-3 3.1.5z" fill={c || EW_KE.accent} />
        <path d="M8.5 12.2l2.3 2.3 4.5-4.9" stroke="#fff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      </svg>);

  return null;
}

// Overlapping attendee avatars + count
function AvatarStack({ avatars, count, label = "going", max = 5, size = 24 }) {
  const K = EW_KE;
  const shown = avatars.slice(0, max);
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
      <div style={{ display: "flex" }}>
        {shown.map((a, i) =>
        <img key={i} src={a} alt="" style={{
          width: size, height: size, borderRadius: 999, objectFit: "cover",
          background: K.line2, marginLeft: i ? -size * 0.34 : 0,
          outline: `2px solid ${K.surface}`, position: "relative", zIndex: max - i
        }} />
        )}
      </div>
      <span style={{ fontFamily: EW_FB, fontSize: 12.5, color: K.ink2 }}>
        <strong style={{ fontFamily: EW_FD, color: K.ink }}>{window.EV.fmtCount(count)}</strong> {label}
      </span>
    </div>);

}

// soft tinted stat tile (no borders)
function EvStat({ icon, value, label, accent }) {
  const K = EW_KE;
  return (
    <div style={{ flex: 1, background: K.bgSoft, borderRadius: 14, padding: "10px 12px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        <EvIcon k={icon} c={accent ? K.accent : K.mute} s={13} />
        <span style={{
          fontFamily: EW_FD, fontWeight: 700, fontSize: 15, letterSpacing: -0.2,
          color: accent ? K.accent : K.ink
        }}>{value}</span>
      </div>
      <div style={{ fontFamily: EW_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1.1, color: K.mute, marginTop: 3 }}>
        {label}
      </div>
    </div>);

}

function EvMetaRow({ icon, children, strong }) {
  const K = EW_KE;
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
      <EvIcon k={icon} c={K.mute} s={14} />
      <span style={{
        fontFamily: strong ? EW_FD : EW_FB, fontWeight: strong ? 700 : 500,
        fontSize: 13, color: strong ? K.ink : K.ink2, lineHeight: 1.35
      }}>{children}</span>
    </div>);

}

function OrganizerRow({ org, compact }) {
  const K = EW_KE;
  const isBiz = org.kind === "business";
  return (
    <button style={{
      width: "100%", border: "none", cursor: "pointer", background: compact ? "transparent" : K.bgSoft,
      borderRadius: 14, padding: compact ? 0 : "10px 12px", display: "flex", alignItems: "center", gap: 10, textAlign: "left"
    }}>
      <img src={org.avatar} alt="" style={{
        width: 32, height: 32, borderRadius: isBiz ? 10 : 999,
        objectFit: "cover", background: K.line2, flexShrink: 0
      }} />
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: "flex", alignItems: "center", gap: 4 }}>
          <span style={{
            fontFamily: EW_FD, fontWeight: 700, fontSize: 13, color: K.ink,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{org.name}</span>
          {org.verified && <EvIcon k="verified" c={isBiz ? K.business : K.accent} s={13} />}
        </span>
        <span style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 2 }}>
          <span style={{
            fontFamily: EW_FB, fontSize: 11.5, color: K.mute,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{isBiz ? `${org.business_type} · organizer` : `@${org.handle} · organizer`}</span>
          <span style={{
            flexShrink: 0, fontFamily: EW_FD, fontWeight: 700, fontSize: 8, letterSpacing: 0.8,
            borderRadius: 999, padding: "2px 6px",
            background: K.surface, color: K.mute
          }}>{isBiz ? "BUSINESS" : "INDIVIDUAL"}</span>
        </span>
      </span>
      <EvIcon k="chev" c={K.muteSoft} s={14} />
    </button>);

}

// Attending (spectator) / Interested pair — reflects car_event_attendees_list.status
function AttendanceToggle({ value, onChange }) {
  const K = EW_KE;
  const opts = [{ k: "attending", label: "Attending", icon: "check" }, { k: "interested", label: "Interested", icon: "star" }];
  return (
    <div style={{ display: "flex", gap: 8 }}>
      {opts.map((o) => {
        const on = value === o.k;
        return (
          <button key={o.k} onClick={() => onChange(on ? null : o.k)} style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: on ? K.ink : K.bgSoft, color: on ? "#fff" : K.ink2,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
            fontFamily: EW_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6,
            transition: "background 140ms ease"
          }}>
            <EvIcon k={o.icon} c={on ? "#fff" : K.mute} s={13} />
            {o.label.toUpperCase()}
          </button>);

      })}
    </div>);

}

// Participation state — requests only exist for upcoming meets
function ParticipationBlock({ ev, state, onRetry }) {
  const K = EW_KE;
  if (ev.status !== "upcoming") {
    if (state && state.status === "accepted") {
      return (
        <div style={{ background: K.bgSoft, borderRadius: 14, padding: "11px 13px", display: "flex", alignItems: "center", gap: 9 }}>
          <span style={{ fontFamily: EW_FB, fontSize: 12.5, color: K.ink2 }}>
            Your <strong style={{ color: K.ink }}>{state.car}</strong> is on the entry list
          </span>
        </div>);

    }
    return null;
  }
  if (!state) return null;
  const carLabel = state.cars ? state.cars.map((c) => `${c.brand} ${c.model}`).join(", ") : state.car;
  const map = {
    pending: { icon: "hourglass", tint: K.mute, text: "Request sent — waiting for the organizer" },
    accepted: { icon: "check", tint: K.mute, text: `Approved${carLabel ? " · " + carLabel : ""}` },
    rejected: { icon: "close", tint: K.mute, text: state.note || "Request declined by the organizer" }
  }[state.status];
  return (
    <div style={{
      background: K.bgSoft,
      borderRadius: 14, padding: "11px 13px", display: "flex", flexDirection: "column", gap: 8
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 9 }}>
        <EvIcon k={map.icon} c={map.tint} s={15} />
        <span style={{ fontFamily: EW_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.35 }}>{map.text}</span>
      </div>
      {state.status === "rejected" &&
      <button onClick={onRetry} style={{
        alignSelf: "flex-start", height: 30, padding: "0 12px", borderRadius: 9, border: "none", cursor: "pointer",
        background: K.surface, color: K.ink, fontFamily: EW_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.5
      }}>TRY AGAIN</button>
      }
    </div>);

}

// Full-screen request flow — pick garage cars + optional notes, send to the organizer
function ParticipationRequestScreen({ ev, onClose, onSubmit }) {
  const K = EW_KE;
  const garage = window.EV.MY_GARAGE;
  const [selected, setSelected] = React.useState([]);
  const [note, setNote] = React.useState("");
  const toggle = (id) => setSelected((s) => s.includes(id) ? s.filter((x) => x !== id) : [...s, id]);
  const chosen = garage.filter((c) => selected.includes(c.id));
  return (
    <div onClick={(e) => e.stopPropagation()} style={{ position: "absolute", inset: 0, zIndex: 120, background: K.surface, display: "flex", flexDirection: "column" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "18px 18px 4px", flexShrink: 0 }}>
        <button onClick={onClose} style={{ width: 34, height: 34, borderRadius: 999, border: "none", cursor: "pointer", background: K.bgSoft, display: "grid", placeItems: "center" }}>
          <span style={{ display: "block", transform: "rotate(180deg)" }}><EvIcon k="chev" c={K.ink} s={14} /></span>
        </button>
        <span style={{ fontFamily: EW_FD, fontWeight: 700, fontSize: 16, color: K.ink, letterSpacing: -0.3 }}>Request to bring a car</span>
      </div>
      <div style={{ flex: 1, overflowY: "auto", padding: 18, display: "flex", flexDirection: "column", gap: 16 }}>
        <p style={{ margin: 0, fontFamily: EW_FB, fontSize: 12.5, color: K.mute, lineHeight: 1.5 }}>
          Select one or more cars from your garage. {ev.organizers[0].kind === "business" ? ev.organizers[0].name : "The organizer"} will decide whether you can participate.
        </p>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {garage.map((c) => {
            const on = selected.includes(c.id);
            return (
              <button key={c.id} onClick={() => toggle(c.id)} style={{
                display: "flex", alignItems: "center", gap: 10, padding: "9px 12px", borderRadius: 14,
                border: "none", cursor: "pointer", background: K.bgSoft, textAlign: "left",
                boxShadow: on ? `inset 0 0 0 2px ${K.ink}` : "none"
              }}>
                <img src={c.photo} alt="" style={{ width: 44, height: 44, borderRadius: 10, objectFit: "cover", flexShrink: 0 }} />
                <span style={{ flex: 1, minWidth: 0, fontFamily: EW_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>{c.year} {c.brand} {c.model}</span>
                <span style={{
                  width: 20, height: 20, borderRadius: 6, flexShrink: 0,
                  border: `2px solid ${on ? K.ink : K.line}`, background: on ? K.ink : "transparent",
                  display: "grid", placeItems: "center"
                }}>{on && <EvIcon k="check" c="#fff" s={11} />}</span>
              </button>);

          })}
        </div>
        <div>
          <span style={{ display: "block", fontFamily: EW_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.8, color: K.mute, marginBottom: 6 }}>
            NOTES FOR ORGANIZERS (OPTIONAL)
          </span>
          <textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Anything the organizer should know…" rows={3} style={{
            width: "100%", resize: "vertical", border: `1px solid ${K.line}`, borderRadius: 12, padding: 10,
            fontFamily: EW_FB, fontSize: 13, color: K.ink, boxSizing: "border-box"
          }} />
        </div>
      </div>
      <div style={{ padding: 18, flexShrink: 0 }}>
        <button disabled={!chosen.length} onClick={() => onSubmit({ cars: chosen, note })} style={{
          width: "100%", height: 50, borderRadius: 14, border: "none", cursor: chosen.length ? "pointer" : "default",
          background: chosen.length ? K.ink : K.bgSoft, color: chosen.length ? "#fff" : K.muteSoft,
          fontFamily: EW_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.8
        }}>SEND REQUEST</button>
      </div>
    </div>);

}

// ─────────────────────────────────────────────────────────
// The floating widget
// ─────────────────────────────────────────────────────────
function EventWidget({ ev, onClose, onOpenEvent }) {
  if (!ev) return null;
  const K = EW_KE;
  const [going, setGoing] = React.useState(ev.my_attendance || null);
  const [part, setPart] = React.useState(ev.my_participation || null);
  const [showRequest, setShowRequest] = React.useState(false);
  const live = ev.status === "live";

  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 90, background: "rgba(10,10,10,0.34)",
      display: "flex", alignItems: "center", justifyContent: "center", padding: "0 18px"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", maxWidth: 340, maxHeight: "84%", overflowY: "auto",
        background: K.surface, borderRadius: 24, boxShadow: "0 30px 70px rgba(0,0,0,0.38)"
      }}>
        {/* cover */}
        <div style={{ position: "relative", height: 132, background: K.bgSoft }}>
          <img src={ev.cover} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
          <div style={{
            position: "absolute", inset: 0,
            background: "linear-gradient(180deg,rgba(10,10,10,0.34) 0%,rgba(10,10,10,0) 45%)"
          }} />
          <div style={{ position: "absolute", top: 12, left: 12 }}><EvStatusChip status={ev.status} /></div>
          <div style={{ position: "absolute", top: 10, right: 10, display: "flex", gap: 6 }}>
            <button style={{
              width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
              background: "rgba(10,10,10,0.5)", display: "grid", placeItems: "center"
            }}><EvIcon k="share" c="#fff" s={14} /></button>
            <button onClick={onClose} style={{
              width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
              background: "rgba(10,10,10,0.5)", display: "grid", placeItems: "center"
            }}><EvIcon k="close" c="#fff" s={13} /></button>
          </div>
        </div>

        <div style={{ padding: 18, display: "flex", flexDirection: "column", gap: 14 }}>
          <div>
            <div style={{
              fontFamily: EW_FD, fontWeight: 700, fontSize: 19, color: K.ink,
              letterSpacing: -0.4, lineHeight: 1.18
            }}>{ev.title}</div>
            <p style={{
              margin: "8px 0 0", fontFamily: EW_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.5,
              display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden"
            }}>{ev.description}</p>
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <EvMetaRow icon="pin" strong>{ev.location_name}</EvMetaRow>
            <EvMetaRow icon="clock">{window.EV.fmtRange(ev.starts_at, ev.ends_at)}</EvMetaRow>
          </div>

          <div style={{ display: "flex", gap: 8 }}>
            <EvStat icon="people" value={window.EV.fmtCount(ev.attendees_count)} label="ATTENDEES" />
            <EvStat icon="car" value={ev.attending_cars_count} label="CARS" />
            <EvStat icon="nav" value={ev.distance} label="AWAY" />
          </div>

          <AvatarStack avatars={ev.attendees} count={ev.attendees_count} />

          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {ev.organizers.map((o, i) => <OrganizerRow key={i} org={o} />)}
          </div>

          {ev.status !== "previous" && <AttendanceToggle value={going} onChange={setGoing} />}
          {ev.status === "upcoming" && !part &&
          <button onClick={() => setShowRequest(true)} style={{
            width: "100%", height: 44, borderRadius: 13, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            fontFamily: EW_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.6
          }}>WANT TO PARTICIPATE?</button>
          }
          <ParticipationBlock ev={ev} state={part} onRetry={() => setShowRequest(true)} />

          <div style={{ display: "flex", gap: 8 }}>
            <button style={{
              width: 52, height: 48, borderRadius: 14, border: "none", cursor: "pointer",
              background: K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
            }}><EvIcon k="nav" c={K.ink} s={17} /></button>
            <button onClick={onOpenEvent} style={{
              flex: 1, height: 48, borderRadius: 14, border: "none", cursor: "pointer",
              background: K.accent, color: K.onAccent,
              display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
              fontFamily: EW_FD, fontWeight: 700, fontSize: 12.5, letterSpacing: 1.2
            }}>
              VIEW EVENT
              <EvIcon k="chev" c="#fff" s={14} />
            </button>
          </div>
        </div>
      </div>

      {showRequest &&
      <ParticipationRequestScreen ev={ev} onClose={() => setShowRequest(false)} onSubmit={({ cars, note }) => { setPart({ status: "pending", cars, note }); setShowRequest(false); }} />
      }
    </div>);

}

Object.assign(window, {
  EventWidget, EvStatusChip, EvIcon, AvatarStack, EvStat, EvMetaRow,
  OrganizerRow, AttendanceToggle, ParticipationBlock, ParticipationRequestScreen
});
