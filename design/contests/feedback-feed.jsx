// Feedback Feed — Kinetic Edge
// Public feed: users post feedback (bug / feature request / feature improvement),
// upvote/downvote, sort by newest / popular (net votes) / oldest.
// Reuses window.KEFlow tokens (add-flow.jsx).

const F = window.KEFlow;
const { T, DISP, BODY, MONO } = F;
const { useState, useRef, useEffect, useMemo } = React;

// ── Category system ──────────────────────────────────────────
const CATS = {
  bug: {
    key: "bug", label: "Bug",
    color: "oklch(58% 0.19 21)", wash: "oklch(58% 0.19 21 / 0.10)", soft: "oklch(58% 0.19 21 / 0.32)",
  },
  feature_request: {
    key: "feature_request", label: "Feature request",
    color: T.accent, wash: T.accentWash, soft: T.accentSoft,
  },
  improvement: {
    key: "improvement", label: "Feature improvement",
    color: "oklch(58% 0.19 258)", wash: "oklch(58% 0.19 258 / 0.10)", soft: "oklch(58% 0.19 258 / 0.32)",
  },
};
const CAT_LIST = [CATS.bug, CATS.feature_request, CATS.improvement];

// ── Status system (separate from category) ──────────────────
const STATUS = {
  in_progress: { key: "in_progress", label: "In progress", color: "#8A6D00", wash: "oklch(70% 0.13 85 / 0.12)", soft: "oklch(70% 0.13 85 / 0.35)" },
  completed:   { key: "completed", label: "Completed", color: "oklch(48% 0.13 152)", wash: "oklch(48% 0.13 152 / 0.10)", soft: "oklch(48% 0.13 152 / 0.32)" },
};

// ── Glyphs ───────────────────────────────────────────────────
const GPlus = ({ c = "#fff", w = 15 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M12 4v16M4 12h16" stroke={c} strokeWidth="2.6" strokeLinecap="round"/></svg>
);
const GClose = ({ c = T.ink, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={c} strokeWidth="2.4" strokeLinecap="round"/></svg>
);
const GArrowUp = ({ c, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M12 19V6M6 11l6-6 6 6" stroke={c} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GArrowDown = ({ c, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M12 5v13M6 13l6 6 6-6" stroke={c} strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GTrash = ({ c = T.mute, w = 15 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M5 7h14M9 7V5a1 1 0 011-1h4a1 1 0 011 1v2m-9 0l1 13a1 1 0 001 1h8a1 1 0 001-1l1-13" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GCheck = ({ c = "#fff", w = 12 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M5 13l4 4 10-11" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GArrow = ({ c = "#fff", w = 16 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M5 12h13M13 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GEmpty = ({ c = T.muteSoft, w = 30 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M4 5h16v11H9l-5 4z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/><path d="M8 9h8M8 12h5" stroke={c} strokeWidth="1.6" strokeLinecap="round"/></svg>
);
const GClock = ({ c, w = 11 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={c} strokeWidth="2"/><path d="M12 7v5l3.5 2" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GCheckCircle = ({ c, w = 11 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={c} strokeWidth="2"/><path d="M8 12.5l2.5 2.5L16 9" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GChevronLeft = ({ c = T.ink, w = 13 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
);
const GChevronRight = ({ c = T.mute, w = 12 }) => (
  <svg width={w} height={w} viewBox="0 0 24 24" fill="none"><path d="M9 5l7 7-7 7" stroke={c} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
);

// ── Mock data ────────────────────────────────────────────────
const SEED_POSTS = [
  { id: "1", user: "wheelwell_dana", cat: "bug", msg: "Cover photo resets to the first image every time I reorder the gallery.", up: 512, down: 37, minsAgo: 2880, own: false },
  { id: "2", user: "turbo_leah", cat: "feature_request", msg: "Would love a dark mode toggle in settings — long night garage sessions need it.", up: 123, down: 3, minsAgo: 300, own: false },
  { id: "3", user: "marcus_vlox", cat: "improvement", msg: "Search filters should remember my last selection between sessions instead of resetting every time.", up: 64, down: 1, minsAgo: 1440, own: true },
  { id: "4", user: "grip_andre", cat: "feature_request", msg: "Add a way to tag co-owners on a build so credit shows up on shared cars.", up: 41, down: 5, minsAgo: 30, own: false },
  { id: "5", user: "detailer_kim", cat: "bug", msg: "App crashes when uploading more than 6 photos to a single post on older phones.", up: 289, down: 2, minsAgo: 8640, own: false },
  { id: "6", user: "n2o_priya", cat: "improvement", msg: "Map pins overlap badly at low zoom near dense meet spots — hard to tap the right one.", up: 18, down: 0, minsAgo: 180, own: false },
].map(p => ({ ...p, myVote: null, status: p.status || "open" }));
SEED_POSTS_STATUS_OVERRIDE(SEED_POSTS, "2", "in_progress");

function SEED_POSTS_STATUS_OVERRIDE(list, id, status) {
  const p = list.find(x => x.id === id);
  if (p) p.status = status;
}

const COMPLETED_POSTS = [
  { id: "c1", user: "detailer_kim", cat: "bug", msg: "Cover photo resets to the first image every time I reorder the gallery.", staffNote: "Fixed — the gallery cover now stays put when you reorder images in a post.", up: 512, down: 37, shippedAgo: 4320 },
  { id: "c2", user: "grip_andre", cat: "feature_request", msg: "Add a way to tag co-owners on a build so credit shows up on shared cars.", staffNote: "Shipped — you can now tag co-owners and they show up as credited contributors.", up: 201, down: 6, shippedAgo: 10080 },
  { id: "c3", user: "n2o_priya", cat: "improvement", msg: "Map pins overlap badly at low zoom near dense meet spots — hard to tap the right one.", staffNote: null, up: 88, down: 1, shippedAgo: 20160 },
];

function relTime(m) {
  if (m < 60) return `${m}m`;
  if (m < 1440) return `${Math.round(m / 60)}h`;
  return `${Math.round(m / 1440)}d`;
}

// ── Avatar ───────────────────────────────────────────────────
function Avatar({ user, size = 34 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 999, flexShrink: 0,
      background: T.bgSoft, border: `1px solid ${T.line}`,
      display: "grid", placeItems: "center",
    }}>
      <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: size * 0.4, color: T.ink2 }}>
        {user[0].toUpperCase()}
      </span>
    </div>
  );
}

// ── Category pill ────────────────────────────────────────────
function CatPill({ cat, size = "sm" }) {
  const c = CATS[cat];
  const sm = size === "sm";
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 6, flexShrink: 0,
      padding: sm ? "4px 9px" : "6px 12px", borderRadius: 999,
      background: c.wash, border: `1px solid ${c.soft}`,
    }}>
      <div style={{ width: 6, height: 6, borderRadius: 999, background: c.color, flexShrink: 0 }}/>
      <span style={{
        fontFamily: DISP, fontWeight: 700, fontSize: sm ? 10 : 11, letterSpacing: 0.5,
        color: c.color, whiteSpace: "nowrap",
      }}>{c.label.toUpperCase()}</span>
    </div>
  );
}

// ── Vote buttons ─────────────────────────────────────────────
function VoteBtn({ dir, active, count, onClick }) {
  const up = dir === "up";
  const Icon = up ? GArrowUp : GArrowDown;
  return (
    <button onClick={onClick} style={{
      display: "flex", alignItems: "center", gap: 6, padding: "7px 11px", borderRadius: 10,
      cursor: "pointer", border: `1.5px solid ${active ? (up ? T.accent : T.ink) : T.line}`,
      background: active ? (up ? T.accent : T.ink) : T.surface,
    }}>
      <Icon c={active ? "#fff" : T.mute}/>
      <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12.5, color: active ? "#fff" : T.ink2 }}>{count}</span>
    </button>
  );
}

// ── Status tag (in-progress / completed) ─────────────────────
function StatusTag({ status }) {
  const s = STATUS[status];
  const Icon = status === "completed" ? GCheckCircle : GClock;
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 6, padding: "4px 9px", borderRadius: 999,
      background: s.wash, border: `1px solid ${s.soft}`, marginBottom: 11,
    }}>
      <Icon c={s.color}/>
      <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10, letterSpacing: 0.5, color: s.color, whiteSpace: "nowrap" }}>{s.label.toUpperCase()}</span>
    </div>
  );
}

// ── Feedback card ────────────────────────────────────────────
function FeedbackCard({ post, onVote, onDelete, completed = false, timeLabel }) {
  return (
    <div className="ke-anim" style={{
      borderRadius: 18, background: T.surface, border: `1px solid ${T.line}`,
      boxShadow: T.shadowCard, padding: 15, animation: "keRise .3s ease both",
    }}>
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 10, marginBottom: 10 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 9, minWidth: 0 }}>
          <Avatar user={post.user}/>
          <div style={{ minWidth: 0 }}>
            <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 13.5, color: T.ink, letterSpacing: -0.1 }}>
              {post.user}{post.own && <span style={{ color: T.muteSoft, fontWeight: 600 }}> · you</span>}
            </div>
            <div style={{ fontFamily: MONO, fontSize: 10.5, color: T.mute, marginTop: 1 }}>{timeLabel}</div>
          </div>
        </div>
        <CatPill cat={post.cat}/>
      </div>

      {(completed || post.status === "in_progress") && <StatusTag status={completed ? "completed" : post.status}/>}

      <p style={{ margin: completed && post.staffNote ? "0 0 10px" : "0 0 13px", fontFamily: BODY, fontSize: 14, fontWeight: 500, lineHeight: 1.5, color: T.ink2, textWrap: "pretty" }}>
        {post.msg}
      </p>

      {completed && post.staffNote && (
        <div style={{ display: "flex", gap: 9, padding: "10px 12px", borderRadius: 12, background: T.bgSoft, border: `1px solid ${T.line2}`, marginBottom: 13 }}>
          <div style={{ width: 3, borderRadius: 2, background: STATUS.completed.color, flexShrink: 0 }}/>
          <div>
            <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.8, color: T.mute, marginBottom: 3 }}>TWEAKD TEAM</div>
            <div style={{ fontFamily: BODY, fontSize: 13, fontWeight: 500, lineHeight: 1.45, color: T.ink2, textWrap: "pretty" }}>{post.staffNote}</div>
          </div>
        </div>
      )}

      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        {completed ? (
          <div style={{ display: "flex", alignItems: "center", gap: 6, fontFamily: MONO, fontWeight: 700, fontSize: 12.5, color: T.ink2 }}>
            <GArrowUp c={T.muteSoft} w={12}/>{post.up - post.down} net votes
          </div>
        ) : (
          <div style={{ display: "flex", gap: 7 }}>
            <VoteBtn dir="up" active={post.myVote === "up"} count={post.up} onClick={() => onVote(post.id, "up")}/>
            <VoteBtn dir="down" active={post.myVote === "down"} count={post.down} onClick={() => onVote(post.id, "down")}/>
          </div>
        )}
        {post.own && !completed && (
          <button onClick={() => onDelete(post.id)} style={{
            width: 34, height: 34, borderRadius: 10, display: "grid", placeItems: "center",
            background: "transparent", border: `1px solid ${T.line}`, cursor: "pointer",
          }}><GTrash/></button>
        )}
      </div>
    </div>
  );
}

// ── Sort tabs ────────────────────────────────────────────────
const SORTS = [
  { key: "newest", label: "NEWEST" },
  { key: "popular", label: "POPULAR" },
  { key: "oldest", label: "OLDEST" },
];
function SortTabs({ value, onChange }) {
  return (
    <div style={{ display: "flex", gap: 4, padding: 4, borderRadius: 14, background: T.bgSoft, border: `1px solid ${T.line}` }}>
      {SORTS.map(s => {
        const on = s.key === value;
        return (
          <button key={s.key} onClick={() => onChange(s.key)} style={{
            flex: 1, height: 38, borderRadius: 10, cursor: "pointer", border: "none",
            background: on ? T.ink : "transparent", color: on ? "#fff" : T.ink2,
            fontFamily: DISP, fontWeight: 700, fontSize: 11, letterSpacing: 1.1,
            boxShadow: on ? "0 2px 8px rgba(11,11,12,0.18)" : "none", transition: "all .18s",
          }}>{s.label}</button>
        );
      })}
    </div>
  );
}

// ── Feed header ──────────────────────────────────────────────
function FeedHeader({ onCompose }) {
  return (
    <div style={{ padding: "0 18px 4px", display: "flex", alignItems: "flex-start", justifyContent: "space-between", flexShrink: 0 }}>
      <div>
        <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>— COMMUNITY</div>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.9, color: T.ink, marginTop: 5, lineHeight: 1.05 }}>Feedback</div>
      </div>
      <button onClick={onCompose} style={{
        display: "flex", alignItems: "center", gap: 7, height: 40, padding: "0 15px", borderRadius: 12,
        background: T.accent, border: "none", cursor: "pointer", marginTop: 4,
        boxShadow: "0 8px 18px rgba(255,77,0,0.28)",
        fontFamily: DISP, fontWeight: 700, fontSize: 11.5, letterSpacing: 1, color: "#fff",
      }}><GPlus/>NEW</button>
    </div>
  );
}

// ── Completed link row (sits above sort tabs, not a 4th tab) ─
function CompletedLinkRow({ count, onOpen }) {
  return (
    <button onClick={onOpen} style={{
      display: "flex", alignItems: "center", justifyContent: "space-between", width: "100%",
      padding: "11px 13px", borderRadius: 13, marginTop: 12, cursor: "pointer",
      background: STATUS.completed.wash, border: `1px solid ${STATUS.completed.soft}`,
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 0.2, color: STATUS.completed.color }}>Completed requests</span>
      </div>
      <GChevronRight c={STATUS.completed.color} w={12}/>
    </button>
  );
}

// ── Empty state ──────────────────────────────────────────────
function EmptyState({ onCompose }) {
  return (
    <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "0 40px", textAlign: "center" }}>
      <div style={{ width: 64, height: 64, borderRadius: 20, background: T.bgSoft, border: `1px solid ${T.line}`, display: "grid", placeItems: "center", marginBottom: 18 }}>
        <GEmpty/>
      </div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 17, color: T.ink }}>No feedback yet</div>
      <p style={{ margin: "8px 0 20px", fontFamily: BODY, fontSize: 13, lineHeight: 1.5, color: T.mute }}>Be the first to report a bug or suggest something.</p>
      <button onClick={onCompose} style={{
        display: "flex", alignItems: "center", gap: 8, height: 46, padding: "0 20px", borderRadius: 13,
        background: T.accent, border: "none", cursor: "pointer", boxShadow: "0 8px 18px rgba(255,77,0,0.28)",
        fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1, color: "#fff",
      }}><GPlus/>NEW FEEDBACK</button>
    </div>
  );
}

// ── Feed screen ──────────────────────────────────────────────
function FeedbackFeedScreen({ posts, setPosts, sort = "popular", onCompose = () => {}, completedCount = COMPLETED_POSTS.length, onOpenCompleted = () => {} }) {
  const [sortKey, setSortKey] = useState(sort);

  const sorted = useMemo(() => {
    const arr = [...posts];
    if (sortKey === "newest") arr.sort((a, b) => a.minsAgo - b.minsAgo);
    else if (sortKey === "oldest") arr.sort((a, b) => b.minsAgo - a.minsAgo);
    else arr.sort((a, b) => (b.up - b.down) - (a.up - a.down));
    return arr;
  }, [posts, sortKey]);

  const onVote = (id, dir) => {
    setPosts(prev => prev.map(p => {
      if (p.id !== id) return p;
      let { up, down, myVote } = p;
      if (myVote === dir) { dir === "up" ? up-- : down--; myVote = null; }
      else {
        if (myVote === "up") up--;
        if (myVote === "down") down--;
        dir === "up" ? up++ : down++;
        myVote = dir;
      }
      return { ...p, up, down, myVote };
    }));
  };
  const onDelete = (id) => setPosts(prev => prev.filter(p => p.id !== id));

  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column", fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <FeedHeader onCompose={onCompose}/>
      <div style={{ padding: "14px 18px 0", flexShrink: 0 }}>
        <SortTabs value={sortKey} onChange={setSortKey}/>
        <CompletedLinkRow count={completedCount} onOpen={onOpenCompleted}/>
      </div>
      <div style={{ height: 12, flexShrink: 0 }}/>
      <div style={{ height: 1, background: T.line, flexShrink: 0 }}/>
      {sorted.length === 0 ? (
        <EmptyState onCompose={onCompose}/>
      ) : (
        <div className="ke-anim" style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "14px 18px 24px", display: "flex", flexDirection: "column", gap: 12, animation: "keRise .3s ease both" }}>
          {sorted.map(p => <FeedbackCard key={p.id} post={p} onVote={onVote} onDelete={onDelete} timeLabel={`${relTime(p.minsAgo)} ago`}/>)}
        </div>
      )}
    </div>
  );
}

// ── Compose: category picker ─────────────────────────────────
function CategoryPicker({ value, onChange }) {
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
      {CAT_LIST.map(c => {
        const on = c.key === value;
        return (
          <button key={c.key} onClick={() => onChange(c.key)} style={{
            display: "flex", alignItems: "center", gap: 7, padding: "10px 14px", borderRadius: 999,
            cursor: "pointer", border: `1.5px solid ${on ? c.color : T.line}`,
            background: on ? c.color : T.surface, boxShadow: on ? "none" : T.shadowCard,
          }}>
            <div style={{ width: 7, height: 7, borderRadius: 999, background: on ? "#fff" : c.color, flexShrink: 0 }}/>
            <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 12.5, letterSpacing: 0.1, color: on ? "#fff" : T.ink2, whiteSpace: "nowrap" }}>{c.label}</span>
            {on && <GCheck w={11}/>}
          </button>
        );
      })}
    </div>
  );
}

// ── Compose: message textarea ────────────────────────────────
function MessageBox({ value, onChange, max = 500 }) {
  const ref = useRef(null);
  const [focus, setFocus] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (el) { el.style.height = "auto"; el.style.height = Math.max(160, el.scrollHeight) + "px"; }
  }, [value]);
  return (
    <div style={{
      position: "relative", borderRadius: 14, background: T.surface,
      border: `1.5px solid ${focus ? T.accent : T.line}`,
      boxShadow: focus ? `0 0 0 4px ${T.accentWash}` : T.shadowCard,
    }}>
      <textarea
        ref={ref} value={value} onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
        placeholder="What's on your mind — a bug, an idea, a tweak?"
        onChange={(e) => onChange(e.target.value.slice(0, max))}
        style={{
          width: "100%", minHeight: 160, resize: "none", border: "none", outline: "none", background: "transparent",
          padding: "13px 15px 28px", fontFamily: BODY, fontSize: 14.5, fontWeight: 500, lineHeight: 1.55,
          color: T.ink, boxSizing: "border-box", display: "block",
        }}
      />
      <div style={{ position: "absolute", right: 12, bottom: 9, fontFamily: MONO, fontSize: 10, letterSpacing: 0.4, color: value.length > max * 0.9 ? T.accent : T.mute }}>
        {value.length} / {max}
      </div>
    </div>
  );
}

// ── Compose screen ───────────────────────────────────────────
function FeedbackComposeScreen({ onClose = () => {}, onSubmit = () => {}, initialCategory = null, initialMessage = "" }) {
  const [cat, setCat] = useState(initialCategory);
  const [msg, setMsg] = useState(initialMessage);
  const canSend = !!cat && msg.trim().length > 0;

  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column", fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <div style={{ height: 48, padding: "0 16px", display: "flex", alignItems: "center", justifyContent: "space-between", flexShrink: 0 }}>
        <button onClick={onClose} style={{
          width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center", cursor: "pointer",
          background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard,
        }}><GClose/></button>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 13.5, letterSpacing: 3, color: T.ink }}>TWEAKD</div>
        <div style={{ width: 36 }}/>
      </div>
      <div style={{ height: 1, background: T.line, flexShrink: 0 }}/>

      <div className="ke-anim" style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "20px 18px 24px", animation: "keRise .4s ease both" }}>
        <div style={{ marginBottom: 22 }}>
          <div style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: 1, color: T.accent }}>— FEEDBACK COMMUNITY</div>
          <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 27, letterSpacing: -0.9, color: T.ink, marginTop: 7, lineHeight: 1.05 }}>Share feedback</div>
          <p style={{ margin: "9px 0 0", fontFamily: BODY, fontSize: 13.5, lineHeight: 1.5, color: T.mute, textWrap: "pretty" }}>
            Visible to everyone. Other drivers can upvote or downvote it.
          </p>
        </div>

        <div style={{ marginBottom: 20 }}>
          <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink, marginBottom: 9 }}>CATEGORY</div>
          <CategoryPicker value={cat} onChange={setCat}/>
        </div>

        <div>
          <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 10.5, letterSpacing: 1.3, color: T.ink, marginBottom: 9 }}>YOUR MESSAGE</div>
          <MessageBox value={msg} onChange={setMsg}/>
        </div>
      </div>

      <div style={{ flexShrink: 0, padding: "14px 18px", borderTop: `1px solid ${T.line}`, background: T.bg }}>
        <button
          onClick={() => canSend && onSubmit({ cat, msg: msg.trim() })}
          style={{
            width: "100%", height: 54, borderRadius: 16, border: "none", cursor: canSend ? "pointer" : "default",
            background: canSend ? T.accent : T.muteSoft, color: "#fff",
            fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            boxShadow: canSend ? "0 10px 24px rgba(255,77,0,0.30)" : "none",
          }}
        >POST FEEDBACK<GArrow/></button>
      </div>
    </div>
  );
}

// ── Completed screen (dedicated, read-only) ──────────────────
function CompletedScreen({ posts = COMPLETED_POSTS, onBack = () => {} }) {
  return (
    <div style={{ width: 390, height: 844, background: T.bg, display: "flex", flexDirection: "column", fontFamily: BODY, color: T.ink, position: "relative", overflow: "hidden" }}>
      <div style={{ height: 54, flexShrink: 0 }}/>
      <div style={{ height: 48, padding: "0 16px", display: "flex", alignItems: "center", gap: 12, flexShrink: 0 }}>
        <button onClick={onBack} style={{
          width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center", cursor: "pointer",
          background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard,
        }}><GChevronLeft/></button>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 15, color: T.ink }}>Completed requests</div>
      </div>
      <div style={{ height: 1, background: T.line, flexShrink: 0 }}/>
      <div className="ke-anim" style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "16px 18px 24px", display: "flex", flexDirection: "column", gap: 12, animation: "keRise .3s ease both" }}>
        {posts.map(p => <FeedbackCard key={p.id} post={p} completed timeLabel={`shipped ${relTime(p.shippedAgo)} ago`}/>)}
      </div>
    </div>
  );
}

// ── Full interactive flow: feed ⇄ compose ⇄ completed ────────
function FeedbackFeedFlow() {
  const [stage, setStage] = useState("feed");
  const [posts, setPosts] = useState(SEED_POSTS);

  const handleSubmit = ({ cat, msg }) => {
    setPosts(prev => [{ id: String(Date.now()), user: "marcus_vlox", cat, msg, up: 0, down: 0, minsAgo: 0, own: true, myVote: null, status: "open" }, ...prev]);
    setStage("feed");
  };

  if (stage === "compose") return <FeedbackComposeScreen onClose={() => setStage("feed")} onSubmit={handleSubmit}/>;
  if (stage === "completed") return <CompletedScreen onBack={() => setStage("feed")}/>;
  return <FeedbackFeedScreen posts={posts} setPosts={setPosts} onCompose={() => setStage("compose")} onOpenCompleted={() => setStage("completed")}/>;
}

Object.assign(window, {
  FeedbackFeedScreen, FeedbackComposeScreen, FeedbackFeedFlow, CompletedScreen, CATS,
  SEED_POSTS_COPY: () => SEED_POSTS.map(p => ({ ...p })),
});
