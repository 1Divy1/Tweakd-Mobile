// feed.jsx — Kinetic Edge
// Vertical post feed. Peek carousel, caption + like/comment, native (subtle) ads.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Feed data — posts + native ads interleaved
// ─────────────────────────────────────────────────────────
const FEED = [
  {
    type: "post", id: "p1",
    user: { username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true },
    location: "Col de Turini", time: "2h",
    images: ["assets/car-2.png", "assets/car-3.png", "assets/car-1.png"],
    caption: "Dawn run up the mountain before the crowds. The straight-six soundtrack on these switchbacks never gets old.",
    likes: 1284, liked: false,
    comments: [
      { user: "jdm_jules",   avatar: "assets/av-2.svg", text: "That red interior is unreal 🔥", time: "1h", likes: 12 },
      { user: "kenji_apex",  avatar: "assets/av-4.svg", text: "Need to join next time", time: "48m", likes: 4 },
      { user: "turbo_tess",  avatar: "assets/av-7.svg", text: "Soundtrack > everything", time: "30m", likes: 2 },
    ],
    commentCount: 96,
  },
  {
    type: "ad", id: "a1",
    user: { username: "apex_detailing", avatar: "assets/av-1.svg", verified: true },
    sponsored: "Sponsored",
    images: ["assets/car-3.png", "assets/car-4.png"],
    caption: "Bring back the showroom shine. Ceramic coating & paint correction booked in 15 minutes.",
    cta: "Book a slot",
    likes: 342, liked: false,
    commentCount: 18,
  },
  {
    type: "post", id: "p2",
    user: { username: "torque_sasha", avatar: "assets/av-1.svg", verified: true },
    location: "Port Hercule", time: "5h",
    images: ["assets/car-1.png"],
    caption: "Golden hour by the marina. Some evenings just write themselves.",
    likes: 873, liked: true,
    comments: [
      { user: "noctis_nico", avatar: "assets/av-6.svg", text: "Framing on this is perfect", time: "3h", likes: 9 },
      { user: "rae_lindqvist", avatar: "assets/av-5.svg", text: "📸📸📸", time: "2h", likes: 1 },
    ],
    commentCount: 41,
  },
  {
    type: "post", id: "p3",
    user: { username: "jdm_jules", avatar: "assets/av-2.svg", verified: true },
    location: "Sunday JDM Linkup", time: "8h",
    images: ["assets/car-4.png", "assets/car-2.png", "assets/car-1.png", "assets/car-3.png"],
    caption: "Best turnout we've had all year. 112 cars rolled through — thank you to everyone who came out.",
    likes: 2106, liked: false,
    comments: [
      { user: "low_n_slow_leo", avatar: "assets/av-3.svg", text: "Was an honour to park next to that lineup", time: "6h", likes: 22 },
      { user: "carla_boost",    avatar: "assets/av-5.svg", text: "Already counting down to the next one", time: "5h", likes: 7 },
    ],
    commentCount: 130,
  },
  {
    type: "ad", id: "a2",
    user: { username: "riviera_tuning", avatar: "assets/av-3.svg" },
    sponsored: "Sponsored",
    images: ["assets/car-2.png"],
    caption: "Dyno days this weekend. See real numbers, not estimates — slots filling fast.",
    cta: "Reserve dyno time",
    likes: 198, liked: false,
    commentCount: 9,
  },
  {
    type: "post", id: "p4",
    user: { username: "kenji_apex", avatar: "assets/av-4.svg", verified: true },
    location: "Larvotto", time: "12h",
    images: ["assets/car-3.png", "assets/car-1.png"],
    caption: "Detailed top to bottom for the show next week. Worth every hour.",
    likes: 654, liked: false,
    comments: [
      { user: "vroom_valeria", avatar: "assets/av-2.svg", text: "Glass finish 👏", time: "10h", likes: 5 },
    ],
    commentCount: 27,
  },
];

const fmt = (n) => n >= 1000 ? (n / 1000).toFixed(1).replace(/\.0$/, "") + "k" : String(n);

// Default layout config — overridable via Tweaks
const FEED_CFG = {
  imageHeight: 240,   // photo height (smaller = whole card fits on screen)
  cardRadius: 20,     // post-card corner roundness
  peek: 22,           // how far neighbour images poke in
  imageFit: "cover",  // cover | contain
};

// ─────────────────────────────────────────────────────────
// Peek carousel — neighbors slightly visible
// ─────────────────────────────────────────────────────────
function Carousel({ images, cfg }) {
  const CARD_W = 342;             // card width (366) minus 12px inset each side
  const multi  = images.length > 1;
  const PEEK   = multi ? cfg.peek : 0;  // how far neighbors poke in
  const GAP    = 8;
  const slideW = CARD_W - PEEK * 2;
  const H      = cfg.imageHeight;

  const [idx, setIdx]   = React.useState(0);
  const [dx, setDx]     = React.useState(0);
  const drag = React.useRef(null);

  const baseOffset = (i) => (CARD_W - slideW) / 2 - i * (slideW + GAP);

  const onDown = (e) => {
    if (!multi) return;
    const p = e.touches ? e.touches[0] : e;
    drag.current = { x: p.clientX };
    e.stopPropagation();
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const p = e.touches ? e.touches[0] : e;
    setDx(p.clientX - drag.current.x);
  };
  const onUp = () => {
    if (!drag.current) return;
    if (dx < -40 && idx < images.length - 1) setIdx(idx + 1);
    else if (dx > 40 && idx > 0) setIdx(idx - 1);
    setDx(0);
    drag.current = null;
  };

  return (
    <div style={{ position: "relative", width: CARD_W, height: H, overflow: "hidden", background: KE.bgSoft }}>
      <div
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}
        style={{
          position: "absolute", top: 0, left: 0, height: "100%",
          display: "flex", gap: GAP, alignItems: "stretch",
          transform: `translateX(${baseOffset(idx) + dx}px)`,
          transition: drag.current ? "none" : "transform 320ms cubic-bezier(.4,0,.2,1)",
          cursor: multi ? "grab" : "default", touchAction: "pan-y",
        }}
      >
        {images.map((src, i) => (
          <div key={i} style={{
            width: slideW, height: "100%", flexShrink: 0, borderRadius: 14,
            overflow: "hidden", background: KE.bgSoft,
            opacity: multi && i !== idx ? 0.55 : 1,
            transition: "opacity 320ms ease",
          }}>
            <img src={src} alt="" draggable={false} style={{
              width: "100%", height: "100%", objectFit: cfg.imageFit, display: "block", userSelect: "none",
            }}/>
          </div>
        ))}
      </div>

      {/* counter */}
      {multi && (
        <div style={{
          position: "absolute", top: 12, right: PEEK + 10,
          background: "rgba(10,10,10,0.6)", color: "#fff",
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 0.5,
          padding: "3px 9px", borderRadius: 999, backdropFilter: "blur(4px)",
        }}>{idx + 1}/{images.length}</div>
      )}

      {/* dots */}
      {multi && (
        <div style={{
          position: "absolute", bottom: 12, left: 0, right: 0,
          display: "flex", justifyContent: "center", gap: 6,
        }}>
          {images.map((_, i) => (
            <span key={i} onClick={() => setIdx(i)} style={{
              width: i === idx ? 18 : 6, height: 6, borderRadius: 999, cursor: "pointer",
              background: i === idx ? "#fff" : "rgba(255,255,255,0.6)",
              boxShadow: "0 1px 3px rgba(0,0,0,0.3)", transition: "width 240ms ease",
            }}/>
          ))}
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Comment section
// ─────────────────────────────────────────────────────────
function CommentSection({ comments }) {
  return (
    <div style={{ borderTop: `1px solid ${KE.line}`, marginTop: 12, paddingTop: 12 }}>
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        {comments.map((c, i) => (
          <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
            <img src={c.avatar} alt="" style={{ width: 30, height: 30, borderRadius: 999, objectFit: "cover", background: KE.line2, flexShrink: 0 }}/>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: FONT_BODY, fontSize: 13, color: KE.ink2, lineHeight: 1.45 }}>
                <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, color: KE.ink, fontSize: 12.5 }}>@{c.user}</span>{" "}
                {c.text}
              </div>
              <div style={{ display: "flex", gap: 14, marginTop: 4, fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 0.5, color: KE.mute }}>
                <span>{c.time}</span>
                <span>{c.likes} likes</span>
                <span>Reply</span>
              </div>
            </div>
            <button style={{ border: "none", background: "transparent", padding: 2, cursor: "pointer", flexShrink: 0 }}>
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M12 21s-7-4.5-9.5-9A5 5 0 0112 5a5 5 0 019.5 7c-2.5 4.5-9.5 9-9.5 9z" stroke={KE.muteSoft} strokeWidth="2" strokeLinejoin="round"/></svg>
            </button>
          </div>
        ))}
      </div>

      {/* input */}
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginTop: 14 }}>
        <img src="assets/avatar.jpg" alt="" style={{ width: 30, height: 30, borderRadius: 999, objectFit: "cover", flexShrink: 0 }}/>
        <div style={{
          flex: 1, height: 40, borderRadius: 999, background: KE.bgSoft, border: `1px solid ${KE.line}`,
          display: "flex", alignItems: "center", padding: "0 14px",
          fontFamily: FONT_BODY, fontSize: 13, color: KE.mute,
        }}>Add a comment…</div>
        <button style={{
          border: "none", background: "transparent", cursor: "pointer", padding: 4,
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12, letterSpacing: 0.5, color: KE.accent,
        }}>Post</button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Action group — heart + comment (sketch: right side)
// ─────────────────────────────────────────────────────────
function Actions({ liked, likes, commentCount, onLike, onComment, commentsOpen }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 6, flexShrink: 0 }}>
      <button onClick={onLike} style={{
        border: "none", background: "transparent", cursor: "pointer",
        display: "flex", alignItems: "center", gap: 6, padding: "6px 4px",
      }}>
        <svg width="24" height="24" viewBox="0 0 24 24" fill={liked ? KE.accent : "none"} style={{ transition: "transform 120ms ease", transform: liked ? "scale(1.05)" : "scale(1)" }}>
          <path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={liked ? KE.accent : KE.ink} strokeWidth="2" strokeLinejoin="round"/>
        </svg>
        <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, color: KE.ink, minWidth: 30 }}>{fmt(likes)}</span>
      </button>
      <button onClick={onComment} style={{
        border: "none", background: "transparent", cursor: "pointer",
        display: "flex", alignItems: "center", gap: 6, padding: "6px 4px",
      }}>
        <svg width="23" height="23" viewBox="0 0 24 24" fill={commentsOpen ? KE.ink : "none"}>
          <path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/>
        </svg>
        <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, color: KE.ink, minWidth: 24 }}>{fmt(commentCount)}</span>
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Caption with expand
// ─────────────────────────────────────────────────────────
function Caption({ username, text }) {
  const [open, setOpen] = React.useState(false);
  const long = text.length > 84;
  return (
    <div style={{
      fontFamily: FONT_BODY, fontSize: 13.5, color: KE.ink2, lineHeight: 1.5,
      ...(open ? {} : {
        display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden",
      }),
    }}>
      <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, color: KE.ink, fontSize: 13.5 }}>@{username}</span>{" "}
      {text}
      {long && !open && (
        <span onClick={(e) => { e.stopPropagation(); setOpen(true); }} style={{ color: KE.mute, cursor: "pointer", fontWeight: 600 }}> more</span>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Post header
// ─────────────────────────────────────────────────────────
function PostHeader({ user, location, time, sponsored }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 11, padding: "12px 14px" }}>
      <div style={{
        width: 40, height: 40, borderRadius: 999, padding: user.verified ? 2 : 0,
        background: user.verified ? KE.accent : "transparent", flexShrink: 0,
      }}>
        <img src={user.avatar} alt="" style={{ width: "100%", height: "100%", borderRadius: 999, objectFit: "cover", background: KE.line2, display: "block" }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, color: KE.ink, letterSpacing: -0.2 }}>@{user.username}</span>
          {user.verified && (
            <span style={{ width: 13, height: 13, borderRadius: 999, background: KE.accent, display: "inline-grid", placeItems: "center" }}>
              <svg width="7" height="7" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke="#fff" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
          )}
        </div>
        <div style={{ fontFamily: FONT_BODY, fontSize: 11.5, color: KE.mute, marginTop: 1, display: "flex", alignItems: "center", gap: 5 }}>
          {sponsored ? (
            <span>{sponsored}</span>
          ) : (
            <>
              <span>{location}</span>
              <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }}/>
              <span>{time}</span>
            </>
          )}
        </div>
      </div>
      <button style={{ border: "none", background: "transparent", padding: 6, cursor: "pointer", flexShrink: 0 }}>
        <svg width="18" height="5" viewBox="0 0 18 5"><circle cx="2.5" cy="2.5" r="2" fill={KE.mute}/><circle cx="9" cy="2.5" r="2" fill={KE.mute}/><circle cx="15.5" cy="2.5" r="2" fill={KE.mute}/></svg>
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Native ad CTA — deliberately subtle (no orange, blends in)
// ─────────────────────────────────────────────────────────
function AdCta({ label }) {
  return (
    <button style={{
      width: "100%", marginTop: 12, height: 44, borderRadius: 12, cursor: "pointer",
      background: KE.bgSoft, border: `1px solid ${KE.line}`, color: KE.ink,
      display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12.5, letterSpacing: 0.4,
    }}>
      {label}
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 12h14m-6-6l6 6-6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
    </button>
  );
}

// ─────────────────────────────────────────────────────────
// Post card (handles both post and ad)
// ─────────────────────────────────────────────────────────
function PostCard({ item, cfg }) {
  const isAd = item.type === "ad";
  const [liked, setLiked]   = React.useState(item.liked);
  const [likes, setLikes]   = React.useState(item.likes);
  const [open, setOpen]     = React.useState(false);

  const toggleLike = () => {
    setLiked(l => { setLikes(n => n + (l ? -1 : 1)); return !l; });
  };

  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: cfg.cardRadius,
      overflow: "hidden", flexShrink: 0,
    }}>
      <PostHeader user={item.user} location={item.location} time={item.time} sponsored={isAd ? item.sponsored : null}/>

      {/* image carousel — full card width with rounded inset slides */}
      <div style={{ padding: "0 12px" }}>
        <Carousel images={item.images} cfg={cfg}/>
      </div>

      {/* caption + actions row (sketch: desc left, heart+comment right) */}
      <div style={{ padding: "12px 14px 14px" }}>
        <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
          <div style={{ flex: 1, minWidth: 0, paddingTop: 4 }}>
            <Caption username={item.user.username} text={item.caption}/>
          </div>
          <Actions
            liked={liked} likes={likes} commentCount={item.commentCount}
            onLike={toggleLike}
            onComment={() => !isAd && setOpen(o => !o)}
            commentsOpen={open}
          />
        </div>

        {isAd && <AdCta label={item.cta}/>}

        {!isAd && !open && item.commentCount > 0 && (
          <button onClick={() => setOpen(true)} style={{
            border: "none", background: "transparent", padding: "8px 0 0", cursor: "pointer",
            fontFamily: FONT_BODY, fontSize: 12.5, color: KE.mute,
          }}>View all {item.commentCount} comments</button>
        )}

        {!isAd && open && <CommentSection comments={item.comments}/>}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────
function FeedTopBar() {
  return (
    <div style={{
      height: 56, padding: "0 18px", flexShrink: 0,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 17, letterSpacing: -0.3, color: KE.ink }}>
        Kinetic<span style={{ color: KE.accent }}>.</span>
      </div>
      <div style={{ display: "flex", gap: 8 }}>
        {[
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/></svg>,
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/></svg>,
        ].map((ic, i) => (
          <div key={i} style={{
            width: 38, height: 38, borderRadius: 12, display: "grid", placeItems: "center",
            border: `1px solid ${KE.line}`, background: KE.surface,
          }}>{ic}</div>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Tab bar
// ─────────────────────────────────────────────────────────
function FeedTabBar() {
  const tabs = [
    { k: "FEED",     icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/></svg> },
    { k: "MAP",      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "REELS",    href: "Reels Page.html", icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
    { k: "CONTESTS", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { k: "PROFILE",  icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0", flexShrink: 0,
      background: KE.surface, borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center",
    }}>
      {tabs.map(t => {
        const on = t.k === "FEED";
        return (
          <div key={t.k} onClick={() => t.href && window.location.assign(t.href)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, cursor: t.href ? "pointer" : "default", color: on ? KE.ink : KE.muteSoft }}>
            {t.icon}
            <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1 }}>{t.k}</span>
            {on && <div style={{ width: 16, height: 2, borderRadius: 2, background: KE.ink, marginTop: 2 }}/>}
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
function FeedScreen({ cfg = FEED_CFG }) {
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <FeedTopBar/>

      <div style={{
        flex: 1, minHeight: 0, overflowY: "auto", padding: "14px 12px 22px",
        display: "flex", flexDirection: "column", gap: 16,
        WebkitMaskImage: "linear-gradient(180deg, transparent 0, #000 12px, #000 calc(100% - 14px), transparent 100%)",
        maskImage: "linear-gradient(180deg, transparent 0, #000 12px, #000 calc(100% - 14px), transparent 100%)",
      }}>
        {FEED.map(item => <PostCard key={item.id} item={item} cfg={cfg}/>)}
      </div>

      <FeedTabBar/>
    </div>
  );
}

window.FeedScreen = FeedScreen;
