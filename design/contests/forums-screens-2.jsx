// forums-screens-2.jsx — Kinetic Edge · Forums
// Thread detail (+ locked), Create thread, Save-shortcut sheet, long-press menu.

const KE = window.KE;
const FD = window.KE_FONT_DISPLAY;
const FB = window.KE_FONT_BODY;
const fmt = window.FR_fmt;

const {
  FR_Label: Label, FR_Avatar: Avatar, FR_VerifiedDot: VerifiedDot,
  FR_TagChip: TagChip, FR_RefineChip: RefineChip, FR_SortControl: SortControl,
  FR_PinBadge: PinBadge, FR_LockBadge: LockBadge, FR_Metric: Metric,
  FR_TopBar: TopBar, FR_IconBtn: IconBtn, FR_Screen: Screen, FR_PrimaryBtn: PrimaryBtn,
  FR_ThreadCard: ThreadCard,
} = window;

const T = window.FORUM_THREADS;
const byId = (id) => T.find(x => x.id === id);

// ═══════════════════════════════════════════════════════════
// Nested reply node — Reddit-style, collapse/expand, [deleted] state.
// ═══════════════════════════════════════════════════════════
function ReplyNode({ node, depth = 0 }) {
  const [collapsed, setCollapsed] = React.useState(false);
  const hasKids = node.children && node.children.length > 0;
  const railColor = depth % 2 === 0 ? KE.line : KE.line2;

  return (
    <div style={{ marginTop: depth === 0 ? 18 : 14 }}>
      <div style={{ display: "flex", gap: 10 }}>
        {/* avatar / thread rail */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", flexShrink: 0 }}>
          <Avatar src={node.deleted ? null : node.author.avatar} size={28} verified={node.author.verified}/>
          {hasKids && !collapsed && (
            <div style={{ width: 2, flex: 1, background: railColor, marginTop: 6, borderRadius: 2 }}/>
          )}
        </div>

        <div style={{ flex: 1, minWidth: 0 }}>
          {/* meta */}
          <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
            <span style={{
              fontFamily: FD, fontWeight: 700, fontSize: 12.5,
              color: node.deleted ? KE.muteSoft : KE.ink,
            }}>{node.deleted ? "[deleted]" : `@${node.author.username}`}</span>
            {node.author.verified && <VerifiedDot size={12}/>}
            <span style={{ width: 3, height: 3, borderRadius: 999, background: KE.muteSoft }}/>
            <span style={{ fontFamily: FB, fontSize: 11, color: KE.mute }}>{node.age}</span>
          </div>

          {/* body */}
          <div style={{
            fontFamily: FB, fontSize: 13, lineHeight: 1.5, marginTop: 4,
            color: node.deleted ? KE.muteSoft : KE.ink2, fontStyle: node.deleted ? "italic" : "normal",
          }}>{node.deleted ? "Comment removed by author" : node.content}</div>

          {/* actions */}
          <div style={{ display: "flex", alignItems: "center", gap: 16, marginTop: 7 }}>
            {!node.deleted && (
              <span style={{ display: "inline-flex", alignItems: "center", gap: 5, cursor: "pointer" }}>
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={KE.mute} strokeWidth="2" strokeLinejoin="round"/></svg>
                <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 11, color: KE.mute }}>{node.likes}</span>
              </span>
            )}
            {!node.deleted && (
              <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.3, color: KE.mute, cursor: "pointer" }}>Reply</span>
            )}
            {hasKids && (
              <span onClick={() => setCollapsed(c => !c)} style={{
                fontFamily: FD, fontWeight: 700, fontSize: 11, letterSpacing: 0.3, color: KE.accent, cursor: "pointer",
                display: "inline-flex", alignItems: "center", gap: 4,
              }}>
                <svg width="9" height="9" viewBox="0 0 12 12" fill="none" style={{ transform: collapsed ? "rotate(-90deg)" : "none" }}>
                  <path d="M2 4l4 4 4-4" stroke={KE.accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
                {collapsed ? `${node.children.length} replies` : "Hide"}
              </span>
            )}
          </div>

          {/* children */}
          {hasKids && !collapsed && (
            <div>{node.children.map(c => <ReplyNode key={c.id} node={c} depth={depth + 1}/>)}</div>
          )}
        </div>
      </div>
    </div>
  );
}

// action bar button
function ActBtn({ icon, label, active, accent }) {
  const col = active ? KE.accent : KE.ink2;
  return (
    <button style={{
      flex: 1, border: "none", background: "transparent", cursor: "pointer",
      display: "flex", flexDirection: "column", alignItems: "center", gap: 4, padding: "2px 0",
    }}>
      {icon(col)}
      <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 10, letterSpacing: 0.4, color: col }}>{label}</span>
    </button>
  );
}

// ═══════════════════════════════════════════════════════════
// THREAD DETAIL
// ═══════════════════════════════════════════════════════════
function ThreadDetailScreen({ locked = false }) {
  const t = locked ? byId("t4") : byId("t1");
  const tree = window.FORUM_REPLY_TREE;
  const overflow = (
    <IconBtn>
      <svg width="18" height="5" viewBox="0 0 18 5"><circle cx="2.5" cy="2.5" r="2" fill={KE.ink2}/><circle cx="9" cy="2.5" r="2" fill={KE.ink2}/><circle cx="15.5" cy="2.5" r="2" fill={KE.ink2}/></svg>
    </IconBtn>
  );

  return (
    <Screen>
      <TopBar onBack title="Thread" action={overflow}/>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {/* header */}
        <div style={{ padding: "16px 18px 0" }}>
          <div style={{ display: "flex", gap: 12, marginBottom: 10 }}>
            {t.pinned && <PinBadge/>}
            {t.locked && <LockBadge/>}
          </div>
          <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 21, lineHeight: 1.25, color: KE.ink, letterSpacing: -0.5, textWrap: "pretty" }}>{t.title}</div>

          <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 12 }}>
            <Avatar src={t.author.avatar} size={30} verified={t.author.verified}/>
            <div>
              <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 13, color: KE.ink }}>@{t.author.username}</span>
                {t.author.verified && <VerifiedDot size={12}/>}
              </div>
              <div style={{ fontFamily: FB, fontSize: 11, color: KE.mute, marginTop: 1 }}>Posted · active {t.age} ago</div>
            </div>
          </div>

          <div style={{ fontFamily: FB, fontSize: 14, lineHeight: 1.6, color: KE.ink2, marginTop: 14 }}>{t.body}</div>

          {/* tag chips */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: 7, marginTop: 14 }}>
            {t.brand && <TagChip label={t.brand} variant="car"/>}
            {t.model && <TagChip label={t.model} variant="car"/>}
            {t.topics.map(tp => <TagChip key={tp} label={tp} variant="topic"/>)}
          </div>
        </div>

        {/* action bar */}
        <div style={{
          display: "flex", alignItems: "center", gap: 4, margin: "16px 18px 0", padding: "10px 6px",
          borderTop: `1px solid ${KE.line}`, borderBottom: `1px solid ${KE.line}`,
        }}>
          <ActBtn label={fmt(t.likes)} active
            icon={(c) => <svg width="20" height="20" viewBox="0 0 24 24" fill={KE.accent}><path d="M12 21s-7.5-4.8-10-9.2A5.4 5.4 0 0112 4.3a5.4 5.4 0 0110 7.5C19.5 16.2 12 21 12 21z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/></svg>}/>
          <ActBtn label={fmt(t.replies)}
            icon={(c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>}/>
          <ActBtn label="Save"
            icon={(c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v16l-6-4-6 4V4z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>}/>
          <ActBtn label="Share"
            icon={(c) => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 12v7a1 1 0 001 1h14a1 1 0 001-1v-7" stroke={c} strokeWidth="2" strokeLinecap="round"/><path d="M12 15V3m0 0L8 7m4-4l4 4" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}/>
        </div>

        {/* replies */}
        <div style={{ padding: "14px 18px 20px" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 4 }}>
            <Label>{t.replies} replies</Label>
            <SortControl value="Hot"/>
          </div>
          {tree.map(n => <ReplyNode key={n.id} node={n}/>)}
        </div>
      </div>

      {/* composer / locked notice */}
      {locked ? (
        <div style={{
          flexShrink: 0, background: KE.bgSoft, borderTop: `1px solid ${KE.line}`,
          padding: "16px 18px 30px", display: "flex", alignItems: "center", gap: 10, justifyContent: "center",
        }}>
          <LockBadge/>
          <span style={{ fontFamily: FB, fontSize: 12.5, color: KE.mute }}>This thread is locked — replies are closed.</span>
        </div>
      ) : (
        <div style={{
          flexShrink: 0, background: KE.surface, borderTop: `1px solid ${KE.line}`,
          padding: "12px 16px 28px", display: "flex", alignItems: "center", gap: 10,
        }}>
          <Avatar src="assets/avatar.jpg" size={32}/>
          <div style={{
            flex: 1, height: 42, borderRadius: 999, background: KE.bg, border: `1px solid ${KE.line}`,
            display: "flex", alignItems: "center", padding: "0 16px",
            fontFamily: FB, fontSize: 13, color: KE.mute,
          }}>Add a reply…</div>
          <button style={{
            width: 42, height: 42, borderRadius: 999, border: "none", background: KE.accent, cursor: "pointer",
            display: "grid", placeItems: "center", flexShrink: 0,
          }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M4 12h15m0 0l-6-6m6 6l-6 6" stroke={KE.onAccent} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
        </div>
      )}
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// CREATE THREAD
// ═══════════════════════════════════════════════════════════
function CreateThreadScreen() {
  const CMP = window.FORUM_TOPICS_COMPONENT;
  const FMT = window.FORUM_TOPICS_FORMAT;
  const selected = ["DIY & tools", "Engine"];

  const field = (label, children) => (
    <div style={{ marginBottom: 18 }}>
      <Label style={{ marginBottom: 8, display: "block" }}>{label}</Label>
      {children}
    </div>
  );

  const postBtn = (
    <button style={{
      height: 34, padding: "0 16px", borderRadius: 999, border: "none", cursor: "pointer",
      background: KE.accent, color: KE.onAccent, fontFamily: FD, fontWeight: 700, fontSize: 12, letterSpacing: 0.4,
    }}>Post</button>
  );

  return (
    <Screen>
      <TopBar onBack title="New thread" action={postBtn}/>
      <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "18px 18px 24px" }}>
        {/* title */}
        <div style={{
          fontFamily: FD, fontWeight: 700, fontSize: 18, color: KE.ink, letterSpacing: -0.3,
          paddingBottom: 12, borderBottom: `1px solid ${KE.line}`,
        }}>Best coilover setup for daily + track?</div>

        {/* body */}
        <div style={{
          fontFamily: FB, fontSize: 14, lineHeight: 1.55, color: KE.ink2, marginTop: 12, marginBottom: 22,
        }}>Running stock adaptive right now, torn between KW V3 and MCS 2-way<span style={{
          display: "inline-block", width: 1.5, height: 17, background: KE.accent, verticalAlign: -3, marginLeft: 1,
        }}/></div>

        {/* car tag — autocomplete */}
        {field("Tag a car", (
          <div>
            {/* garage prefill */}
            <div style={{ display: "flex", gap: 8, marginBottom: 10 }}>
              <span style={{
                display: "inline-flex", alignItems: "center", gap: 6, cursor: "pointer",
                background: KE.accentWash, border: `1px solid ${KE.accentSoft}`, borderRadius: 10, padding: "7px 11px",
              }}>
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M3 13l2-5a3 3 0 013-2h8a3 3 0 013 2l2 5v4a1 1 0 01-1 1H4a1 1 0 01-1-1v-4z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/></svg>
                <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 11.5, color: KE.accent }}>From your garage · BMW M4</span>
              </span>
            </div>
            {/* search field with dropdown */}
            <div style={{
              height: 46, borderRadius: 12, background: KE.surface, border: `1px solid ${KE.ink}`,
              display: "flex", alignItems: "center", padding: "0 14px", gap: 10,
            }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="7" stroke={KE.mute} strokeWidth="2"/><path d="M20 20l-3.5-3.5" stroke={KE.mute} strokeWidth="2" strokeLinecap="round"/></svg>
              <span style={{ fontFamily: FB, fontSize: 14, color: KE.ink }}>m4<span style={{ display: "inline-block", width: 1.5, height: 16, background: KE.accent, verticalAlign: -3 }}/></span>
            </div>
            <div style={{
              marginTop: 6, background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 12, overflow: "hidden",
            }}>
              {[["BMW M4", "BMW"], ["BMW M4 CS", "BMW"], ["BMW M4 GTS", "BMW"]].map((r, i) => (
                <div key={r[0]} style={{
                  display: "flex", alignItems: "center", justifyContent: "space-between", padding: "11px 14px",
                  borderTop: i ? `1px solid ${KE.line2}` : "none", cursor: "pointer",
                  background: i === 0 ? KE.bgSoft : "transparent",
                }}>
                  <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 13.5, color: KE.ink }}>{r[0]}</span>
                  <span style={{ fontFamily: FB, fontSize: 11, color: KE.mute }}>{r[1]}</span>
                </div>
              ))}
            </div>
            <div style={{ fontFamily: FB, fontSize: 11, color: KE.mute, marginTop: 8 }}>Brand is set automatically from the model. Leave empty for a general thread.</div>
          </div>
        ))}

        {/* topics multi-select */}
        {field("Topics", (
          <div>
            <div style={{ fontFamily: FB, fontSize: 10.5, color: KE.muteSoft, textTransform: "uppercase", letterSpacing: 1, marginBottom: 8 }}>Component</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 14 }}>
              {CMP.map(t => {
                const on = selected.includes(t.name);
                return <RefineChip key={t.name} label={t.name} selected={on}/>;
              })}
            </div>
            <div style={{ fontFamily: FB, fontSize: 10.5, color: KE.muteSoft, textTransform: "uppercase", letterSpacing: 1, marginBottom: 8 }}>Format</div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
              {FMT.map(t => {
                const on = selected.includes(t.name);
                return <RefineChip key={t.name} label={t.name} selected={on}/>;
              })}
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// SAVE-SHORTCUT SHEET (over dimmed model hub)
// ═══════════════════════════════════════════════════════════
function SaveShortcutScreen() {
  return (
    <div style={{ position: "relative", width: 390, height: 844 }}>
      {/* dimmed backdrop */}
      <div style={{ position: "absolute", inset: 0 }}><window.ModelHubScreen/></div>
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,10,10,0.4)" }}/>

      {/* sheet */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0,
        background: KE.surface, borderRadius: "24px 24px 0 0", padding: "12px 20px 30px",
        boxShadow: "0 -10px 40px rgba(0,0,0,0.18)",
      }}>
        <div style={{ width: 40, height: 4, borderRadius: 999, background: KE.line, margin: "0 auto 18px" }}/>
        <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 19, color: KE.ink, letterSpacing: -0.4 }}>Save shortcut</div>
        <div style={{ fontFamily: FB, fontSize: 12.5, color: KE.mute, marginTop: 4, marginBottom: 18 }}>Pin this filter to your paddock for one-tap access.</div>

        {/* filter preview */}
        <div style={{ display: "flex", gap: 7, marginBottom: 18 }}>
          <TagChip label="BMW" variant="car"/>
          <TagChip label="M4" variant="car"/>
          <TagChip label="Tuning" variant="topic"/>
        </div>

        {/* name field */}
        <Label style={{ marginBottom: 8, display: "block" }}>Name</Label>
        <div style={{
          height: 48, borderRadius: 12, background: KE.bg, border: `1px solid ${KE.ink}`,
          display: "flex", alignItems: "center", padding: "0 14px", marginBottom: 16,
        }}>
          <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 15, color: KE.ink }}>M4 · Tuning</span>
          <span style={{ display: "inline-block", width: 1.5, height: 18, background: KE.accent, marginLeft: 2 }}/>
        </div>

        {/* notify toggle */}
        <div style={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          padding: "14px 0", borderTop: `1px solid ${KE.line}`, borderBottom: `1px solid ${KE.line}`, marginBottom: 20,
        }}>
          <div>
            <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 14, color: KE.ink }}>Notify me</div>
            <div style={{ fontFamily: FB, fontSize: 11.5, color: KE.mute, marginTop: 1 }}>New hot threads in this filter</div>
          </div>
          <div style={{ width: 46, height: 28, borderRadius: 999, background: KE.accent, padding: 3, display: "flex", justifyContent: "flex-end" }}>
            <div style={{ width: 22, height: 22, borderRadius: 999, background: "#fff", boxShadow: "0 1px 3px rgba(0,0,0,0.2)" }}/>
          </div>
        </div>

        {/* actions */}
        <div style={{ display: "flex", gap: 10 }}>
          <PrimaryBtn kind="neutral" full>Cancel</PrimaryBtn>
          <PrimaryBtn kind="accent" full>Save shortcut</PrimaryBtn>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// LONG-PRESS MENU on a tag chip → "Save as shortcut"
// ═══════════════════════════════════════════════════════════
function LongPressScreen() {
  return (
    <div style={{ position: "relative", width: 390, height: 844 }}>
      <div style={{ position: "absolute", inset: 0 }}><window.TopicHubScreen/></div>
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,10,10,0.35)" }}/>

      {/* lifted chip + popover near a card */}
      <div style={{ position: "absolute", top: 300, left: 34 }}>
        <div style={{ transform: "scale(1.08)", transformOrigin: "left center", filter: "drop-shadow(0 8px 20px rgba(0,0,0,0.25))" }}>
          <TagChip label="BMW" variant="car"/>
        </div>
        <div style={{
          marginTop: 12, background: KE.surface, borderRadius: 14, overflow: "hidden", width: 220,
          boxShadow: "0 12px 40px rgba(0,0,0,0.22)",
        }}>
          {[
            ["Save as shortcut", KE.accent, true],
            ["Open BMW hub", KE.ink, false],
            ["Mute this car", KE.ink2, false],
          ].map((r, i) => (
            <div key={r[0]} style={{
              display: "flex", alignItems: "center", gap: 11, padding: "13px 15px",
              borderTop: i ? `1px solid ${KE.line2}` : "none", cursor: "pointer",
            }}>
              <span style={{
                width: 20, height: 20, borderRadius: 6, display: "grid", placeItems: "center",
              }}>
                {r[2] ? (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v16l-6-4-6 4V4z" stroke={r[1]} strokeWidth="2" strokeLinejoin="round"/></svg>
                ) : (
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={r[1]} strokeWidth="2"/></svg>
                )}
              </span>
              <span style={{ fontFamily: FD, fontWeight: 700, fontSize: 13.5, color: r[1] }}>{r[0]}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  ThreadDetailScreen, CreateThreadScreen, SaveShortcutScreen, LongPressScreen,
});
