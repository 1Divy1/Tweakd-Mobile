// Profile v2 — IG-informed compact header, garage-first, badge highlights.
// Grounded in Tweakd-Mobile repo: app_colors.dart palette, bottom nav shape.
const { useState: useStateV2 } = React;
const KEv = window.KE;
const F_DISP = window.KE_FONT_DISPLAY;
const F_BODY = window.KE_FONT_BODY;

// ── icons (stroke, simple) ──
const I = {
  back: (c)=><svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M15 6l-6 6 6 6" stroke={c} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  dots: (c)=><svg width="16" height="4" viewBox="0 0 16 4"><circle cx="2" cy="2" r="1.5" fill={c}/><circle cx="8" cy="2" r="1.5" fill={c}/><circle cx="14" cy="2" r="1.5" fill={c}/></svg>,
  gear: (c)=><svg width="17" height="17" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3" stroke={c} strokeWidth="2"/><path d="M19.4 15a1.7 1.7 0 00.3 1.9l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.9-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1-1.6 1.7 1.7 0 00-1.9.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.9 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1a1.7 1.7 0 001.6-1 1.7 1.7 0 00-.3-1.9l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.9.3h.1a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5h.1a1.7 1.7 0 001.9-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.9v.1a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  check: (c)=><svg width="10" height="10" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke={c} strokeWidth="4" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  plus: (c)=><svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M12 5v14m-7-7h14" stroke={c} strokeWidth="2.5" strokeLinecap="round"/></svg>,
  msg: (c)=><svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M21 11.5a8.5 8.5 0 01-12.2 7.6L3 21l1.9-5.8A8.5 8.5 0 1121 11.5z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  pencil: (c)=><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M17 3l4 4L8 20l-5 1 1-5L17 3z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  share: (c)=><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M12 3v12m0-12L8 7m4-4l4 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  chevR: (c)=><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round"/></svg>,
  trophy: (c)=><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M6 4h12v3a6 6 0 01-12 0V4zm6 9v4m-3 3h6m-9-13H3v2a3 3 0 003 3m12-5h3v2a3 3 0 01-3 3" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  flag: (c)=><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M5 21V4m0 0h13l-2.5 4L18 12H5" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  wrench: (c)=><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M14.7 6.3a4.5 4.5 0 00-5.9 5.9L3 18v3h3l5.8-5.8a4.5 4.5 0 005.9-5.9L14.5 12l-2.5-2.5 2.7-3.2z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  medal: (c)=><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="15" r="5" stroke={c} strokeWidth="2"/><path d="M8.5 10.5L5.5 3h4l2.5 5.5L14.5 3h4l-3 7.5" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  star: (c)=><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M12 3l2.7 5.6 6.3.8-4.6 4.3 1.2 6.1L12 16.9l-5.6 2.9 1.2-6.1L3 9.4l6.3-.8L12 3z" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  grid: (c)=><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="18" height="18" rx="2" stroke={c} strokeWidth="2"/><path d="M9 3v18M15 3v18M3 9h18M3 15h18" stroke={c} strokeWidth="2"/></svg>,
  garage: (c)=><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M3 10l9-6 9 6v10H3V10z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><path d="M7 20v-6h10v6M7 16h10" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  award: (c)=><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="9" r="6" stroke={c} strokeWidth="2"/><path d="M8.5 14L7 22l5-3 5 3-1.5-8" stroke={c} strokeWidth="2" strokeLinejoin="round"/></svg>,
  tag: (c)=><svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M11.5 3H19a2 2 0 012 2v7.5a2 2 0 01-.6 1.4l-8 8a2 2 0 01-2.8 0l-6.5-6.5a2 2 0 010-2.8l8-8A2 2 0 0111.5 3z" stroke={c} strokeWidth="2" strokeLinejoin="round"/><circle cx="15.5" cy="7.5" r="1.4" fill={c}/></svg>,
  carSm: (c)=><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M5 11l1.5-4.5A2 2 0 018.4 5h7.2a2 2 0 011.9 1.5L19 11m-14 0h14m-14 0a2 2 0 00-2 2v4h2m14-6a2 2 0 012 2v4h-2m-14 0v2h3v-2m11 0v2h-3v-2m3 0H7" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
};

// ── data ──
const BADGES_V2 = [
  { k:"pioneer", name:"Pioneer",     icon:"flag",   art:"assets/badges/pioneer-unlocked.svg", how:"Joined in the launch year",            date:"Mar 2026", rarity:"Founding" },
];

// ── badge art: real medallion artwork when unlocked, an image-slot placeholder when pending ──
function BadgeArt({ badge, size=58 }) {
  if (badge.art) return <img src={badge.art} width={size} height={size} style={{ width:size, height:size, display:"block", flexShrink:0 }}/>;
  return (
    <div style={{ width:size, height:size, borderRadius:999, flexShrink:0, border:`1.5px dashed ${KEv.line}`, background:`repeating-linear-gradient(45deg, ${KEv.bgSoft} 0 6px, ${KEv.surface} 6px 12px)` }}></div>
  );
}
const CARS_V2 = [
  { make:"BMW", model:"M5 CS", year:"2021", hp:627, tq:"553", mods:12, svc:4, image:"assets/car-m5.webp", fav:true, slug:"bmw-m5-cs-vlox" },
  { make:"Mercedes-AMG", model:"G63", year:"2023", hp:577, tq:"627", mods:6, svc:9, image:"assets/car-g63.jpg", slug:"amg-g63-vlox" },
  { make:"Audi", model:"RS Q8 · ABT", year:"2022", hp:641, tq:"627", mods:18, svc:7, image:"assets/car-rsq8.webp", slug:"audi-rsq8-abt-vlox" },
];
const POSTS_V2 = ["car-m5.webp","car-g63.jpg","car-rsq8.webp","car-g63.jpg","car-m5.webp","car-rsq8.webp","car-rsq8.webp","car-m5.webp","car-g63.jpg"].map((n,i)=>({ image:`assets/${n}`, count:[3,1,4,2,1,5,1,2,1][i] }));
const TAGS_V2 = [
  { by:"jdm_jules", what:"post comment", car:"BMW M5 CS", image:"assets/car-m5.webp", excerpt:"That frozen green in the moors is unreal", time:"1h" },
  { by:"torque_sasha", what:"post", car:"G63", image:"assets/car-g63.jpg", excerpt:"Blacked-out G at the marina meet.", time:"5h" },
  { by:"kenji_apex", what:"thread", car:"BMW M5 CS", image:"assets/car-m5.webp", excerpt:"Stage 2 dyno results — 712 whp on pump", time:"20h" },
  { by:"vroom_valeria", what:"post", car:"RS Q8", image:"assets/car-rsq8.webp", excerpt:"ABT kit looks right in the Alps.", time:"2d" },
];

// ── chrome ──
function TopBarV2({ own }) {
  return (
    <div style={{ height:52, padding:"0 14px", display:"flex", alignItems:"center", gap:10, background:KEv.bg, flexShrink:0 }}>
      <div style={{ width:36, height:36, borderRadius:999, display:"grid", placeItems:"center", background:own?"transparent":KEv.surface }}>{!own && I.back(KEv.ink)}</div>
      <div style={{ flex:1, fontFamily:F_DISP, fontWeight:700, fontSize:own?14:19, letterSpacing:-0.3, color:KEv.ink }}>{!own && "@marcus_vlox"}</div>
      <div style={{ width:36, height:36, borderRadius:999, display:"grid", placeItems:"center", background:KEv.surface }}>{own?I.gear(KEv.ink):I.dots(KEv.ink)}</div>
    </div>
  );
}

function BottomNavV2() {
  const items = [
    ["home", <svg key="h" width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M3 10.5L12 3l9 7.5V20a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1v-9.5z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg>],
    ["map", <svg key="m" width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M9 4l-6 2v14l6-2 6 2 6-2V4l-6 2-6-2zm0 0v14m6-12v14" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg>],
    ["forum", <svg key="f" width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M4 5h13a2 2 0 012 2v6a2 2 0 01-2 2H9l-4 3v-3H4a1 1 0 01-1-1V6a1 1 0 011-1z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/></svg>],
    ["megaphone", <svg key="g" width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M3 10v4a1 1 0 001 1h2l6 4V5L6 9H4a1 1 0 00-1 1zm13-1a4 4 0 010 6m2.5-9a8 8 0 010 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>],
    ["search", <svg key="s" width="24" height="24" viewBox="0 0 24 24" fill="none"><circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="2"/><path d="M20 20l-4-4" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg>],
    ["person", <svg key="p" width="24" height="24" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2"/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/></svg>],
  ];
  return (
    <div style={{ padding:"10px 6px 28px", background:KEv.surface, borderRadius:"28px 28px 0 0", boxShadow:"0 -4px 20px rgba(0,0,0,0.08)", display:"flex", justifyContent:"space-around", flexShrink:0 }}>
      {items.map(([k, icon]) => {
        const on = k === "person";
        return (
          <div key={k} style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:6, color:on?KEv.ink:KEv.muteSoft }}>
            {icon}
            <div style={{ width:18, height:3, borderRadius:2, background:on?KEv.ink:"transparent" }}></div>
          </div>
        );
      })}
    </div>
  );
}

// ── header ──
function StatV2({ n, label }) {
  return (
    <div style={{ display:"flex", flexDirection:"column", alignItems:"center", cursor:"pointer", minWidth:56 }}>
      <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:18, color:KEv.ink, letterSpacing:-0.4 }}>{n}</div>
      <div style={{ fontFamily:F_BODY, fontSize:12, fontWeight:600, color:KEv.mute, marginTop:1 }}>{label}</div>
    </div>
  );
}

function BtnV2({ label, icon, primary, grow=1, onClick }) {
  return (
    <button onClick={onClick} style={{ flex:grow, height:40, borderRadius:10, border:primary?"none":`1px solid ${KEv.line}`, background:primary?KEv.accent:KEv.surface, color:primary?KEv.onAccent:KEv.ink, display:"flex", alignItems:"center", justifyContent:"center", gap:7, cursor:"pointer", fontFamily:F_BODY, fontWeight:700, fontSize:13.5, letterSpacing:0.1 }}>
      {icon}{label}
    </button>
  );
}

function HeaderV2({ own, onShareProfile, onOpenBadges, onOpenBadge }) {
  return (
    <div style={{ padding:"6px 16px 0" }}>
      {/* avatar + name + stats */}
      <div style={{ display:"flex", alignItems:"center", gap:18 }}>
        <div style={{ position:"relative", width:84, height:84, flexShrink:0 }}>
          <div style={{ width:"100%", height:"100%", borderRadius:999, padding:3, background:KEv.surface, border:`1px solid ${KEv.line}` }}>
            <img src="assets/avatar.jpg" style={{ width:"100%", height:"100%", borderRadius:999, objectFit:"cover", display:"block" }}/>
          </div>
          <div style={{ position:"absolute", right:0, bottom:2, width:22, height:22, borderRadius:999, background:KEv.accent, display:"grid", placeItems:"center", border:`2.5px solid ${KEv.bg}` }}>{I.check(KEv.onAccent)}</div>
        </div>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:19, color:KEv.ink, letterSpacing:-0.4, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>Marcus Vlox</div>
          <div style={{ marginTop:8, display:"flex", justifyContent:"space-between", paddingRight:8 }}>
            <StatV2 n="3,240" label="reputation"/>
            <StatV2 n="1,500" label="followers"/>
            <StatV2 n="53" label="following"/>
          </div>
        </div>
      </div>

      {/* bio — left-aligned, IG-style */}
      <div style={{ marginTop:10, fontFamily:F_BODY, fontSize:13, lineHeight:1.5, color:KEv.ink2, textWrap:"pretty" }}>
        Apex hunter from the principality. Cold starts, mountain switchbacks, and a soft spot for naturally aspirated straight-sixes.
      </div>

      {/* actions */}
      <div style={{ marginTop:14, display:"flex", gap:8 }}>
        {own ? (<React.Fragment>
          <BtnV2 label="Edit profile" icon={I.pencil(KEv.ink)}/>
          <BtnV2 label="Share profile" icon={I.share(KEv.ink)} onClick={onShareProfile}/>
        </React.Fragment>) : (<React.Fragment>
          <BtnV2 label="Follow" icon={I.plus(KEv.onAccent)} primary/>
          <BtnV2 label="Message" icon={I.msg(KEv.ink)}/>
        </React.Fragment>)}
      </div>

      {/* badge highlights — real unlocked artwork, placeholders pending the rest */}
      <div style={{ marginTop:18, display:"flex", justifyContent:"flex-start", alignItems:"flex-start" }}>
        {BADGES_V2.slice(0,4).map((b)=>(
          <div key={b.k} onClick={()=>onOpenBadge(b)} style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:7, width:76, cursor:"pointer" }}>
            <BadgeArt badge={b} size={92}/>
            <span style={{ fontFamily:F_DISP, fontSize:9.5, fontWeight:700, letterSpacing:0.5, textTransform:"uppercase", color:KEv.ink2, whiteSpace:"nowrap" }}>{b.name}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── tabs ──
function TabsV2({ tab, onChange }) {
  const items = [
    { k:"garage", label:"Garage", icon:I.garage },
    { k:"posts", label:"Posts", icon:I.grid },
    { k:"tags", label:"Tags", icon:I.tag },
  ];
  return (
    <div style={{ display:"flex", marginTop:16, borderBottom:`1px solid ${KEv.line}`, background:KEv.bg, position:"sticky", top:0, zIndex:3 }}>
      {items.map((it)=>{
        const on = tab===it.k; const c = on?KEv.ink:KEv.muteSoft;
        return (
          <button key={it.k} onClick={()=>onChange(it.k)} style={{ flex:1, height:46, border:"none", background:"transparent", cursor:"pointer", position:"relative", display:"flex", alignItems:"center", justifyContent:"center", gap:6 }}>
            {it.icon(c)}
            <span style={{ fontFamily:F_BODY, fontWeight:700, fontSize:11.5, color:c }}>{it.label}</span>
            {on && <div style={{ position:"absolute", left:"22%", right:"22%", bottom:-1, height:2, background:KEv.ink }}></div>}
          </button>
        );
      })}
    </div>
  );
}

// ── sections ──
// Garage card — spec plate: 16:9 whole-car photo over a 3-up data plate.
function SpecCellV2({ v, u, label }) {
  return (
    <div style={{ whiteSpace:"nowrap" }}>
      <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:15, color:KEv.ink, letterSpacing:-0.3 }}>{v}<span style={{ fontSize:10, fontWeight:700, color:KEv.mute, marginLeft:2.5 }}>{u}</span></div>
      <div style={{ fontFamily:F_BODY, fontSize:8.5, fontWeight:700, letterSpacing:0.7, textTransform:"uppercase", color:KEv.muteSoft, marginTop:2 }}>{label}</div>
    </div>
  );
}

function GarageV2({ onShare }) {
  return (
    <div style={{ padding:16, display:"flex", flexDirection:"column", gap:14 }}>
      {CARS_V2.map((c,i)=>(
        <div key={i} style={{ borderRadius:16, background:KEv.surface, border:`1px solid ${KEv.line}`, overflow:"hidden", cursor:"pointer", flexShrink:0 }}>
          <div style={{ position:"relative", aspectRatio:"16 / 9", background:KEv.bgSoft }}>
            <img src={c.image} style={{ position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover" }}/>
            <button onClick={(e)=>{ e.stopPropagation(); onShare(c); }} style={{ position:"absolute", top:10, right:10, width:34, height:34, borderRadius:999, background:"rgba(10,10,10,0.45)", border:"none", display:"grid", placeItems:"center", cursor:"pointer" }}>
              {I.share("#fff")}
            </button>
          </div>
          <div style={{ padding:"12px 15px 13px" }}>
            <div style={{ display:"flex", alignItems:"center", justifyContent:"space-between", gap:10 }}>
              <div style={{ minWidth:0 }}>
                <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:17, color:KEv.ink, letterSpacing:-0.4, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>{c.make} {c.model}</div>
              </div>
              {I.chevR(KEv.muteSoft)}
            </div>
            <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", marginTop:12, paddingTop:11, borderTop:`1px solid ${KEv.line}` }}>
              {[[c.hp,"hp","Power"],[c.tq,"lb-ft","Torque"],[c.year,"","Year"]].map(([v,u,l],j)=>(
                <div key={l} style={{ borderLeft:j?`1px solid ${KEv.line}`:"none", paddingLeft:j?13:0 }}>
                  <SpecCellV2 v={v} u={u} label={l}/>
                </div>
              ))}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function PostsV2() {
  return (
    <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", gap:2, paddingTop:2 }}>
      {POSTS_V2.map((p,i)=>(
        <div key={i} style={{ position:"relative", aspectRatio:"1 / 1", background:KEv.bgSoft, cursor:"pointer" }}>
          <img src={p.image} style={{ position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover" }}/>
          {p.count>1 && (
            <div style={{ position:"absolute", top:6, right:6, width:20, height:20, borderRadius:6, background:"rgba(10,10,10,0.55)", display:"grid", placeItems:"center" }}>
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><rect x="7" y="3" width="14" height="14" rx="2.5" stroke="#fff" strokeWidth="2"/><path d="M4 7v12a2 2 0 002 2h12" stroke="#fff" strokeWidth="2" strokeLinecap="round"/></svg>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

function BadgesV2({ onOpenBadge }) {
  return (
    <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
      {BADGES_V2.map((b)=>(
        <div key={b.k} onClick={()=>onOpenBadge(b)} style={{ display:"flex", alignItems:"center", gap:14, padding:"13px 15px", borderRadius:14, background:KEv.surface, border:`1px solid ${KEv.line}`, cursor:"pointer" }}>
          <BadgeArt badge={b} size={50}/>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ display:"flex", alignItems:"center", gap:7 }}>
              <span style={{ fontFamily:F_DISP, fontWeight:700, fontSize:14.5, color:KEv.ink, letterSpacing:-0.2 }}>{b.name}</span>
              <span style={{ fontFamily:F_BODY, fontWeight:700, fontSize:8.5, letterSpacing:0.7, textTransform:"uppercase", color:KEv.mute, background:KEv.bgSoft, padding:"2.5px 6px", borderRadius:5 }}>{b.rarity}</span>
            </div>
            <div style={{ fontFamily:F_BODY, fontSize:12, color:KEv.mute, marginTop:3, lineHeight:1.4 }}>{b.how}</div>
          </div>
          <div style={{ fontFamily:F_BODY, fontSize:11, fontWeight:600, color:KEv.muteSoft, flexShrink:0 }}>{b.date}</div>
        </div>
      ))}
    </div>
  );
}

function TagsV2() {
  return (
    <div style={{ padding:16, display:"flex", flexDirection:"column", gap:10 }}>
      {TAGS_V2.map((t,i)=>(
        <div key={i} style={{ display:"flex", alignItems:"flex-start", gap:12, padding:"12px 14px", borderRadius:14, background:KEv.surface, border:`1px solid ${KEv.line}`, cursor:"pointer" }}>
          <div style={{ width:44, height:44, borderRadius:10, overflow:"hidden", flexShrink:0, border:`1px solid ${KEv.line}` }}>
            <img src={t.image} style={{ width:"100%", height:"100%", objectFit:"cover" }}/>
          </div>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontFamily:F_BODY, fontSize:12.5, color:KEv.ink2, lineHeight:1.45 }}>
              <span style={{ fontWeight:700, color:KEv.ink }}>@{t.by}</span> tagged your <span style={{ fontWeight:700, color:KEv.ink }}>{t.car}</span> in a {t.what}
            </div>
            <div style={{ marginTop:4, fontFamily:F_BODY, fontSize:12, fontStyle:"italic", color:KEv.mute, overflow:"hidden", textOverflow:"ellipsis", whiteSpace:"nowrap" }}>"{t.excerpt}"</div>
          </div>
          <span style={{ fontFamily:F_BODY, fontSize:11, color:KEv.muteSoft, flexShrink:0, marginTop:2 }}>{t.time}</span>
        </div>
      ))}
    </div>
  );
}

// ── screen ──
function ProfileScreenV2({ own=false, screenHeight=844 }) {
  const [tab, setTab] = useStateV2("garage");
  const [sheet, setSheet] = useStateV2(null); // { kind:"profile" } | { kind:"car", car }
  const [qrCar, setQrCar] = useStateV2(null);
  const [badgesOpen, setBadgesOpen] = useStateV2(false);
  const [badgeDetail, setBadgeDetail] = useStateV2(null);
  const { ShareSheet, QRScreen } = window;
  return (
    <div style={{ width:390, height:screenHeight, background:KEv.bg, fontFamily:F_BODY, color:KEv.ink, overflow:"hidden", display:"flex", flexDirection:"column", position:"relative" }}>
      <div style={{ height:54, flexShrink:0 }}></div>
      <TopBarV2 own={own}/>
      <div style={{ flex:1, minHeight:0, overflowY:"auto" }}>
        <HeaderV2 own={own} onShareProfile={()=>setSheet({ kind:"profile" })} onOpenBadges={()=>setBadgesOpen(true)} onOpenBadge={setBadgeDetail}/>
        <TabsV2 tab={tab} onChange={setTab}/>
        {tab==="garage"?<GarageV2 onShare={(car)=>setSheet({ kind:"car", car })}/>:tab==="posts"?<PostsV2/>:<TagsV2/>}
        <div style={{ height:12 }}></div>
      </div>
      <BottomNavV2/>
      {sheet && <ShareSheet kind={sheet.kind} car={sheet.car} own={own} onClose={()=>setSheet(null)} onViewQr={(car)=>{ setSheet(null); setQrCar(car); }}/>}
      {badgesOpen && <BadgesSheet onClose={()=>setBadgesOpen(false)} onOpenBadge={setBadgeDetail}/>}
      {badgeDetail && <BadgeDetailScreen badge={badgeDetail} onClose={()=>setBadgeDetail(null)}/>}
      {qrCar && <QRScreen car={qrCar} onClose={()=>setQrCar(null)}/>}
    </div>
  );
}

// ── all-badges sheet ──
const BDG_ANIM = <style>{`@keyframes bdgRise{from{transform:translateY(22px);opacity:0}to{transform:translateY(0);opacity:1}}`}</style>;

function BadgesSheet({ onClose, onOpenBadge }) {
  return (
    <div style={{ position:"absolute", inset:0, zIndex:40 }}>
      {BDG_ANIM}
      <div onClick={onClose} style={{ position:"absolute", inset:0, background:"rgba(10,10,10,0.5)" }}></div>
      <div style={{ position:"absolute", left:0, right:0, bottom:0, maxHeight:"82%", display:"flex", flexDirection:"column", background:KEv.bg, borderRadius:"26px 26px 0 0", boxShadow:"0 -16px 50px rgba(0,0,0,0.35)", animation:"bdgRise .28s ease both" }}>
        <div style={{ padding:"12px 0 0", flexShrink:0 }}>
          <div style={{ width:40, height:5, borderRadius:99, background:KEv.muteSoft, margin:"0 auto 14px" }}></div>
          <div style={{ padding:"0 20px 14px", display:"flex", alignItems:"flex-start", justifyContent:"space-between" }}>
            <div>
              <div style={{ fontFamily:F_BODY, fontWeight:700, fontSize:10.5, letterSpacing:1.4, textTransform:"uppercase", color:KEv.accent }}>{BADGES_V2.length} earned</div>
              <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:20, letterSpacing:-0.6, color:KEv.ink, marginTop:5 }}>Badges</div>
            </div>
            <button onClick={onClose} style={{ width:34, height:34, borderRadius:11, background:KEv.surface, border:`1px solid ${KEv.line}`, display:"grid", placeItems:"center", cursor:"pointer" }}><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 5l14 14M19 5L5 19" stroke={KEv.ink} strokeWidth="2.2" strokeLinecap="round"/></svg></button>
          </div>
          <div style={{ height:1, background:KEv.line }}></div>
        </div>
        <div style={{ flex:1, minHeight:0, overflowY:"auto", padding:"16px 20px 26px" }}>
          <BadgesV2 onOpenBadge={onOpenBadge}/>
        </div>
      </div>
    </div>
  );
}

// ── single badge detail ── full white screen, art centered, description below
function BadgeDetailScreen({ badge, onClose }) {
  return (
    <div style={{ position:"absolute", inset:0, zIndex:50, background:KEv.surface, display:"flex", flexDirection:"column", animation:"bdgRise .22s ease both" }}>
      {BDG_ANIM}
      <div style={{ padding:"18px 16px 0", display:"flex", justifyContent:"flex-end" }}>
        <button onClick={onClose} style={{ width:36, height:36, borderRadius:12, background:KEv.bgSoft, border:`1px solid ${KEv.line}`, display:"grid", placeItems:"center", cursor:"pointer" }}><svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 5l14 14M19 5L5 19" stroke={KEv.ink} strokeWidth="2.2" strokeLinecap="round"/></svg></button>
      </div>
      <div style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", padding:"0 36px 60px", textAlign:"center" }}>
        <BadgeArt badge={badge} size={300}/>
        <div style={{ fontFamily:F_DISP, fontWeight:700, fontSize:40, letterSpacing:-0.5, color:KEv.ink, marginTop:26, textTransform:"uppercase" }}>{badge.name}</div>
        <div style={{ fontFamily:F_BODY, fontSize:20, lineHeight:1.55, color:KEv.ink2, marginTop:18, maxWidth:280 }}>{badge.how}</div>
      </div>
    </div>
  );
}

window.ProfileScreenV2 = ProfileScreenV2;
