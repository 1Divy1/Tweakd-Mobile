// Onboarding screens — Tweakd (uses window.KEFlow + window.ONB)
const F = window.KEFlow;
const { T, DISP, BODY, MONO, Field, FieldRow, Input, Textarea, Dropdown, StatusChip, Check } = F;
const O = window.ONB;
const { OnbShell, Toggle, RadiusSlider } = O;

// ── shared sub-bits ───────────────────────────────────────────
function CardWrap({ children, style }) {
  return (
    <div style={{
      background: T.surface, borderRadius: 18,
      boxShadow: T.shadowCard, padding: 14, ...style,
    }}>{children}</div>
  );
}

function RemoveBtn() {
  return (
    <div style={{
      width: 30, height: 30, borderRadius: 10, flexShrink: 0,
      background: T.bgSoft, display: "grid", placeItems: "center",
    }}>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={T.mute} strokeWidth="2.4" strokeLinecap="round"/></svg>
    </div>
  );
}

function DashedAdd({ label }) {
  return (
    <div style={{
      width: "100%", height: 52, borderRadius: 14, background: T.surface,
      boxShadow: T.shadowCard, display: "flex", alignItems: "center",
      justifyContent: "center", gap: 9,
      fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.3, color: T.ink,
    }}>
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={T.accent} strokeWidth="2.6" strokeLinecap="round"/></svg>
      {label}
    </div>
  );
}

function BrandMark({ initial }) {
  return (
    <div style={{
      width: 34, height: 34, borderRadius: 10, flexShrink: 0, background: T.ink,
      display: "grid", placeItems: "center",
      fontFamily: DISP, fontWeight: 700, fontSize: 14, color: "#fff", letterSpacing: 0.5,
    }}>{initial}</div>
  );
}

function AtPrefix() {
  return <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 16, color: T.muteSoft }}>@</span>;
}

// ═════════════════════════════════════════════════════════════
// STEP 1 · IDENTITY — handle + bio + role chips
// ═════════════════════════════════════════════════════════════
function StepIdentity() {
  const username = "apex_garage";
  const bio = "Weekend tuner chasing apexes. R34 owner, GT3 dreamer — here for the builds, meets & marketplace finds.";
  const max = 150;
  const roles = [
    "CAR ENTHUSIAST", "MECHANIC", "TUNER", "CAR SPOTTER",
    "PHOTOGRAPHER", "PILOT / RACER", "DETAILER", "COLLECTOR",
    "DEALER", "FABRICATOR", "JOURNALIST", "EVENT ORGANIZER",
  ];
  const on = new Set(["CAR ENTHUSIAST", "TUNER", "PHOTOGRAPHER"]);
  return (
    <OnbShell step={1} kicker="IDENTITY" title="Claim your handle & role"
      sub="This is how the community finds and @-mentions you — and how we tailor your feed to your role in the scene.">
      <Field label="USERNAME">
        <Input value={username} mono focus prefix={<AtPrefix/>}/>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 11 }}>
          <div style={{
            width: 19, height: 19, borderRadius: 999, background: T.accent,
            display: "grid", placeItems: "center", boxShadow: "0 2px 6px rgba(255,77,0,0.30)",
          }}><Check w={11}/></div>
          <span style={{ fontFamily: BODY, fontSize: 12.5, color: T.ink2 }}>
            <b style={{ color: T.ink, fontFamily: MONO, fontWeight: 700 }}>@{username}</b> is available
          </span>
        </div>
      </Field>

      <Field label="BIO" optional>
        <Textarea value={bio}/>
        <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 8 }}>
          <span style={{
            fontFamily: MONO, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.5,
            color: bio.length > max * 0.9 ? T.accent : T.muteSoft,
          }}>{bio.length} / {max}</span>
        </div>
      </Field>

      <Field label="ROLES">
        <div style={{ display: "flex", flexWrap: "wrap", gap: 9 }}>
          {roles.map(r => <StatusChip key={r} label={r} on={on.has(r)}/>)}
        </div>
      </Field>
    </OnbShell>
  );
}

// ═════════════════════════════════════════════════════════════
// STEP 2 · PREFERENCES — garage brands/models + taste categories
// ═════════════════════════════════════════════════════════════
function BrandRow({ initial, brand, models }) {
  return (
    <CardWrap style={{ padding: 13 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 11 }}>
        <BrandMark initial={initial}/>
        <div style={{ flex: 1, minWidth: 0 }}>
          <Dropdown value={brand}/>
        </div>
        <RemoveBtn/>
      </div>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.3, color: T.mute, marginBottom: 8 }}>
        MODELS
      </div>
      <Dropdown value={models} placeholder="Select models"/>
    </CardWrap>
  );
}

function StepPreferences() {
  const cats = [
    "JDM", "MUSCLE", "OFF-ROADERS", "CLASSIC / RETRO", "TRACK BUILDS",
    "EURO", "STANCE", "HYPERCARS", "RALLY", "DRIFT", "OVERLAND",
    "RESTOMOD", "LOWRIDERS", "EVs", "SLEEPERS",
  ];
  const on = new Set(["JDM", "TRACK BUILDS", "CLASSIC / RETRO", "DRIFT"]);
  return (
    <OnbShell step={2} kicker="PREFERENCES" title="Your garage & taste" showBack
      sub="Brands you follow and the scenes that get your pulse up — we'll tune your feed and the marketplace around both.">
      <Field label="BRANDS & MODELS">
        <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 12 }}>
          <BrandRow initial="B" brand="BMW" models="M3 · M4 Competition · M2"/>
          <BrandRow initial="T" brand="Toyota" models="GR Supra · GR86"/>
          <BrandRow initial="P" brand="Porsche" models="911 GT3 · Cayman GT4"/>
        </div>
        <DashedAdd label="ADD BRAND"/>
      </Field>

      <Field label="CATEGORIES">
        <div style={{ display: "flex", flexWrap: "wrap", gap: 9 }}>
          {cats.map(c => <StatusChip key={c} label={c} on={on.has(c)}/>)}
        </div>
        <div style={{ fontFamily: BODY, fontSize: 12.5, color: T.mute, lineHeight: 1.5, marginTop: 10 }}>
          {on.size} selected · pick at least 3 to calibrate your feed.
        </div>
      </Field>
    </OnbShell>
  );
}

// ═════════════════════════════════════════════════════════════
// STEP 3 · LOCATION — home base + discovery radius
// ═════════════════════════════════════════════════════════════
function MapPreview() {
  return (
    <div style={{
      position: "relative", height: 150, borderRadius: 16, overflow: "hidden",
      background: T.bgSoft, boxShadow: T.shadowCard,
      backgroundImage:
        `linear-gradient(${T.line2} 1px, transparent 1px), linear-gradient(90deg, ${T.line2} 1px, transparent 1px)`,
      backgroundSize: "26px 26px",
    }}>
      <div style={{ position: "absolute", top: "38%", left: 0, right: 0, height: 8, background: "#fff", opacity: 0.8 }}/>
      <div style={{ position: "absolute", top: 0, bottom: 0, left: "58%", width: 8, background: "#fff", opacity: 0.8 }}/>
      <div style={{
        position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)",
        width: 132, height: 132, borderRadius: 999, background: "rgba(255,77,0,0.10)",
        border: `1.5px solid rgba(255,77,0,0.45)`,
      }}/>
      <div style={{
        position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-100%)",
        display: "flex", flexDirection: "column", alignItems: "center",
      }}>
        <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
          <path d="M12 22s7-6.2 7-12a7 7 0 10-14 0c0 5.8 7 12 7 12z" fill={T.accent} stroke="#fff" strokeWidth="1.5"/>
          <circle cx="12" cy="10" r="2.6" fill="#fff"/>
        </svg>
      </div>
    </div>
  );
}

function StepLocation() {
  return (
    <OnbShell step={3} kicker="LOCATION" title="Where's home base?" showBack
      sub="Used for local meets, events and marketplace finds — never shown publicly on your profile.">
      <Field label="COUNTRY">
        <Dropdown value="Portugal" placeholder="Select your country"/>
      </Field>
      <Field label="REGION">
        <Dropdown value="Lisboa" placeholder="Select your region"/>
      </Field>
      <Field label="CITY">
        <Dropdown value="Lisbon" placeholder="Select your city"/>
      </Field>
      <div style={{ height: 4 }}/>
      <RadiusSlider value={40} min={10} max={100}/>
    </OnbShell>
  );
}

// ═════════════════════════════════════════════════════════════
// STEP 4 · NOTIFICATIONS
// ═════════════════════════════════════════════════════════════
function NotifIcon({ children }) {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: 12, flexShrink: 0,
      background: T.bgSoft, display: "grid", placeItems: "center",
    }}>{children}</div>
  );
}

function NotifRow({ icon, title, sub, on }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 13, padding: "13px 14px",
      background: T.surface, borderRadius: 16, boxShadow: T.shadowCard,
    }}>
      <NotifIcon>{icon}</NotifIcon>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 14.5, color: T.ink, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontFamily: BODY, fontSize: 12, color: T.mute, lineHeight: 1.4, marginTop: 2 }}>{sub}</div>
      </div>
      <Toggle on={on}/>
    </div>
  );
}

function NotifGroup({ label, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.4, color: T.mute, marginBottom: 10 }}>
        {label}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 9 }}>{children}</div>
    </div>
  );
}

function StepNotifications() {
  return (
    <OnbShell step={4} kicker="NOTIFICATIONS" title="What should we ping you about?" showBack primaryLabel="FINISH SETUP"
      sub="Stay on top of what matters. You can fine-tune any of these later.">
      <NotifGroup label="ON YOUR CONTENT">
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M12 21s-7-4.3-9.3-9C1.3 9 3 5.5 6.4 5.5c2 0 3.2 1.2 3.6 2.3.4-1.1 1.6-2.3 3.6-2.3 3.4 0 5.1 3.5 3.7 6.5C19 16.7 12 21 12 21z" fill={T.accent}/></svg>}
          title="Likes" sub="When someone likes your builds & posts" on={true}/>
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M4 5h16v11H9l-5 4z" stroke={T.ink} strokeWidth="2" strokeLinejoin="round"/></svg>}
          title="Comments" sub="Replies and threads on your content" on={true}/>
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M4 12v7h16v-7M12 16V3M7 8l5-5 5 5" stroke={T.ink} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>}
          title="Shares" sub="When your content gets reposted" on={false}/>
      </NotifGroup>

      <NotifGroup label="MESSAGES">
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="13" rx="3" stroke={T.ink} strokeWidth="2"/><path d="M4 7l8 5 8-5" stroke={T.ink} strokeWidth="2" strokeLinecap="round"/></svg>}
          title="Direct messages" sub="New DMs and message requests" on={true}/>
      </NotifGroup>

      <NotifGroup label="MEETS & EVENTS · WITHIN 40 KM">
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M13 2L4 13h6l-1 9 9-12h-6l1-8z" fill={T.accent}/></svg>}
          title="Flash meets" sub="Spontaneous link-ups happening near you" on={true}/>
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="16" rx="3" stroke={T.ink} strokeWidth="2"/><path d="M3 9h18M8 3v4M16 3v4" stroke={T.ink} strokeWidth="2" strokeLinecap="round"/></svg>}
          title="Organized events" sub="Shows, track days & cars-and-coffee" on={true}/>
      </NotifGroup>

      <NotifGroup label="MARKETPLACE">
        <NotifRow
          icon={<svg width="19" height="19" viewBox="0 0 24 24" fill="none"><path d="M4 9h16l-1.5 11h-13z" stroke={T.ink} strokeWidth="2" strokeLinejoin="round"/><path d="M9 9V6a3 3 0 016 0v3" stroke={T.ink} strokeWidth="2"/></svg>}
          title="Price drops" sub="When a saved item gets a discount" on={true}/>
      </NotifGroup>
    </OnbShell>
  );
}

Object.assign(window, {
  OnbStepIdentity: StepIdentity,
  OnbStepPreferences: StepPreferences,
  OnbStepLocation: StepLocation,
  OnbStepNotifications: StepNotifications,
});
