/* Tweakd Admin — lightweight SVG charts (no dependencies)
   Declarative: put data in a JSON <script> child of a [data-chart] container.
   <div data-chart="line"><script type="application/json">{...}</script></div>
   Re-renders on resize. Palette pulled from CSS variables. */
(function(){
  const NS="http://www.w3.org/2000/svg";
  const css=(n,f)=>{const v=getComputedStyle(document.documentElement).getPropertyValue(n).trim();return v||f;};
  const P=()=>({
    ink:css('--ink','#0A0A0A'), ink2:css('--ink2','#3F3F46'),
    mute:css('--mute','#8A8680'), muteSoft:css('--muteSoft','#B8B3AC'),
    line:css('--line','#ECE8E2'), line2:css('--line2','#F2EFE9'),
    accent:css('--accent','#FF4D00'), accentSoft:css('--accentSoft','#FFE4D6'),
    surface:css('--surface','#fff'),
  });
  const FD='"Space Grotesk", sans-serif';
  const el=(t,a)=>{const e=document.createElementNS(NS,t);for(const k in a)e.setAttribute(k,a[k]);return e;};
  const fmt=n=>n>=1000?(n/1000).toFixed(n%1000===0?0:1)+'k':(''+n);

  function svg(w,h){const s=el('svg',{viewBox:`0 0 ${w} ${h}`,width:'100%',height:h,preserveAspectRatio:'xMidYMid meet'});s.style.display='block';s.style.overflow='visible';return s;}

  // ── LINE ──────────────────────────────────────────────
  function line(c,cfg){
    const p=P();
    const W=c.clientWidth||640, H=cfg.height||220;
    const padL=38, padR=12, padT=14, padB=26;
    const data=cfg.data, labels=cfg.labels||[];
    const color=cfg.color||p.ink;
    const max=cfg.max!=null?cfg.max:Math.max(...data)*1.12, min=cfg.min!=null?cfg.min:0;
    const iw=W-padL-padR, ih=H-padT-padB;
    const X=i=>padL+(data.length<=1?0:i/(data.length-1)*iw);
    const Y=v=>padT+ih-(v-min)/(max-min||1)*ih;
    const s=svg(W,H);
    // gridlines + y labels
    const ticks=4;
    for(let t=0;t<=ticks;t++){
      const val=min+(max-min)*t/ticks, y=Y(val);
      s.appendChild(el('line',{x1:padL,y1:y,x2:W-padR,y2:y,stroke:t===0?p.line:p.line2,'stroke-width':1}));
      const tx=el('text',{x:padL-8,y:y+3.5,'text-anchor':'end','font-family':FD,'font-size':10,'font-weight':600,fill:p.muteSoft});
      tx.textContent=fmt(Math.round(val));s.appendChild(tx);
    }
    // area
    let d='',a='';
    data.forEach((v,i)=>{const x=X(i),y=Y(v);d+=(i?'L':'M')+x+' '+y+' ';});
    a=d+`L ${X(data.length-1)} ${Y(min)} L ${X(0)} ${Y(min)} Z`;
    const gid='lg'+Math.random().toString(36).slice(2,7);
    const defs=el('defs');const lg=el('linearGradient',{id:gid,x1:0,y1:0,x2:0,y2:1});
    lg.appendChild(el('stop',{offset:'0%','stop-color':color,'stop-opacity':.14}));
    lg.appendChild(el('stop',{offset:'100%','stop-color':color,'stop-opacity':0}));
    defs.appendChild(lg);s.appendChild(defs);
    s.appendChild(el('path',{d:a,fill:`url(#${gid})`}));
    s.appendChild(el('path',{d:d.trim(),fill:'none',stroke:color,'stroke-width':2.4,'stroke-linejoin':'round','stroke-linecap':'round'}));
    // optional comparison (dashed) series
    if(cfg.compare){
      let dc='';cfg.compare.forEach((v,i)=>{const x=X(i),y=Y(v);dc+=(i?'L':'M')+x+' '+y+' ';});
      s.appendChild(el('path',{d:dc.trim(),fill:'none',stroke:p.muteSoft,'stroke-width':2,'stroke-dasharray':'4 4','stroke-linejoin':'round'}));
    }
    // last point marker
    const lx=X(data.length-1), ly=Y(data[data.length-1]);
    s.appendChild(el('circle',{cx:lx,cy:ly,r:4.5,fill:p.surface,stroke:color,'stroke-width':2.4}));
    // x labels
    labels.forEach((lb,i)=>{
      if(lb==='')return;
      const tx=el('text',{x:X(i),y:H-6,'text-anchor':'middle','font-family':FD,'font-size':10,'font-weight':600,fill:p.mute});
      tx.textContent=lb;s.appendChild(tx);
    });
    c.innerHTML='';c.appendChild(s);
  }

  // ── BAR ───────────────────────────────────────────────
  function bar(c,cfg){
    const p=P();
    const W=c.clientWidth||640, H=cfg.height||220;
    const padL=38, padR=12, padT=14, padB=26;
    const data=cfg.data, labels=cfg.labels||[];
    const max=cfg.max!=null?cfg.max:Math.max(...data)*1.14;
    const iw=W-padL-padR, ih=H-padT-padB;
    const s=svg(W,H);
    const ticks=4;
    for(let t=0;t<=ticks;t++){
      const val=max*t/ticks, y=padT+ih-val/max*ih;
      s.appendChild(el('line',{x1:padL,y1:y,x2:W-padR,y2:y,stroke:t===0?p.line:p.line2,'stroke-width':1}));
      const tx=el('text',{x:padL-8,y:y+3.5,'text-anchor':'end','font-family':FD,'font-size':10,'font-weight':600,fill:p.muteSoft});
      tx.textContent=fmt(Math.round(val));s.appendChild(tx);
    }
    const n=data.length, slot=iw/n, bw=Math.min(cfg.barWidth||30, slot*0.6);
    data.forEach((v,i)=>{
      const x=padL+slot*i+slot/2-bw/2, h=v/max*ih, y=padT+ih-h;
      const hi=cfg.highlight===i;
      s.appendChild(el('rect',{x,y,width:bw,height:Math.max(h,1),rx:6,fill:hi?p.accent:p.ink,opacity:hi?1:.86}));
      if(labels[i]!=null){
        const tx=el('text',{x:padL+slot*i+slot/2,y:H-6,'text-anchor':'middle','font-family':FD,'font-size':10,'font-weight':600,fill:hi?p.ink:p.mute});
        tx.textContent=labels[i];s.appendChild(tx);
      }
    });
    c.innerHTML='';c.appendChild(s);
  }

  // ── DONUT ─────────────────────────────────────────────
  function donut(c,cfg){
    const p=P();
    const size=cfg.size||200, sw=cfg.stroke||24, r=(size-sw)/2, cx=size/2, cy=size/2;
    const total=cfg.segments.reduce((a,s)=>a+s.value,0);
    const s=svg(size,size);
    s.setAttribute('viewBox',`0 0 ${size} ${size}`);s.removeAttribute('height');s.style.height=size+'px';s.style.width=size+'px';s.style.margin='0 auto';
    s.appendChild(el('circle',{cx,cy,r,fill:'none',stroke:p.line2,'stroke-width':sw}));
    const C=2*Math.PI*r;let off=0;
    cfg.segments.forEach(seg=>{
      const frac=seg.value/total;
      const arc=el('circle',{cx,cy,r,fill:'none',stroke:seg.color,'stroke-width':sw,
        'stroke-dasharray':`${frac*C} ${C}`,'stroke-dashoffset':-off,
        transform:`rotate(-90 ${cx} ${cy})`,'stroke-linecap':'butt'});
      s.appendChild(arc);off+=frac*C;
    });
    // center label
    if(cfg.centerLabel!=null){
      const t1=el('text',{x:cx,y:cy-2,'text-anchor':'middle','font-family':FD,'font-size':cfg.centerSize||30,'font-weight':700,fill:p.ink,'letter-spacing':-1});
      t1.textContent=cfg.centerLabel;s.appendChild(t1);
      if(cfg.centerSub){const t2=el('text',{x:cx,y:cy+16,'text-anchor':'middle','font-family':FD,'font-size':10,'font-weight':700,fill:p.mute,'letter-spacing':1});t2.textContent=cfg.centerSub;s.appendChild(t2);}
    }
    c.innerHTML='';c.appendChild(s);
  }

  // ── SPARKLINE ─────────────────────────────────────────
  function spark(c,cfg){
    const p=P();
    const W=c.clientWidth||120, H=cfg.height||36;
    const data=cfg.data, color=cfg.color||p.ink;
    const max=Math.max(...data), min=Math.min(...data);
    const X=i=>i/(data.length-1)*W, Y=v=>H-2-(v-min)/(max-min||1)*(H-4);
    const s=svg(W,H);
    let d='';data.forEach((v,i)=>{d+=(i?'L':'M')+X(i)+' '+Y(v)+' ';});
    s.appendChild(el('path',{d:d.trim(),fill:'none',stroke:color,'stroke-width':2,'stroke-linejoin':'round','stroke-linecap':'round'}));
    s.appendChild(el('circle',{cx:X(data.length-1),cy:Y(data[data.length-1]),r:2.6,fill:color}));
    c.innerHTML='';c.appendChild(s);
  }

  const R={line,bar,donut,spark};
  function renderAll(){
    document.querySelectorAll('[data-chart]').forEach(c=>{
      const type=c.getAttribute('data-chart');
      const src=c.querySelector('script[type="application/json"]');
      if(!src||!R[type])return;
      let cfg;try{cfg=JSON.parse(src.textContent);}catch(e){return;}
      // keep the json around for re-render on resize
      c.__cfg=cfg;R[type](c,cfg);c.appendChild(src);
    });
  }
  let raf;window.addEventListener('resize',()=>{cancelAnimationFrame(raf);raf=requestAnimationFrame(()=>{
    document.querySelectorAll('[data-chart]').forEach(c=>{if(c.__cfg)R[c.getAttribute('data-chart')](c,c.__cfg);});
  });});
  window.Charts=R;
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',renderAll);else renderAll();
})();
