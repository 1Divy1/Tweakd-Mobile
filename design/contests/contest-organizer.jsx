// contest-organizer.jsx — Kinetic Edge
// Organizer side: run the contests inside your own meet — create one,
// watch the board, finish it early with a confirm sheet, publish results.

const CO_KE = window.KE;
const CO_FD = window.KE_FONT_DISPLAY;
const CO_FB = window.KE_FONT_BODY;
const { EvIcon: COIcon, CatIcon: COCat, LeaderRow: CORow, useLiveBoard: COBoard,
  CSectionTitle: COTitle } = window;

function COHead({ title, sub, onBack, action, onAction }) {
  const K = CO_KE;
  return (
    <div style={{ padding: "52px 16px 14px", flexShrink: 0, background: K.surface }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
        <button onClick={onBack} style={{
          width: 34, height: 34, borderRadius: 999, border: "none", cursor: "pointer",
          background: K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={K.ink} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" /></svg>
        </button>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.35 }}>{title}</div>
          {sub && <div style={{
            fontFamily: CO_FB, fontSize: 11.5, color: K.mute, marginTop: 2,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{sub}</div>}
        </div>
        {action &&
          <button onClick={onAction} style={{
            height: 32, padding: "0 12px", borderRadius: 10, border: "none", cursor: "pointer",
            background: K.ink, color: "#fff", fontFamily: CO_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.7, flexShrink: 0
          }}>{action}</button>}
      </div>
    </div>);
}

// ── organizer contest row ──────────────────────────────
function OrgContestCard({ contest, onFinish, onOpen, onOpenNow }) {
  const K = CO_KE;
  const cat = window.CT.catOf(contest);
  const { board, total, flash } = COBoard(contest);
  const live = contest.status === "live";
  const finished = contest.status === "finished";
  return (
    <div style={{ background: K.surface, borderRadius: 18, padding: 14, boxShadow: "0 2px 14px rgba(10,10,10,0.07)", display: "flex", flexDirection: "column", gap: 12 }}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 11 }}>
        <span style={{
          width: 36, height: 36, borderRadius: 12, flexShrink: 0, display: "grid", placeItems: "center",
          background: live ? K.accentWash : K.bgSoft
        }}><COCat k={cat.icon} c={live ? K.accent : K.mute} s={16} /></span>
        <button onClick={onOpen} style={{ flex: 1, minWidth: 0, border: "none", background: "transparent", padding: 0, textAlign: "left", cursor: "pointer" }}>
          <span style={{ display: "block", fontFamily: CO_FD, fontWeight: 700, fontSize: 14.5, color: K.ink, letterSpacing: -0.25 }}>
            {contest.title}
          </span>
          <span style={{ display: "block", fontFamily: CO_FB, fontSize: 11.5, color: K.mute, marginTop: 3 }}>
            {live ? `${window.CT.fmtLeft(contest.closes_at)} · ${window.EV.fmtCount(total)} votes` :
              finished ? `Closed ${window.EV.fmtTime(new Date(contest.finished_at || contest.closes_at))} · ${window.EV.fmtCount(total)} votes` :
              `${window.CT.fmtOpensIn(contest.opens_at)} · ${board.length} cars entered`}
          </span>
        </button>
        <span style={{
          flexShrink: 0, display: "inline-flex", alignItems: "center", gap: 5, borderRadius: 999, padding: "4px 9px",
          background: live ? K.accent : finished ? K.ink : K.bgSoft,
          color: live || finished ? "#fff" : K.mute,
          fontFamily: CO_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1
        }}>
          {live && <window.LiveDot />}
          {live ? "OPEN" : finished ? "CLOSED" : "SCHEDULED"}
        </span>
      </div>

      {board.length > 0 && (live || finished) &&
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {board.slice(0, live ? 3 : 1).map((row) =>
            <CORow key={row.id} row={row} total={total} top dense flashing={flash === row.id} />)}
        </div>}

      {live &&
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onOpen} style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, fontFamily: CO_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.7
          }}>FULL BOARD</button>
          <button onClick={onFinish} style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: K.ink, color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", gap: 7,
            fontFamily: CO_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.7
          }}>
            <COCat k="trophy" c={K.accent} s={13} />FINISH NOW
          </button>
        </div>}

      {contest.status === "scheduled" &&
        <div style={{ display: "flex", gap: 8 }}>
          <button style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, fontFamily: CO_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.7
          }}>EDIT</button>
          <button onClick={onOpenNow} style={{
            flex: 1, height: 40, borderRadius: 12, border: "none", cursor: "pointer",
            background: K.accent, color: "#fff", fontFamily: CO_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.7
          }}>OPEN VOTING NOW</button>
        </div>}

      {finished &&
        <div style={{ display: "flex", alignItems: "center", gap: 8, background: K.bgSoft, borderRadius: 12, padding: "9px 11px" }}>
          <COIcon k="check" c={K.mute} s={14} />
          <span style={{ flex: 1, fontFamily: CO_FB, fontSize: 11.5, color: K.ink2 }}>
            Results published · badge awarded
          </span>
        </div>}
    </div>);
}

// ── finish confirmation ────────────────────────────────
function FinishSheet({ open, contest, onClose, onConfirm }) {
  const K = CO_KE;
  const { board, total } = COBoard(contest, { run: false });
  if (!open) return null;
  const lead = board[0];
  const gap = lead.votes - (board[1] ? board[1].votes : 0);
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 95, background: "rgba(10,10,10,0.5)", display: "flex", alignItems: "flex-end"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", background: K.surface, borderRadius: "24px 24px 0 0", padding: 18,
        display: "flex", flexDirection: "column", gap: 14
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.3 }}>
            Finish “{contest.title}”?
          </span>
          <button onClick={onClose} style={{
            width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
            background: K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
          }}><COIcon k="close" c={K.ink} s={13} /></button>
        </div>
        <p style={{ margin: 0, fontFamily: CO_FB, fontSize: 13, color: K.ink2, lineHeight: 1.55 }}>
          Voting closes immediately — {window.CT.fmtLeft(contest.closes_at)} early. The standings freeze as they are now
          and the winner gets the badge.
        </p>
        <div style={{ background: K.bgSoft, borderRadius: 16, padding: 12, display: "flex", flexDirection: "column", gap: 10 }}>
          <span style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: K.mute }}>WINS IF YOU FINISH NOW</span>
          <div style={{ display: "flex", alignItems: "center", gap: 11 }}>
            <img src={lead.photo} alt="" style={{ width: 46, height: 46, borderRadius: 12, objectFit: "cover" }} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 14, color: K.ink, letterSpacing: -0.2 }}>
                {lead.brand} {lead.model}
              </div>
              <div style={{ fontFamily: CO_FB, fontSize: 11.5, color: K.mute, marginTop: 2 }}>
                @{lead.owner.handle} · {lead.votes} of {total} votes
              </div>
            </div>
          </div>
          <div style={{
            display: "flex", alignItems: "center", gap: 8, borderRadius: 11, padding: "8px 10px",
            background: gap <= 3 ? K.accentWash : K.surface
          }}>
            <COCat k={gap <= 3 ? "bolt" : "check"} c={gap <= 3 ? K.accent : K.mute} s={14} />
            <span style={{ fontFamily: CO_FB, fontSize: 11.5, color: K.ink2, lineHeight: 1.4 }}>
              {gap <= 3 ?
                `Only ${gap} vote${gap === 1 ? "" : "s"} ahead of second — it could still flip.` :
                `Clear lead — ${gap} votes ahead of second.`}
            </span>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={onClose} style={{
            flex: 1, height: 50, borderRadius: 14, border: "none", cursor: "pointer",
            background: K.bgSoft, color: K.ink, fontFamily: CO_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.7
          }}>KEEP IT OPEN</button>
          <button onClick={onConfirm} style={{
            flex: 1.3, height: 50, borderRadius: 14, border: "none", cursor: "pointer",
            background: K.accent, color: "#fff", fontFamily: CO_FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.7
          }}>FINISH & PUBLISH</button>
        </div>
      </div>
    </div>);
}

// ── organizer contests dashboard ───────────────────────
function OrganizerContestsScreen({ eventId = "m1", onBack, onCreate, autoFinish, published = false }) {
  const K = CO_KE;
  const ev = window.EV.eventById(eventId);
  const all = window.CT.contestsByEvent(eventId);
  const [finishing, setFinishing] = React.useState(autoFinish ? window.CT.contestById(autoFinish) : null);
  const [closed, setClosed] = React.useState(published ? [autoFinish || "k1"] : []);
  const [banner, setBanner] = React.useState(published ? window.CT.contestById(autoFinish || "k1") : null);

  const shown = all.map((c) => closed.includes(c.id) ?
    { ...c, status: "finished", finished_at: "2026-08-11T21:12:00", finished_early: true } : c);
  const liveCount = shown.filter((c) => c.status === "live").length;

  return (
    <div style={{
      width: 390, height: 844, background: K.bg, position: "relative", overflowY: "auto", overflowX: "hidden",
      fontFamily: CO_FB, color: K.ink
    }}>
      <COHead title="Contests" sub={`${ev.title} · you're an organizer`} onBack={onBack} action="NEW" onAction={onCreate} />

      <div style={{ padding: "4px 16px 34px", display: "flex", flexDirection: "column", gap: 20 }}>
        {banner &&
          <div style={{
            background: K.ink, borderRadius: 18, padding: "13px 15px", display: "flex", alignItems: "center", gap: 11
          }}>
            <span style={{ width: 34, height: 34, borderRadius: 11, background: "rgba(255,255,255,0.1)", display: "grid", placeItems: "center", flexShrink: 0 }}>
              <COCat k="trophy" c={K.accent} s={16} />
            </span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 13, color: "#fff" }}>
                “{banner.title}” finished
              </div>
              <div style={{ fontFamily: CO_FB, fontSize: 11.5, color: "rgba(255,255,255,0.6)", marginTop: 2 }}>
                Results are live · everyone at the meet was notified
              </div>
            </div>
            <button onClick={() => setBanner(null)} style={{
              width: 28, height: 28, borderRadius: 999, border: "none", cursor: "pointer",
              background: "rgba(255,255,255,0.12)", display: "grid", placeItems: "center", flexShrink: 0
            }}><COIcon k="close" c="#fff" s={12} /></button>
          </div>}

        <div style={{ display: "flex", gap: 8 }}>
          {[
            { v: liveCount, l: "RUNNING", accent: true },
            { v: shown.filter((c) => c.status === "scheduled").length, l: "SCHEDULED" },
            { v: window.EV.fmtCount(shown.reduce((s, c) => s + window.CT.totalVotes(window.CT.resolveEntries(c)), 0)), l: "VOTES TONIGHT" }
          ].map((s, i) =>
            <div key={i} style={{ flex: 1, background: K.surface, borderRadius: 14, padding: "11px 12px" }}>
              <div style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 17, letterSpacing: -0.3, color: s.accent && s.v ? K.accent : K.ink }}>{s.v}</div>
              <div style={{ fontFamily: CO_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1, color: K.mute, marginTop: 2 }}>{s.l}</div>
            </div>)}
        </div>

        {["live", "scheduled", "finished"].map((st) => {
          const group = shown.filter((c) => c.status === st);
          if (!group.length) return null;
          return (
            <div key={st}>
              <COTitle>{st === "live" ? "RUNNING NOW" : st === "scheduled" ? "SCHEDULED" : "FINISHED"}</COTitle>
              <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
                {group.map((c) =>
                  <OrgContestCard key={c.id} contest={c}
                    onFinish={() => setFinishing(c)}
                    onOpenNow={() => {}}
                    onOpen={() => {}} />)}
              </div>
            </div>);
        })}

        <button onClick={onCreate} style={{
          width: "100%", height: 52, borderRadius: 16, border: "none", cursor: "pointer",
          background: K.surface, color: K.ink, display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
          fontFamily: CO_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.9, boxShadow: "0 2px 14px rgba(10,10,10,0.07)"
        }}>
          <COIcon k="plus" c={K.accent} s={16} />ADD ANOTHER CONTEST
        </button>
      </div>

      <FinishSheet open={!!finishing} contest={finishing || all[0]}
        onClose={() => setFinishing(null)}
        onConfirm={() => { setClosed((c) => [...c, finishing.id]); setBanner(finishing); setFinishing(null); }} />
    </div>);
}

// ── create a contest ───────────────────────────────────
function CreateContestScreen({ eventId = "m1", onBack, onDone, step: initStep = 1 }) {
  const K = CO_KE;
  const ev = window.EV.eventById(eventId);
  const cats = Object.values(window.CT.CATS);
  const [cat, setCat] = React.useState(initStep > 1 ? "exhaust" : null);
  const [title, setTitle] = React.useState(initStep > 1 ? "Best exhaust system" : "");
  const [criteria, setCriteria] = React.useState(initStep > 1 ?
    "Judged on note and build quality — walk the row, listen, then vote." : "");
  const [opens, setOpens] = React.useState("At the start of the meet");
  const [closes, setCloses] = React.useState("1 hour before it ends");
  const [entry, setEntry] = React.useState("opt_in");
  const [created, setCreated] = React.useState(false);

  const pickCat = (c) => {
    setCat(c.key);
    if (c.key !== "custom") setTitle(c.label);
    else setTitle("");
  };
  const ready = cat && title.trim().length > 2;

  const field = { width: "100%", border: "none", background: CO_KE.surface, borderRadius: 12, padding: "12px 13px", fontFamily: CO_FB, fontSize: 13.5, color: CO_KE.ink, boxSizing: "border-box" };
  const Label = ({ children }) =>
    <span style={{ display: "block", fontFamily: CO_FD, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.2, color: K.mute, marginBottom: 7 }}>{children}</span>;

  const Choice = ({ opts, value, onChange }) =>
    <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
      {opts.map((raw) => {
        const o = typeof raw === "string" ? { k: raw, label: raw } : raw;
        const on = value === o.k;
        return (
          <button key={o.k} onClick={() => onChange(o.k)} style={{
            display: "flex", alignItems: "center", gap: 10, padding: "11px 12px", borderRadius: 12, border: "none",
            cursor: "pointer", background: K.surface, textAlign: "left",
            boxShadow: on ? `inset 0 0 0 1.5px ${K.ink}` : "none"
          }}>
            <span style={{
              width: 18, height: 18, borderRadius: 999, flexShrink: 0, display: "grid", placeItems: "center",
              border: `2px solid ${on ? K.ink : K.line}`, background: on ? K.ink : "transparent"
            }}>{on && <span style={{ width: 6, height: 6, borderRadius: 999, background: "#fff" }} />}</span>
            <span style={{ flex: 1, minWidth: 0 }}>
              <span style={{ display: "block", fontFamily: CO_FD, fontWeight: 700, fontSize: 12.5, color: K.ink }}>{o.label}</span>
              {o.sub && <span style={{ display: "block", fontFamily: CO_FB, fontSize: 11, color: K.mute, marginTop: 2 }}>{o.sub}</span>}
            </span>
          </button>);
      })}
    </div>;

  return (
    <div style={{
      width: 390, height: 844, background: K.bg, position: "relative", overflow: "hidden",
      fontFamily: CO_FB, color: K.ink, display: "flex", flexDirection: "column"
    }}>
      <COHead title="New contest" sub={ev.title} onBack={onBack} />

      <div style={{ flex: 1, overflowY: "auto", overflowX: "hidden", padding: "6px 16px 26px", display: "flex", flexDirection: "column", gap: 22 }}>
        <div>
          <Label>CATEGORY</Label>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            {cats.map((c) => {
              const on = cat === c.key;
              return (
                <button key={c.key} onClick={() => pickCat(c)} style={{
                  display: "flex", alignItems: "center", gap: 9, padding: "11px 12px", borderRadius: 14, border: "none",
                  cursor: "pointer", background: on ? K.ink : K.surface, textAlign: "left"
                }}>
                  <COCat k={c.icon} c={on ? K.accent : K.mute} s={16} />
                  <span style={{
                    fontFamily: CO_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.2,
                    color: on ? "#fff" : K.ink, lineHeight: 1.2
                  }}>{c.key === "custom" ? "Custom" : c.label.replace("Best ", "")}</span>
                </button>);
            })}
          </div>
        </div>

        <div>
          <Label>CONTEST NAME</Label>
          <input value={title} onChange={(e) => setTitle(e.target.value)}
            placeholder={cat === "custom" ? "e.g. Best daily driver" : "Name shown to attendees"}
            style={{ ...field, fontFamily: CO_FD, fontWeight: 700, fontSize: 14.5 }} />
        </div>

        <div>
          <Label>HOW SHOULD PEOPLE JUDGE IT?</Label>
          <textarea value={criteria} onChange={(e) => setCriteria(e.target.value)} rows={3}
            placeholder="One or two lines. Attendees see this above the leaderboard."
            style={{ ...field, resize: "vertical", lineHeight: 1.5 }} />
        </div>

        <div>
          <Label>WHICH CARS CAN ENTER</Label>
          <Choice value={entry} onChange={setEntry} opts={[
            { k: "opt_in", label: "Owners opt in", sub: `Approved cars choose to be judged · ${ev.attending_cars_count} approved` },
            { k: "all", label: "Every approved car", sub: "Whole entry list is on the ballot" },
            { k: "pick", label: "I'll pick the entrants", sub: "You choose from the entry list" }
          ]} />
        </div>

        <div>
          <Label>VOTING OPENS</Label>
          <Choice value={opens} onChange={setOpens} opts={["As soon as I publish it", "At the start of the meet", "Set a time"]} />
        </div>

        <div>
          <Label>VOTING CLOSES</Label>
          <Choice value={closes} onChange={setCloses} opts={["1 hour before it ends", "When the meet ends", "Set a time"]} />
          <div style={{ display: "flex", alignItems: "center", gap: 9, marginTop: 9, padding: "10px 12px", background: K.surface, borderRadius: 12 }}>
            <COCat k="bolt" c={K.mute} s={14} />
            <span style={{ fontFamily: CO_FB, fontSize: 11.5, color: K.ink2, lineHeight: 1.45 }}>
              You can always finish it early from the contests list.
            </span>
          </div>
        </div>
      </div>

      <div style={{ flexShrink: 0, padding: "12px 16px 18px", background: K.bg, boxShadow: "0 -10px 22px -14px rgba(10,10,10,0.35)" }}>
        <button disabled={!ready} onClick={() => { setCreated(true); onDone && onDone(); }} style={{
          width: "100%", height: 52, borderRadius: 15, border: "none", cursor: ready ? "pointer" : "default",
          background: ready ? K.accent : K.line, color: ready ? "#fff" : K.muteSoft,
          fontFamily: CO_FD, fontWeight: 700, fontSize: 12.5, letterSpacing: 1
        }}>{created ? "PUBLISHED" : "PUBLISH CONTEST"}</button>
      </div>
    </div>);
}

Object.assign(window, { OrganizerContestsScreen, CreateContestScreen, FinishSheet, OrgContestCard });
