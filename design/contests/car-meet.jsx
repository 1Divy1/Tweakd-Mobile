// car-meet.jsx — Kinetic Edge
// Dedicated event page (car meets). Top half = event info, bottom half = participating cars.
// Borderless surfaces; orange only for LIVE + primary actions.

const CM_KE = window.KE;
const CM_FD = window.KE_FONT_DISPLAY;
const CM_FB = window.KE_FONT_BODY;
const {
  EvStatusChip: CMStatusChip, EvIcon: CMIcon, AvatarStack: CMStack,
  EvStat: CMStat, OrganizerRow: CMOrganizer } = window;

function SectionTitle({ children, action, onAction }) {
  const K = CM_KE;
  return (
    <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 12 }}>
      <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.5, color: K.mute }}>
        {children}
      </span>
      {action &&
      <button onClick={onAction} style={{
        border: "none", background: "transparent", cursor: "pointer", padding: 0,
        fontFamily: CM_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.6, color: K.accent
      }}>{action}</button>
      }
    </div>);

}

function Block({ children, pad = 16, tint }) {
  const K = CM_KE;
  return (
    <div style={{ background: tint || K.bgSoft, borderRadius: 18, padding: pad }}>{children}</div>);

}

// ── Hero ────────────────────────────────────────────────
function EventHero({ ev, onBack }) {
  const K = CM_KE;
  return (
    <div style={{ position: "relative", height: 268, background: K.ink }}>
      <img src={ev.cover} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
      <div style={{
        position: "absolute", inset: 0,
        background: "linear-gradient(180deg,rgba(10,10,10,0.5) 0%,rgba(10,10,10,0.05) 38%,rgba(10,10,10,0.82) 100%)"
      }} />
      <div style={{ position: "absolute", top: 52, left: 16, right: 16, display: "flex", justifyContent: "space-between" }}>
        <button onClick={onBack} style={{
          width: 38, height: 38, borderRadius: 999, border: "none", cursor: "pointer",
          background: "rgba(255,255,255,0.92)", display: "grid", placeItems: "center",
          boxShadow: "0 4px 14px rgba(0,0,0,0.2)"
        }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={K.ink} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" /></svg>
        </button>
        <button style={{
          width: 38, height: 38, borderRadius: 999, border: "none", cursor: "pointer",
          background: "rgba(255,255,255,0.92)", display: "grid", placeItems: "center",
          boxShadow: "0 4px 14px rgba(0,0,0,0.2)"
        }}><CMIcon k="share" c={K.ink} s={16} /></button>
      </div>
      <div style={{ position: "absolute", left: 18, right: 18, bottom: 18 }}>
        <CMStatusChip status={ev.status} />
        <div style={{
          fontFamily: CM_FD, fontWeight: 700, fontSize: 25, color: "#fff",
          letterSpacing: -0.6, lineHeight: 1.12, marginTop: 10, textWrap: "pretty"
        }}>{ev.title}</div>
        <div style={{ display: "flex", alignItems: "center", gap: 7, marginTop: 8 }}>
          <CMIcon k="pin" c="rgba(255,255,255,0.75)" s={13} />
          <span style={{ fontFamily: CM_FB, fontSize: 13, color: "rgba(255,255,255,0.88)" }}>
            {ev.location_name} · {ev.distance}
          </span>
        </div>
      </div>
    </div>);

}

// ── Sticky tabs ─────────────────────────────────────────
function EventTabs({ tab, onTab, carCount, contestCount, contestLive }) {
  const K = CM_KE;
  const tabs = [{ k: "overview", label: "OVERVIEW" }, { k: "cars", label: `CARS · ${carCount}` }];
  if (contestCount) tabs.push({ k: "contests", label: "CONTESTS", dot: contestLive });
  return (
    <div style={{
      flexShrink: 0, zIndex: 20, background: K.surface,
      padding: "10px 16px 12px", boxShadow: "0 8px 16px -12px rgba(10,10,10,0.35)"
    }}>
      <div style={{ display: "flex", gap: 6, background: K.bgSoft, borderRadius: 14, padding: 4 }}>
        {tabs.map((t) => {
          const on = tab === t.k;
          return (
            <button key={t.k} onClick={() => onTab(t.k)} style={{
              flex: 1, height: 38, borderRadius: 11, border: "none", cursor: "pointer",
              background: on ? K.surface : "transparent", color: on ? K.ink : K.mute,
              fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.9,
              boxShadow: on ? "0 2px 8px rgba(10,10,10,0.1)" : "none", transition: "all 140ms ease",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 5
            }}>
              {t.dot && <span className="ke-blink" style={{ width: 5, height: 5, borderRadius: 999, background: K.accent }} />}
              {t.label}
            </button>);

        })}
      </div>
    </div>);

}

// ── When / deadline rows ────────────────────────────────
function WhenBlock({ ev, regClosed }) {
  const K = CM_KE;
  const s = new Date(ev.starts_at);
  const live = ev.status === "live";
  return (
    <Block pad={0}>
      <div style={{ display: "flex", alignItems: "center", gap: 14, padding: 16 }}>
        <div style={{
          width: 56, height: 60, borderRadius: 14, background: K.surface, flexShrink: 0,
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center"
        }}>
          <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 9.5, letterSpacing: 1, color: live ? K.accent : K.mute }}>
            {["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][s.getMonth()]}
          </span>
          <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 23, color: K.ink, letterSpacing: -0.5, lineHeight: 1.1 }}>
            {s.getDate()}
          </span>
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 14, color: K.ink, letterSpacing: -0.2 }}>
            {window.EV.fmtRange(ev.starts_at, ev.ends_at)}
          </div>
          <div style={{ fontFamily: CM_FB, fontSize: 12.5, color: K.mute, marginTop: 3 }}>
            {ev.address}
          </div>
        </div>
      </div>
      {ev.status === "upcoming" &&
      <div style={{
        display: "flex", alignItems: "center", gap: 9, padding: "12px 16px",
        background: K.bgSoft,
        borderRadius: "0 0 18px 18px"
      }}>
          <CMIcon k={regClosed ? "close" : "hourglass"} c={K.mute} s={14} />
          <span style={{ fontFamily: CM_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.35 }}>
            {regClosed ?
          <>Car registration <strong style={{ color: K.ink }}>closed</strong> — spectators still welcome</> :
          <>Register your car before <strong style={{ color: K.ink }}>{window.EV.fmtDeadline(ev.registration_deadline)}</strong></>}
          </span>
        </div>
      }
    </Block>);

}

// ── Participation status card (pending / rejected only — accepted shows via the top row) ──
function ParticipateCTA({ ev, state, onRetry }) {
  const K = CM_KE;
  if (ev.status === "previous") return null;
  if (state && state.status === "accepted") return null;
  if (ev.status === "live" && !state) {
    return (
      <Block>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <CMIcon k="close" c={K.mute} s={15} />
          <span style={{ fontFamily: CM_FB, fontSize: 12.5, color: K.ink2 }}>
            Entries are closed — the meet is already running
          </span>
        </div>
      </Block>);

  }
  if (!state) return null;
  const carLabel = state.cars ? state.cars.map((c) => `${c.brand} ${c.model}`).join(", ") : state.car;
  const map = {
    pending: {
      tint: K.bgSoft, icon: "hourglass", color: K.ink,
      title: "Request pending",
      body: `${ev.organizers[0].kind === "business" ? ev.organizers[0].name : "@" + ev.organizers[0].handle} will approve or decline your entry.`
    },
    rejected: {
      tint: K.bgSoft, icon: "close", color: K.mute,
      title: "Entry declined",
      body: state.note || "The organizer declined this entry."
    }
  }[state.status];
  return (
    <Block tint={map.tint}>
      <div style={{ display: "flex", gap: 12 }}>
        <span style={{
          width: 36, height: 36, borderRadius: 12, background: CM_KE.surface,
          display: "grid", placeItems: "center", flexShrink: 0
        }}><CMIcon k={map.icon} c={map.color} s={16} /></span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 13.5, color: K.ink, letterSpacing: -0.1 }}>
              {map.title}
            </span>
            {carLabel &&
            <span style={{
              fontFamily: CM_FB, fontSize: 11.5, color: K.mute,
              whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
            }}>· {carLabel}</span>
            }
          </div>
          <p style={{ margin: "5px 0 0", fontFamily: CM_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.45 }}>
            {map.body}
          </p>
          {state.status === "rejected" &&
          <button onClick={onRetry} style={{
            marginTop: 10, height: 34, padding: "0 14px", borderRadius: 10, border: "none", cursor: "pointer",
            background: K.surface, color: K.ink, fontFamily: CM_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.6
          }}>TRY ANOTHER CAR</button>
          }
        </div>
      </div>
    </Block>);

}

// ── Attendance row: interested / attending / participating ─
function AttendanceRow({ tier, onTier, participation, onParticipate, regClosed }) {
  const K = CM_KE;
  const pending = participation && participation.status === "pending";
  const partOn = !!participation && participation.status !== "rejected";
  const seg = (on) => ({
    flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
    display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
    fontFamily: CM_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.4,
    background: on ? K.ink : K.bgSoft, color: on ? "#fff" : K.ink2
  });
  return (
    <div style={{ display: "flex", gap: 8 }}>
      <button onClick={() => onTier(tier === "interested" ? null : "interested")} style={seg(tier === "interested")}>
        INTERESTED
      </button>
      <button onClick={() => onTier(tier === "attending" ? null : "attending")} style={seg(tier === "attending")}>
        ATTENDING
      </button>
      <button onClick={regClosed ? undefined : onParticipate} style={{
        ...seg(partOn && !pending),
        background: pending ? K.accentWash : partOn ? K.ink : K.bgSoft,
        color: pending ? K.accent : partOn ? "#fff" : regClosed ? K.muteSoft : K.ink2,
        cursor: regClosed ? "default" : "pointer", opacity: regClosed ? 0.6 : 1
      }}>
        <CMIcon k={pending ? "hourglass" : "car"} c={pending ? K.accent : partOn ? "#fff" : regClosed ? K.muteSoft : K.mute} s={13} />
        {pending ? "PENDING" : "PARTICIPATE?"}
      </button>
    </div>);

}

// ── Car-picker sheet: choose garage cars + notes, send for approval ─
function ParticipateSheet({ open, onClose, onSubmit, initial }) {
  const K = CM_KE;
  const garage = window.EV.MY_GARAGE;
  const [selected, setSelected] = React.useState((initial && initial.cars || []).map((c) => c.id));
  const [note, setNote] = React.useState((initial && initial.note) || "");
  if (!open) return null;
  const toggle = (id) => setSelected((s) => s.includes(id) ? s.filter((x) => x !== id) : [...s, id]);
  const chosen = garage.filter((c) => selected.includes(c.id));
  return (
    <div onClick={onClose} style={{ position: "absolute", inset: 0, zIndex: 90, background: "rgba(10,10,10,0.4)", display: "flex", alignItems: "flex-end" }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", maxHeight: "88%", overflowY: "auto", background: K.surface,
        borderRadius: "24px 24px 0 0", padding: 20, display: "flex", flexDirection: "column", gap: 16
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.3 }}>Bring a car</span>
          <button onClick={onClose} style={{ width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer", background: K.bgSoft, display: "grid", placeItems: "center" }}>
            <CMIcon k="close" c={K.ink} s={13} />
          </button>
        </div>
        <p style={{ margin: 0, fontFamily: CM_FB, fontSize: 12.5, color: K.mute, lineHeight: 1.5 }}>
          Select one or more cars from your garage. The organizer will approve or decline your entry.
        </p>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {garage.map((c) => {
            const on = selected.includes(c.id);
            return (
              <button key={c.id} onClick={() => toggle(c.id)} style={{
                display: "flex", alignItems: "center", gap: 10, padding: "9px 12px", borderRadius: 14,
                border: "none", cursor: "pointer", background: on ? K.accentWash : K.bgSoft, textAlign: "left"
              }}>
                <img src={c.photo} alt="" style={{ width: 44, height: 44, borderRadius: 10, objectFit: "cover", flexShrink: 0 }} />
                <span style={{ flex: 1, minWidth: 0, fontFamily: CM_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>{c.year} {c.brand} {c.model}</span>
                <span style={{
                  width: 20, height: 20, borderRadius: 6, flexShrink: 0,
                  border: `2px solid ${on ? K.accent : K.line}`, background: on ? K.accent : "transparent",
                  display: "grid", placeItems: "center"
                }}>{on && <CMIcon k="check" c="#fff" s={11} />}</span>
              </button>);

          })}
        </div>
        <div>
          <span style={{ display: "block", fontFamily: CM_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.8, color: K.mute, marginBottom: 6 }}>
            NOTES FOR ORGANIZERS (OPTIONAL)
          </span>
          <textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Anything the organizer should know…" rows={3} style={{
            width: "100%", resize: "vertical", border: `1px solid ${K.line}`, borderRadius: 12, padding: 10,
            fontFamily: CM_FB, fontSize: 13, color: K.ink, boxSizing: "border-box"
          }} />
        </div>
        <button disabled={!chosen.length} onClick={() => onSubmit({ cars: chosen, note })} style={{
          height: 50, borderRadius: 14, border: "none", cursor: chosen.length ? "pointer" : "default",
          background: chosen.length ? K.ink : K.bgSoft, color: chosen.length ? "#fff" : K.muteSoft,
          fontFamily: CM_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.8
        }}>SEND REQUEST</button>
      </div>
    </div>);

}

// ── Withdraw confirmation ──────────────────────────────
function WithdrawModal({ open, onClose, onConfirm }) {
  const K = CM_KE;
  const [note, setNote] = React.useState("");
  if (!open) return null;
  return (
    <div onClick={onClose} style={{ position: "absolute", inset: 0, zIndex: 95, background: "rgba(10,10,10,0.45)", display: "flex", alignItems: "center", justifyContent: "center", padding: "0 20px" }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: "100%", maxWidth: 340, background: K.surface, borderRadius: 20, padding: 20, display: "flex", flexDirection: "column", gap: 14 }}>
        <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 16, color: K.ink, letterSpacing: -0.2 }}>Withdraw from this meet?</span>
        <p style={{ margin: 0, fontFamily: CM_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.5 }}>
          You'll be removed from the entry list and from any contests running inside this meet. You can request entry again later.
        </p>
        <div>
          <span style={{ display: "block", fontFamily: CM_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.8, color: K.mute, marginBottom: 6 }}>
            NOTE FOR ORGANIZERS (OPTIONAL)
          </span>
          <textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Let them know why, if you'd like…" rows={3} style={{
            width: "100%", resize: "vertical", border: `1px solid ${K.line}`, borderRadius: 12, padding: 10,
            fontFamily: CM_FB, fontSize: 13, color: K.ink, boxSizing: "border-box"
          }} />
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onClose} style={{ flex: 1, height: 44, borderRadius: 12, border: "none", cursor: "pointer", background: K.bgSoft, color: K.ink, fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6 }}>CANCEL</button>
          <button onClick={() => onConfirm(note)} style={{ flex: 1, height: 44, borderRadius: 12, border: "none", cursor: "pointer", background: K.accent, color: "#fff", fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6 }}>WITHDRAW</button>
        </div>
      </div>
    </div>);

}

// ── Participating car card (photo-forward) ──────────────
function CarCard({ c, onOpen }) {
  const K = CM_KE;
  return (
    <button onClick={onOpen} style={{
      width: "100%", border: "none", padding: 0, cursor: "pointer", textAlign: "left",
      background: K.surface, borderRadius: 18, overflow: "hidden",
      boxShadow: "0 2px 14px rgba(10,10,10,0.07)"
    }}>
      <span style={{ display: "block", position: "relative", height: 152, background: K.bgSoft }}>
        <img src={c.photo} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
        <span style={{
          position: "absolute", inset: 0,
          background: "linear-gradient(180deg,rgba(10,10,10,0) 45%,rgba(10,10,10,0.72) 100%)"
        }} />
        <span style={{ position: "absolute", left: 14, right: 14, bottom: 12 }}>
          <span style={{
            display: "block", fontFamily: CM_FD, fontWeight: 700, fontSize: 16, color: "#fff",
            letterSpacing: -0.3, lineHeight: 1.15
          }}>{c.brand} {c.model}</span>
          <span style={{
            display: "block", fontFamily: CM_FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.2,
            color: "rgba(255,255,255,0.72)", marginTop: 4
          }}>{c.year}</span>
        </span>
      </span>
      <span style={{ display: "flex", alignItems: "center", gap: 9, padding: "11px 14px" }}>
        <img src={c.owner.avatar} alt="" style={{ width: 26, height: 26, borderRadius: 999, objectFit: "cover", background: K.line2 }} />
        <span style={{ flex: 1, minWidth: 0, fontFamily: CM_FB, fontSize: 12.5, color: K.ink2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
          @{c.owner.handle}
        </span>
        <span style={{ display: "inline-flex", alignItems: "center", gap: 5 }}>
          <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.8, color: K.accent }}>GARAGE</span>
          <CMIcon k="chev" c={K.accent} s={12} />
        </span>
      </span>
    </button>);

}

// ── Contests teaser on the overview ─────────────────────
function ContestsBlock({ contests, onOpen, onSeeAll }) {
  const K = CM_KE;
  if (!contests || !contests.length) {
    return (
      <Block>
        <div style={{ display: "flex", gap: 12, alignItems: "flex-start" }}>
          <span style={{ width: 36, height: 36, borderRadius: 12, background: K.surface, display: "grid", placeItems: "center", flexShrink: 0 }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6" stroke={K.mute} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>
          </span>
          <div style={{ flex: 1 }}>
            <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 13.5, color: K.ink, letterSpacing: -0.1 }}>No contests</span>
            <p style={{ margin: "5px 0 0", fontFamily: CM_FB, fontSize: 12.5, color: K.ink2, lineHeight: 1.45 }}>
              The organizer hasn't opened any votes for this meet.
            </p>
          </div>
        </div>
      </Block>);
  }
  const live = contests.filter((c) => c.status === "live");
  const shown = (live.length ? live : contests).slice(0, 2);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
      {shown.map((c) => <window.ContestCard key={c.id} contest={c} onOpen={() => onOpen(c.id)} />)}
      {contests.length > shown.length &&
      <button onClick={onSeeAll} style={{
        width: "100%", height: 44, borderRadius: 13, border: "none", cursor: "pointer",
        background: K.bgSoft, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        fontFamily: CM_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.8
      }}>
          ALL {contests.length} CONTESTS
          <CMIcon k="chev" c={K.ink} s={12} />
        </button>}
    </div>);

}

// ── Attendees ───────────────────────────────────────────
function AttendeesBlock({ ev }) {
  const K = CM_KE;
  const shown = ev.attendees.slice(0, 6);
  const rest = Math.max(0, ev.attendees_count - shown.length);
  return (
    <Block>
      <div style={{ display: "flex", alignItems: "center", gap: 8, flexWrap: "wrap" }}>
        {shown.map((a, i) =>
        <img key={i} src={a} alt="" style={{ width: 38, height: 38, borderRadius: 999, objectFit: "cover", background: K.line2 }} />
        )}
        {rest > 0 &&
        <span style={{
          width: 38, height: 38, borderRadius: 999, background: K.surface, display: "grid", placeItems: "center",
          fontFamily: CM_FD, fontWeight: 700, fontSize: 11, color: K.ink2
        }}>+{window.EV.fmtCount(rest)}</span>
        }
      </div>
      <button style={{
        width: "100%", height: 40, marginTop: 14, borderRadius: 12, border: "none", cursor: "pointer",
        background: K.surface, color: K.ink, fontFamily: CM_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.8
      }}>SEE ALL ATTENDEES</button>
    </Block>);

}

// ── Recap gallery (previous meets) ──────────────────────
function RecapBlock({ ev }) {
  const K = CM_KE;
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: 6 }}>
      {ev.gallery.map((g, i) =>
      <div key={i} style={{
        position: "relative", aspectRatio: "1/1", borderRadius: 12, overflow: "hidden", background: K.bgSoft
      }}>
          <img src={g} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
          {i === ev.gallery.length - 1 &&
        <div style={{
          position: "absolute", inset: 0, background: "rgba(10,10,10,0.55)", display: "grid", placeItems: "center",
          fontFamily: CM_FD, fontWeight: 700, fontSize: 13, color: "#fff"
        }}>+142</div>
        }
        </div>
      )}
    </div>);

}

// ── Screen ──────────────────────────────────────────────
function CarMeetScreen({
  eventId = "m1", initTab = "overview", participation, regClosed = false, initEnter = false, onBack })
{
  const K = CM_KE;
  const ev = window.EV.eventById(eventId);
  const [tab, setTab] = React.useState(initTab);
  const [tier, setTier] = React.useState(ev.my_attendance || null);
  const [part, setPart] = React.useState(
    participation !== undefined ? participation : ev.my_participation);
  const [showPicker, setShowPicker] = React.useState(false);
  const [showWithdraw, setShowWithdraw] = React.useState(false);
  const contests = window.CT ? window.CT.contestsByEvent(ev.id) : [];
  const liveContest = contests.some((c) => c.status === "live");
  const [openContest, setOpenContest] = React.useState(null);
  const [showEnter, setShowEnter] = React.useState(initEnter);

  const live = ev.status === "live";
  const cars = ev.cars;
  const accepted = part && part.status === "accepted";
  const requestParticipation = ({ cars, note }) => { setPart({ status: "pending", cars, note }); setShowPicker(false); };
  const withdraw = () => { setPart(null); setShowWithdraw(false); };

  return (
    <div style={{
      width: 390, height: 844, background: K.surface, position: "relative",
      fontFamily: CM_FB, color: K.ink, overflow: "hidden", display: "flex", flexDirection: "column"
    }}>
      <div style={{ flexShrink: 0 }}>
      <EventHero ev={ev} onBack={onBack} />

      {/* stats + attendance */}
      <div style={{ padding: "16px 16px 4px", display: "flex", flexDirection: "column", gap: 12 }}>
        <div style={{ display: "flex", gap: 8 }}>
          <CMStat icon="people" value={window.EV.fmtCount(ev.attendees_count)} label="ATTENDEES" />
          <CMStat icon="car" value={ev.attending_cars_count} label="CARS" accent={live} />
          <CMStat icon="clock" value={window.EV.fmtTime(new Date(ev.starts_at))} label={live ? "STARTED" : ev.status === "previous" ? "STARTED" : "STARTS"} />
        </div>
        {ev.status !== "previous" ?
        accepted ?
        <div style={{ display: "flex", gap: 8 }}>
            <button disabled style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "default", opacity: 0.55,
            background: K.ink, color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", gap: 7,
            fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6
          }}><CMIcon k="check" c="#fff" s={13} />PARTICIPATING</button>
            <button onClick={() => setShowWithdraw(true)} style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 7,
            fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.6
          }}>WITHDRAW</button>
          </div> :
        <AttendanceRow tier={tier} onTier={setTier} participation={part} regClosed={regClosed} onParticipate={() => setShowPicker(true)} /> :
        <button style={{
          width: "100%", height: 40, borderRadius: 12, border: "none", cursor: "pointer",
          background: K.bgSoft, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          fontFamily: CM_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.8
        }}>
            <CMIcon k="star" c={K.mute} s={13} />
            FOLLOW THIS ORGANIZER
          </button>
        }
      </div>

      <EventTabs tab={tab} onTab={setTab} carCount={ev.attending_cars_count}
        contestCount={contests.length} contestLive={liveContest} />
      </div>

      <div style={{ flex: 1, overflowY: "auto", overflowX: "hidden" }}>
      {tab === "contests" ?
      <window.ContestsTab ev={ev} onOpen={setOpenContest} onEnter={() => setShowEnter(true)}
        myEntryCount={contests.filter((c) => c.my_entry && c.status !== "finished").length} /> :
      tab === "overview" ?
      <div style={{ padding: "4px 16px 34px", display: "flex", flexDirection: "column", gap: 22 }}>
          <WhenBlock ev={ev} regClosed={regClosed} />

          <ParticipateCTA ev={ev} state={part} onRetry={() => setShowPicker(true)} />

          <div>
            <SectionTitle>ABOUT THIS MEET</SectionTitle>
            <Block>
              <p style={{ margin: 0, fontFamily: CM_FB, fontSize: 13.5, color: K.ink2, lineHeight: 1.6, textWrap: "pretty" }}>
                {ev.description}
              </p>
            </Block>
          </div>

          <div>
            <SectionTitle>{ev.organizers.length > 1 ? "ORGANIZERS" : "ORGANIZER"}</SectionTitle>
            <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
              {ev.organizers.map((o, i) => <CMOrganizer key={i} org={o} />)}
            </div>
          </div>

          {ev.rules && ev.rules.length > 0 &&
        <div>
              <SectionTitle>NOTES FROM THE ORGANIZER</SectionTitle>
              <Block>
                <div style={{ display: "flex", flexDirection: "column", gap: 11 }}>
                  {ev.rules.map((r, i) =>
              <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
                      <span style={{
                  width: 18, height: 18, borderRadius: 999, background: K.surface, flexShrink: 0,
                  display: "grid", placeItems: "center", fontFamily: CM_FD, fontWeight: 700, fontSize: 9.5, color: K.mute,
                  marginTop: 1
                }}>{i + 1}</span>
                      <span style={{ fontFamily: CM_FB, fontSize: 13, color: K.ink2, lineHeight: 1.45 }}>{r}</span>
                    </div>
              )}
                </div>
              </Block>
            </div>
        }

          {ev.status === "previous" && ev.gallery &&
        <div>
              <SectionTitle action="SEE ALL">PHOTOS FROM THE MEET</SectionTitle>
              <RecapBlock ev={ev} />
            </div>
        }

          <div>
            <SectionTitle action={contests.length ? "SEE ALL" : null} onAction={() => setTab("contests")}>CONTESTS</SectionTitle>
            <ContestsBlock contests={contests} onOpen={setOpenContest} onSeeAll={() => setTab("contests")} />
          </div>

          <div>
            <SectionTitle action="SEE ALL">ATTENDEES</SectionTitle>
            <AttendeesBlock ev={ev} />
          </div>

          <button onClick={() => setTab("cars")} style={{
            width: "100%", height: 52, borderRadius: 16, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
            fontFamily: CM_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.9
          }}>
            <CMIcon k="car" c={K.ink} s={16} />
            SEE ALL {ev.attending_cars_count} CARS
            <CMIcon k="chev" c={K.ink} s={13} />
          </button>
        </div> :

      <div style={{ padding: "4px 16px 34px", display: "flex", flexDirection: "column", gap: 14 }}>
          <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between" }}>
            <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.3 }}>
              {ev.status === "previous" ? "Cars that showed up" : "On the entry list"}
            </span>
            <span style={{ fontFamily: CM_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.6, color: K.mute }}>
              {ev.attending_cars_count} APPROVED
            </span>
          </div>

          {ev.status === "upcoming" &&
        <ParticipateCTA ev={ev} state={part} onRetry={() => setShowPicker(true)} />
        }

          {cars.map((c) =>
        <CarCard key={c.id} c={c} onOpen={() => window.location.assign("About car page.html")} />
        )}

          <div style={{ textAlign: "center", padding: "6px 0 0", fontFamily: CM_FB, fontSize: 12, color: K.muteSoft }}>
            Showing {cars.length} of {ev.attending_cars_count}
          </div>
        </div>
      }
      </div>

      <ParticipateSheet open={showPicker} onClose={() => setShowPicker(false)} onSubmit={requestParticipation} initial={part && part.cars ? part : null} />
      <WithdrawModal open={showWithdraw} onClose={() => setShowWithdraw(false)} onConfirm={withdraw} />
      {window.EnterContestsSheet &&
      <window.EnterContestsSheet open={showEnter} ev={ev} onClose={() => setShowEnter(false)}
        onSave={() => setShowEnter(false)}
        initial={contests.filter((c) => c.my_entry).map((c) => c.id)} />}
      {openContest &&
      <div style={{ position: "absolute", inset: 0, zIndex: 100 }}>
          <window.ContestScreen contestId={openContest} onBack={() => setOpenContest(null)} />
        </div>}
    </div>);

}

window.CarMeetScreen = CarMeetScreen;
