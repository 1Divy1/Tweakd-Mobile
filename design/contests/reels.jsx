// reels.jsx — Kinetic Edge
// Full-bleed vertical reels. Dark surface, Kinetic type + orange accent.
// Two overlay layouts: "rail" (classic right action stack) and "dock" (glass control bar).

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// Dark reels theme
const RE = {
  bg:    "#0A0A0A",
  text:  "#FFFFFF",
  soft:  "rgba(255,255,255,0.72)",
  dim:   "rgba(255,255,255,0.5)",
  glass: "rgba(22,22,24,0.55)",
  hair:  "rgba(255,255,255,0.16)",
};

const fmt = (n) => n >= 1e6 ? (n/1e6).toFixed(1).replace(/\.0$/,"")+"M"
               : n >= 1000 ? (n/1000).toFixed(1).replace(/\.0$/,"")+"k" : String(n);

// ─────────────────────────────────────────────────────────
// Reel data
// ─────────────────────────────────────────────────────────
const BASE_REELS = [
  {
    id: "r1",
    user: { username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true },
    img: "assets/car-2.png",
    caption: "Cold start, empty road, red leather. Some mornings you just let the straight-six do the talking.",
    specs: ["BMW M3", "S58 · 510hp", "Manual"],
    audio: "Midnight Pull — synthwave loop",
    likes: 18420, comments: 642, shares: 1290, liked: false, saved: false, following: false,
  },
  {
    id: "r2",
    user: { username: "torque_sasha", avatar: "assets/av-1.svg", verified: true },
    img: "assets/car-1.png",
    caption: "Golden hour by the marina. Wood rim, chrome, and not a single screen in sight.",
    specs: ["Classic Roadster", "Inline-6", "Restored"],
    audio: "Original audio — torque_sasha",
    likes: 9304, comments: 218, shares: 540, liked: true, saved: false, following: true,
  },
  {
    id: "r3",
    user: { username: "jdm_jules", avatar: "assets/av-2.svg", verified: true },
    img: "assets/car-4.png",
    caption: "112 cars rolled through the Sunday linkup. Best turnout all year — pan to the end for the flyby.",
    specs: ["Nissan Skyline", "RB26 · 600hp", "Built"],
    audio: "Tunnel Run — bass house",
    likes: 27110, comments: 980, shares: 3120, liked: false, saved: true, following: false,
  },
  {
    id: "r4",
    user: { username: "kenji_apex", avatar: "assets/av-4.svg", verified: true },
    img: "assets/car-3.png",
    caption: "Detailed top to bottom for the show next week. Paint depth is unreal in person.",
    specs: ["Audi RS6", "V8 TT", "Stage 2"],
    audio: "Slow Burn — lo-fi",
    likes: 6730, comments: 154, shares: 410, liked: false, saved: false, following: false,
  },
  {
    id: "r5",
    user: { username: "low_n_slow_leo", avatar: "assets/av-3.svg" },
    img: "assets/car-1.png",
    caption: "Night roll through the old town. Headlights on cobblestone hits different.",
    specs: ["Targa Build", "Flat-6", "Bagged"],
    audio: "After Hours — darkwave",
    likes: 12860, comments: 333, shares: 720, liked: false, saved: false, following: false,
  },
  {
    id: "r6",
    user: { username: "turbo_tess", avatar: "assets/av-7.svg", verified: true },
    img: "assets/car-3.png",
    caption: "Dyno day pulls. Numbers in the next post but trust me — it pulls clean to redline.",
    specs: ["Supra MK4", "2JZ · 720hp", "Single Turbo"],
    audio: "Boost Threshold — phonk",
    likes: 21540, comments: 870, shares: 2010, liked: false, saved: false, following: false,
  },
];

// ─────────────────────────────────────────────────────────
// Icons
// ─────────────────────────────────────────────────────────
const Ic = {
  heart: (c, fill) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill={fill||"none"}><path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  comment: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  share: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M22 3L11 14M22 3l-7 19-4-8-8-4 19-7z" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  save: (c, fill) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill={fill||"none"}><path d="M6 3h12a1 1 0 011 1v17l-7-4-7 4V4a1 1 0 011-1z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  more: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24"><circle cx="12" cy="5" r="1.8" fill={c}/><circle cx="12" cy="12" r="1.8" fill={c}/><circle cx="12" cy="19" r="1.8" fill={c}/></svg>,
  garage: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M3 10l9-6 9 6v10a1 1 0 01-1 1H4a1 1 0 01-1-1V10z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M7 21v-6h10v6M7 14h10" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  music: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M9 18V5l11-2v13" stroke={c} strokeWidth="2" strokeLinejoin="round"/><circle cx="6" cy="18" r="3" stroke={c} strokeWidth="2"/><circle cx="17" cy="16" r="3" stroke={c} strokeWidth="2"/></svg>,
  camera: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><rect x="2.5" y="6.5" width="19" height="13" rx="3" stroke={c} strokeWidth="2"/><circle cx="12" cy="13" r="3.5" stroke={c} strokeWidth="2"/><path d="M8 6.5l1.2-2.2h5.6L16 6.5" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  plus: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={c} strokeWidth="2.4" strokeLinecap="round"/></svg>,
  check: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke={c} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  play: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill={c}><path d="M8 5v14l11-7-11-7z"/></svg>,
  flag: (c) => <svg width="100%" height="100%" viewBox="0 0 24 24" fill="none"><path d="M5 21V4m0 0l9 1.5L20 4v11l-6 1.5L5 15" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
};

// ─────────────────────────────────────────────────────────
// Spec chips
// ─────────────────────────────────────────────────────────
function SpecChips({ specs, accent }) {
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
      {specs.map((s, i) => (
        <span key={i} style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.4,
          color: RE.text, padding: "5px 9px", borderRadius: 7,
          background: i === 0 ? accent : "rgba(255,255,255,0.14)",
          border: i === 0 ? "none" : `1px solid ${RE.hair}`,
          backdropFilter: "blur(6px)", WebkitBackdropFilter: "blur(6px)",
          whiteSpace: "nowrap",
        }}>{s.toUpperCase()}</span>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Caption with expand
// ─────────────────────────────────────────────────────────
function ReelCaption({ username, text }) {
  const [open, setOpen] = React.useState(false);
  const long = text.length > 72;
  return (
    <div style={{
      fontFamily: FONT_BODY, fontSize: 13, color: "rgba(255,255,255,0.92)", lineHeight: 1.5,
      textShadow: "0 1px 8px rgba(0,0,0,0.5)",
      ...(open ? {} : { display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden" }),
    }}>
      {text}
      {long && !open && (
        <span onClick={(e) => { e.stopPropagation(); setOpen(true); }} style={{ color: RE.dim, fontWeight: 600, cursor: "pointer" }}> more</span>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Audio marquee
// ─────────────────────────────────────────────────────────
function AudioRow({ audio, accent }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, maxWidth: "100%" }}>
      <span style={{ width: 14, height: 14, flexShrink: 0, color: RE.text }}>{Ic.music(RE.text)}</span>
      <div style={{ overflow: "hidden", flex: 1, maskImage: "linear-gradient(90deg,#000 80%,transparent)", WebkitMaskImage: "linear-gradient(90deg,#000 80%,transparent)" }}>
        <div style={{
          fontFamily: FONT_BODY, fontSize: 11.5, fontWeight: 600, color: RE.soft, whiteSpace: "nowrap",
          display: "inline-block", animation: "ke-marquee 11s linear infinite",
        }}>{audio}&nbsp;&nbsp;•&nbsp;&nbsp;{audio}&nbsp;&nbsp;•&nbsp;&nbsp;</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Follow-aware avatar
// ─────────────────────────────────────────────────────────
function ReelAvatar({ src, following, accent, onToggle, size = 46 }) {
  const [fol, setFol] = React.useState(following);
  return (
    <div style={{ position: "relative", width: size, height: size, flexShrink: 0 }}>
      <div style={{ width: size, height: size, borderRadius: 999, padding: 2, background: "#fff" }}>
        <img src={src} alt="" style={{ width: "100%", height: "100%", borderRadius: 999, objectFit: "cover", display: "block", background: KE.line2 }}/>
      </div>
      {!fol && (
        <button onClick={(e) => { e.stopPropagation(); setFol(true); onToggle && onToggle(); }} style={{
          position: "absolute", bottom: -8, left: "50%", transform: "translateX(-50%)",
          width: 20, height: 20, borderRadius: 999, border: "2px solid #0A0A0A", background: accent,
          display: "grid", placeItems: "center", cursor: "pointer", padding: 0,
        }}>
          <span style={{ width: 12, height: 12, color: "#fff" }}>{Ic.plus("#fff")}</span>
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Rail action button (variation A)
// ─────────────────────────────────────────────────────────
function RailBtn({ icon, label, onClick, size }) {
  return (
    <button onClick={(e) => { e.stopPropagation(); onClick && onClick(); }} style={{
      border: "none", background: "transparent", cursor: "pointer", padding: 0,
      display: "flex", flexDirection: "column", alignItems: "center", gap: 5,
    }}>
      <span style={{ width: size, height: size, display: "block", filter: "drop-shadow(0 2px 5px rgba(0,0,0,0.45))" }}>{icon}</span>
      {label !== undefined && (
        <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, color: RE.text, textShadow: "0 1px 4px rgba(0,0,0,0.5)" }}>{label}</span>
      )}
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// Reel media — Ken Burns when active, double-tap like, tap pause
// ─────────────────────────────────────────────────────────
function ReelMedia({ img, active, liked, onDoubleLike, radius, overlay }) {
  const [paused, setPaused] = React.useState(false);
  const [burst, setBurst]   = React.useState(0);
  const tapRef = React.useRef(0);

  const onTap = () => {
    const now = Date.now();
    if (now - tapRef.current < 280) {        // double tap
      if (!liked) onDoubleLike();
      setBurst(b => b + 1);
      tapRef.current = 0;
    } else {
      tapRef.current = now;
      setTimeout(() => { if (tapRef.current && Date.now() - tapRef.current >= 280) setPaused(p => !p); }, 290);
    }
  };

  return (
    <div onClick={onTap} style={{
      position: "absolute", inset: 0, borderRadius: radius, overflow: "hidden",
      background: "#000", cursor: "pointer",
    }}>
      <img src={img} alt="" draggable={false} style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        userSelect: "none",
        animation: active && !paused ? "ke-kenburns 14s ease-in-out infinite alternate" : "none",
        transformOrigin: "60% 40%",
      }}/>
      {/* top + bottom scrims */}
      <div style={{ position: "absolute", inset: 0, pointerEvents: "none", background:
        `linear-gradient(180deg, rgba(0,0,0,${0.32*overlay}) 0%, rgba(0,0,0,0) 22%, rgba(0,0,0,0) 50%, rgba(0,0,0,${0.78*overlay}) 100%)` }}/>
      {/* pause glyph */}
      {paused && active && (
        <div style={{ position: "absolute", inset: 0, display: "grid", placeItems: "center", pointerEvents: "none" }}>
          <div style={{ width: 64, height: 64, borderRadius: 999, background: "rgba(0,0,0,0.4)", backdropFilter: "blur(8px)", display: "grid", placeItems: "center" }}>
            <span style={{ width: 30, height: 30, marginLeft: 3, color: "#fff", opacity: 0.92 }}>{Ic.play("#fff")}</span>
          </div>
        </div>
      )}
      {/* double-tap heart burst */}
      {burst > 0 && (
        <div key={burst} style={{ position: "absolute", inset: 0, display: "grid", placeItems: "center", pointerEvents: "none" }}>
          <span style={{ width: 110, height: 110, color: KE.accent, animation: "ke-burst 800ms ease-out forwards", filter: "drop-shadow(0 6px 20px rgba(0,0,0,0.4))" }}>{Ic.heart(KE.accent, KE.accent)}</span>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// One reel
// ─────────────────────────────────────────────────────────
function Reel({ data, active, layout, cfg, onOpenComments }) {
  const [liked, setLiked]   = React.useState(data.liked);
  const [likes, setLikes]   = React.useState(data.likes);
  const [saved, setSaved]   = React.useState(data.saved);
  const [garaged, setGaraged] = React.useState(false);
  const [menuOpen, setMenuOpen] = React.useState(false);
  const [reported, setReported] = React.useState(false);
  const [toast, setToast] = React.useState(null);
  const accent = cfg.accent;
  const size = cfg.railIcon;

  const flashToast = (msg) => { setToast(msg); clearTimeout(flashToast._t); flashToast._t = setTimeout(() => setToast(null), 1900); };
  const onSaveFromMenu = () => { setSaved(s => { flashToast(s ? "Removed from saved" : "Saved to your reels"); return !s; }); setMenuOpen(false); };
  const onReport = () => { setReported(true); flashToast("Report sent — thanks for flagging"); setMenuOpen(false); };

  const toggleLike = () => setLiked(l => { setLikes(n => n + (l ? -1 : 1)); return !l; });
  const forceLike  = () => { if (!liked) { setLiked(true); setLikes(n => n + 1); } };
  const railSize = layout === "rail" ? size : size - 3;

  return (
    <div style={{
      position: "relative", width: "100%", height: "100%", flexShrink: 0,
      scrollSnapAlign: "start", scrollSnapStop: "always",
      padding: cfg.radius > 0 ? 8 : 0, boxSizing: "border-box", background: RE.bg,
    }}>
      <ReelMedia img={data.img} active={active} liked={liked} onDoubleLike={forceLike}
                 radius={cfg.radius} overlay={cfg.overlay}/>

      {/* progress bar — sits just above the nav bar */}
      <div style={{ position: "absolute", left: cfg.radius>0?20:12, right: cfg.radius>0?20:12, bottom: 82, height: 3, borderRadius: 3, background: "rgba(255,255,255,0.22)", overflow: "hidden", zIndex: 4 }}>
        <div key={active ? data.id + "-on" : data.id} style={{
          height: "100%", borderRadius: 3, background: accent,
          width: active ? "100%" : "0%",
          animation: active ? "ke-progress 14s linear infinite" : "none",
        }}/>
      </div>

      {/* ── Variation A: classic right rail ── */}
      {layout === "rail" && (
        <React.Fragment>
          <div style={{ position: "absolute", right: cfg.radius>0?20:12, bottom: 98, display: "flex", flexDirection: "column", alignItems: "center", gap: 20, zIndex: 5 }}>
            <ReelAvatar src={data.user.avatar} following={data.following} accent={accent} size={46}/>
            <RailBtn size={railSize} onClick={toggleLike} label={fmt(likes)} icon={Ic.heart(liked ? accent : "#fff", liked ? accent : null)}/>
            <RailBtn size={railSize} onClick={() => onOpenComments(data)} label={fmt(data.comments)} icon={Ic.comment("#fff")}/>
            <RailBtn size={railSize} onClick={() => {}} label={fmt(data.shares)} icon={Ic.share("#fff")}/>
            <RailBtn size={railSize} onClick={() => setMenuOpen(true)} icon={Ic.more("#fff")}/>
          </div>

          <div style={{ position: "absolute", left: cfg.radius>0?20:14, right: 78, bottom: 98, display: "flex", flexDirection: "column", gap: 9, zIndex: 5 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: RE.text, textShadow: "0 1px 6px rgba(0,0,0,0.5)" }}>@{data.user.username}</span>
              {data.user.verified && <span style={{ width: 14, height: 14, borderRadius: 999, background: accent, display: "inline-grid", placeItems: "center" }}><span style={{ width: 9, height: 9 }}>{Ic.check("#fff")}</span></span>}
            </div>
            <ReelCaption username={data.user.username} text={data.caption}/>
            <SpecChips specs={data.specs} accent={accent}/>
            <GarageBtn garaged={garaged} accent={accent} onClick={() => setGaraged(g => !g)}/>
            <AudioRow audio={data.audio} accent={accent}/>
          </div>
        </React.Fragment>
      )}

      {/* ── Variation B: docked glass control bar ── */}
      {layout === "dock" && (
        <div style={{ position: "absolute", left: cfg.radius>0?20:12, right: cfg.radius>0?20:12, bottom: 94, display: "flex", flexDirection: "column", gap: 12, zIndex: 5 }}>
          {/* meta card */}
          <div style={{ display: "flex", flexDirection: "column", gap: 9 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <ReelAvatar src={data.user.avatar} following={data.following} accent={accent} size={40}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                  <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14.5, color: RE.text, textShadow: "0 1px 6px rgba(0,0,0,0.5)" }}>@{data.user.username}</span>
                  {data.user.verified && <span style={{ width: 13, height: 13, borderRadius: 999, background: accent, display: "inline-grid", placeItems: "center" }}><span style={{ width: 8, height: 8 }}>{Ic.check("#fff")}</span></span>}
                </div>
                <div style={{ marginTop: 3 }}><AudioRow audio={data.audio} accent={accent}/></div>
              </div>
              <GarageBtn garaged={garaged} accent={accent} onClick={() => setGaraged(g => !g)} compact/>
            </div>
            <ReelCaption username={data.user.username} text={data.caption}/>
            <SpecChips specs={data.specs} accent={accent}/>
          </div>

          {/* glass dock */}
          <div style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "0 6px", height: 56, borderRadius: 18, position: "relative", overflow: "hidden",
          }}>
            <div style={{ position: "absolute", inset: 0, background: RE.glass, backdropFilter: "blur(16px) saturate(160%)", WebkitBackdropFilter: "blur(16px) saturate(160%)", border: `1px solid ${RE.hair}`, borderRadius: 18 }}/>
            <DockBtn size={railSize} onClick={toggleLike} label={fmt(likes)} icon={Ic.heart(liked ? accent : "#fff", liked ? accent : null)}/>
            <DockBtn size={railSize} onClick={() => onOpenComments(data)} label={fmt(data.comments)} icon={Ic.comment("#fff")}/>
            <DockBtn size={railSize} onClick={() => {}} label={fmt(data.shares)} icon={Ic.share("#fff")}/>
            <DockBtn size={railSize} onClick={() => setMenuOpen(true)} label="More" icon={Ic.more("#fff")}/>
          </div>
        </div>
      )}

      <MoreMenu open={menuOpen} onClose={() => setMenuOpen(false)} accent={accent}
                saved={saved} reported={reported} onSave={onSaveFromMenu} onReport={onReport}/>
      {toast && (
        <div style={{
          position: "absolute", left: "50%", bottom: 116, transform: "translateX(-50%)", zIndex: 30,
          background: "rgba(20,20,22,0.9)", color: "#fff", fontFamily: FONT_DISPLAY, fontWeight: 700,
          fontSize: 12, letterSpacing: 0.2, padding: "10px 16px", borderRadius: 999,
          border: `1px solid ${RE.hair}`, backdropFilter: "blur(10px)", WebkitBackdropFilter: "blur(10px)",
          whiteSpace: "nowrap", boxShadow: "0 8px 24px rgba(0,0,0,0.4)", animation: "ke-fade 200ms ease",
          display: "flex", alignItems: "center", gap: 7,
        }}>
          <span style={{ width: 14, height: 14, color: accent }}>{Ic.check(accent)}</span>{toast}
        </div>
      )}
    </div>
  );
}

function GarageBtn({ garaged, accent, onClick, compact }) {
  return (
    <button onClick={(e) => { e.stopPropagation(); onClick(); }} style={{
      display: "inline-flex", alignItems: "center", gap: 7, alignSelf: "flex-start",
      height: compact ? 34 : 36, padding: compact ? "0 12px" : "0 14px", borderRadius: 999, cursor: "pointer",
      background: garaged ? accent : "rgba(255,255,255,0.14)",
      border: garaged ? "none" : `1px solid ${RE.hair}`,
      backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)",
      color: RE.text, fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.4,
    }}>
      <span style={{ width: 16, height: 16 }}>{garaged ? Ic.check("#fff") : Ic.garage("#fff")}</span>
      {!compact && (garaged ? "In your garage" : "Add to garage")}
    </button>
  );
}

function DockBtn({ icon, label, onClick, size }) {
  return (
    <button onClick={(e) => { e.stopPropagation(); onClick && onClick(); }} style={{
      position: "relative", zIndex: 1, flex: 1, border: "none", background: "transparent", cursor: "pointer",
      display: "flex", flexDirection: "column", alignItems: "center", gap: 3, padding: 0,
    }}>
      <span style={{ width: size, height: size, display: "block" }}>{icon}</span>
      {label !== undefined && <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9.5, color: RE.soft }}>{label}</span>}
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// More menu — action sheet (Save · Report)
// ─────────────────────────────────────────────────────────
function MoreMenu({ open, onClose, accent, saved, reported, onSave, onReport }) {
  if (!open) return null;
  const Row = ({ icon, title, sub, danger, active, onClick }) => (
    <button onClick={(e) => { e.stopPropagation(); onClick(); }} style={{
      display: "flex", alignItems: "center", gap: 14, width: "100%", textAlign: "left",
      border: "none", background: "transparent", cursor: "pointer", padding: "14px 18px",
      borderRadius: 14,
    }}>
      <span style={{
        width: 40, height: 40, borderRadius: 12, flexShrink: 0, display: "grid", placeItems: "center",
        background: danger ? "rgba(224,36,94,0.1)" : (active ? accent : KE.bgSoft),
        border: `1px solid ${danger ? "rgba(224,36,94,0.2)" : KE.line}`,
      }}>
        <span style={{ width: 20, height: 20 }}>{icon(danger ? "#E0245E" : (active ? "#fff" : KE.ink))}</span>
      </span>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: "block", fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14.5, color: danger ? "#E0245E" : KE.ink }}>{title}</span>
        <span style={{ display: "block", fontFamily: FONT_BODY, fontSize: 12, color: KE.mute, marginTop: 1 }}>{sub}</span>
      </span>
    </button>
  );
  return (
    <div onClick={onClose} style={{ position: "absolute", inset: 0, zIndex: 45, display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
      <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.45)", animation: "ke-fade 200ms ease" }}/>
      <div onClick={(e) => e.stopPropagation()} style={{
        position: "relative", margin: 10, marginBottom: 18, background: KE.surface, borderRadius: 22,
        padding: 8, animation: "ke-sheet 260ms cubic-bezier(.22,1,.36,1)", boxShadow: "0 -8px 40px rgba(0,0,0,0.3)",
      }}>
        <Row icon={Ic.save} title={saved ? "Saved" : "Save"} active={saved}
             sub={saved ? "In your saved reels" : "Add this reel to your saved list"} onClick={onSave}/>
        <div style={{ height: 1, background: KE.line, margin: "2px 18px" }}/>
        <Row icon={Ic.flag} title={reported ? "Reported" : "Report"} danger
             sub={reported ? "Thanks — our team will review it" : "Flag this reel as inappropriate"} onClick={onReport}/>
        <button onClick={onClose} style={{
          width: "100%", marginTop: 4, padding: "13px", border: "none", background: KE.bgSoft, cursor: "pointer",
          borderRadius: 14, fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, color: KE.ink2,
        }}>Cancel</button>
      </div>
    </div>
  );
}

function ReelTopBar({ accent }) {
  const [tab, setTab] = React.useState("forYou");
  const T = (k, label) => (
    <button onClick={() => setTab(k)} style={{
      border: "none", background: "transparent", cursor: "pointer", padding: "4px 2px",
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, whiteSpace: "nowrap",
      color: tab === k ? RE.text : RE.dim, position: "relative",
      textShadow: "0 1px 6px rgba(0,0,0,0.5)",
    }}>
      {label}
      {tab === k && <div style={{ position: "absolute", left: "50%", transform: "translateX(-50%)", bottom: -6, width: 18, height: 2.5, borderRadius: 3, background: accent }}/>}
    </button>
  );
  return (
    <div style={{
      position: "absolute", top: 0, left: 0, right: 0, zIndex: 10,
      paddingTop: 58, display: "flex", alignItems: "center", justifyContent: "space-between", padding: "58px 18px 0",
    }}>
      <div style={{ display: "flex", gap: 18 }}>
        {T("following", "Following")}
        {T("forYou", "For You")}
      </div>
      <button style={{ border: "none", background: "transparent", cursor: "pointer", width: 24, height: 24, padding: 0, filter: "drop-shadow(0 1px 5px rgba(0,0,0,0.5))" }}>
        {Ic.camera("#fff")}
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Comment sheet (light, matches app)
// ─────────────────────────────────────────────────────────
const SAMPLE_COMMENTS = [
  { user: "jdm_jules",    avatar: "assets/av-2.svg", text: "That spec sheet is filthy 🔥", time: "12m", likes: 42 },
  { user: "noctis_nico",  avatar: "assets/av-6.svg", text: "The pan at the end though — clean.", time: "28m", likes: 18 },
  { user: "rae_lindqvist",avatar: "assets/av-5.svg", text: "Need a walkaround of that interior", time: "44m", likes: 9 },
  { user: "carla_boost",  avatar: "assets/av-5.svg", text: "Saved straight to my garage list", time: "1h", likes: 6 },
  { user: "low_n_slow_leo",avatar:"assets/av-3.svg", text: "Sound on = instant follow", time: "1h", likes: 3 },
];

function CommentSheet({ data, onClose, accent }) {
  if (!data) return null;
  return (
    <div onClick={onClose} style={{ position: "absolute", inset: 0, zIndex: 40, display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
      <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.45)", animation: "ke-fade 220ms ease" }}/>
      <div onClick={(e) => e.stopPropagation()} style={{
        position: "relative", background: KE.surface, borderRadius: "22px 22px 0 0",
        height: "66%", display: "flex", flexDirection: "column", animation: "ke-sheet 280ms cubic-bezier(.22,1,.36,1)",
        boxShadow: "0 -10px 40px rgba(0,0,0,0.3)",
      }}>
        <div style={{ display: "grid", placeItems: "center", paddingTop: 10 }}>
          <div style={{ width: 38, height: 4, borderRadius: 99, background: KE.line }}/>
        </div>
        <div style={{ padding: "12px 18px 10px", borderBottom: `1px solid ${KE.line}`, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, color: KE.ink, whiteSpace: "nowrap" }}>{fmt(data.comments)} comments</span>
          <button onClick={onClose} style={{ border: "none", background: "transparent", cursor: "pointer", padding: 4 }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/></svg>
          </button>
        </div>
        <div style={{ flex: 1, overflowY: "auto", padding: "14px 18px", display: "flex", flexDirection: "column", gap: 16 }}>
          {SAMPLE_COMMENTS.map((c, i) => (
            <div key={i} style={{ display: "flex", gap: 11, alignItems: "flex-start" }}>
              <img src={c.avatar} alt="" style={{ width: 34, height: 34, borderRadius: 999, objectFit: "cover", background: KE.line2, flexShrink: 0 }}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: FONT_BODY, fontSize: 13.5, color: KE.ink2, lineHeight: 1.45 }}>
                  <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, color: KE.ink, fontSize: 13 }}>@{c.user}</span>{" "}{c.text}
                </div>
                <div style={{ display: "flex", gap: 14, marginTop: 5, fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.4, color: KE.mute }}>
                  <span>{c.time}</span><span>Reply</span>
                </div>
              </div>
              <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 3, flexShrink: 0 }}>
                <span style={{ width: 15, height: 15 }}>{Ic.heart(KE.muteSoft)}</span>
                <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, color: KE.mute }}>{c.likes}</span>
              </div>
            </div>
          ))}
        </div>
        <div style={{ padding: "12px 16px", borderTop: `1px solid ${KE.line}`, display: "flex", alignItems: "center", gap: 10 }}>
          <img src="assets/avatar.jpg" alt="" style={{ width: 32, height: 32, borderRadius: 999, objectFit: "cover", flexShrink: 0 }}/>
          <div style={{ flex: 1, height: 40, borderRadius: 999, background: KE.bgSoft, border: `1px solid ${KE.line}`, display: "flex", alignItems: "center", padding: "0 14px", fontFamily: FONT_BODY, fontSize: 13, color: KE.mute }}>Add a comment…</div>
          <button style={{ border: "none", background: "transparent", cursor: "pointer", padding: 4, fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12, letterSpacing: 0.4, color: accent }}>Post</button>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Dark tab bar — 5 tabs, Reels active (center)
// ─────────────────────────────────────────────────────────
function ReelTabBar({ accent }) {
  const tabs = [
    { k: "FEED",     href: "Feed Page.html",     icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/></svg> },
    { k: "MAP",      href: "Map Page.html",      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "REELS",    href: null,                 center: true, icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
    { k: "CONTESTS", href: null,                 icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { k: "PROFILE",  href: "Profile Page.html",  icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      position: "absolute", left: 0, right: 0, bottom: 0, zIndex: 20,
      height: 76, paddingBottom: 20, flexShrink: 0,
      background: "linear-gradient(180deg, rgba(10,10,10,0) 0%, rgba(10,10,10,0.78) 38%, #0A0A0A 100%)",
      display: "flex", justifyContent: "space-around", alignItems: "center",
    }}>
      {tabs.map(t => {
        const on = t.k === "REELS";
        const color = on ? accent : "rgba(255,255,255,0.55)";
        const inner = (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, color }}>
            {t.icon}
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1 }}>{t.k}</span>
            {on && <div style={{ width: 16, height: 2, borderRadius: 2, background: accent, marginTop: 2 }}/>}
          </div>
        );
        return t.href
          ? <a key={t.k} href={t.href} style={{ textDecoration: "none" }}>{inner}</a>
          : <div key={t.k} style={{ cursor: "pointer" }}>{inner}</div>;
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
const REEL_CFG = { overlay: 1, accent: KE.accent, railIcon: 30, radius: 0 };

function ReelsScreen({ layout = "rail", cfg = REEL_CFG }) {
  const C = { ...REEL_CFG, ...cfg };
  const scrollRef = React.useRef(null);
  const [items, setItems]   = React.useState(() => BASE_REELS.map((r, i) => ({ ...r, key: r.id + "-0-" + i })));
  const [activeKey, setActiveKey] = React.useState(items[0].key);
  const [comments, setComments]   = React.useState(null);

  // active reel detection
  React.useEffect(() => {
    const root = scrollRef.current;
    if (!root) return;
    const io = new IntersectionObserver((entries) => {
      entries.forEach(e => { if (e.isIntersecting && e.intersectionRatio >= 0.6) setActiveKey(e.target.dataset.key); });
    }, { root, threshold: [0.6] });
    root.querySelectorAll("[data-reel]").forEach(el => io.observe(el));
    return () => io.disconnect();
  }, [items.length]);

  // infinite append
  const onScroll = (e) => {
    const el = e.currentTarget;
    if (el.scrollTop + el.clientHeight > el.scrollHeight - el.clientHeight * 1.5) {
      setItems(prev => {
        const round = Math.floor(prev.length / BASE_REELS.length);
        return [...prev, ...BASE_REELS.map((r, i) => ({ ...r, key: r.id + "-" + round + "-" + i }))];
      });
    }
  };

  return (
    <div style={{ width: 390, height: 844, background: RE.bg, position: "relative", overflow: "hidden", fontFamily: FONT_BODY }}>
      <ReelTopBar accent={C.accent}/>

      <div ref={scrollRef} onScroll={onScroll} style={{
        position: "absolute", inset: 0, overflowY: "auto",
        scrollSnapType: "y mandatory", WebkitOverflowScrolling: "touch",
      }}>
        {items.map(it => (
          <div key={it.key} data-reel data-key={it.key} style={{ height: 844, width: "100%" }}>
            <Reel data={it} active={it.key === activeKey} layout={layout} cfg={C} onOpenComments={setComments}/>
          </div>
        ))}
      </div>

      <ReelTabBar accent={C.accent}/>
      <CommentSheet data={comments} onClose={() => setComments(null)} accent={C.accent}/>
    </div>
  );
}

window.ReelsScreen = ReelsScreen;
