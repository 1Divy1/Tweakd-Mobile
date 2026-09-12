// forums-ui.jsx — Kinetic Edge · Forums
// Shared, reusable UI: chrome, chips, sort control, thread card, tiles,
// avatars, badges, skeletons. Screens compose these.

const KE = window.KE;
const FD = window.KE_FONT_DISPLAY;
const FB = window.KE_FONT_BODY;

const fmt = (n) => n >= 1000 ? (n / 1000).toFixed(1).replace(/\.0$/, "") + "k" : String(n);

// Tweakable knobs — mutated by TweaksPanel controls, read at render time.
// (module-scope object, not props: the whole tree re-renders on each tweak
// change, so plain mutation-then-render is sufficient here.)
window.FR_CFG = window.FR_CFG || { radius: 16, tabIcon: 21 };
const cfg = () => window.FR_CFG;

// ─────────────────────────────────────────────────────────
// Tiny primitives
// ─────────────────────────────────────────────────────────
function Label({ children, color = KE.mute, style }) {
  return (
    <span style={{
      fontFamily: FD, fontWeight: 700, fontSize: 10, letterSpacing: 1.4,
      textTransform: "uppercase", color, ...style,
    }}>{children}</span>
  );
}

function Avatar({ src, size = 32, verified = false }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 999, flexShrink: 0,
      padding: verified ? 1.5 : 0, background: verified ? KE.accent : "transparent",
    }}>
      {src ? (
        <img src={src} alt="" style={{
          width: "100%", height: "100%", borderRadius: 999, objectFit: "cover",
          background: KE.line2, display: "block",
        }}/>
      ) : (
        <div style={{
          width: "100%", height: "100%", borderRadius: 999, background: KE.line,
          display: "grid", placeItems: "center",
        }}>
          <svg width={size * 0.5} height={size * 0.5} viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="8" r="4" stroke={KE.muteSoft} strokeWidth="2"/>
            <path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke={KE.muteSoft} strokeWidth="2" strokeLinecap="round"/>
          </svg>
        </div>
      )}
    </div>
  );
}

function VerifiedDot({ size = 13 }) {
  return (
    <span style={{
      width: size, height: size, borderRadius: 999, background: KE.accent,
      display: "inline-grid", placeItems: "center", flexShrink: 0,
    }}>
      <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none">
        <path d="M5 12l4 4 10-10" stroke={KE.onAccent} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </span>
  );
}

// Brand monogram — typographic, no copyrighted logos.
function BrandMark({ mono, size = 44, tone = "neutral" }) {
  const dark = tone === "dark";
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.28, flexShrink: 0,
      display: "grid", placeItems: "center",
      background: dark ? KE.ink : KE.surface,
      border: `1px solid ${dark ? KE.ink : KE.line}`,
      color: dark ? KE.surface : KE.ink,
      fontFamily: FD, fontWeight: 700, fontSize: size * 0.34, letterSpacing: 0.5,
    }}>{mono}</div>
  );
}

// ─────────────────────────────────────────────────────────
// Tag chip — brand / model / topic. Looks tappable; navigates to that hub.
// variant: "car" (neutral outline) · "topic" (soft fill) · "active" (ink)
// ─────────────────────────────────────────────────────────
function TagChip({ label, variant = "car", small = false, onClick }) {
  const pad = small ? "3px 8px" : "5px 10px";
  const fs = small ? 10.5 : 11;
  const base = {
    display: "inline-flex", alignItems: "center", gap: 5, cursor: "pointer",
    padding: pad, borderRadius: 8, fontFamily: FD, fontWeight: 700,
    fontSize: fs, letterSpacing: 0.2, whiteSpace: "nowrap",
    transition: "background 140ms ease, border-color 140ms ease",
  };
  const skins = {
    car:    { background: KE.surface, border: `1px solid ${KE.line}`, color: KE.ink2 },
    topic:  { background: KE.bgSoft,  border: `1px solid ${KE.line}`, color: KE.mute },
    active: { background: KE.ink,     border: `1px solid ${KE.ink}`,  color: KE.surface },
  };
  return (
    <span onClick={onClick} style={{ ...base, ...skins[variant] }}>
      {variant === "car" && (
        <span style={{ width: 4, height: 4, borderRadius: 999, background: KE.accent, flexShrink: 0 }}/>
      )}
      {label}
    </span>
  );
}

// Refine chip — horizontal filter row. selected = ink filled.
function RefineChip({ label, selected, onClick }) {
  return (
    <button onClick={onClick} style={{
      flexShrink: 0, border: `1px solid ${selected ? KE.ink : KE.line}`,
      background: selected ? KE.ink : KE.surface,
      color: selected ? KE.surface : KE.ink2,
      padding: "7px 13px", borderRadius: 999, cursor: "pointer",
      fontFamily: FD, fontWeight: 700, fontSize: 11.5, letterSpacing: 0.3,
      whiteSpace: "nowrap", transition: "all 140ms ease",
    }}>{label}</button>
  );
}

// ─────────────────────────────────────────────────────────
// Sort control — Hot / New / Active segmented control.
// ─────────────────────────────────────────────────────────
function SortControl({ value = "Hot", onChange }) {
  const opts = ["Hot", "New", "Active"];
  return (
    <div style={{
      display: "inline-flex", background: KE.bgSoft, border: `1px solid ${KE.line}`,
      borderRadius: 10, padding: 3, gap: 2,
    }}>
      {opts.map(o => {
        const on = o === value;
        return (
          <button key={o} onClick={() => onChange && onChange(o)} style={{
            border: "none", cursor: "pointer", padding: "6px 12px", borderRadius: 7,
            background: on ? KE.surface : "transparent",
            boxShadow: on ? "0 1px 2px rgba(0,0,0,0.06)" : "none",
            color: on ? KE.ink : KE.mute,
            fontFamily: FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.4,
            transition: "all 140ms ease",
          }}>{o}</button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Badges
// ─────────────────────────────────────────────────────────
function PinBadge() {
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 4,
      color: KE.accent, fontFamily: FD, fontWeight: 700, fontSize: 9.5, letterSpacing: 1,
    }}>
      <svg width="11" height="11" viewBox="0 0 24 24" fill="none">
        <path d="M9 4h6l-1 6 3 3v2H7v-2l3-3-1-6z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/>
        <path d="M12 15v5" stroke={KE.accent} strokeWidth="2" strokeLinecap="round"/>
      </svg>
      PINNED
    </span>
  );
}

function LockBadge() {
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 4,
      color: KE.mute, fontFamily: FD, fontWeight: 700, fontSize: 9.5, letterSpacing: 1,
    }}>
      <svg width="11" height="11" viewBox="0 0 24 24" fill="none">
        <rect x="5" y="11" width="14" height="9" rx="2" stroke={KE.mute} strokeWidth="2"/>
        <path d="M8 11V8a4 4 0 018 0v3" stroke={KE.mute} strokeWidth="2"/>
      </svg>
      LOCKED
    </span>
  );
}

// Metric — reply / like counts with icon.
function Metric({ kind, value }) {
  const icon = kind === "reply" ? (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
      <path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={KE.mute} strokeWidth="2" strokeLinejoin="round"/>
    </svg>
  ) : (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
      <path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={KE.mute} strokeWidth="2" strokeLinejoin="round"/>
    </svg>
  );
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 5 }}>
      {icon}
      <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 12, color: KE.ink2 }}>{fmt(value)}</span>
    </span>
  );
}

// ─────────────────────────────────────────────────────────
// Thread card — the repeating unit across every list.
// hideCar / hideTopic drop the tag(s) that equal the current hub context.
// ─────────────────────────────────────────────────────────
function ThreadCard({ t, hideCar = false, hideBrand = false, hideModel = false, hideTopic = null, onOpen, compact = false }) {
  const chips = [];
  if (!hideCar && !hideBrand && t.brand) chips.push({ label: t.brand, variant: "car" });
  if (!hideCar && !hideModel && t.model) chips.push({ label: t.model, variant: "car" });
  t.topics.forEach(tp => {
    if (tp !== hideTopic) chips.push({ label: tp, variant: "topic" });
  });

  return (
    <div onClick={onOpen} style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: cfg().radius,
      padding: "13px 15px", cursor: "pointer",
    }}>
      {/* top badge row */}
      {(t.pinned || t.locked) && (
        <div style={{ display: "flex", gap: 12, marginBottom: 8 }}>
          {t.pinned && <PinBadge/>}
          {t.locked && <LockBadge/>}
        </div>
      )}

      {/* title */}
      <div style={{
        fontFamily: FD, fontWeight: 700, fontSize: 15.5, lineHeight: 1.3,
        color: KE.ink, letterSpacing: -0.2, textWrap: "pretty",
      }}>{t.title}</div>

      {/* body snippet */}
      {!compact && t.body && (
        <div style={{
          fontFamily: FB, fontSize: 12.5, lineHeight: 1.45, color: KE.mute, marginTop: 5,
          display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden",
        }}>{t.body}</div>
      )}

      {/* author + activity */}
      <div style={{ display: "flex", alignItems: "center", gap: 7, marginTop: 10 }}>
        <Avatar src={t.author.avatar} size={20} verified={t.author.verified}/>
        <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 11.5, color: KE.ink2 }}>@{t.author.username}</span>
        <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }}/>
        <span style={{ fontFamily: FB, fontSize: 11.5, color: KE.mute }}>active {t.age} ago</span>
      </div>

      {/* chips */}
      {chips.length > 0 && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: 11 }}>
          {chips.map((c, i) => (
            <TagChip key={i} label={c.label} variant={c.variant} small
              onClick={(e) => e.stopPropagation()}/>
          ))}
        </div>
      )}

      {/* metrics */}
      <div style={{
        display: "flex", alignItems: "center", gap: 18, marginTop: 12,
        paddingTop: 11, borderTop: `1px solid ${KE.line2}`,
      }}>
        <Metric kind="reply" value={t.replies}/>
        <Metric kind="like" value={t.likes}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Shortcut card — pinned saved filter on the home screen.
// ─────────────────────────────────────────────────────────
function ShortcutCard({ s, onOpen }) {
  const sub = [s.brand, s.model && s.brand ? null : s.model, s.topic]
    .filter(Boolean);
  const line = s.model ? `${s.brand} · ${s.model}` : (s.brand || s.topic);
  return (
    <div onClick={onOpen} style={{
      flexShrink: 0, width: 158, background: KE.surface, border: `1px solid ${KE.line}`,
      borderRadius: Math.max(0, cfg().radius - 2), padding: "12px 13px", cursor: "pointer", position: "relative",
    }}>
      {/* drag grip + unread */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 10 }}>
        <svg width="12" height="8" viewBox="0 0 12 8" fill={KE.muteSoft}>
          <circle cx="2" cy="2" r="1.2"/><circle cx="6" cy="2" r="1.2"/><circle cx="10" cy="2" r="1.2"/>
          <circle cx="2" cy="6" r="1.2"/><circle cx="6" cy="6" r="1.2"/><circle cx="10" cy="6" r="1.2"/>
        </svg>
        {s.unread > 0 ? (
          <span style={{
            minWidth: 20, height: 20, padding: "0 6px", borderRadius: 999,
            background: KE.accent, color: KE.onAccent,
            fontFamily: FD, fontWeight: 700, fontSize: 10.5,
            display: "grid", placeItems: "center",
          }}>{s.unread}</span>
        ) : (
          s.notify && <span style={{ width: 6, height: 6, borderRadius: 999, background: KE.muteSoft }}/>
        )}
      </div>
      <div style={{
        fontFamily: FD, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.2,
        lineHeight: 1.2, marginBottom: 4,
      }}>{s.name}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
        <span style={{ width: 4, height: 4, borderRadius: 999, background: KE.accent, flexShrink: 0 }}/>
        <span style={{
          fontFamily: FB, fontSize: 11, color: KE.mute, whiteSpace: "nowrap",
          overflow: "hidden", textOverflow: "ellipsis",
        }}>{line}</span>
      </div>
    </div>
  );
}

// Add-shortcut affordance (dashed).
function AddShortcutCard({ onClick }) {
  return (
    <div onClick={onClick} style={{
      flexShrink: 0, width: 92, alignSelf: "stretch", minHeight: 96,
      borderRadius: 14, border: `1.5px dashed ${KE.muteSoft}`, cursor: "pointer",
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 8,
      background: "transparent",
    }}>
      <div style={{
        width: 30, height: 30, borderRadius: 999, background: KE.surface, border: `1px solid ${KE.line}`,
        display: "grid", placeItems: "center",
      }}>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
          <path d="M12 5v14M5 12h14" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round"/>
        </svg>
      </div>
      <Label style={{ fontSize: 9 }}>Add</Label>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Browse tiles
// ─────────────────────────────────────────────────────────
function BrandTile({ b, onClick }) {
  return (
    <div onClick={onClick} style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: Math.max(0, cfg().radius - 2),
      padding: 14, cursor: "pointer", display: "flex", flexDirection: "column", gap: 10,
    }}>
      <BrandMark mono={b.mono} size={40}/>
      <div>
        <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 14, color: KE.ink }}>{b.name}</div>
        <div style={{ fontFamily: FB, fontSize: 11, color: KE.mute, marginTop: 1 }}>{fmt(b.threads)} threads</div>
      </div>
    </div>
  );
}

function TopicTile({ topic, onClick }) {
  return (
    <div onClick={onClick} style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: Math.max(0, cfg().radius - 4),
      padding: "12px 13px", cursor: "pointer",
      display: "flex", flexDirection: "column", gap: 3,
    }}>
      <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 13.5, color: KE.ink, letterSpacing: -0.1 }}>{topic.name}</div>
      <div style={{ fontFamily: FB, fontSize: 10.5, color: KE.mute }}>{fmt(topic.threads)}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Chrome — top bar & bottom tab bar
// ─────────────────────────────────────────────────────────
function TopBar({ title, onBack, action, subtitle }) {
  return (
    <div style={{
      minHeight: 56, padding: "0 14px", flexShrink: 0,
      display: "flex", alignItems: "center", gap: 12,
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      {onBack !== undefined ? (
        <div style={{
          width: 36, height: 36, borderRadius: 12, flexShrink: 0,
          display: "grid", placeItems: "center", cursor: "pointer",
          border: `1px solid ${KE.line}`, background: KE.surface,
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
      ) : <div style={{ width: 36, flexShrink: 0 }}/>}

      <div style={{ flex: 1, minWidth: 0, textAlign: "center" }}>
        <div style={{
          fontFamily: FD, fontWeight: 700, fontSize: subtitle ? 15 : 14,
          letterSpacing: subtitle ? -0.3 : 2,
          color: KE.ink, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
          textTransform: subtitle ? "none" : "uppercase",
        }}>{title}</div>
        {subtitle && (
          <div style={{ fontFamily: FB, fontSize: 11, color: KE.mute, marginTop: 1 }}>{subtitle}</div>
        )}
      </div>

      {action ? action : <div style={{ width: 36, flexShrink: 0 }}/>}
    </div>
  );
}

function IconBtn({ children }) {
  return (
    <div style={{
      width: 36, height: 36, borderRadius: 12, flexShrink: 0,
      display: "grid", placeItems: "center", cursor: "pointer",
      border: `1px solid ${KE.line}`, background: KE.surface,
    }}>{children}</div>
  );
}

function TabBar({ active = "FORUMS" }) {
  const s = cfg().tabIcon;
  const tabs = [
    { k: "FEED",    href: "Feed Page.html", icon: <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M4 11.5L12 4l8 7.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/><path d="M6 10v9a1 1 0 001 1h3v-6h4v6h3a1 1 0 001-1v-9" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "MAP",     href: "Map Page.html", icon: <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "FORUMS",  icon: <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><path d="M4 5h13a2 2 0 012 2v6a2 2 0 01-2 2H9l-4 3v-3H4a1 1 0 01-1-1V6a1 1 0 011-1z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "SEARCH",  href: "Search Page.html", icon: <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2"/><path d="M20 20l-3.5-3.5" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
    { k: "PROFILE", href: "Profile Page.html", icon: <svg width={s} height={s} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0", flexShrink: 0,
      background: KE.surface, borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center",
    }}>
      {tabs.map(t => {
        const on = t.k === active;
        return (
          <div key={t.k} onClick={() => t.href && window.location.assign(t.href)} style={{
            display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
            cursor: t.href ? "pointer" : "default", color: on ? KE.ink : KE.muteSoft,
          }}>
            {t.icon}
            {on && <div style={{ width: 16, height: 2, borderRadius: 2, background: KE.ink, marginTop: 2 }}/>}
          </div>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Skeletons — loading state for thread lists.
// ─────────────────────────────────────────────────────────
function SkeletonCard() {
  const bar = (w, h = 12, mt = 0) => (
    <div style={{ width: w, height: h, borderRadius: 6, background: KE.line, marginTop: mt }}/>
  );
  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 16, padding: "14px 15px",
    }}>
      {bar("88%", 14)}
      {bar("60%", 14, 8)}
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 14 }}>
        <div style={{ width: 20, height: 20, borderRadius: 999, background: KE.line }}/>
        {bar("40%", 10)}
      </div>
      <div style={{ display: "flex", gap: 6, marginTop: 12 }}>
        {bar(54, 22)} {bar(44, 22)} {bar(60, 22)}
      </div>
    </div>
  );
}

function SectionHead({ children, right }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
      <Label>{children}</Label>
      {right}
    </div>
  );
}

// Screen shell — status spacer + fixed device size.
function Screen({ children }) {
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FB, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      {children}
    </div>
  );
}

Object.assign(window, {
  FR_fmt: fmt,
  FR_Label: Label, FR_Avatar: Avatar, FR_VerifiedDot: VerifiedDot, FR_BrandMark: BrandMark,
  FR_TagChip: TagChip, FR_RefineChip: RefineChip, FR_SortControl: SortControl,
  FR_PinBadge: PinBadge, FR_LockBadge: LockBadge, FR_Metric: Metric,
  FR_ThreadCard: ThreadCard, FR_ShortcutCard: ShortcutCard, FR_AddShortcutCard: AddShortcutCard,
  FR_BrandTile: BrandTile, FR_TopicTile: TopicTile,
  FR_TopBar: TopBar, FR_IconBtn: IconBtn, FR_TabBar: TabBar,
  FR_SkeletonCard: SkeletonCard, FR_SectionHead: SectionHead, FR_Screen: Screen,
});
