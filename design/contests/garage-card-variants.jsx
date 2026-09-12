// Garage card refactor — four card directions, same data, whole-car photography.
const K = window.KE;
const FD = window.KE_FONT_DISPLAY;
const FB = window.KE_FONT_BODY;

const CARS = [
  { make:"BMW", model:"M4 Competition", year:"2024", hp:503, tq:"479", zs:"3.4", mods:12, svc:4, img:"assets/car-4.png", fav:true },
  { make:"Porsche", model:"911 GT3", year:"2022", hp:502, tq:"347", zs:"3.2", mods:5, svc:9, slot:true },
  { make:"Nissan", model:"Skyline R34", year:"2001", hp:280, tq:"289", zs:"5.2", mods:24, svc:16, slot:true },
];

const chev = (c)=><svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke={c} strokeWidth="2.4" strokeLinecap="round"/></svg>;

// Whole-car image: real photo where we have one, drop-slot otherwise.
function CarImg({ car, id, radius=0, fit="cover" }) {
  if (car.slot) return <image-slot id={id} shape="rect" fit={fit} placeholder="full car · 3/4 front" style={{ position:"absolute", inset:0, width:"100%", height:"100%" }}></image-slot>;
  return <img src={car.img} style={{ position:"absolute", inset:0, width:"100%", height:"100%", objectFit:"cover", borderRadius:radius }}/>;
}

const Fav = () => <span style={{ width:6, height:6, borderRadius:999, background:K.accent, flexShrink:0 }}></span>;

function SpecCell({ v, u, label, align="left" }) {
  return (
    <div style={{ textAlign:align, whiteSpace:"nowrap" }}>
      <div style={{ fontFamily:FD, fontWeight:700, fontSize:14, color:K.ink, letterSpacing:-0.3 }}>{v}<span style={{ fontSize:9.5, fontWeight:700, color:K.mute, marginLeft:2 }}>{u}</span></div>
      <div style={{ fontFamily:FB, fontSize:8.5, fontWeight:700, letterSpacing:0.7, textTransform:"uppercase", color:K.muteSoft, marginTop:2 }}>{label}</div>
    </div>
  );
}

// ── A · Poster: full-bleed 16:9, name over the metal, spec strip beneath ──
function CardPoster({ car, id }) {
  return (
    <div style={{ borderRadius:18, background:K.surface, border:`1px solid ${K.line}`, overflow:"hidden", cursor:"pointer", flexShrink:0 }}>
      <div style={{ position:"relative", aspectRatio:"16 / 9", background:K.bgSoft }}>
        <CarImg car={car} id={id}/>
        <div style={{ position:"absolute", inset:0, background:"linear-gradient(to top, rgba(8,8,8,0.72) 0%, rgba(8,8,8,0.18) 38%, rgba(8,8,8,0) 62%)", pointerEvents:"none" }}></div>
        {car.fav && <div style={{ position:"absolute", top:11, left:12, padding:"4px 9px 4.5px", borderRadius:999, background:K.accent, color:K.onAccent, fontFamily:FB, fontWeight:700, fontSize:9.5, letterSpacing:0.5, textTransform:"uppercase", pointerEvents:"none" }}>Daily</div>}
        <div style={{ position:"absolute", left:14, right:14, bottom:11, pointerEvents:"none" }}>
          <div style={{ fontFamily:FB, fontSize:9.5, fontWeight:700, letterSpacing:1.2, textTransform:"uppercase", color:"rgba(255,255,255,0.72)" }}>{car.year} · {car.make}</div>
          <div style={{ fontFamily:FD, fontWeight:700, fontSize:20, color:"#fff", letterSpacing:-0.5, marginTop:1 }}>{car.model}</div>
        </div>
      </div>
      <div style={{ padding:"11px 16px", display:"flex", justifyContent:"space-between", alignItems:"center" }}>
        <SpecCell v={car.hp} u="hp" label="Power"/>
        <SpecCell v={car.tq} u="lb-ft" label="Torque"/>
        <SpecCell v={car.zs} u="s" label="0–60"/>
        <SpecCell v={car.mods} u="" label="Mods" align="right"/>
      </div>
    </div>
  );
}

// ── B · Rail: compact horizontal row, more cars per screen ──
function CardRail({ car, id }) {
  return (
    <div style={{ display:"flex", gap:13, padding:10, borderRadius:14, background:K.surface, border:`1px solid ${K.line}`, alignItems:"center", cursor:"pointer", flexShrink:0 }}>
      <div style={{ position:"relative", width:104, height:78, borderRadius:9, overflow:"hidden", background:K.bgSoft, flexShrink:0 }}>
        <CarImg car={car} id={id}/>
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:"flex", alignItems:"center", gap:6 }}>
          {car.fav && <Fav/>}
          <span style={{ fontFamily:FD, fontWeight:700, fontSize:15, color:K.ink, letterSpacing:-0.3, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>{car.make} {car.model}</span>
        </div>
        <div style={{ fontFamily:FB, fontSize:11, fontWeight:600, color:K.mute, marginTop:2 }}>{car.year}</div>
        <div style={{ display:"flex", gap:5, marginTop:8 }}>
          {[`${car.hp} hp`, `${car.zs}s`, `${car.mods} mods`].map((s)=>(
            <span key={s} style={{ fontFamily:FB, fontSize:10, fontWeight:700, color:K.ink2, background:K.bg, border:`1px solid ${K.line}`, padding:"3px 7px", borderRadius:6, whiteSpace:"nowrap" }}>{s}</span>
          ))}
        </div>
      </div>
      <div style={{ paddingRight:4 }}>{chev(K.muteSoft)}</div>
    </div>
  );
}

// ── C · Spec plate: photo over a data plate ──
function CardPlate({ car, id }) {
  return (
    <div style={{ borderRadius:16, background:K.surface, border:`1px solid ${K.line}`, overflow:"hidden", cursor:"pointer", flexShrink:0 }}>
      <div style={{ position:"relative", aspectRatio:"3 / 2", background:K.bgSoft }}>
        <CarImg car={car} id={id}/>
        {car.fav && <div style={{ position:"absolute", top:11, right:12, width:22, height:22, borderRadius:999, background:"rgba(255,255,255,0.92)", display:"grid", placeItems:"center", pointerEvents:"none" }}><span style={{ width:8, height:8, borderRadius:999, background:K.accent }}></span></div>}
      </div>
      <div style={{ padding:"12px 15px 13px" }}>
        <div style={{ display:"flex", alignItems:"baseline", justifyContent:"space-between", gap:8 }}>
          <div style={{ minWidth:0 }}>
            <div style={{ fontFamily:FD, fontWeight:700, fontSize:17, color:K.ink, letterSpacing:-0.4, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>{car.make} {car.model}</div>
            <div style={{ fontFamily:FB, fontSize:11, fontWeight:600, color:K.mute, marginTop:2 }}>{car.year} · {car.mods} mods · {car.svc} service entries</div>
          </div>
          {chev(K.muteSoft)}
        </div>
        <div style={{ display:"grid", gridTemplateColumns:"repeat(3, 1fr)", marginTop:12, paddingTop:11, borderTop:`1px solid ${K.line}` }}>
          {[[car.hp,"hp","Power"],[car.tq,"lb-ft","Torque"],[car.zs,"s","0–60"]].map(([v,u,l],i)=>(
            <div key={l} style={{ borderLeft:i?`1px solid ${K.line}`:"none", paddingLeft:i?13:0 }}>
              <SpecCell v={v} u={u} label={l}/>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ── D · Gallery: no card chrome, photo-first, caption beneath ──
function CardGallery({ car, id }) {
  return (
    <div style={{ cursor:"pointer", flexShrink:0 }}>
      <div style={{ position:"relative", aspectRatio:"5 / 4", borderRadius:16, overflow:"hidden", background:K.bgSoft }}>
        <CarImg car={car} id={id}/>
        <div style={{ position:"absolute", top:12, left:12, padding:"4px 9px", borderRadius:7, background:"rgba(255,255,255,0.9)", fontFamily:FD, fontWeight:700, fontSize:10.5, letterSpacing:0.4, color:K.ink, pointerEvents:"none" }}>{car.year}</div>
      </div>
      <div style={{ display:"flex", alignItems:"center", gap:10, padding:"10px 2px 0" }}>
        <div style={{ flex:1, minWidth:0 }}>
          <div style={{ display:"flex", alignItems:"center", gap:6 }}>
            {car.fav && <Fav/>}
            <span style={{ fontFamily:FD, fontWeight:700, fontSize:16, color:K.ink, letterSpacing:-0.35, whiteSpace:"nowrap", overflow:"hidden", textOverflow:"ellipsis" }}>{car.make} {car.model}</span>
          </div>
          <div style={{ fontFamily:FB, fontSize:11.5, fontWeight:600, color:K.mute, marginTop:2 }}>{car.hp} hp · {car.mods} mods</div>
        </div>
        {chev(K.muteSoft)}
      </div>
    </div>
  );
}

// ── phone-context shell ──
const TABS = ["Garage","Posts","Tags"];
function GarageShell({ children, note }) {
  return (
    <div style={{ width:390, background:K.bg, fontFamily:FB, display:"flex", flexDirection:"column", height:"100%", overflow:"hidden" }}>
      <div style={{ display:"flex", borderBottom:`1px solid ${K.line}`, flexShrink:0 }}>
        {TABS.map((t)=>{
          const on = t==="Garage";
          return (
            <div key={t} style={{ flex:1, height:44, display:"grid", placeItems:"center", position:"relative" }}>
              <span style={{ fontFamily:FB, fontWeight:700, fontSize:11.5, color:on?K.ink:K.muteSoft }}>{t}</span>
              {on && <div style={{ position:"absolute", left:"25%", right:"25%", bottom:-1, height:2, background:K.ink }}></div>}
            </div>
          );
        })}
      </div>
      <div style={{ padding:"12px 16px 6px", display:"flex", alignItems:"center", justifyContent:"space-between", flexShrink:0 }}>
        <span style={{ fontFamily:FB, fontSize:10.5, fontWeight:700, letterSpacing:0.8, textTransform:"uppercase", color:K.mute }}>{note}</span>
        <span style={{ fontFamily:FB, fontSize:11, fontWeight:700, color:K.accent }}>+ Add car</span>
      </div>
      <div style={{ flex:1, minHeight:0, overflow:"hidden", padding:"6px 16px 16px", display:"flex", flexDirection:"column", gap:14 }}>{children}</div>
    </div>
  );
}

function VariantList({ Card, prefix, note }) {
  return (
    <GarageShell note={note}>
      {CARS.map((c,i)=><Card key={i} car={c} id={`${prefix}-${i}`}/>)}
    </GarageShell>
  );
}

window.GarageVariants = {
  A: ()=><VariantList Card={CardPoster} prefix="gv-a" note="A · Poster"/>,
  B: ()=><VariantList Card={CardRail} prefix="gv-b" note="B · Rail"/>,
  C: ()=><VariantList Card={CardPlate} prefix="gv-c" note="C · Spec plate"/>,
  D: ()=><VariantList Card={CardGallery} prefix="gv-d" note="D · Gallery"/>,
};
