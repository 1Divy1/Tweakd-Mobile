// contest-ui.jsx — Kinetic Edge
// Shared contest primitives: category icons, contest cards, the realtime
// leaderboard, the winner badge and the shareable winner card.

const CU_KE = window.KE;
const CU_FD = window.KE_FONT_DISPLAY;
const CU_FB = window.KE_FONT_BODY;
const { EvIcon: CUIcon } = window;

// category glyphs — same stroke language as EvIcon
function CatIcon({ k, c, s = 14 }) {
  const p = { width: s, height: s, viewBox: "0 0 24 24", fill: "none" };
  if (k === "exhaust") return <svg {...p}><path d="M3 14h11a4 4 0 014 4v1" stroke={c} strokeWidth="2" strokeLinecap="round" /><circle cx="18" cy="9" r="3" stroke={c} strokeWidth="2" /><path d="M3 10.5v7" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "wheels") return <svg {...p}><circle cx="12" cy="12" r="8.5" stroke={c} strokeWidth="2" /><circle cx="12" cy="12" r="3" stroke={c} strokeWidth="2" /><path d="M12 3.5v5M12 15.5v5M3.5 12h5M15.5 12h5" stroke={c} strokeWidth="1.6" strokeLinecap="round" /></svg>;
  if (k === "paint") return <svg {...p}><path d="M12 3.5S5.5 11 5.5 15a6.5 6.5 0 0013 0c0-4-6.5-11.5-6.5-11.5z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  if (k === "interior") return <svg {...p}><circle cx="12" cy="12" r="8.5" stroke={c} strokeWidth="2" /><circle cx="12" cy="12" r="2.6" stroke={c} strokeWidth="2" /><path d="M3.7 11h5.8M14.5 11h5.8M12 14.6v5.9" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "loud") return <svg {...p}><path d="M5 9.5h3l4.5-3.5v12L8 14.5H5z" stroke={c} strokeWidth="2" strokeLinejoin="round" /><path d="M16.5 9a4.5 4.5 0 010 6M19.5 6.5a8 8 0 010 11" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "trophy") return <svg {...p}><path d="M7 4h10v3.5a5 5 0 01-10 0V4z" stroke={c} strokeWidth="2" strokeLinejoin="round" /><path d="M7 5.5H4.5V7a3 3 0 003 3M17 5.5h2.5V7a3 3 0 01-3 3M12 12.5V16m-3.5 3.5h7" stroke={c} strokeWidth="2" strokeLinecap="round" /></svg>;
  if (k === "vote") return <svg {...p}><path d="M4 12.5l4.5 4.5L20 6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" /></svg>;
  if (k === "bolt") return <svg {...p}><path d="M13 3L6 13h5l-1 8 7.5-10.5H12L13 3z" stroke={c} strokeWidth="2" strokeLinejoin="round" /></svg>;
  return <CUIcon k={k} c={c} s={s} />;
}

function LiveDot({ c = "#fff", s = 5 }) {
  return <span className="ke-blink" style={{ width: s, height: s, borderRadius: 999, background: c, flexShrink: 0 }} />;
}

// contest status pill
function ContestChip({ contest, size = "md" }) {
  const K = CU_KE;
  const sm = size === "sm";
  const tone =
    contest.status === "live" ? { bg: K.accent, fg: "#fff", label: window.CT.fmtLeft(contest.closes_at).toUpperCase() } :
    contest.status === "finished" ? { bg: K.ink, fg: "#fff", label: "RESULTS IN" } :
    { bg: K.bgSoft, fg: K.mute, label: window.CT.fmtOpensIn(contest.opens_at).toUpperCase() };
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 5, background: tone.bg, color: tone.fg,
      borderRadius: 999, padding: sm ? "3px 8px" : "4px 10px",
      fontFamily: CU_FD, fontWeight: 700, fontSize: sm ? 8.5 : 9.5, letterSpacing: 1, whiteSpace: "nowrap"
    }}>
      {contest.status === "live" && <LiveDot />}
      {tone.label}
    </span>);
}

// ── realtime board ─────────────────────────────────────
// Votes tick in while the contest is open; rows animate to their new rank.
function useLiveBoard(contest, { run = true, myVote } = {}) {
  const base = React.useMemo(() => window.CT.resolveEntries(contest), [contest.id]);
  const [rows, setRows] = React.useState(base);
  const [flash, setFlash] = React.useState(null);
  const prevOrder = React.useRef(window.CT.ranked(base).map((r) => r.id));

  React.useEffect(() => {
    if (!run || contest.status !== "live") return;
    const t = setInterval(() => {
      setRows((rs) => {
        const total = rs.reduce((s, r) => s + r.votes, 0) || 1;
        // weight toward the leaders, but leave room for an upset
        const pick = Math.random() < 0.22 ?
          rs[Math.floor(Math.random() * rs.length)] :
          rs.reduce((a, b) => (a.votes / total > Math.random() ? a : b));
        setFlash(pick.id);
        return rs.map((r) => r.id === pick.id ? { ...r, votes: r.votes + 1 } : r);
      });
    }, 1900);
    return () => clearInterval(t);
  }, [run, contest.id]);

  const board = window.CT.ranked(rows).map((r, i) => {
    const was = prevOrder.current.indexOf(r.id);
    return { ...r, rank: i + 1, moved: was > i ? "up" : was > -1 && was < i ? "down" : null };
  });
  React.useEffect(() => { prevOrder.current = board.map((r) => r.id); }, [board.map((r) => r.id).join()]);

  const total = rows.reduce((s, r) => s + r.votes, 0);
  const mine = myVote !== undefined ? myVote : contest.my_vote;
  return { board, total, flash, mine };
}

// one leaderboard row — bar fill sits behind the content
function LeaderRow({ row, total, top, mine, flashing, onVote, votable, dense }) {
  const K = CU_KE;
  const pct = total ? row.votes / total * 100 : 0;
  const lead = row.rank === 1 && top;
  return (
    <div style={{
      position: "relative", overflow: "hidden", borderRadius: 14,
      background: mine ? K.accentWash : K.bgSoft,
      boxShadow: mine ? `inset 0 0 0 1.5px ${K.accent}` : "none",
      transition: "background 200ms ease"
    }}>
      <div style={{ position: "relative", display: "flex", alignItems: "center", gap: 10, padding: dense ? "7px 10px" : "9px 11px" }}>
        <span style={{
          width: 22, textAlign: "center", flexShrink: 0,
          fontFamily: CU_FD, fontWeight: 700, fontSize: lead ? 17 : 14,
          letterSpacing: -0.4, color: lead ? K.accent : row.rank <= 3 ? K.ink : K.muteSoft
        }}>{row.rank}</span>
        <img src={row.photo} alt="" style={{
          width: dense ? 34 : 40, height: dense ? 34 : 40, borderRadius: 10,
          objectFit: "cover", flexShrink: 0, background: K.line2
        }} />
        <span style={{ flex: 1, minWidth: 0 }}>
          <span style={{
            display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: dense ? 12.5 : 13.5,
            color: K.ink, letterSpacing: -0.2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{row.brand} {row.model}</span>
          <span style={{ display: "flex", alignItems: "center", gap: 5, marginTop: 2 }}>
            <span style={{ fontFamily: CU_FB, fontSize: 11, color: K.mute }}>@{row.owner.handle}</span>
            {mine && <span style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 0.9, color: K.accent }}>· YOUR VOTE</span>}
            {row.moved === "up" && !mine &&
              <span style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 9, letterSpacing: 0.5, color: K.accent }}>▲</span>}
          </span>
        </span>
        <span style={{ textAlign: "right", flexShrink: 0, minWidth: 44 }}>
          <span style={{
            display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: dense ? 14 : 15.5,
            letterSpacing: -0.3, color: lead ? K.accent : K.ink,
            transform: flashing ? "scale(1.14)" : "scale(1)", transition: "transform 300ms ease"
          }}>{row.votes}</span>
          <span style={{ display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: 8, letterSpacing: 0.9, color: K.mute }}>
            {pct.toFixed(0)}%
          </span>
        </span>
        {votable &&
          <button onClick={(ev) => { ev.stopPropagation(); onVote(row.id); }} style={{
            flexShrink: 0, height: 30, padding: "0 11px", borderRadius: 9, border: "none",
            cursor: "pointer", background: mine ? K.accent : K.surface, color: mine ? "#fff" : K.ink,
            fontFamily: CU_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.7
          }}>{mine ? "VOTED" : "VOTE"}</button>}
      </div>
    </div>);
}

// compact card used in the contests tab
function ContestCard({ contest, onOpen, live }) {
  const K = CU_KE;
  const cat = window.CT.catOf(contest);
  const entries = window.CT.resolveEntries(contest);
  const board = window.CT.ranked(entries);
  const total = window.CT.totalVotes(entries);
  const finished = contest.status === "finished";
  const soon = window.CT.isClosingSoon(contest);
  return (
    <button onClick={onOpen} style={{
      width: "100%", textAlign: "left", border: "none", cursor: "pointer", padding: 14,
      background: K.surface, borderRadius: 18, boxShadow: "0 2px 14px rgba(10,10,10,0.07)",
      display: "flex", flexDirection: "column", gap: 12
    }}>
      <span style={{ display: "flex", alignItems: "flex-start", gap: 11 }}>
        <span style={{
          width: 38, height: 38, borderRadius: 12, flexShrink: 0, display: "grid", placeItems: "center",
          background: contest.status === "live" ? K.accentWash : K.bgSoft
        }}>
          <CatIcon k={cat.icon} c={contest.status === "live" ? K.accent : K.mute} s={17} />
        </span>
        <span style={{ flex: 1, minWidth: 0 }}>
          <span style={{
            display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: 15, color: K.ink,
            letterSpacing: -0.3, lineHeight: 1.2
          }}>{contest.title}</span>
          <span style={{ display: "flex", alignItems: "center", gap: 7, marginTop: 5, flexWrap: "wrap" }}>
            <ContestChip contest={contest} size="sm" />
            <span style={{ fontFamily: CU_FB, fontSize: 11.5, color: K.mute }}>
              {entries.length} cars{total ? ` · ${window.EV.fmtCount(total)} votes` : ""}
            </span>
          </span>
        </span>
        <CUIcon k="chev" c={K.muteSoft} s={14} />
      </span>

      {finished ?
        <span style={{ display: "flex", alignItems: "center", gap: 10, background: K.bgSoft, borderRadius: 14, padding: "9px 11px" }}>
          <img src={board[0].photo} alt="" style={{ width: 36, height: 36, borderRadius: 10, objectFit: "cover" }} />
          <span style={{ flex: 1, minWidth: 0 }}>
            <span style={{ display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1.1, color: K.accent }}>WINNER</span>
            <span style={{
              display: "block", fontFamily: CU_FD, fontWeight: 700, fontSize: 13, color: K.ink, letterSpacing: -0.2,
              whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
            }}>{board[0].brand} {board[0].model}</span>
          </span>
          <span style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>{board[0].votes}</span>
        </span> :
      contest.status === "scheduled" ?
        <span style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ display: "flex" }}>
            {entries.slice(0, 4).map((en, i) =>
              <img key={en.id} src={en.photo} alt="" style={{
                width: 26, height: 26, borderRadius: 8, objectFit: "cover",
                marginLeft: i ? -7 : 0, outline: `2px solid ${K.surface}`
              }} />)}
          </span>
          <span style={{ fontFamily: CU_FB, fontSize: 11.5, color: K.mute }}>
            {entries.length} cars entered{contest.my_entry ? " · yours is in" : ""}
          </span>
        </span> :
        <span style={{ display: "flex", flexDirection: "column", gap: 5 }}>
          {board.slice(0, 2).map((row) =>
            <LeaderRow key={row.id} row={row} total={total} top dense
              mine={contest.my_vote === row.id} />)}
          {!contest.my_vote &&
            <span style={{
              display: "flex", alignItems: "center", justifyContent: "center", gap: 7, height: 34,
              borderRadius: 11, background: K.accent, color: "#fff",
              fontFamily: CU_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.8, marginTop: 3
            }}>
              <CatIcon k="vote" c="#fff" s={13} />{soon ? "VOTE BEFORE IT CLOSES" : "CAST YOUR VOTE"}
            </span>}
        </span>}
    </button>);
}

// ── winner badge ───────────────────────────────────────
// Flat plate in the house language — orange for a win, ink for a placing.
function ContestBadge({ badge, size = 64, rank = 1, label = true }) {
  const K = CU_KE;
  const win = rank === 1;
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 7, width: label ? size + 22 : size }}>
      <div style={{
        width: size, height: size, borderRadius: size * 0.3, flexShrink: 0,
        background: win ? K.accent : K.ink, display: "grid", placeItems: "center", position: "relative",
        boxShadow: win ? "0 6px 18px rgba(255,77,0,0.28)" : "0 6px 16px rgba(10,10,10,0.18)"
      }}>
        <CatIcon k={badge.icon} c="#fff" s={size * 0.42} />
        <span style={{
          position: "absolute", bottom: -6, right: -6, minWidth: 22, height: 22, padding: "0 5px",
          borderRadius: 999, background: K.surface, display: "grid", placeItems: "center",
          fontFamily: CU_FD, fontWeight: 700, fontSize: 10.5, color: win ? K.accent : K.ink,
          boxShadow: "0 2px 8px rgba(10,10,10,0.16)"
        }}>{rank === 1 ? "1st" : rank === 2 ? "2nd" : "3rd"}</span>
      </div>
      {label &&
        <span style={{
          fontFamily: CU_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 0.9, color: K.mute,
          textAlign: "center", lineHeight: 1.3
        }}>{badge.short}</span>}
    </div>);
}

// ── shareable winner card ──────────────────────────────
// What the winner posts to the feed. Dark plate so it stands out in the timeline.
function WinnerCard({ badge, width = 322 }) {
  const K = CU_KE;
  return (
    <div style={{
      width, borderRadius: 20, overflow: "hidden", background: K.ink,
      boxShadow: "0 14px 40px rgba(10,10,10,0.28)"
    }}>
      <div style={{ position: "relative", height: width * 0.62, background: "#151515" }}>
        <img src={badge.car.photo} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block", opacity: 0.96 }} />
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg,rgba(10,10,10,0.55) 0%,rgba(10,10,10,0) 40%,rgba(10,10,10,0.86) 100%)" }} />
        <div style={{ position: "absolute", top: 13, left: 14, display: "inline-flex", alignItems: "center", gap: 6, background: K.accent, borderRadius: 999, padding: "5px 11px" }}>
          <CatIcon k="trophy" c="#fff" s={12} />
          <span style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.4, color: "#fff" }}>WINNER</span>
        </div>
        <div style={{ position: "absolute", left: 14, right: 14, bottom: 13 }}>
          <div style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.4, color: K.accent }}>
            {badge.short}
          </div>
          <div style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 21, color: "#fff", letterSpacing: -0.5, lineHeight: 1.15, marginTop: 4 }}>
            {badge.car.brand} {badge.car.model}
          </div>
        </div>
      </div>
      <div style={{ padding: "13px 14px 15px", display: "flex", alignItems: "center", gap: 11 }}>
        <img src={badge.car.owner.avatar} alt="" style={{ width: 30, height: 30, borderRadius: 999, objectFit: "cover", background: "#222" }} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 12.5, color: "#fff", letterSpacing: -0.1 }}>
            @{badge.car.owner.handle}
          </div>
          <div style={{
            fontFamily: CU_FB, fontSize: 11, color: "rgba(255,255,255,0.6)", marginTop: 2,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{badge.event}</div>
        </div>
        <div style={{ textAlign: "right" }}>
          <div style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 16, color: "#fff", letterSpacing: -0.3 }}>{badge.votes}</div>
          <div style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 8, letterSpacing: 1, color: "rgba(255,255,255,0.5)" }}>
            OF {badge.of} VOTES
          </div>
        </div>
      </div>
    </div>);
}

function CSectionTitle({ children, action, onAction }) {
  const K = CU_KE;
  return (
    <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 12 }}>
      <span style={{ fontFamily: CU_FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.5, color: K.mute }}>{children}</span>
      {action &&
        <button onClick={onAction} style={{
          border: "none", background: "transparent", cursor: "pointer", padding: 0,
          fontFamily: CU_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.6, color: K.accent
        }}>{action}</button>}
    </div>);
}

Object.assign(window, {
  CatIcon, LiveDot, ContestChip, useLiveBoard, LeaderRow, ContestCard,
  ContestBadge, WinnerCard, CSectionTitle
});
