// contest-attendee.jsx — Kinetic Edge
// Attendee side: the CONTESTS tab inside a meet, one contest screen with the
// realtime board, the vote picker, entry opt-in, and the results + share flow.

const CA_KE = window.KE;
const CA_FD = window.KE_FONT_DISPLAY;
const CA_FB = window.KE_FONT_BODY;
const { EvIcon: CAIcon, CatIcon: CACat, ContestChip: CAChip, ContestCard: CACard,
  LeaderRow: CARow, useLiveBoard: CABoard, ContestBadge: CABadge, WinnerCard: CAWinner,
  CSectionTitle: CATitle } = window;

function CABlock({ children, pad = 14, tint }) {
  return <div style={{ background: tint || CA_KE.bgSoft, borderRadius: 18, padding: pad }}>{children}</div>;
}

function CABar({ children }) {
  const K = CA_KE;
  return (
    <div style={{
      flexShrink: 0, background: K.surface, padding: "12px 16px 18px",
      boxShadow: "0 -10px 22px -14px rgba(10,10,10,0.4)", zIndex: 30
    }}>{children}</div>);
}

// ── CONTESTS tab inside the meet page ──────────────────
function ContestsTab({ ev, onOpen, onEnter, myEntryCount = 1 }) {
  const K = CA_KE;
  const all = window.CT.contestsByEvent(ev.id);
  const live = all.filter((c) => c.status === "live");
  const soon = all.filter((c) => c.status === "scheduled");
  const done = all.filter((c) => c.status === "finished");
  const unvoted = live.filter((c) => !c.my_vote).length;

  if (!all.length) {
    return (
      <div style={{ padding: "26px 16px 34px" }}>
        <CABlock pad={18}>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 9, textAlign: "center" }}>
            <span style={{ width: 42, height: 42, borderRadius: 13, background: K.surface, display: "grid", placeItems: "center" }}>
              <CACat k="trophy" c={K.muteSoft} s={19} />
            </span>
            <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 14.5, color: K.ink }}>No contests here</span>
            <p style={{ margin: 0, fontFamily: CA_FB, fontSize: 12.5, color: K.mute, lineHeight: 1.5, maxWidth: 250 }}>
              The organizer hasn't opened any votes for this meet.
            </p>
          </div>
        </CABlock>
      </div>);
  }

  return (
    <div style={{ padding: "4px 16px 34px", display: "flex", flexDirection: "column", gap: 22 }}>
      {/* your standing in this meet's contests */}
      <div style={{
        display: "flex", alignItems: "center", gap: 12, background: K.ink, borderRadius: 18, padding: "13px 15px"
      }}>
        <span style={{ width: 34, height: 34, borderRadius: 11, background: "rgba(255,255,255,0.1)", display: "grid", placeItems: "center", flexShrink: 0 }}>
          <CACat k="trophy" c={K.accent} s={16} />
        </span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 13, color: "#fff", letterSpacing: -0.1 }}>
            {myEntryCount ? `Your M4 is entered in ${myEntryCount} contest${myEntryCount > 1 ? "s" : ""}` : "Your car isn't entered yet"}
          </div>
          <div style={{ fontFamily: CA_FB, fontSize: 11.5, color: "rgba(255,255,255,0.6)", marginTop: 2 }}>
            {unvoted ? `${unvoted} vote${unvoted > 1 ? "s" : ""} still open to you` : "You've voted in every open contest"}
          </div>
        </div>
        <button onClick={onEnter} style={{
          flexShrink: 0, height: 32, padding: "0 12px", borderRadius: 10, border: "none", cursor: "pointer",
          background: "rgba(255,255,255,0.12)", color: "#fff",
          fontFamily: CA_FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.7
        }}>MANAGE</button>
      </div>

      {live.length > 0 &&
        <div>
          <CATitle>VOTING OPEN NOW</CATitle>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {live.map((c) => <CACard key={c.id} contest={c} onOpen={() => onOpen(c.id)} />)}
          </div>
        </div>}

      {soon.length > 0 &&
        <div>
          <CATitle>OPENS LATER TONIGHT</CATitle>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {soon.map((c) => <CACard key={c.id} contest={c} onOpen={() => onOpen(c.id)} />)}
          </div>
        </div>}

      {done.length > 0 &&
        <div>
          <CATitle>RESULTS</CATitle>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {done.map((c) => <CACard key={c.id} contest={c} onOpen={() => onOpen(c.id)} />)}
          </div>
        </div>}

      <p style={{
        margin: 0, fontFamily: CA_FB, fontSize: 11.5, color: K.muteSoft, lineHeight: 1.5,
        textAlign: "center", padding: "0 10px"
      }}>
        One vote per contest. You can change it any time until the organizer closes voting.
      </p>
    </div>);
}

// ── vote picker ────────────────────────────────────────
function VoteSheet({ open, contest, board, current, onClose, onPick }) {
  const K = CA_KE;
  const [sel, setSel] = React.useState(current || null);
  React.useEffect(() => { if (open) setSel(current || null); }, [open, current]);
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 90, background: "rgba(10,10,10,0.44)", display: "flex", alignItems: "flex-end"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", maxHeight: "90%", background: K.surface, borderRadius: "24px 24px 0 0",
        display: "flex", flexDirection: "column", overflow: "hidden"
      }}>
        <div style={{ padding: "18px 18px 12px", flexShrink: 0 }}>
          <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 12 }}>
            <div>
              <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.3 }}>
                {current ? "Change your vote" : "Pick your favourite"}
              </div>
              <div style={{ fontFamily: CA_FB, fontSize: 12, color: K.mute, marginTop: 3 }}>
                {contest.title} · {window.CT.fmtLeft(contest.closes_at)}
              </div>
            </div>
            <button onClick={onClose} style={{
              width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
              background: K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
            }}><CAIcon k="close" c={K.ink} s={13} /></button>
          </div>
        </div>
        <div style={{ flex: 1, overflowY: "auto", padding: "0 18px", display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          {board.map((row) => {
            const on = sel === row.id;
            const own = row.id === contest.my_entry;
            return (
              <button key={row.id} onClick={() => setSel(row.id)} style={{
                position: "relative", border: "none", padding: 0, cursor: "pointer", textAlign: "left",
                background: K.bgSoft, borderRadius: 16, overflow: "hidden",
                boxShadow: on ? `inset 0 0 0 2.5px ${K.accent}` : "none", transition: "box-shadow 140ms ease"
              }}>
                <span style={{ display: "block", position: "relative", height: 96 }}>
                  <img src={row.photo} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
                  {on &&
                    <span style={{
                      position: "absolute", top: 8, right: 8, width: 24, height: 24, borderRadius: 999,
                      background: K.accent, display: "grid", placeItems: "center"
                    }}><CAIcon k="check" c="#fff" s={13} /></span>}
                  {own &&
                    <span style={{
                      position: "absolute", top: 8, left: 8, background: "rgba(10,10,10,0.66)", borderRadius: 999,
                      padding: "3px 7px", fontFamily: CA_FD, fontWeight: 700, fontSize: 8, letterSpacing: 0.9, color: "#fff"
                    }}>YOUR CAR</span>}
                </span>
                <span style={{ display: "block", padding: "9px 10px 11px" }}>
                  <span style={{
                    display: "block", fontFamily: CA_FD, fontWeight: 700, fontSize: 12.5, color: K.ink,
                    letterSpacing: -0.2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
                  }}>{row.brand} {row.model}</span>
                  <span style={{ display: "block", fontFamily: CA_FB, fontSize: 10.5, color: K.mute, marginTop: 2 }}>
                    @{row.owner.handle}
                  </span>
                </span>
              </button>);
          })}
        </div>
        <div style={{ padding: 18, flexShrink: 0 }}>
          <button disabled={!sel} onClick={() => onPick(sel)} style={{
            width: "100%", height: 50, borderRadius: 14, border: "none", cursor: sel ? "pointer" : "default",
            background: sel ? K.accent : K.bgSoft, color: sel ? "#fff" : K.muteSoft,
            fontFamily: CA_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.9
          }}>{current ? "SAVE NEW VOTE" : "CAST VOTE"}</button>
        </div>
      </div>
    </div>);
}

// ── enter your car into contests ───────────────────────
function EnterContestsSheet({ open, ev, onClose, onSave, initial = ["k1", "k2"] }) {
  const K = CA_KE;
  const list = window.CT.contestsByEvent(ev.id).filter((c) => c.status !== "finished");
  const [sel, setSel] = React.useState(initial);
  if (!open) return null;
  const toggle = (id) => setSel((s) => s.includes(id) ? s.filter((x) => x !== id) : [...s, id]);
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 92, background: "rgba(10,10,10,0.44)", display: "flex", alignItems: "flex-end"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", maxHeight: "90%", overflowY: "auto", background: K.surface,
        borderRadius: "24px 24px 0 0", padding: 18, display: "flex", flexDirection: "column", gap: 14
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 17, color: K.ink, letterSpacing: -0.3 }}>Enter your car</span>
          <button onClick={onClose} style={{
            width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
            background: K.bgSoft, display: "grid", placeItems: "center"
          }}><CAIcon k="close" c={K.ink} s={13} /></button>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 10, background: K.bgSoft, borderRadius: 14, padding: "9px 11px" }}>
          <img src="assets/car-1.png" alt="" style={{ width: 40, height: 40, borderRadius: 10, objectFit: "cover" }} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>2023 BMW M4 Competition</div>
            <div style={{ fontFamily: CA_FB, fontSize: 11.5, color: K.mute, marginTop: 2 }}>Approved for this meet</div>
          </div>
        </div>
        <p style={{ margin: 0, fontFamily: CA_FB, fontSize: 12.5, color: K.mute, lineHeight: 1.5 }}>
          Pick the categories you want to be judged in. You can pull out until voting opens.
        </p>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {list.map((c) => {
            const on = sel.includes(c.id);
            const locked = c.status === "live";
            const cat = window.CT.catOf(c);
            return (
              <button key={c.id} disabled={locked && on} onClick={() => !(locked && on) && toggle(c.id)} style={{
                display: "flex", alignItems: "center", gap: 11, padding: "10px 12px", borderRadius: 14, border: "none",
                cursor: locked && on ? "default" : "pointer", background: on ? K.accentWash : K.bgSoft, textAlign: "left",
                boxShadow: on ? `inset 0 0 0 1.5px ${K.accent}` : "none"
              }}>
                <span style={{ width: 32, height: 32, borderRadius: 10, background: K.surface, display: "grid", placeItems: "center", flexShrink: 0 }}>
                  <CACat k={cat.icon} c={on ? K.accent : K.mute} s={15} />
                </span>
                <span style={{ flex: 1, minWidth: 0 }}>
                  <span style={{ display: "block", fontFamily: CA_FD, fontWeight: 700, fontSize: 13, color: K.ink, letterSpacing: -0.1 }}>{c.title}</span>
                  <span style={{ display: "block", fontFamily: CA_FB, fontSize: 11, color: K.mute, marginTop: 2 }}>
                    {locked ? (on ? "Voting open — entry locked in" : "Voting already open") : window.CT.fmtOpensIn(c.opens_at)}
                  </span>
                </span>
                <span style={{
                  width: 20, height: 20, borderRadius: 6, flexShrink: 0,
                  border: `2px solid ${on ? K.accent : K.line}`, background: on ? K.accent : "transparent",
                  display: "grid", placeItems: "center", opacity: locked && on ? 0.5 : 1
                }}>{on && <CAIcon k="check" c="#fff" s={11} />}</span>
              </button>);
          })}
        </div>
        <button onClick={() => onSave(sel)} style={{
          height: 50, borderRadius: 14, border: "none", cursor: "pointer", background: K.ink, color: "#fff",
          fontFamily: CA_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.9
        }}>SAVE ENTRIES</button>
      </div>
    </div>);
}

// ── share sheet for a win ──────────────────────────────
function ShareWinSheet({ open, badge, onClose }) {
  const K = CA_KE;
  const [posted, setPosted] = React.useState(false);
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: "absolute", inset: 0, zIndex: 95, background: "rgba(10,10,10,0.55)",
      display: "flex", alignItems: "flex-end"
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: "100%", background: K.surface, borderRadius: "24px 24px 0 0", padding: 18,
        display: "flex", flexDirection: "column", alignItems: "center", gap: 15
      }}>
        <div style={{ width: "100%", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 16, color: K.ink, letterSpacing: -0.3 }}>
            {posted ? "Posted to the feed" : "Share your win"}
          </span>
          <button onClick={onClose} style={{
            width: 30, height: 30, borderRadius: 999, border: "none", cursor: "pointer",
            background: K.bgSoft, display: "grid", placeItems: "center"
          }}><CAIcon k="close" c={K.ink} s={13} /></button>
        </div>
        <CAWinner badge={badge} width={300} />
        {posted ?
          <div style={{ display: "flex", alignItems: "center", gap: 8, fontFamily: CA_FB, fontSize: 12.5, color: K.mute }}>
            <CAIcon k="check" c={K.accent} s={14} />Your followers can see it now
          </div> :
          <div style={{ width: "100%", display: "flex", gap: 8 }}>
            <button style={{
              width: 52, height: 48, borderRadius: 14, border: "none", cursor: "pointer",
              background: K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
            }}><CAIcon k="share" c={K.ink} s={17} /></button>
            <button onClick={() => setPosted(true)} style={{
              flex: 1, height: 48, borderRadius: 14, border: "none", cursor: "pointer",
              background: K.accent, color: "#fff", fontFamily: CA_FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.9
            }}>POST TO FEED</button>
          </div>}
      </div>
    </div>);
}

// ── single contest screen ──────────────────────────────
function ContestScreen({ contestId = "k1", onBack, autoVote, openShare = false }) {
  const K = CA_KE;
  const contest = window.CT.contestById(contestId);
  const ev = window.EV.eventById(contest.event_id);
  const cat = window.CT.catOf(contest);
  const [mine, setMine] = React.useState(contest.my_vote);
  const [sheet, setSheet] = React.useState(!!autoVote);
  const [share, setShare] = React.useState(openShare);
  const [toast, setToast] = React.useState(null);
  const { board, total, flash } = CABoard(contest, { myVote: mine });

  const live = contest.status === "live";
  const finished = contest.status === "finished";
  const winner = finished ? board[0] : null;
  const iWon = finished && winner.id === contest.my_entry;
  const badge = finished ? { ...window.CT.winnerBadge(contest), car: winner, votes: winner.votes, of: total } : null;

  const pick = (id) => {
    setMine(id);
    setSheet(false);
    setToast(id === mine ? "Vote unchanged" : `Vote counted for ${board.find((b) => b.id === id).brand}`);
    setTimeout(() => setToast(null), 2600);
  };

  return (
    <div style={{
      width: 390, height: 844, background: K.surface, position: "relative", overflow: "hidden",
      fontFamily: CA_FB, color: K.ink, display: "flex", flexDirection: "column"
    }}>
      {/* header */}
      <div style={{ background: finished ? K.ink : K.surface, padding: "52px 16px 16px", flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <button onClick={onBack} style={{
            width: 34, height: 34, borderRadius: 999, border: "none", cursor: "pointer",
            background: finished ? "rgba(255,255,255,0.12)" : K.bgSoft, display: "grid", placeItems: "center", flexShrink: 0
          }}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={finished ? "#fff" : K.ink} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" /></svg>
          </button>
          <span style={{
            flex: 1, minWidth: 0, fontFamily: CA_FB, fontSize: 12, color: finished ? "rgba(255,255,255,0.6)" : K.mute,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
          }}>{ev.title}</span>
          {live && <CAChip contest={contest} size="sm" />}
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 16 }}>
          <span style={{
            fontFamily: CA_FD, fontWeight: 700, fontSize: 22, letterSpacing: -0.5,
            color: finished ? "#fff" : K.ink, lineHeight: 1.15
          }}>{contest.title}</span>
        </div>
        <div style={{ display: "flex", gap: 18, marginTop: 14 }}>
          {[
            { v: window.EV.fmtCount(total), l: "VOTES CAST" },
            { v: board.length, l: "CARS IN" },
            { v: finished ? "CLOSED" : live ? window.CT.fmtLeft(contest.closes_at).toUpperCase() : window.CT.fmtOpensIn(contest.opens_at).toUpperCase(), l: finished ? "VOTING" : live ? "REMAINING" : "STATUS" }
          ].map((s, i) =>
            <div key={i}>
              <div style={{
                fontFamily: CA_FD, fontWeight: 700, fontSize: 15, letterSpacing: -0.2,
                color: finished ? "#fff" : i === 2 && live ? K.accent : K.ink
              }}>{s.v}</div>
              <div style={{
                fontFamily: CA_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1.1, marginTop: 2,
                color: finished ? "rgba(255,255,255,0.5)" : K.mute
              }}>{s.l}</div>
            </div>)}
        </div>
      </div>

      <div style={{ flex: 1, overflowY: "auto", overflowX: "hidden", padding: "18px 16px 26px", display: "flex", flexDirection: "column", gap: 20 }}>
        {/* winner reveal */}
        {finished &&
          <div>
            <div style={{
              background: K.bgSoft, borderRadius: 20, overflow: "hidden"
            }}>
              <div style={{ position: "relative", height: 176 }}>
                <img src={winner.photo} alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
                <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg,rgba(10,10,10,0) 40%,rgba(10,10,10,0.82) 100%)" }} />
                <div style={{ position: "absolute", top: 12, left: 12, display: "inline-flex", alignItems: "center", gap: 6, background: K.accent, borderRadius: 999, padding: "5px 11px" }}>
                  <CACat k="trophy" c="#fff" s={12} />
                  <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 9, letterSpacing: 1.3, color: "#fff" }}>WINNER</span>
                </div>
                <div style={{ position: "absolute", left: 14, right: 14, bottom: 12 }}>
                  <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 19, color: "#fff", letterSpacing: -0.4 }}>
                    {winner.brand} {winner.model}
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 7, marginTop: 5 }}>
                    <img src={winner.owner.avatar} alt="" style={{ width: 20, height: 20, borderRadius: 999 }} />
                    <span style={{ fontFamily: CA_FB, fontSize: 12, color: "rgba(255,255,255,0.85)" }}>
                      @{winner.owner.handle} · {winner.votes} of {total} votes
                    </span>
                  </div>
                </div>
              </div>
              <div style={{ padding: "13px 14px", display: "flex", alignItems: "center", gap: 12 }}>
                <CABadge badge={badge} size={44} rank={1} label={false} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 12.5, color: K.ink }}>
                    {cat.short.charAt(0) + cat.short.slice(1).toLowerCase()} badge awarded
                  </div>
                  <div style={{ fontFamily: CA_FB, fontSize: 11.5, color: K.mute, marginTop: 2 }}>
                    Now on the car and the owner's profile
                  </div>
                </div>
              </div>
            </div>
            {iWon &&
              <div style={{
                marginTop: 10, background: K.accentWash, borderRadius: 16, padding: "12px 14px",
                boxShadow: `inset 0 0 0 1.5px ${K.accent}`, display: "flex", alignItems: "center", gap: 11
              }}>
                <CACat k="bolt" c={K.accent} s={17} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>That's your car</div>
                  <div style={{ fontFamily: CA_FB, fontSize: 11.5, color: K.ink2, marginTop: 2 }}>Post the card to your feed</div>
                </div>
                <button onClick={() => setShare(true)} style={{
                  height: 34, padding: "0 13px", borderRadius: 10, border: "none", cursor: "pointer",
                  background: K.accent, color: "#fff", fontFamily: CA_FD, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.7
                }}>SHARE</button>
              </div>}
          </div>}

        {/* criteria */}
        <div>
          <CATitle>{finished ? "HOW IT WAS JUDGED" : "HOW IT WORKS"}</CATitle>
          <CABlock>
            <p style={{ margin: 0, fontFamily: CA_FB, fontSize: 13, color: K.ink2, lineHeight: 1.55, textWrap: "pretty" }}>
              {contest.criteria}
            </p>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 11 }}>
              <img src={ev.organizers[0].avatar} alt="" style={{ width: 22, height: 22, borderRadius: 999, objectFit: "cover" }} />
              <span style={{ fontFamily: CA_FB, fontSize: 11.5, color: K.mute }}>
                Set by @{ev.organizers[0].handle}
              </span>
            </div>
          </CABlock>
        </div>

        {/* board */}
        <div>
          <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", marginBottom: 12 }}>
            <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.5, color: K.mute }}>
              {finished ? "FINAL STANDINGS" : contest.status === "scheduled" ? "CARS ENTERED" : "LEADERBOARD"}
            </span>
            {live &&
              <span style={{ display: "inline-flex", alignItems: "center", gap: 5 }}>
                <window.LiveDot c={K.accent} />
                <span style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 9, letterSpacing: 1, color: K.accent }}>UPDATING LIVE</span>
              </span>}
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
            {board.map((row) =>
              <CARow key={row.id} row={row} total={total} top={!!total}
                mine={mine === row.id} flashing={flash === row.id}
                votable={live} onVote={pick} />)}
          </div>
          {contest.status === "scheduled" &&
            <p style={{ margin: "12px 0 0", fontFamily: CA_FB, fontSize: 12, color: K.muteSoft, textAlign: "center" }}>
              Voting opens at {window.EV.fmtTime(new Date(contest.opens_at))}
            </p>}
        </div>
      </div>

      {/* footer action */}
      {live &&
        <CABar>
          {mine ?
            <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
              <div style={{ flex: 1, minWidth: 0, display: "flex", alignItems: "center", gap: 9 }}>
                <img src={board.find((b) => b.id === mine).photo} alt="" style={{ width: 38, height: 38, borderRadius: 11, objectFit: "cover", flexShrink: 0 }} />
                <div style={{ minWidth: 0 }}>
                  <div style={{ fontFamily: CA_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1, color: K.accent }}>YOUR VOTE</div>
                  <div style={{
                    fontFamily: CA_FD, fontWeight: 700, fontSize: 13, color: K.ink, letterSpacing: -0.2,
                    whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
                  }}>{board.find((b) => b.id === mine).brand} {board.find((b) => b.id === mine).model}</div>
                </div>
              </div>
              <button onClick={() => setSheet(true)} style={{
                height: 44, padding: "0 16px", borderRadius: 13, border: "none", cursor: "pointer",
                background: K.bgSoft, color: K.ink, fontFamily: CA_FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.7, flexShrink: 0
              }}>CHANGE</button>
            </div> :
            <button onClick={() => setSheet(true)} style={{
              width: "100%", height: 52, borderRadius: 15, border: "none", cursor: "pointer",
              background: K.accent, color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
              fontFamily: CA_FD, fontWeight: 700, fontSize: 12.5, letterSpacing: 1
            }}>
              <CACat k="vote" c="#fff" s={15} />CAST YOUR VOTE
            </button>}
        </CABar>}

      {finished &&
        <CABar>
          <button onClick={() => setShare(true)} style={{
            width: "100%", height: 52, borderRadius: 15, border: "none", cursor: "pointer",
            background: iWon ? K.accent : K.bgSoft, color: iWon ? "#fff" : K.ink,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
            fontFamily: CA_FD, fontWeight: 700, fontSize: 12.5, letterSpacing: 1
          }}>
            <CAIcon k="share" c={iWon ? "#fff" : K.ink} s={15} />
            {iWon ? "SHARE YOUR WIN" : "SHARE THE RESULT"}
          </button>
        </CABar>}

      {toast &&
        <div style={{
          position: "absolute", left: 16, right: 16, bottom: 96, zIndex: 80,
          background: K.ink, borderRadius: 14, padding: "12px 14px", display: "flex", alignItems: "center", gap: 9,
          boxShadow: "0 12px 30px rgba(10,10,10,0.3)"
        }}>
          <CAIcon k="check" c={K.accent} s={15} />
          <span style={{ fontFamily: CA_FB, fontSize: 12.5, color: "#fff" }}>{toast}</span>
        </div>}

      <VoteSheet open={sheet} contest={contest} board={board} current={mine}
        onClose={() => setSheet(false)} onPick={pick} />
      {badge && <ShareWinSheet open={share} badge={badge} onClose={() => setShare(false)} />}
    </div>);
}

Object.assign(window, { ContestsTab, ContestScreen, VoteSheet, EnterContestsSheet, ShareWinSheet, CABlock });
