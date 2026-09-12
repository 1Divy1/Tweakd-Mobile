// followers.jsx — Kinetic Edge
// Followers / Following screen — single page, tab-switched

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Dataset
// ─────────────────────────────────────────────────────────
const FOLL_USERS = [
  { username: "torque_sasha",   name: "Sasha Korev",      car: "Porsche 911 GT3",    avatar: "assets/av-1.svg", verified: true,  youFollow: true  },
  { username: "jdm_jules",      name: "Jules Nakamura",   car: "Toyota Supra MK4",   avatar: "assets/av-2.svg", verified: true,  youFollow: true  },
  { username: "low_n_slow_leo", name: "Leo Ferreira",     car: "Mazda RX-7",         avatar: "assets/av-3.svg",                   youFollow: false },
  { username: "kenji_apex",     name: "Kenji Okafor",     car: "Nissan GT-R R34",    avatar: "assets/av-4.svg", verified: true,  youFollow: true  },
  { username: "rallyrider_rae", name: "Rae Lindqvist",    car: "Subaru Impreza WRX", avatar: "assets/av-5.svg",                   youFollow: false },
  { username: "noctis_nico",    name: "Nico Stavros",     car: "Audi RS6 Avant",     avatar: "assets/av-6.svg",                   youFollow: true  },
  { username: "turbo_tess",     name: "Tess Harada",      car: "Honda Civic Type R", avatar: "assets/av-7.svg",                   youFollow: false },
  { username: "macro_mark",     name: "Mark Delvaux",     car: "Lotus Elise",        avatar: "assets/av-1.svg",                   youFollow: false },
  { username: "vroom_valeria",  name: "Valeria Rossi",    car: "Ferrari 458 Italia", avatar: "assets/av-2.svg", verified: true,  youFollow: true  },
  { username: "apex_andrei",    name: "Andrei Volkov",    car: "Mitsubishi Evo IX",  avatar: "assets/av-3.svg",                   youFollow: false },
  { username: "driftking_dami", name: "Dami Osei",        car: "Nissan Silvia S15",  avatar: "assets/av-4.svg",                   youFollow: false },
  { username: "carla_boost",    name: "Carla Mendez",     car: "VW Golf R",          avatar: "assets/av-5.svg",                   youFollow: false },
  { username: "night_run_nina", name: "Nina Vasquez",     car: "BMW M2 Competition", avatar: "assets/av-6.svg",                   youFollow: true  },
  { username: "throttle_tom",   name: "Tom Eriksson",     car: "Ford Mustang GT350", avatar: "assets/av-7.svg",                   youFollow: false },
  { username: "sideslip_sol",   name: "Sol Park",         car: "Toyota GR86",        avatar: "assets/av-1.svg",                   youFollow: false },
];

const FOLLOWERS_COUNT = 1500;
const FOLLOWING_COUNT = 53;
const FOLLOWING_LIST  = FOLL_USERS.filter(u => u.youFollow);

// ─────────────────────────────────────────────────────────
// TopBar
// ─────────────────────────────────────────────────────────
function FollTopBar({ username }) {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
      flexShrink: 0,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12,
        display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface,
      }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{ textAlign: "center" }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink }}>
          {username.toUpperCase()}
        </div>
      </div>
      <div style={{ width: 36, height: 36 }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Tab switcher — segmented pill
// ─────────────────────────────────────────────────────────
function TabSwitcher({ active, onSwitch }) {
  const tabs = [
    { key: "followers", label: "FOLLOWERS", count: FOLLOWERS_COUNT.toLocaleString() },
    { key: "following", label: "FOLLOWING",  count: FOLLOWING_COUNT.toLocaleString()  },
  ];
  return (
    <div style={{
      margin: "14px 20px 0",
      display: "flex",
      background: KE.surface,
      border: `1px solid ${KE.line}`,
      borderRadius: 16,
      padding: 4,
      gap: 4,
      flexShrink: 0,
    }}>
      {tabs.map(tab => {
        const on = active === tab.key;
        return (
          <button key={tab.key} onClick={() => onSwitch(tab.key)} style={{
            flex: 1, border: "none", cursor: "pointer",
            borderRadius: 12,
            background: on ? KE.ink : "transparent",
            padding: "10px 0",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 7,
            transition: "background 150ms ease",
          }}>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
              letterSpacing: 1.4, color: on ? KE.surface : KE.mute,
            }}>{tab.label}</span>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
              letterSpacing: 0.5,
              background: on ? "rgba(255,255,255,0.14)" : KE.bgSoft,
              color: on ? "rgba(255,255,255,0.75)" : KE.mute,
              padding: "2px 7px", borderRadius: 6,
            }}>{tab.count}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Search bar — same pattern as search.jsx
// ─────────────────────────────────────────────────────────
function FollSearchBar({ value, onChange, focused, onFocus, onBlur, placeholder }) {
  return (
    <div style={{
      height: 52, borderRadius: 14, background: KE.surface,
      border: `1px solid ${focused ? KE.ink : KE.line}`,
      transition: "border-color 160ms ease",
      display: "flex", alignItems: "center", padding: "0 14px", gap: 10,
    }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <circle cx="11" cy="11" r="7" stroke={focused ? KE.ink : KE.mute} strokeWidth="2"/>
        <path d="M20 20l-3.5-3.5" stroke={focused ? KE.ink : KE.mute} strokeWidth="2" strokeLinecap="round"/>
      </svg>
      <input
        value={value}
        onChange={onChange}
        onFocus={onFocus}
        onBlur={onBlur}
        placeholder={placeholder}
        style={{
          flex: 1, border: "none", outline: "none", background: "transparent",
          fontFamily: FONT_BODY, fontSize: 14, color: KE.ink, padding: 0,
        }}
      />
      {value && (
        <button onClick={() => onChange({ target: { value: "" } })} style={{
          border: "none", background: "transparent", padding: 4, cursor: "pointer",
          display: "grid", placeItems: "center",
        }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" fill={KE.line}/>
            <path d="M9 9l6 6m0-6l-6 6" stroke={KE.ink2} strokeWidth="1.8" strokeLinecap="round"/>
          </svg>
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Highlight helper
// ─────────────────────────────────────────────────────────
function FollHighlight({ text, query }) {
  if (!query) return <>{text}</>;
  const lo = text.toLowerCase();
  const q  = query.toLowerCase();
  const i  = lo.indexOf(q);
  if (i === -1) return <>{text}</>;
  return (
    <>
      {text.slice(0, i)}
      <span style={{ color: KE.accent, background: KE.accentSoft, padding: "0 2px", borderRadius: 3 }}>
        {text.slice(i, i + query.length)}
      </span>
      {text.slice(i + query.length)}
    </>
  );
}

// ─────────────────────────────────────────────────────────
// User row — single follower / following entry
// ─────────────────────────────────────────────────────────
function UserRow({ user, query, showMutual }) {
  const [following, setFollowing] = React.useState(user.youFollow);
  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 16,
      padding: "12px 14px", display: "flex", alignItems: "center", gap: 13,
    }}>
      {/* Avatar */}
      <div style={{
        width: 50, height: 50, borderRadius: 999, flexShrink: 0,
        padding: user.verified ? 2 : 0,
        background: user.verified ? KE.accent : "transparent",
      }}>
        <img src={user.avatar} alt="" style={{
          width: "100%", height: "100%", borderRadius: 999,
          objectFit: "cover", background: KE.line2, display: "block",
        }}/>
      </div>

      {/* Info */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 5, flexWrap: "wrap" }}>
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14,
            color: KE.ink, letterSpacing: -0.2,
          }}>
            <FollHighlight text={user.username} query={query}/>
          </span>
          {user.verified && (
            <span style={{
              width: 14, height: 14, borderRadius: 999, background: KE.accent,
              display: "inline-grid", placeItems: "center", flexShrink: 0,
            }}>
              <svg width="8" height="8" viewBox="0 0 24 24" fill="none">
                <path d="M5 12l4 4 10-10" stroke={KE.onAccent} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </span>
          )}
          {showMutual && user.youFollow && (
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 8,
              letterSpacing: 1, color: KE.mute,
              background: KE.bgSoft, border: `1px solid ${KE.line}`,
              padding: "2px 6px", borderRadius: 5,
            }}>MUTUAL</span>
          )}
        </div>
        <div style={{
          fontFamily: FONT_BODY, fontSize: 12, color: KE.mute, marginTop: 2,
          whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
        }}>{user.car}</div>
      </div>

      {/* Follow button */}
      <button onClick={() => setFollowing(f => !f)} style={{
        flexShrink: 0,
        border: following ? `1px solid ${KE.line}` : "none",
        background: following ? KE.surface : KE.accent,
        color: following ? KE.ink : KE.onAccent,
        padding: "8px 13px", borderRadius: 10, cursor: "pointer",
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2,
        display: "flex", alignItems: "center", gap: 4,
        transition: "all 120ms ease",
      }}>
        {following ? (
          <>
            <svg width="9" height="9" viewBox="0 0 24 24" fill="none">
              <path d="M5 12l4 4 10-10" stroke={KE.ink} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            FOLLOWING
          </>
        ) : "FOLLOW"}
      </button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Empty search state
// ─────────────────────────────────────────────────────────
function NoResults({ query }) {
  return (
    <div style={{
      flex: 1, display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center",
      padding: "40px 30px", gap: 12,
    }}>
      <div style={{
        width: 64, height: 64, borderRadius: 20, background: KE.surface,
        border: `1px solid ${KE.line}`, display: "grid", placeItems: "center",
      }}>
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
          <circle cx="11" cy="11" r="7" stroke={KE.ink} strokeWidth="2"/>
          <path d="M20 20l-3.5-3.5" stroke={KE.ink} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 17,
        color: KE.ink, letterSpacing: -0.3, textAlign: "center",
      }}>No results for "{query}"</div>
      <div style={{
        fontFamily: FONT_BODY, fontSize: 13, color: KE.mute,
        textAlign: "center", lineHeight: 1.5,
      }}>Try a different username.</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// TabBar
// ─────────────────────────────────────────────────────────
function FollTabBar() {
  const tabs = [
    { k: "FEED",     icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/></svg> },
    { k: "MAP",      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "REELS",    href: "Reels Page.html", icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
    { k: "CONTESTS", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { k: "PROFILE",  icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  const active = "PROFILE";
  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0",
      background: KE.surface, borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center",
      flexShrink: 0,
    }}>
      {tabs.map(t => {
        const on = t.k === active;
        return (
          <div key={t.k} onClick={() => t.href && window.location.assign(t.href)} style={{
            display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
            cursor: t.href ? "pointer" : "default",
            color: on ? KE.ink : KE.muteSoft,
          }}>
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
// Main screen
// ─────────────────────────────────────────────────────────
function FollowersScreen({ initTab = "followers", initQuery = "" }) {
  const [activeTab, setActiveTab]   = React.useState(initTab);
  const [query, setQuery]           = React.useState(initQuery);
  const [focused, setFocused]       = React.useState(initQuery.length > 0);

  React.useEffect(() => {
    setActiveTab(initTab);
    setQuery(initQuery);
    setFocused(initQuery.length > 0);
  }, [initTab, initQuery]);

  const list   = activeTab === "followers" ? FOLL_USERS : FOLLOWING_LIST;
  const filt   = query.length > 0
    ? list.filter(u => u.username.toLowerCase().includes(query.toLowerCase()))
    : list;

  const isMutualCtx = activeTab === "followers";
  const countLabel  = `${filt.length} ${activeTab === "followers" ? "FOLLOWERS" : "FOLLOWING"}`;
  const placeholder = activeTab === "followers" ? "Search followers…" : "Search following…";

  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      {/* status bar spacer */}
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>

      <FollTopBar username="@marcus_vlox"/>

      <TabSwitcher active={activeTab} onSwitch={t => { setActiveTab(t); setQuery(""); }}/>

      {/* search bar */}
      <div style={{ padding: "12px 20px 0", flexShrink: 0 }}>
        <FollSearchBar
          value={query}
          onChange={e => setQuery(e.target.value)}
          focused={focused}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder={placeholder}
        />
      </div>

      {/* count label */}
      <div style={{
        padding: "12px 24px 6px", flexShrink: 0,
        display: "flex", justifyContent: "space-between", alignItems: "center",
      }}>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
          letterSpacing: 1.4, color: KE.mute,
        }}>{countLabel}</span>
        {query && (
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            letterSpacing: 1.2, color: KE.ink,
          }}>FOR "{query.toLowerCase()}"</span>
        )}
      </div>

      {/* list */}
      <div style={{
        flex: 1, minHeight: 0, overflowY: "auto",
        padding: "2px 16px 20px",
        display: "flex", flexDirection: "column", gap: 10,
        WebkitMaskImage: "linear-gradient(180deg, transparent 0, #000 10px, #000 calc(100% - 16px), transparent 100%)",
        maskImage: "linear-gradient(180deg, transparent 0, #000 10px, #000 calc(100% - 16px), transparent 100%)",
      }}>
        {filt.length === 0 ? (
          <NoResults query={query}/>
        ) : (
          filt.map(u => (
            <UserRow key={u.username} user={u} query={query} showMutual={isMutualCtx}/>
          ))
        )}
      </div>

      <FollTabBar/>
    </div>
  );
}

window.FollowersScreen = FollowersScreen;
