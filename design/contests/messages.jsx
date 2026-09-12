// messages.jsx — Kinetic Edge · DM inbox
// Minimalist: warm-neutral white surfaces, near-black ink, orange used sparingly
// (unread dots, request accent, active presence). Entered from the feed header.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Mock threads
// ─────────────────────────────────────────────────────────
const THREADS = [
  {
    id: "t1", username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true,
    preview: "Dawn run Sunday? Col de Turini before the crowds hit 🏔️",
    time: "2m", unread: 2, online: true, mine: false,
  },
  {
    id: "t2", username: "torque_sasha", avatar: "assets/av-1.svg", verified: true,
    preview: "You: sending the marina shots over now",
    time: "18m", unread: 0, online: true, mine: true,
  },
  {
    id: "t3", username: "jdm_jules", avatar: "assets/av-2.svg", verified: true,
    preview: "112 cars this year — insane turnout",
    time: "1h", unread: 1, online: false, mine: false,
  },
  {
    id: "t4", username: "kenji_apex", avatar: "assets/av-4.svg", verified: true,
    preview: "You: worth every hour of detailing",
    time: "3h", unread: 0, online: false, mine: true, seen: true,
  },
  {
    id: "t5", username: "low_n_slow_leo", avatar: "assets/av-3.svg",
    preview: "Shared a post",
    time: "5h", unread: 0, online: false, mine: false, shared: true,
  },
  {
    id: "t6", username: "rallyrider_rae", avatar: "assets/av-5.svg",
    preview: "Sent you the tuning specs 🔧",
    time: "1d", unread: 0, online: false, mine: false,
  },
  {
    id: "t7", username: "turbo_tess", avatar: "assets/av-7.svg",
    preview: "You: let's link at the next meet",
    time: "2d", unread: 0, online: false, mine: true, seen: true,
  },
];

// ─────────────────────────────────────────────────────────
// Chrome
// ─────────────────────────────────────────────────────────
function InboxTopBar() {
  return (
    <div style={{
      height: 56, padding: "0 12px 0 12px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div
        onClick={() => window.location.assign("Feed Page.html")}
        style={{
          width: 36, height: 36, borderRadius: 12, cursor: "pointer",
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
      }}>MESSAGES</div>
      <div style={{
        width: 36, height: 36, borderRadius: 12,
        display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface, cursor: "pointer",
      }}>
        {/* compose / new message */}
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
          <path d="M4 20h4l10-10-4-4L4 16v4z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/>
          <path d="M14 6l4 4" stroke={KE.ink} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
    </div>
  );
}

function SearchField() {
  return (
    <div style={{
      height: 44, borderRadius: 14, background: KE.surface,
      border: `1px solid ${KE.line}`,
      display: "flex", alignItems: "center", padding: "0 14px", gap: 10,
    }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <circle cx="11" cy="11" r="7" stroke={KE.mute} strokeWidth="2"/>
        <path d="M20 20l-3.5-3.5" stroke={KE.mute} strokeWidth="2" strokeLinecap="round"/>
      </svg>
      <span style={{ fontFamily: FONT_BODY, fontSize: 14, color: KE.mute }}>Search messages</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Active-now presence rail
// ─────────────────────────────────────────────────────────
function ActiveRail() {
  const active = THREADS.filter(t => t.online);
  return (
    <div style={{ padding: "4px 0 2px" }}>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4,
        color: KE.mute, padding: "0 20px 10px",
      }}>ACTIVE NOW</div>
      <div style={{
        display: "flex", gap: 16, overflowX: "auto", padding: "0 20px 4px",
      }}>
        {active.map(t => (
          <div key={t.id} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6, flexShrink: 0, cursor: "pointer" }}>
            <div style={{ position: "relative" }}>
              <img src={t.avatar} alt="" style={{
                width: 52, height: 52, borderRadius: 999, objectFit: "cover",
                background: KE.line2, display: "block",
              }}/>
              <span style={{
                position: "absolute", bottom: 1, right: 1,
                width: 13, height: 13, borderRadius: 999, background: KE.accent,
                border: `2.5px solid ${KE.bg}`,
              }}/>
            </div>
            <span style={{
              fontFamily: FONT_BODY, fontSize: 11, color: KE.ink2, maxWidth: 56,
              whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
            }}>{t.username.split("_")[0]}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Thread row
// ─────────────────────────────────────────────────────────
function ThreadRow({ t }) {
  const unread = t.unread > 0;
  return (
    <div
      onClick={() => window.location.assign("Chat Page.html")}
      style={{
        display: "flex", alignItems: "center", gap: 14, cursor: "pointer",
        padding: "12px 20px",
      }}>
      {/* avatar with verified ring + presence dot */}
      <div style={{ position: "relative", flexShrink: 0 }}>
        <div style={{
          width: 54, height: 54, borderRadius: 999, padding: t.verified ? 2 : 0,
          background: t.verified ? KE.accent : "transparent",
        }}>
          <img src={t.avatar} alt="" style={{
            width: "100%", height: "100%", borderRadius: 999, objectFit: "cover",
            background: KE.line2, display: "block",
            border: t.verified ? `2px solid ${KE.bg}` : "none",
          }}/>
        </div>
        {t.online && (
          <span style={{
            position: "absolute", bottom: 1, right: 1,
            width: 13, height: 13, borderRadius: 999, background: KE.accent,
            border: `2.5px solid ${KE.bg}`,
          }}/>
        )}
      </div>

      {/* text */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15,
            color: KE.ink, letterSpacing: -0.2,
          }}>{t.username}</span>
          {t.verified && (
            <span style={{
              width: 14, height: 14, borderRadius: 999, background: KE.accent,
              display: "inline-grid", placeItems: "center", flexShrink: 0,
            }}>
              <svg width="8" height="8" viewBox="0 0 24 24" fill="none">
                <path d="M5 12l4 4 10-10" stroke={KE.onAccent} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </span>
          )}
        </div>
        <div style={{
          display: "flex", alignItems: "center", gap: 6, marginTop: 3,
        }}>
          {t.shared && (
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
              <path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7M12 3v13m0-13l-4 4m4-4l4 4" stroke={KE.mute} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          )}
          <span style={{
            fontFamily: FONT_BODY, fontSize: 13,
            color: unread ? KE.ink : KE.mute,
            fontWeight: unread ? 600 : 400,
            whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
            flex: 1, minWidth: 0,
          }}>{t.preview}</span>
        </div>
      </div>

      {/* meta */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 6, flexShrink: 0 }}>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 0.4,
          color: unread ? KE.accent : KE.muteSoft,
        }}>{t.time}</span>
        {unread ? (
          <span style={{
            minWidth: 18, height: 18, padding: "0 5px", borderRadius: 999,
            background: KE.accent, color: KE.onAccent,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            display: "grid", placeItems: "center",
          }}>{t.unread}</span>
        ) : t.mine && t.seen ? (
          <img src={t.avatar} alt="" style={{
            width: 14, height: 14, borderRadius: 999, objectFit: "cover", opacity: 0.9,
          }}/>
        ) : (
          <span style={{ width: 18, height: 18 }}/>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Message requests entry
// ─────────────────────────────────────────────────────────
function RequestsRow() {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 14, cursor: "pointer",
      padding: "12px 20px",
    }}>
      <div style={{
        width: 54, height: 54, borderRadius: 999, flexShrink: 0,
        border: `1px solid ${KE.line}`, background: KE.surface,
        display: "grid", placeItems: "center",
      }}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2v10z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink }}>
          Message requests
        </div>
        <div style={{ fontFamily: FONT_BODY, fontSize: 13, color: KE.mute, marginTop: 3 }}>
          vroom_valeria, noctis_nico &amp; 2 others
        </div>
      </div>
      <span style={{
        minWidth: 18, height: 18, padding: "0 5px", borderRadius: 999,
        background: KE.accent, color: KE.onAccent,
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
        display: "grid", placeItems: "center", flexShrink: 0,
      }}>4</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────
function InboxEmpty() {
  return (
    <div style={{
      flex: 1, display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center", padding: 40, gap: 16,
    }}>
      <div style={{
        width: 72, height: 72, borderRadius: 24, background: KE.surface,
        display: "grid", placeItems: "center", border: `1px solid ${KE.line}`,
      }}>
        <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
          <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2v10z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 20,
        color: KE.ink, letterSpacing: -0.4, textAlign: "center",
      }}>No messages yet</div>
      <div style={{
        fontFamily: FONT_BODY, fontSize: 13, color: KE.mute,
        textAlign: "center", lineHeight: 1.5, maxWidth: 240,
      }}>Start a conversation with drivers you follow — plan meets, swap specs, share runs.</div>
      <button style={{
        border: "none", background: KE.accent, color: KE.onAccent,
        padding: "12px 20px", borderRadius: 12, cursor: "pointer", marginTop: 4,
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.2,
      }}>NEW MESSAGE</button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
function MessagesScreen({ state = "default" }) {
  const empty = state === "empty";
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <InboxTopBar/>

      {empty ? (
        <InboxEmpty/>
      ) : (
        <div style={{ flex: 1, minHeight: 0, overflowY: "auto", paddingBottom: 20 }}>
          <div style={{ padding: "16px 20px 12px" }}>
            <SearchField/>
          </div>

          <ActiveRail/>

          <div style={{ height: 1, background: KE.line, margin: "12px 20px 4px" }}/>

          <RequestsRow/>
          <div style={{ height: 1, background: KE.line2, margin: "0 20px" }}/>

          {THREADS.map(t => (
            <ThreadRow key={t.id} t={t}/>
          ))}
        </div>
      )}
    </div>
  );
}

window.MessagesScreen = MessagesScreen;
