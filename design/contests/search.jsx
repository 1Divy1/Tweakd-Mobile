// Search screen — Kinetic Edge
// Minimalist: warm-neutral white surfaces, near-black ink, orange used sparingly.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Mock dataset
// ─────────────────────────────────────────────────────────
const USERS = [
  { username: "marcus_vlox",    car: "BMW M4",            avatar: "assets/avatar.jpg",  verified: true },
  { username: "torque_sasha",   car: "Porsche 911 GT3",   avatar: "assets/av-1.svg" },
  { username: "jdm_jules",      car: "Toyota Supra MK4",  avatar: "assets/av-2.svg",   verified: true },
  { username: "low_n_slow_leo", car: "Mazda RX-7",        avatar: "assets/av-3.svg" },
  { username: "kenji_apex",     car: "Nissan GT-R R34",   avatar: "assets/av-4.svg",   verified: true },
  { username: "rallyrider_rae", car: "Subaru Impreza",    avatar: "assets/av-5.svg" },
  { username: "noctis_nico",    car: "Audi RS6",          avatar: "assets/av-6.svg" },
  { username: "turbo_tess",     car: "Honda Civic Type R",avatar: "assets/av-7.svg" },
  { username: "macro_mark",     car: "Lotus Elise",       avatar: "assets/av-1.svg" },
  { username: "vroom_valeria",  car: "Ferrari 458",       avatar: "assets/av-2.svg" },
];

// ─────────────────────────────────────────────────────────
// Chrome
// ─────────────────────────────────────────────────────────
function TopBar() {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg,
      borderBottom: `1px solid ${KE.line}`,
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
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2,
        color: KE.ink,
      }}>SEARCH</div>
      <div style={{ width: 36, height: 36 }}/>
    </div>
  );
}

function TabBar({ active = "FEED" }) {
  const tabs = [
    { k: "FEED",     icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="3" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="3" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/><rect x="13" y="13" width="8" height="8" rx="1.5" stroke="currentColor" strokeWidth="2"/></svg> },
    { k: "MAP",      icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M9 3l-6 2v16l6-2 6 2 6-2V3l-6 2-6-2zm0 0v16m6-14v16" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg> },
    { k: "REELS",    href: "Reels Page.html", icon: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="5" stroke="currentColor" strokeWidth="2"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill="currentColor"/></svg> },
    { k: "CONTESTS", icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg> },
    { k: "PROFILE",  icon: <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg> },
  ];
  return (
    <div style={{
      height: 76, paddingBottom: 20, borderRadius: "16px 16px 0 0",
      background: KE.surface,
      borderTop: `1px solid ${KE.line}`,
      display: "flex", justifyContent: "space-around", alignItems: "center",
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
// Search bar
// ─────────────────────────────────────────────────────────
function SearchBar({ value, onChange, focused, onFocus, onBlur }) {
  return (
    <div style={{
      height: 56, borderRadius: 16, background: KE.surface,
      border: `1px solid ${focused ? KE.ink : KE.line}`,
      transition: "border-color 160ms ease",
      display: "flex", alignItems: "center", padding: "0 16px", gap: 12,
    }}>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <circle cx="11" cy="11" r="7" stroke={focused ? KE.ink : KE.mute} strokeWidth="2"/>
        <path d="M20 20l-3.5-3.5" stroke={focused ? KE.ink : KE.mute} strokeWidth="2" strokeLinecap="round"/>
      </svg>
      <input
        value={value}
        onChange={onChange}
        onFocus={onFocus}
        onBlur={onBlur}
        placeholder="Search by username"
        style={{
          flex: 1, border: "none", outline: "none", background: "transparent",
          fontFamily: FONT_BODY, fontSize: 15, color: KE.ink, padding: 0,
        }}
      />
      {value && (
        <button
          onClick={() => onChange({ target: { value: "" }})}
          style={{
            border: "none", background: "transparent", padding: 4, cursor: "pointer",
            display: "grid", placeItems: "center",
          }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="10" fill={KE.line}/>
            <path d="M9 9l6 6m0-6l-6 6" stroke={KE.ink2} strokeWidth="1.8" strokeLinecap="round"/>
          </svg>
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// User result card — pure white over the warm-grey bg, hairline only.
// ─────────────────────────────────────────────────────────
function UserCard({ user, query }) {
  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 16,
      padding: "12px 14px", display: "flex", alignItems: "center", gap: 14,
      cursor: "pointer",
    }}>
      <div style={{
        width: 48, height: 48, borderRadius: 999, padding: user.verified ? 2 : 0,
        background: user.verified ? KE.accent : "transparent",
        flexShrink: 0,
      }}>
        <img src={user.avatar} alt="" style={{
          width: "100%", height: "100%", borderRadius: 999, objectFit: "cover",
          background: KE.line2, display: "block",
        }}/>
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15,
            color: KE.ink, letterSpacing: -0.2,
          }}>
            <Highlight text={user.username} query={query}/>
          </span>
          {user.verified && (
            <span style={{
              width: 14, height: 14, borderRadius: 999, background: KE.accent,
              display: "inline-grid", placeItems: "center",
            }}>
              <svg width="8" height="8" viewBox="0 0 24 24" fill="none">
                <path d="M5 12l4 4 10-10" stroke={KE.onAccent} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </span>
          )}
        </div>
        <div style={{
          fontFamily: FONT_BODY, fontSize: 12, color: KE.mute, marginTop: 2,
          whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
        }}>{user.car}</div>
      </div>

      <button style={{
        border: "none", background: KE.accent, color: KE.onAccent,
        padding: "8px 14px", borderRadius: 10, cursor: "pointer",
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2,
      }}>FOLLOW</button>
    </div>
  );
}

function Highlight({ text, query }) {
  if (!query || query.length < 1) return <>{text}</>;
  const lower = text.toLowerCase();
  const q = query.toLowerCase();
  const i = lower.indexOf(q);
  if (i === -1) return <>{text}</>;
  return (
    <>
      {text.slice(0, i)}
      <span style={{ color: KE.accent, background: KE.accentSoft, padding: "0 3px", borderRadius: 3 }}>
        {text.slice(i, i + query.length)}
      </span>
      {text.slice(i + query.length)}
    </>
  );
}

// ─────────────────────────────────────────────────────────
// Empty state — neutral, no orange
// ─────────────────────────────────────────────────────────
function EmptyState() {
  return (
    <div style={{
      flex: 1, display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center",
      padding: 40, gap: 16,
    }}>
      <div style={{
        width: 72, height: 72, borderRadius: 24, background: KE.surface,
        display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`,
      }}>
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
          <circle cx="11" cy="11" r="7" stroke={KE.ink} strokeWidth="2"/>
          <path d="M20 20l-3.5-3.5" stroke={KE.ink} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 20,
        color: KE.ink, letterSpacing: -0.4, textAlign: "center",
      }}>Find your people</div>
      <div style={{
        fontFamily: FONT_BODY, fontSize: 13, color: KE.mute,
        textAlign: "center", lineHeight: 1.5, maxWidth: 240,
      }}>
        Type a username to find drivers across the community.
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
function SearchScreen({ state = "empty" }) {
  const initial =
    state === "empty"   ? "" :
    state === "typing"  ? "ke" :
                          "marc";

  const [value, setValue] = React.useState(initial);
  const [focused, setFocused] = React.useState(state !== "empty");

  React.useEffect(() => {
    setValue(initial);
    setFocused(state !== "empty");
  }, [state, initial]);

  const matches = value.length >= 2
    ? USERS.filter(u => u.username.toLowerCase().includes(value.toLowerCase()))
    : [];

  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <TopBar/>

      {/* search bar */}
      <div style={{ padding: "20px 20px 12px", flexShrink: 0 }}>
        <SearchBar
          value={value}
          onChange={(e) => setValue(e.target.value)}
          focused={focused}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
        />
      </div>

      {/* hint when 1 char */}
      {focused && value.length > 0 && value.length < 2 && (
        <div style={{
          padding: "0 24px 8px", display: "flex", alignItems: "center", gap: 6,
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.mute,
        }}>
          <div style={{ width: 4, height: 4, borderRadius: 999, background: KE.ink }}/>
          KEEP TYPING — MIN 2 CHARACTERS
        </div>
      )}

      {/* body */}
      <div style={{ flex: 1, minHeight: 0, display: "flex", flexDirection: "column" }}>
        {value.length < 2 ? (
          <EmptyState/>
        ) : (
          <>
            <div style={{
              padding: "4px 24px 12px",
              display: "flex", justifyContent: "space-between", alignItems: "center",
            }}>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4,
                color: KE.mute,
              }}>
                {matches.length} {matches.length === 1 ? "DRIVER" : "DRIVERS"}
              </span>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4,
                color: KE.ink,
              }}>
                FOR “{value.toLowerCase()}”
              </span>
            </div>

            {matches.length === 0 ? (
              <div style={{ flex: 1, display: "grid", placeItems: "center", padding: 30 }}>
                <div style={{ textAlign: "center" }}>
                  <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 18, color: KE.ink }}>No drivers found</div>
                  <div style={{ fontFamily: FONT_BODY, fontSize: 13, color: KE.mute, marginTop: 6 }}>Try a different username.</div>
                </div>
              </div>
            ) : (
              <div style={{
                flex: 1, minHeight: 0, overflowY: "auto", padding: "0 16px 20px",
                display: "flex", flexDirection: "column", gap: 10,
              }}>
                {matches.map(u => (
                  <UserCard key={u.username} user={u} query={value}/>
                ))}
              </div>
            )}
          </>
        )}
      </div>

      <TabBar/>
    </div>
  );
}

window.SearchScreen = SearchScreen;
