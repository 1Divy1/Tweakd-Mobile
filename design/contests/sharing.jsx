// sharing.jsx — Kinetic Edge · Share Sheet + Car QR Code
// Profile & garage sharing to outside social apps, plus a per-car QR code
// (smart link: opens the Tweakd app if installed, else a public web page)
// that can be downloaded as a real, scannable SVG.
const { useState: useStateSh, useMemo: useMemoSh, useRef: useRefSh, useEffect: useEffectSh } = React;
const KEsh = window.KE;
const SD = window.KE_FONT_DISPLAY;
const SB = window.KE_FONT_BODY;

const SH_I = {
  close:   c => <svg width="14" height="14" viewBox="0 0 24 24" fill="none"><path d="M5 5l14 14M19 5L5 19" stroke={c} strokeWidth="2.2" strokeLinecap="round"/></svg>,
  share:   c => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 3v12m0-12L8 7m4-4l4 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  link:    c => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M9 15l6-6M8 13l-2 2a3.5 3.5 0 005 5l2-2M16 11l2-2a3.5 3.5 0 00-5-5l-2 2" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  qr:      c => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><rect x="3" y="3" width="6" height="6" rx="1" stroke={c} strokeWidth="2"/><rect x="15" y="3" width="6" height="6" rx="1" stroke={c} strokeWidth="2"/><rect x="3" y="15" width="6" height="6" rx="1" stroke={c} strokeWidth="2"/><path d="M15 15h2.5v2.5M21 15v2M15 21h2M18.5 18.5H21v2.5" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  bubble:  c => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M4 4h16a2 2 0 012 2v10a2 2 0 01-2 2H10l-5 4v-4H4a2 2 0 01-2-2V6a2 2 0 012-2z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  wa:      c => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M12 3a9 9 0 100 18c1.6 0 3.1-.4 4.4-1.1L21 21l-1.1-4.4A9 9 0 0012 3z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  camera:  c => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="7" width="18" height="13" rx="3" stroke={c} strokeWidth="1.8"/><path d="M8 7l1.4-2.4h5.2L16 7" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/><circle cx="12" cy="13.5" r="3.6" stroke={c} strokeWidth="1.8"/></svg>,
  x:       c => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M5 5l14 14M19 5L5 19" stroke={c} strokeWidth="1.8" strokeLinecap="round"/></svg>,
  send:    c => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 11l18-8-8 18-2-8-8-2z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  mail:    c => <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2.5" stroke={c} strokeWidth="1.8"/><path d="M3.5 6.5L12 13l8.5-6.5" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/></svg>,
  more:    c => <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><circle cx="5" cy="12" r="1.8" fill={c}/><circle cx="12" cy="12" r="1.8" fill={c}/><circle cx="19" cy="12" r="1.8" fill={c}/></svg>,
  download:c => <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><path d="M12 3v13m0 0l-4.5-4.5M12 16l4.5-4.5" stroke={c} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/><path d="M5 20h14" stroke={c} strokeWidth="2.2" strokeLinecap="round"/></svg>,
  check:   c => <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M5 12l4 4 10-10" stroke={c} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  chevR:   c => <svg width="9" height="14" viewBox="0 0 8 14"><path d="M1 1l6 6-6 6" stroke={c} strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  phone:   c => <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><rect x="7" y="2" width="10" height="20" rx="2.5" stroke={c} strokeWidth="1.8"/><path d="M10 18h4" stroke={c} strokeWidth="1.8" strokeLinecap="round"/></svg>,
  globe:   c => <svg width="17" height="17" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke={c} strokeWidth="1.8"/><path d="M3 12h18M12 3c2.4 2.7 2.4 15.3 0 18M12 3c-2.4 2.7-2.4 15.3 0 18" stroke={c} strokeWidth="1.8"/></svg>,
};

const SH_ANIM = <style>{`@keyframes shRise{from{transform:translateY(22px);opacity:0}to{transform:translateY(0);opacity:1}}@keyframes shPop{from{transform:scale(.94);opacity:0}to{transform:scale(1);opacity:1}}`}</style>;

// ── real, scannable QR — kazuhikoarase qrcode-generator (window.qrcode) ──
function buildQrSvg(text) {
  if (!window.qrcode) return null;
  const qr = window.qrcode(0, 'M');
  qr.addData(text);
  qr.make();
  let raw = qr.createSvgTag(10, 4);
  const wm = raw.match(/width="(\d+)(px)?"/);
  const size = wm ? wm[1] : '320';
  if (!/viewBox/.test(raw)) raw = raw.replace('<svg ', `<svg viewBox="0 0 ${size} ${size}" `);
  const display = raw.replace(/width="\d+(px)?"/, 'width="100%"').replace(/height="\d+(px)?"/, 'height="100%"');
  return { display, download: raw, size };
}

function copyToClipboard(text) {
  if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).catch(()=>{});
}

function downloadSvgFile(svgStr, filename) {
  const blob = new Blob([svgStr], { type: 'image/svg+xml;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click(); document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

// ── sheet chrome ──
function SheetScrim({ onClose }) {
  return <div onClick={onClose} style={{ position:"absolute", inset:0, background:"rgba(10,10,10,0.5)", zIndex:40 }}/>;
}

function SocialTile({ icon, label, onClick }) {
  return (
    <button onClick={onClick} style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:7, background:"transparent", border:"none", cursor:"pointer", width:60, flexShrink:0 }}>
      <div style={{ width:50, height:50, borderRadius:16, background:KEsh.bgSoft, border:`1px solid ${KEsh.line}`, display:"grid", placeItems:"center" }}>{icon(KEsh.ink2)}</div>
      <span style={{ fontFamily:SB, fontSize:10.5, fontWeight:600, color:KEsh.mute, whiteSpace:"nowrap" }}>{label}</span>
    </button>
  );
}

function ShareRow({ icon, title, sub, onClick, accent }) {
  return (
    <button onClick={onClick} style={{ width:"100%", display:"flex", alignItems:"center", gap:13, padding:"12px 4px", background:"transparent", border:"none", cursor:"pointer", textAlign:"left", borderTop:`1px solid ${KEsh.line2}` }}>
      <div style={{ width:40, height:40, borderRadius:12, flexShrink:0, display:"grid", placeItems:"center", background:accent?KEsh.accentWash:KEsh.bgSoft, border:`1px solid ${accent?KEsh.accentSoft:KEsh.line}` }}>{icon(accent?KEsh.accent:KEsh.ink)}</div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontFamily:SD, fontWeight:700, fontSize:14.5, color:accent?KEsh.accent:KEsh.ink, letterSpacing:-0.2 }}>{title}</div>
        {sub && <div style={{ fontFamily:SB, fontSize:11.5, color:KEsh.mute, marginTop:1 }}>{sub}</div>}
      </div>
      {SH_I.chevR(KEsh.muteSoft)}
    </button>
  );
}

const SOCIAL_TARGETS = [
  ["Messages", SH_I.bubble], ["WhatsApp", SH_I.wa], ["Instagram", SH_I.camera],
  ["X", SH_I.x], ["Telegram", SH_I.send], ["Email", SH_I.mail], ["More", SH_I.more],
];

// ── Share Sheet — profile or car ──
function ShareSheet({ kind = "profile", car, own, onClose = () => {}, onViewQr = () => {} }) {
  const [copied, setCopied] = useStateSh(false);
  const isCar = kind === "car";
  const url = isCar ? `tweakd.app/c/${car.slug}` : `tweakd.app/marcus_vlox`;
  const handleCopy = () => { copyToClipboard(`https://${url}`); setCopied(true); setTimeout(()=>setCopied(false), 1600); };

  return (
    <div style={{ position:"absolute", inset:0, zIndex:40 }}>
      {SH_ANIM}
      <SheetScrim onClose={onClose}/>
      <div style={{ position:"absolute", left:0, right:0, bottom:0, background:KEsh.bg, borderRadius:"26px 26px 0 0", boxShadow:"0 -16px 50px rgba(0,0,0,0.35)", animation:"shRise .28s ease both", paddingBottom:26, zIndex:41 }}>
        <div style={{ padding:"12px 0 0" }}>
          <div style={{ width:40, height:5, borderRadius:99, background:KEsh.muteSoft, margin:"0 auto 14px" }}/>
          <div style={{ padding:"0 20px 14px", display:"flex", alignItems:"flex-start", justifyContent:"space-between" }}>
            <div>
              <div style={{ fontFamily:SB, fontWeight:700, fontSize:10.5, letterSpacing:1.4, textTransform:"uppercase", color:KEsh.accent }}>{isCar ? "Share build" : "Share profile"}</div>
              <div style={{ fontFamily:SD, fontWeight:700, fontSize:20, letterSpacing:-0.6, color:KEsh.ink, marginTop:5 }}>{isCar ? `${car.make} ${car.model}` : "Marcus Vlox"}</div>
            </div>
            <button onClick={onClose} style={{ width:34, height:34, borderRadius:11, background:KEsh.surface, border:`1px solid ${KEsh.line}`, display:"grid", placeItems:"center", cursor:"pointer" }}>{SH_I.close(KEsh.ink)}</button>
          </div>
          <div style={{ height:1, background:KEsh.line }}/>
        </div>

        {/* QR button — big, explicit, hard to miss */}
        {isCar && (
          <div style={{ padding:"14px 20px 4px" }}>
            <button onClick={()=>onViewQr(car)} style={{ width:"100%", display:"flex", alignItems:"center", gap:14, padding:"14px 16px", borderRadius:16, background:KEsh.accent, border:"none", cursor:"pointer", textAlign:"left" }}>
              <div style={{ width:44, height:44, borderRadius:12, background:"rgba(255,255,255,0.18)", display:"grid", placeItems:"center", flexShrink:0 }}>{SH_I.qr("#fff")}</div>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontFamily:SD, fontWeight:700, fontSize:15.5, color:KEsh.onAccent, letterSpacing:-0.2 }}>Get QR code</div>
                <div style={{ fontFamily:SB, fontSize:12, color:"rgba(255,255,255,0.85)", marginTop:1 }}>Print it, stick it on the car</div>
              </div>
              {SH_I.chevR(KEsh.onAccent)}
            </button>
          </div>
        )}

        {/* social row */}
        <div style={{ padding:"18px 0 6px 20px", display:"flex", gap:14, overflowX:"auto" }}>
          {SOCIAL_TARGETS.map(([label, icon]) => <SocialTile key={label} icon={icon} label={label} onClick={onClose}/>)}
        </div>

        {/* actions */}
        <div style={{ padding:"6px 20px 0" }}>
          <ShareRow icon={copied?SH_I.check:SH_I.link} title={copied?"Copied!":"Copy link"} sub={url} onClick={handleCopy}/>
        </div>
      </div>
    </div>
  );
}

// ── QR Code screen — car build sharing, real downloadable SVG ──
function QRScreen({ car, onClose = () => {} }) {
  const url = `tweakd.app/c/${car.slug}`;
  const qr = useMemoSh(() => buildQrSvg(`https://${url}`), [car.slug]);
  const handleDownload = () => { if (qr) downloadSvgFile(qr.download, `tweakd-${car.slug}-qr.svg`); };

  return (
    <div style={{ position:"absolute", inset:0, zIndex:50 }}>
      {SH_ANIM}
      <div onClick={onClose} style={{ position:"absolute", inset:0, background:"rgba(10,10,10,0.6)" }}/>
      <button onClick={onClose} style={{ position:"absolute", top:16, right:16, width:34, height:34, borderRadius:11, background:"rgba(255,255,255,0.14)", border:"1px solid rgba(255,255,255,0.25)", display:"grid", placeItems:"center", cursor:"pointer", zIndex:2 }}>{SH_I.close("#fff")}</button>
      <div style={{ position:"absolute", inset:0, display:"flex", alignItems:"center", justifyContent:"center", padding:22 }}>
        <div style={{ width:"100%", maxWidth:326, background:KEsh.surface, borderRadius:24, boxShadow:"0 24px 60px rgba(0,0,0,0.4)", padding:"22px 20px", animation:"shPop .24s ease both" }}>
          {/* QR block */}
          <div style={{ borderRadius:16, background:"#fff", border:`1px solid ${KEsh.line}`, padding:18, display:"flex", justifyContent:"center" }}>
            <div style={{ width:200, height:200 }}>
              {qr ? <div style={{ width:"100%", height:"100%" }} dangerouslySetInnerHTML={{ __html: qr.display }}/> : <div style={{ width:"100%", height:"100%", background:KEsh.bgSoft }}/>}
            </div>
          </div>

          {/* action */}
          <button onClick={handleDownload} style={{ width:"100%", marginTop:18, height:48, borderRadius:12, border:"none", background:KEsh.accent, color:KEsh.onAccent, cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center", gap:8, fontFamily:SB, fontWeight:700, fontSize:14 }}>{SH_I.download(KEsh.onAccent)}Download SVG</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ShareSheet, QRScreen });
