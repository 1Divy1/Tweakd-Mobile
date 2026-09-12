// contest-extras.jsx — Kinetic Edge
// Where a win lands afterwards: badges on the car profile, a trophy row on the
// owner's profile, and the winner card as it appears posted in the feed.

const CX_KE = window.KE;
const CX_FD = window.KE_FONT_DISPLAY;
const CX_FB = window.KE_FONT_BODY;
const { EvIcon: CXIcon, CatIcon: CXCat, ContestBadge: CXBadge, WinnerCard: CXWinner, CSectionTitle: CXTitle } = window;

// badges the M4 has won (finished contests where it placed)
function myBadges() {
  const paint = window.CT.contestById("k4");
  const b1 = window.CT.winnerBadge(paint);
  return [
  { badge: b1, rank: 1 },
  { badge: { ...b1, short: "WHEELS", icon: "wheels", title: "Best wheels", event: "Ace Café Late Linkup", votes: 44, of: 132 }, rank: 2 },
  { badge: { ...b1, short: "EXHAUST", icon: "exhaust", title: "Best exhaust system", event: "Hillclimb Breakfast Meet", votes: 31, of: 118 }, rank: 3 }];

}

// ── car profile: contest badges section ────────────────
function CarProfileBadges({ width = 390 }) {
  const K = CX_KE;
  const items = myBadges();
  return (
    <div style={{ width, background: K.surface, minHeight: 844, fontFamily: CX_FB, color: K.ink, overflow: "hidden" }}>
      <div style={{ position: "relative", height: 210 }}>
        <img src="assets/car-1.png" alt="" style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg,rgba(10,10,10,0.4) 0%,rgba(10,10,10,0) 45%,rgba(10,10,10,0.8) 100%)" }} />
        <div style={{ position: "absolute", left: 18, right: 18, bottom: 16 }}>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 6, background: K.accent, borderRadius: 999, padding: "4px 10px" }}>
            <CXCat k="trophy" c="#fff" s={11} />
            <span style={{ fontFamily: CX_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 1.2, color: "#fff" }}>3 CONTEST BADGES</span>
          </div>
          <div style={{ fontFamily: CX_FD, fontWeight: 700, fontSize: 23, color: "#fff", letterSpacing: -0.5, marginTop: 9 }}>
            BMW M4 Competition
          </div>
          <div style={{ fontFamily: CX_FB, fontSize: 12.5, color: "rgba(255,255,255,0.8)", marginTop: 4 }}>
            2023 · @torque_sasha
          </div>
        </div>
      </div>

      <div style={{ padding: "20px 16px 34px", display: "flex", flexDirection: "column", gap: 22 }}>
        <div>
          <CXTitle action="SEE ALL">CONTEST BADGES</CXTitle>
          <div style={{ background: K.bgSoft, borderRadius: 18, padding: "16px 14px" }}>
            <div style={{ display: "flex", gap: 10, justifyContent: "space-around" }}>
              {items.map((it, i) => <CXBadge key={i} badge={it.badge} rank={it.rank} size={58} />)}
            </div>
          </div>
        </div>

        <div>
          <CXTitle>WHERE THEY CAME FROM</CXTitle>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {items.map((it, i) =>
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 11, background: K.bgSoft, borderRadius: 14, padding: "11px 12px" }}>
                <span style={{
                width: 32, height: 32, borderRadius: 10, flexShrink: 0, display: "grid", placeItems: "center",
                background: it.rank === 1 ? K.accent : K.surface
              }}><CXCat k={it.badge.icon} c={it.rank === 1 ? "#fff" : K.mute} s={15} /></span>
                <span style={{ flex: 1, minWidth: 0 }}>
                  <span style={{ display: "block", fontFamily: CX_FD, fontWeight: 700, fontSize: 13, color: K.ink, letterSpacing: -0.15 }}>
                    {it.badge.title}
                  </span>
                  <span style={{
                  display: "block", fontFamily: CX_FB, fontSize: 11.5, color: K.mute, marginTop: 2,
                  whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis"
                }}>{it.badge.event}</span>
                </span>
                <span style={{ textAlign: "right", flexShrink: 0 }}>
                  <span style={{ display: "block", fontFamily: CX_FD, fontWeight: 700, fontSize: 12.5, color: it.rank === 1 ? K.accent : K.ink }}>
                    {it.rank === 1 ? "1st" : it.rank === 2 ? "2nd" : "3rd"}
                  </span>
                  <span style={{ display: "block", fontFamily: CX_FD, fontWeight: 700, fontSize: 8.5, letterSpacing: 0.8, color: K.mute, marginTop: 2 }}>
                    {it.badge.votes}/{it.badge.of}
                  </span>
                </span>
              </div>)}
          </div>
        </div>

        <div>
          <CXTitle>ON THE OWNER'S PROFILE</CXTitle>
          <div style={{ display: "flex", alignItems: "center", gap: 12, background: K.bgSoft, borderRadius: 18, padding: 14 }}>
            <img src="assets/av-1.svg" alt="" style={{ width: 44, height: 44, borderRadius: 999, objectFit: "cover", background: K.line2 }} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: CX_FD, fontWeight: 700, fontSize: 13.5, color: K.ink }}>Sasha Petrov</div>
              <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 5 }}>
                {items.map((it, i) =>
                <span key={i} style={{
                  width: 22, height: 22, borderRadius: 7, display: "grid", placeItems: "center",
                  background: it.rank === 1 ? CX_KE.accent : CX_KE.ink
                }}><CXCat k={it.badge.icon} c="#fff" s={11} /></span>)}
                <span style={{ fontFamily: CX_FB, fontSize: 11.5, color: K.mute, marginLeft: 3 }}>3 wins this season</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>);
}

// ── the card as posted in the feed ─────────────────────
function FeedWinPost({ width = 390 }) {
  const K = CX_KE;
  const badge = window.CT.winnerBadge(window.CT.contestById("k4"));
  return (
    <div style={{ width, background: K.bg, minHeight: 600, padding: "22px 16px", fontFamily: CX_FB, display: "flex", flexDirection: "column", gap: 14 }}>
      <div style={{ background: K.surface, borderRadius: 20, padding: 14, boxShadow: "0 2px 14px rgba(10,10,10,0.07)", display: "flex", flexDirection: "column", gap: 12 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <img src="assets/av-1.svg" alt="" style={{ width: 34, height: 34, borderRadius: 999, background: K.line2 }} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: CX_FD, fontWeight: 700, fontSize: 13, color: K.ink }}>@torque_sasha</div>
            <div style={{ fontFamily: CX_FB, fontSize: 11.5, color: K.mute, marginTop: 2 }}>Won a contest · 12m ago</div>
          </div>
          <CXIcon k="chev" c={K.muteSoft} s={14} />
        </div>
        <p style={{ margin: 0, fontFamily: CX_FB, fontSize: 13.5, color: K.ink2, lineHeight: 1.55 }}>
          Two years of wet sanding paid off. Thanks to everyone on the terrace who voted.
        </p>
        <CXWinner badge={badge} width={width - 60} />
        <div style={{ display: "flex", alignItems: "center", gap: 16, paddingTop: 2 }}>
          {[{ i: "heart", v: "184" }, { i: "comment", v: "26" }].map((a, i) =>
          <span key={i} style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
              <CXIcon k={a.i} c={K.mute} s={17} />
              <span style={{ fontFamily: CX_FD, fontWeight: 700, fontSize: 11.5, color: K.ink2 }}>{a.v}</span>
            </span>)}
          <span style={{ display: "inline-flex", marginLeft: "auto" }}><CXIcon k="save" c={K.mute} s={17} /></span>
        </div>
      </div>
    </div>);
}

Object.assign(window, { CarProfileBadges, FeedWinPost, myBadges });