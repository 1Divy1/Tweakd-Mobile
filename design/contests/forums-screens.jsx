// forums-screens.jsx — Kinetic Edge · Forums
// Screen compositions built from forums-ui primitives.

const KE = window.KE;
const FD = window.KE_FONT_DISPLAY;
const FB = window.KE_FONT_BODY;
const fmt = window.FR_fmt;

const {
  FR_Label: Label, FR_Avatar: Avatar, FR_VerifiedDot: VerifiedDot, FR_BrandMark: BrandMark,
  FR_TagChip: TagChip, FR_RefineChip: RefineChip, FR_SortControl: SortControl,
  FR_PinBadge: PinBadge, FR_LockBadge: LockBadge, FR_Metric: Metric,
  FR_ThreadCard: ThreadCard, FR_ShortcutCard: ShortcutCard, FR_AddShortcutCard: AddShortcutCard,
  FR_BrandTile: BrandTile, FR_TopicTile: TopicTile,
  FR_TopBar: TopBar, FR_IconBtn: IconBtn, FR_TabBar: TabBar,
  FR_SkeletonCard: SkeletonCard, FR_SectionHead: SectionHead, FR_Screen: Screen,
} = window;

const T   = window.FORUM_THREADS;
const byId = (id) => T.find(x => x.id === id);
const BRANDS = window.FORUM_BRANDS;

// scrollbar-free body helper
const bodyScroll = {
  flex: 1, minHeight: 0, overflowY: "auto",
};

// create-icon button for the top bar
function CreateBtn() {
  return (
    <IconBtn>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
        <path d="M12 5v14M5 12h14" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round"/>
      </svg>
    </IconBtn>
  );
}
function BellBtn({ on = false }) {
  return (
    <IconBtn>
      <svg width="16" height="16" viewBox="0 0 24 24" fill={on ? KE.accent : "none"}>
        <path d="M6 9a6 6 0 1112 0c0 5 2 6 2 6H4s2-1 2-6z" stroke={on ? KE.accent : KE.ink} strokeWidth="2" strokeLinejoin="round"/>
        <path d="M10 20a2 2 0 004 0" stroke={on ? KE.accent : KE.ink} strokeWidth="2" strokeLinecap="round"/>
      </svg>
    </IconBtn>
  );
}

// Big pill CTA (accent primary or neutral)
function PrimaryBtn({ children, kind = "accent", full = false, icon, onClick }) {
  const accent = kind === "accent";
  return (
    <button onClick={onClick} style={{
      width: full ? "100%" : "auto", height: 48, borderRadius: 14, cursor: "pointer",
      border: accent ? "none" : `1px solid ${KE.line}`,
      background: accent ? KE.accent : KE.surface,
      color: accent ? KE.onAccent : KE.ink,
      display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
      fontFamily: FD, fontWeight: 700, fontSize: 13.5, letterSpacing: 0.3, padding: "0 20px",
    }}>{icon}{children}</button>
  );
}

// ═══════════════════════════════════════════════════════════
// 1 · LANDING — populated
// ═══════════════════════════════════════════════════════════
function LandingScreen() {
  const S = window.FORUM_SHORTCUTS;
  return (
    <Screen>
      <TopBar title="Forums" subtitle="Your paddock" action={<CreateBtn/>}/>
      <div style={{ ...bodyScroll, padding: "18px 0 20px" }}>
        {/* shortcuts */}
        <div style={{ padding: "0 18px" }}>
          <SectionHead right={<Label color={KE.ink} style={{ cursor: "pointer" }}>Edit</Label>}>Your shortcuts</SectionHead>
        </div>
        <div style={{
          display: "flex", gap: 10, overflowX: "auto", padding: "0 18px 4px",
        }}>
          {S.map(s => <ShortcutCard key={s.id} s={s}/>)}
          <AddShortcutCard/>
        </div>

        {/* hot in your forums */}
        <div style={{ padding: "22px 18px 0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
            <Label>Hot in your forums</Label>
            <SortControl value="Hot"/>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <ThreadCard t={byId("t2")} compact/>
            <ThreadCard t={byId("t3")} compact/>
            <ThreadCard t={byId("t10")} compact/>
          </div>
        </div>

        {/* browse entry */}
        <div style={{ padding: "24px 18px 0" }}>
          <Label style={{ marginBottom: 12, display: "block" }}>Browse everything</Label>
          <div style={{ display: "flex", gap: 12 }}>
            {[
              { t: "By car", d: "Brand → model", ic: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M3 13l2-5a3 3 0 013-2h8a3 3 0 013 2l2 5v5a1 1 0 01-1 1h-2a1 1 0 01-1-1v-1H7v1a1 1 0 01-1 1H4a1 1 0 01-1-1v-5z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/><circle cx="7.5" cy="14.5" r="1.2" fill={KE.ink}/><circle cx="16.5" cy="14.5" r="1.2" fill={KE.ink}/></svg> },
              { t: "By topic", d: "Across all cars", ic: <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="3" y="4" width="7" height="7" rx="1.6" stroke={KE.ink} strokeWidth="2"/><rect x="14" y="4" width="7" height="7" rx="1.6" stroke={KE.ink} strokeWidth="2"/><rect x="3" y="13" width="7" height="7" rx="1.6" stroke={KE.ink} strokeWidth="2"/><rect x="14" y="13" width="7" height="7" rx="1.6" stroke={KE.ink} strokeWidth="2"/></svg> },
            ].map(b => (
              <div key={b.t} style={{
                flex: 1, background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 16,
                padding: "16px 14px", cursor: "pointer",
              }}>
                <div style={{ marginBottom: 12 }}>{b.ic}</div>
                <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 15, color: KE.ink, letterSpacing: -0.2 }}>{b.t}</div>
                <div style={{ fontFamily: FB, fontSize: 11.5, color: KE.mute, marginTop: 2 }}>{b.d}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <TabBar active="FORUMS"/>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// 1b · LANDING — empty (day one, zero shortcuts)
// ═══════════════════════════════════════════════════════════
function LandingEmptyScreen() {
  const HUBS = window.FORUM_POPULAR_HUBS;
  return (
    <Screen>
      <TopBar title="Forums" subtitle="Your paddock" action={<CreateBtn/>}/>
      <div style={{ ...bodyScroll, padding: "18px 18px 20px" }}>
        {/* hero */}
        <div style={{
          background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 20,
          padding: "26px 22px", textAlign: "center",
        }}>
          <div style={{
            width: 58, height: 58, borderRadius: 18, background: KE.bg, border: `1px solid ${KE.line}`,
            display: "grid", placeItems: "center", margin: "0 auto 14px",
          }}>
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
              <path d="M9 4h6l-1 6 3 3v2H7v-2l3-3-1-6z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/>
              <path d="M12 15v5" stroke={KE.accent} strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </div>
          <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 20, color: KE.ink, letterSpacing: -0.4 }}>Pin the forums you live in</div>
          <div style={{ fontFamily: FB, fontSize: 13, color: KE.mute, lineHeight: 1.5, marginTop: 8, maxWidth: 260, marginInline: "auto" }}>
            Shortcuts are saved filters — a car, a topic, or both. Pin a few and they land right here.
          </div>
        </div>

        {/* popular hubs */}
        <div style={{ marginTop: 24 }}>
          <Label style={{ marginBottom: 12, display: "block" }}>Popular hubs to start with</Label>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 9 }}>
            {HUBS.map(h => (
              <div key={h.name} style={{
                display: "inline-flex", alignItems: "center", gap: 9, cursor: "pointer",
                background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 999,
                padding: "8px 8px 8px 12px",
              }}>
                <div>
                  <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 12.5, color: KE.ink }}>{h.name}</div>
                  <div style={{ fontFamily: FB, fontSize: 10, color: KE.mute }}>{h.meta}</div>
                </div>
                <span style={{
                  width: 24, height: 24, borderRadius: 999, background: KE.bg, border: `1px solid ${KE.line}`,
                  display: "grid", placeItems: "center",
                }}>
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={KE.ink} strokeWidth="2.4" strokeLinecap="round"/></svg>
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* create CTA */}
        <div style={{
          marginTop: 24, background: KE.accentWash, border: `1px solid ${KE.accentSoft}`,
          borderRadius: 18, padding: "18px 18px 20px",
        }}>
          <div style={{ fontFamily: FD, fontWeight: 700, fontSize: 15, color: KE.ink }}>Got something to say?</div>
          <div style={{ fontFamily: FB, fontSize: 12.5, color: KE.ink2, marginTop: 4, marginBottom: 14 }}>
            Every great forum started with one thread. Make it yours.
          </div>
          <PrimaryBtn full icon={
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={KE.onAccent} strokeWidth="2.4" strokeLinecap="round"/></svg>
          }>Start the first thread</PrimaryBtn>
        </div>
      </div>
      <TabBar active="FORUMS"/>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// 2 · BROWSE — segmented By car / By topic
// ═══════════════════════════════════════════════════════════
function Segmented({ value }) {
  return (
    <div style={{
      display: "flex", background: KE.bgSoft, border: `1px solid ${KE.line}`,
      borderRadius: 12, padding: 3, margin: "14px 18px 4px",
    }}>
      {["By car", "By topic"].map(o => {
        const on = o === value;
        return (
          <div key={o} style={{
            flex: 1, textAlign: "center", padding: "9px 0", borderRadius: 9, cursor: "pointer",
            background: on ? KE.surface : "transparent",
            boxShadow: on ? "0 1px 2px rgba(0,0,0,0.06)" : "none",
            color: on ? KE.ink : KE.mute,
            fontFamily: FD, fontWeight: 700, fontSize: 12.5, letterSpacing: 0.3,
          }}>{o}</div>
        );
      })}
    </div>
  );
}

function BrowseCarScreen() {
  return (
    <Screen>
      <TopBar title="Browse" onBack/>
      <Segmented value="By car"/>
      <div style={{ ...bodyScroll, padding: "14px 18px 20px" }}>
        <Label style={{ marginBottom: 12, display: "block" }}>{BRANDS.length} brands</Label>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {BRANDS.map(b => <BrandTile key={b.name} b={b}/>)}
        </div>
      </div>
    </Screen>
  );
}

function BrowseTopicScreen() {
  const CMP = window.FORUM_TOPICS_COMPONENT;
  const FMT = window.FORUM_TOPICS_FORMAT;
  return (
    <Screen>
      <TopBar title="Browse" onBack/>
      <Segmented value="By topic"/>
      <div style={{ ...bodyScroll, padding: "16px 18px 20px" }}>
        <Label style={{ marginBottom: 12, display: "block" }}>By component</Label>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
          {CMP.map(t => <TopicTile key={t.name} topic={t}/>)}
        </div>
        <div style={{ height: 1, background: KE.line, margin: "20px 0" }}/>
        <Label style={{ marginBottom: 12, display: "block" }}>By format</Label>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
          {FMT.map(t => <TopicTile key={t.name} topic={t}/>)}
        </div>
      </div>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// 3 · BRAND HUB — BMW
// ═══════════════════════════════════════════════════════════
function BrandHubScreen() {
  const bmw = BRANDS.find(b => b.name === "BMW");
  const threads = ["t1", "t3", "t2", "t4"].map(byId);
  return (
    <Screen>
      <TopBar onBack title="BMW" subtitle={`${fmt(bmw.threads)} threads`} action={<BellBtn/>}/>
      <div style={{ ...bodyScroll, padding: "16px 0 20px" }}>
        {/* model band */}
        <div style={{ padding: "0 18px" }}><Label style={{ marginBottom: 11, display: "block" }}>Models</Label></div>
        <div style={{ display: "flex", gap: 9, overflowX: "auto", padding: "0 18px 4px" }}>
          {bmw.models.map((m, i) => (
            <div key={m} style={{
              flexShrink: 0, background: i === 1 ? KE.ink : KE.surface, border: `1px solid ${i === 1 ? KE.ink : KE.line}`,
              color: i === 1 ? KE.surface : KE.ink, borderRadius: 12, padding: "10px 15px", cursor: "pointer",
              fontFamily: FD, fontWeight: 700, fontSize: 14, letterSpacing: -0.2,
            }}>{m}</div>
          ))}
        </div>

        {/* refine chips */}
        <div style={{ padding: "18px 18px 0" }}><Label style={{ marginBottom: 10, display: "block" }}>Refine by topic</Label></div>
        <div style={{ display: "flex", gap: 8, overflowX: "auto", padding: "0 18px 2px" }}>
          {["Tuning", "Suspension", "Engine", "Exhaust", "DIY & tools", "Help"].map((c, i) => (
            <RefineChip key={c} label={c} selected={false}/>
          ))}
        </div>

        {/* threads */}
        <div style={{ padding: "20px 18px 0" }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
            <Label>Hot in BMW</Label>
            <SortControl value="Hot"/>
          </div>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {threads.map(t => <ThreadCard key={t.id} t={t} hideBrand compact/>)}
          </div>
        </div>
      </div>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// 4 · MODEL HUB — M4 (primary destination)
// ═══════════════════════════════════════════════════════════
function ModelHubScreen({ loading = false }) {
  const threads = ["t1", "t2", "t3", "t4"].map(byId);
  return (
    <Screen>
      <TopBar onBack title="M4" subtitle="BMW · 1.2k threads" action={<BellBtn/>}/>
      <div style={{ ...bodyScroll, padding: "16px 18px 20px" }}>
        {/* save shortcut */}
        <PrimaryBtn full icon={
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v16l-6-4-6 4V4z" stroke={KE.onAccent} strokeWidth="2" strokeLinejoin="round"/></svg>
        }>Save shortcut</PrimaryBtn>

        {/* refine chips */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", margin: "16px 0 2px" }}>
          {["All", "Tuning", "Suspension", "Engine", "Exhaust", "DIY & tools"].map((c, i) => (
            <RefineChip key={c} label={c} selected={i === 0}/>
          ))}
        </div>

        {/* sort + count */}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", margin: "18px 0 12px" }}>
          <Label>{loading ? "Loading…" : "142 threads"}</Label>
          <SortControl value="Hot"/>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {loading
            ? [0, 1, 2, 3].map(i => <SkeletonCard key={i}/>)
            : threads.map(t => <ThreadCard key={t.id} t={t} hideBrand hideModel/>)}
        </div>
      </div>
    </Screen>
  );
}

// ═══════════════════════════════════════════════════════════
// 5 · TOPIC HUB — Tuning (mirror, inverted)
// ═══════════════════════════════════════════════════════════
function TopicHubScreen() {
  const threads = ["t3", "t2", "t10", "t6", "t5", "t12"].map(byId);
  return (
    <Screen>
      <TopBar onBack title="Tuning" subtitle="4.1k threads · all cars" action={<BellBtn/>}/>
      <div style={{ ...bodyScroll, padding: "16px 18px 20px" }}>
        <PrimaryBtn full icon={
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v16l-6-4-6 4V4z" stroke={KE.onAccent} strokeWidth="2" strokeLinejoin="round"/></svg>
        }>Save shortcut</PrimaryBtn>

        {/* brand/model refine chips */}
        <div style={{ margin: "16px 0 2px" }}>
          <Label style={{ marginBottom: 10, display: "block" }}>Refine by car</Label>
          <div style={{ display: "flex", gap: 8, overflowX: "auto" }}>
            {["BMW", "Porsche", "Toyota", "Nissan", "Honda", "Mazda"].map((c, i) => (
              <RefineChip key={c} label={c} selected={false}/>
            ))}
          </div>
        </div>

        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", margin: "18px 0 12px" }}>
          <Label>Hot threads</Label>
          <SortControl value="Hot"/>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {threads.map(t => <ThreadCard key={t.id} t={t} hideTopic="Tuning" compact/>)}
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, {
  FR_PrimaryBtn: PrimaryBtn,
  LandingScreen, LandingEmptyScreen,
  BrowseCarScreen, BrowseTopicScreen,
  BrandHubScreen, ModelHubScreen, TopicHubScreen,
});
