/* Tweakd Admin — Tweaks panel (vanilla, host-protocol aware, shared across pages)
   Persists to localStorage so a tweak carries across the linked pages,
   and posts __edit_mode_set_keys so the host can rewrite the on-disk defaults. */
(function(){
  const LS='tweakd.admin.tweaks';
  const ACCENTS={
    ember:{name:'Ember',accent:'#FF4D00',hot:'#E64500',soft:'#FFE4D6',wash:'rgba(255,77,0,0.06)'},
    cobalt:{name:'Cobalt',accent:'#2A6FDB',hot:'#215BBB',soft:'#DEE9FA',wash:'rgba(42,111,219,0.06)'},
    track:{name:'Track',accent:'#1F8A5B',hot:'#16714A',soft:'#DDEFE6',wash:'rgba(31,138,91,0.06)'},
  };
  const defaults=Object.assign({accent:'ember',density:'airy',sidebar:'expanded'},window.TWEAK_DEFAULTS||{});
  let state=Object.assign({},defaults);
  try{const saved=JSON.parse(localStorage.getItem(LS)||'{}');state=Object.assign(state,saved);}catch(e){}

  function apply(){
    const a=ACCENTS[state.accent]||ACCENTS.ember;
    const r=document.documentElement.style;
    r.setProperty('--accent',a.accent);r.setProperty('--accentHot',a.hot);
    r.setProperty('--accentSoft',a.soft);r.setProperty('--accentWash',a.wash);
    document.body.setAttribute('data-density',state.density);
    document.body.setAttribute('data-sidebar',state.sidebar);
    if(window.Charts){document.querySelectorAll('[data-chart]').forEach(c=>{if(c.__cfg)window.Charts[c.getAttribute('data-chart')](c,c.__cfg);});}
  }
  function persist(){
    try{localStorage.setItem(LS,JSON.stringify(state));}catch(e){}
    try{window.parent.postMessage({type:'__edit_mode_set_keys',edits:state},'*');}catch(e){}
  }
  function set(k,v){state[k]=v;apply();persist();build();}

  // apply immediately (before panel exists) so pages open pre-tweaked
  if(document.body)apply();else document.addEventListener('DOMContentLoaded',apply);

  // ── panel ──
  let panel;
  function style(){
    if(document.getElementById('tw-style'))return;
    const s=document.createElement('style');s.id='tw-style';
    s.textContent=`
    #tw-panel{position:fixed;right:20px;bottom:20px;width:280px;z-index:9999;
      background:var(--surface);border:1px solid var(--line);border-radius:16px;
      box-shadow:0 12px 40px rgba(10,10,10,.16);font-family:var(--fbody);
      overflow:hidden;display:none;}
    #tw-panel.on{display:block;}
    .tw-head{display:flex;align-items:center;justify-content:space-between;
      padding:14px 16px;border-bottom:1px solid var(--line);}
    .tw-head h4{margin:0;font-family:var(--fdisplay);font-weight:700;font-size:14px;letter-spacing:-.2px;}
    .tw-x{width:26px;height:26px;border-radius:8px;border:1px solid var(--line);background:var(--surface);
      cursor:pointer;display:grid;place-items:center;color:var(--ink2);}
    .tw-x:hover{background:var(--bgSoft);}
    .tw-body{padding:16px;display:flex;flex-direction:column;gap:18px;}
    .tw-sec>label{display:block;font-family:var(--fdisplay);font-weight:700;font-size:10px;
      letter-spacing:1.3px;color:var(--mute);text-transform:uppercase;margin-bottom:9px;}
    .tw-sw{display:flex;gap:10px;}
    .tw-sw button{flex:1;height:38px;border-radius:10px;border:2px solid var(--line);
      cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;background:var(--surface);
      font-family:var(--fdisplay);font-weight:700;font-size:11px;color:var(--ink2);}
    .tw-sw button .c{width:14px;height:14px;border-radius:999px;}
    .tw-sw button.on{border-color:var(--ink);}
    .tw-seg{display:flex;background:var(--bgSoft);border:1px solid var(--line);border-radius:10px;padding:3px;gap:3px;}
    .tw-seg button{flex:1;padding:8px 0;border:none;background:transparent;border-radius:8px;cursor:pointer;
      font-family:var(--fdisplay);font-weight:700;font-size:11.5px;color:var(--mute);}
    .tw-seg button.on{background:var(--surface);color:var(--ink);box-shadow:0 1px 2px rgba(10,10,10,.06);}`;
    document.head.appendChild(s);
  }
  function build(){
    style();
    if(!panel){panel=document.createElement('div');panel.id='tw-panel';document.body.appendChild(panel);}
    const wasOn=panel.classList.contains('on');
    const accBtns=Object.entries(ACCENTS).map(([k,a])=>
      `<button data-acc="${k}" class="${state.accent===k?'on':''}"><span class="c" style="background:${a.accent}"></span>${a.name}</button>`).join('');
    panel.innerHTML=`
      <div class="tw-head"><h4>Tweaks</h4><button class="tw-x" id="tw-close">✕</button></div>
      <div class="tw-body">
        <div class="tw-sec"><label>Accent</label><div class="tw-sw" id="tw-acc">${accBtns}</div></div>
        <div class="tw-sec"><label>Density</label><div class="tw-seg" id="tw-den">
          <button data-den="airy" class="${state.density==='airy'?'on':''}">Airy</button>
          <button data-den="dense" class="${state.density==='dense'?'on':''}">Dense</button></div></div>
        <div class="tw-sec"><label>Sidebar</label><div class="tw-seg" id="tw-sb">
          <button data-sb="expanded" class="${state.sidebar==='expanded'?'on':''}">Expanded</button>
          <button data-sb="collapsed" class="${state.sidebar==='collapsed'?'on':''}">Collapsed</button></div></div>
      </div>`;
    if(wasOn)panel.classList.add('on');
    panel.querySelector('#tw-close').onclick=()=>{hide();try{window.parent.postMessage({type:'__edit_mode_dismissed'},'*');}catch(e){}};
    panel.querySelectorAll('#tw-acc button').forEach(b=>b.onclick=()=>set('accent',b.dataset.acc));
    panel.querySelectorAll('#tw-den button').forEach(b=>b.onclick=()=>set('density',b.dataset.den));
    panel.querySelectorAll('#tw-sb button').forEach(b=>b.onclick=()=>set('sidebar',b.dataset.sb));
  }
  function show(){build();panel.classList.add('on');}
  function hide(){if(panel)panel.classList.remove('on');}

  window.addEventListener('message',e=>{
    const t=e.data&&e.data.type;
    if(t==='__activate_edit_mode')show();
    else if(t==='__deactivate_edit_mode')hide();
  });
  function announce(){try{window.parent.postMessage({type:'__edit_mode_available'},'*');}catch(e){}}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>{apply();announce();});
  else{apply();announce();}
})();
