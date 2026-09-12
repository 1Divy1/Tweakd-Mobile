// chat.jsx — Kinetic Edge · DM chat thread
// Minimalist bubbles: outgoing = near-black ink, incoming = white surface + hairline.
// Orange reserved for send action, presence, and unread. Shared-post card + typing.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// keyframes for the typing indicator — injected once
if (typeof document !== "undefined" && !document.getElementById("ke-chat-kf")) {
  const s = document.createElement("style");
  s.id = "ke-chat-kf";
  s.textContent =
    "@keyframes keTyping{0%,60%,100%{transform:translateY(0);opacity:.35}30%{transform:translateY(-4px);opacity:1}}";
  document.head.appendChild(s);
}

const PEER = { username: "marcus_vlox", avatar: "assets/avatar.jpg", verified: true };

// ─────────────────────────────────────────────────────────
// Thread transcript
// ─────────────────────────────────────────────────────────
const MESSAGES = [
  { id: "m1", from: "them", kind: "text", text: "Yo — you free this weekend?" },
  { id: "m2", from: "them", kind: "text", text: "Thinking a dawn run up Col de Turini before the crowds hit 🏔️", time: "8:12" },
  { id: "m3", from: "me",   kind: "text", text: "Say less. What time are we rolling out?" },
  { id: "m4", from: "them", kind: "text", text: "5:30 from the marina. Golden hour on the switchbacks is unreal." },
  { id: "m5", from: "them", kind: "post" }, // shared post card
  { id: "m6", from: "me",   kind: "text", text: "That framing 🔥 count me in" },
  { id: "m7", from: "me",   kind: "text", text: "I'll bring the M4, just got it detailed", time: "8:15", seen: true },
];

// ─────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────
function ChatHeader() {
  const iconBtn = (child) => (
    <div style={{
      width: 36, height: 36, borderRadius: 12, cursor: "pointer",
      display: "grid", placeItems: "center",
      border: `1px solid ${KE.line}`, background: KE.surface,
    }}>{child}</div>
  );
  return (
    <div style={{
      height: 60, padding: "0 12px",
      display: "flex", alignItems: "center", gap: 10,
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div onClick={() => window.location.assign("Messages Page.html")}>
        {iconBtn(
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: 11, flex: 1, minWidth: 0, cursor: "pointer" }}>
        <div style={{
          width: 40, height: 40, borderRadius: 999, padding: PEER.verified ? 2 : 0,
          background: PEER.verified ? KE.accent : "transparent", flexShrink: 0,
        }}>
          <img src={PEER.avatar} alt="" style={{
            width: "100%", height: "100%", borderRadius: 999, objectFit: "cover",
            background: KE.line2, display: "block", border: `2px solid ${KE.bg}`,
          }}/>
        </div>
        <div style={{ minWidth: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.2,
              whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
            }}>{PEER.username}</span>
            {PEER.verified && (
              <span style={{ width: 13, height: 13, borderRadius: 999, background: KE.accent, display: "inline-grid", placeItems: "center", flexShrink: 0 }}>
                <svg width="7" height="7" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke="#fff" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </span>
            )}
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 5, marginTop: 1 }}>
            <span style={{ width: 6, height: 6, borderRadius: 999, background: KE.accent }}/>
            <span style={{ fontFamily: FONT_BODY, fontSize: 11.5, color: KE.mute }}>Active now</span>
          </div>
        </div>
      </div>

      {iconBtn(
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
          <path d="M6.5 10.5a11 11 0 007 7l2-2a1.5 1.5 0 011.6-.3 12 12 0 003.3.7 1.5 1.5 0 011.3 1.5V21a1.5 1.5 0 01-1.6 1.5A18 18 0 013 5.6 1.5 1.5 0 014.5 4H7a1.5 1.5 0 011.5 1.3c.1 1.1.3 2.2.7 3.3a1.5 1.5 0 01-.4 1.6l-2 2z" stroke={KE.ink} strokeWidth="1.8" strokeLinejoin="round"/>
        </svg>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Bubbles
// ─────────────────────────────────────────────────────────
function TextBubble({ from, text, last }) {
  const mine = from === "me";
  return (
    <div style={{ display: "flex", justifyContent: mine ? "flex-end" : "flex-start" }}>
      <div style={{
        maxWidth: "76%",
        background: mine ? KE.ink : KE.surface,
        color: mine ? "#F6F4F1" : KE.ink,
        border: mine ? "none" : `1px solid ${KE.line}`,
        borderRadius: 20,
        borderBottomRightRadius: mine && last ? 6 : 20,
        borderBottomLeftRadius: !mine && last ? 6 : 20,
        padding: "10px 14px",
        fontFamily: FONT_BODY, fontSize: 14.5, lineHeight: 1.45,
      }}>{text}</div>
    </div>
  );
}

function SharedPostBubble() {
  return (
    <div style={{ display: "flex", justifyContent: "flex-start" }}>
      <div style={{
        width: 220, background: KE.surface, border: `1px solid ${KE.line}`,
        borderRadius: 20, borderBottomLeftRadius: 6, overflow: "hidden", cursor: "pointer",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 12px 8px" }}>
          <img src="assets/avatar.jpg" alt="" style={{ width: 22, height: 22, borderRadius: 999, objectFit: "cover" }}/>
          <span style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12, color: KE.ink }}>@marcus_vlox</span>
        </div>
        <img src="assets/car-1.png" alt="" style={{ width: "100%", height: 140, objectFit: "cover", display: "block", background: KE.bgSoft }}/>
        <div style={{ padding: "9px 12px 11px" }}>
          <div style={{
            fontFamily: FONT_BODY, fontSize: 12.5, color: KE.ink2, lineHeight: 1.4,
            display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden",
          }}>Golden hour on the switchbacks — this is the shot I want to recreate.</div>
        </div>
      </div>
    </div>
  );
}

function TypingBubble() {
  return (
    <div style={{ display: "flex", justifyContent: "flex-start" }}>
      <div style={{
        background: KE.surface, border: `1px solid ${KE.line}`,
        borderRadius: 20, borderBottomLeftRadius: 6, padding: "13px 16px",
        display: "flex", gap: 5, alignItems: "center",
      }}>
        {[0, 1, 2].map(i => (
          <span key={i} style={{
            width: 7, height: 7, borderRadius: 999, background: KE.mute,
            animation: `keTyping 1.2s ${i * 0.18}s infinite ease-in-out`,
          }}/>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Composer
// ─────────────────────────────────────────────────────────
function Composer() {
  return (
    <div style={{
      flexShrink: 0, background: KE.bg, borderTop: `1px solid ${KE.line}`,
      padding: "10px 14px 26px", display: "flex", alignItems: "center", gap: 10,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 999, flexShrink: 0,
        border: `1px solid ${KE.line}`, background: KE.surface,
        display: "grid", placeItems: "center", cursor: "pointer",
      }}>
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path d="M12 5v14M5 12h14" stroke={KE.ink} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>

      <div style={{
        flex: 1, height: 44, borderRadius: 999, background: KE.surface,
        border: `1px solid ${KE.line}`,
        display: "flex", alignItems: "center", padding: "0 8px 0 16px", gap: 8,
      }}>
        <span style={{ flex: 1, fontFamily: FONT_BODY, fontSize: 14.5, color: KE.mute }}>Message…</span>
        <div style={{ width: 32, height: 32, borderRadius: 999, display: "grid", placeItems: "center", cursor: "pointer" }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="12" r="9" stroke={KE.mute} strokeWidth="1.8"/>
            <circle cx="9" cy="10.5" r="1.2" fill={KE.mute}/>
            <circle cx="15" cy="10.5" r="1.2" fill={KE.mute}/>
            <path d="M8.5 14.5a4 4 0 007 0" stroke={KE.mute} strokeWidth="1.8" strokeLinecap="round"/>
          </svg>
        </div>
      </div>

      <div style={{
        width: 44, height: 44, borderRadius: 999, flexShrink: 0,
        background: KE.accent, display: "grid", placeItems: "center", cursor: "pointer",
      }}>
        <svg width="19" height="19" viewBox="0 0 24 24" fill="none">
          <path d="M4 12l16-8-6 16-2.5-6L4 12z" fill={KE.onAccent}/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
function ChatScreen({ state = "default" }) {
  const typing = state === "typing";

  // determine which messages are "last in group" for tail rounding
  const rows = MESSAGES.map((m, i) => {
    const next = MESSAGES[i + 1];
    const last = !next || next.from !== m.from;
    return { ...m, last };
  });

  return (
    <div style={{
      width: 390, height: 844, background: KE.bg,
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <ChatHeader/>

      {/* transcript */}
      <div style={{
        flex: 1, minHeight: 0, overflowY: "auto", padding: "16px 16px 8px",
        display: "flex", flexDirection: "column", gap: 6,
      }}>
        {/* peer intro */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8, padding: "6px 0 18px" }}>
          <div style={{
            width: 64, height: 64, borderRadius: 999, padding: 2, background: KE.accent,
          }}>
            <img src={PEER.avatar} alt="" style={{
              width: "100%", height: "100%", borderRadius: 999, objectFit: "cover",
              border: `2px solid ${KE.bg}`, display: "block",
            }}/>
          </div>
          <div style={{ fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 16, color: KE.ink }}>{PEER.username}</div>
          <div style={{ fontFamily: FONT_BODY, fontSize: 12, color: KE.mute }}>You both follow each other · 4.2k followers</div>
        </div>

        {/* date divider */}
        <div style={{ display: "flex", justifyContent: "center", padding: "0 0 10px" }}>
          <span style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.4,
            color: KE.mute, background: KE.bgSoft, border: `1px solid ${KE.line}`,
            padding: "5px 12px", borderRadius: 999,
          }}>TODAY · 8:10</span>
        </div>

        {rows.map(m => {
          if (m.kind === "post") return <SharedPostBubble key={m.id}/>;
          return (
            <div key={m.id} style={{ display: "flex", flexDirection: "column", gap: 3 }}>
              <TextBubble from={m.from} text={m.text} last={m.last}/>
              {m.time && (
                <div style={{
                  fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.6,
                  color: KE.muteSoft, textAlign: m.from === "me" ? "right" : "left",
                  padding: m.from === "me" ? "1px 4px 0 0" : "1px 0 0 4px",
                }}>
                  {m.time}{m.from === "me" && m.seen ? " · Seen" : ""}
                </div>
              )}
            </div>
          );
        })}

        {typing && <TypingBubble/>}
      </div>

      <Composer/>
    </div>
  );
}

window.ChatScreen = ChatScreen;
