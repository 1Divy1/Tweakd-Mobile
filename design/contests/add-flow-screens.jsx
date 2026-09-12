// Add-to-Garage flow — screens (uses window.KEFlow primitives)
const F = window.KEFlow;
const { T, DISP, BODY, MONO, ProgressWindow, FlowHeader, SectionHeader,
  Field, FieldRow, Input, Dropdown, Segmented, Textarea, StatusChip, Footer, Shell, Check } = F;

// ── STEP 1 · IDENTITY ────────────────────────────────────────
function ImageHero() {
  return (
    <div style={{
      position: "relative", height: 168, borderRadius: 18, overflow: "hidden",
      background: "#1a1a1a", boxShadow: "0 8px 22px rgba(11,11,12,0.14)",
    }}>
      <img src="assets/car-4.png" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%",
        objectFit: "cover", filter: "saturate(1.05) brightness(0.96)",
      }}/>
      <div style={{
        position: "absolute", inset: 0,
        background: "linear-gradient(180deg, rgba(0,0,0,0) 40%, rgba(0,0,0,0.55) 100%)",
      }}/>
      <div style={{
        position: "absolute", top: 12, left: 12, padding: "5px 9px", borderRadius: 8,
        background: "rgba(255,255,255,0.92)", backdropFilter: "blur(6px)",
        fontFamily: MONO, fontWeight: 700, fontSize: 9.5, letterSpacing: 1, color: T.ink,
      }}>PRIMARY · 1 / 1</div>
      <div style={{
        position: "absolute", top: 12, right: 12, width: 34, height: 34, borderRadius: 11,
        background: "rgba(255,255,255,0.92)", display: "grid", placeItems: "center",
        backdropFilter: "blur(6px)",
      }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <path d="M3 7h3l2-3h8l2 3h3v12H3z" stroke={T.ink} strokeWidth="2" strokeLinejoin="round"/>
          <circle cx="12" cy="13" r="3.6" stroke={T.ink} strokeWidth="2"/>
        </svg>
      </div>
      <div style={{
        position: "absolute", left: 14, bottom: 12,
        fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 0.3, color: "#fff",
      }}>Studio shot · tap to replace</div>
    </div>
  );
}

function Step1() {
  return (
    <Shell step={1} kicker="IDENTITY" title="Visual & basics" primaryLabel="NEXT">
      <Field label="PRIMARY ASSET"><ImageHero/></Field>
      <Field label="MAKE"><Dropdown value="BMW"/></Field>
      <Field label="MODEL"><Dropdown value="M4 Competition"/></Field>
      <FieldRow>
        <Field label="YEAR"><Input mono value="2024"/></Field>
        <Field label="CHASSIS CODE"><Input mono value="G82"/></Field>
      </FieldRow>
    </Shell>
  );
}

// ── STEP 2 · PERFORMANCE ─────────────────────────────────────
function PWRReadout() {
  return (
    <div style={{
      marginTop: 4, borderRadius: 16, overflow: "hidden",
      border: `1px solid ${T.line}`, background: T.ink, padding: "16px 18px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
    }}>
      <div>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1.6, color: "rgba(255,255,255,0.55)" }}>
          POWER-TO-WEIGHT · AUTO
        </div>
        <div style={{ display: "flex", alignItems: "baseline", gap: 6, marginTop: 6 }}>
          <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 30, color: "#fff", letterSpacing: -0.5 }}>305</span>
          <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, color: T.accent, letterSpacing: 1 }}>HP / T</span>
        </div>
      </div>
      <div style={{
        width: 46, height: 46, borderRadius: 14, background: "rgba(255,77,0,0.16)",
        display: "grid", placeItems: "center",
      }}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M13 2L3 14h7l-1 8 11-14h-7z" fill={T.accent}/></svg>
      </div>
    </div>
  );
}

function Step2() {
  return (
    <Shell step={2} kicker="PERFORMANCE" title="Power & weight" showBack primaryLabel="NEXT">
      <FieldRow>
        <Field label="POWER"><Input mono value="503" suffix="HP"/></Field>
        <Field label="TORQUE"><Input mono value="650" suffix="NM"/></Field>
      </FieldRow>
      <FieldRow>
        <Field label="0–100"><Input mono value="3.9" suffix="SEC"/></Field>
        <Field label="WEIGHT"><Input mono value="1650" suffix="KG"/></Field>
      </FieldRow>
      <Field label="DISPLACEMENT"><Input mono value="3.0" suffix="LITRE"/></Field>
      <PWRReadout/>
    </Shell>
  );
}

// ── STEP 3 · DRIVETRAIN ──────────────────────────────────────
function Step3() {
  return (
    <Shell step={3} kicker="DRIVETRAIN" title="Configuration" showBack primaryLabel="NEXT">
      <Field label="DRIVETRAIN"><Dropdown value="Rear-Wheel Drive"/></Field>
      <Field label="COLOR"><Dropdown value="Inka Orange" swatch="#FF4D00"/></Field>
      <Field label="MILEAGE UNIT"><Segmented options={["KILOMETERS", "MILES"]} value="KILOMETERS"/></Field>
      <Field label="ENGINE CODE"><Input mono value="S58"/></Field>
    </Shell>
  );
}

// ── STEP 4 · STORY ───────────────────────────────────────────
function Step4() {
  const roles = ["DAILY DRIVER", "FAMILY HAULER", "GARAGE QUEEN", "OFF ROADER",
    "PARTS CAR", "PROJECT CAR", "SHOW CAR", "TRACK TOY", "WEEKEND CRUISER", "WORK VEHICLE"];
  return (
    <Shell step={4} kicker="STORY" title="What's this machine's role?" showBack primaryLabel="NEXT">
      <Field label="STATUS">
        <div style={{ display: "flex", flexWrap: "wrap", gap: 9 }}>
          {roles.map(r => <StatusChip key={r} label={r} on={r === "DAILY DRIVER"}/>)}
        </div>
      </Field>
      <div style={{
        marginTop: 6, display: "flex", gap: 10, alignItems: "flex-start",
        padding: "13px 15px", borderRadius: 14, background: T.accentWash,
        border: `1px solid ${T.accentSoft}`,
      }}>
        <div style={{ width: 7, height: 7, borderRadius: 99, background: T.accent, marginTop: 6, flexShrink: 0 }}/>
        <div style={{ fontFamily: BODY, fontSize: 13, lineHeight: 1.5, color: T.ink2 }}>
          Your status shapes how the build appears on the grid and who it's surfaced to. Pick the one that fits best.
        </div>
      </div>
    </Shell>
  );
}

// ── STEP 5 · GALLERY ─────────────────────────────────────────
function GalleryTile({ src, lead }) {
  return (
    <div style={{
      position: "relative", aspectRatio: "1 / 1", borderRadius: 14, overflow: "hidden",
      background: T.bgSoft, boxShadow: T.shadowCard, border: `1px solid ${T.line}`,
    }}>
      <img src={src} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }}/>
      {lead && (
        <div style={{
          position: "absolute", left: 7, bottom: 7, padding: "3px 7px", borderRadius: 6,
          background: T.accent, fontFamily: MONO, fontWeight: 700, fontSize: 8, letterSpacing: 0.8, color: "#fff",
        }}>COVER</div>
      )}
      <div style={{
        position: "absolute", top: 6, right: 6, width: 22, height: 22, borderRadius: 8,
        background: "rgba(11,11,12,0.55)", backdropFilter: "blur(4px)", display: "grid", placeItems: "center",
      }}>
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"/></svg>
      </div>
    </div>
  );
}
function AddTile() {
  return (
    <div style={{
      aspectRatio: "1 / 1", borderRadius: 14, background: T.surface,
      border: `1.5px dashed ${T.muteSoft}`, display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center", gap: 7,
    }}>
      <div style={{ width: 36, height: 36, borderRadius: 11, background: T.bgSoft, display: "grid", placeItems: "center" }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
          <path d="M3 7h3l2-3h8l2 3h3v12H3z" stroke={T.accent} strokeWidth="2" strokeLinejoin="round"/>
          <circle cx="12" cy="13" r="3.4" stroke={T.accent} strokeWidth="2"/>
        </svg>
      </div>
      <span style={{ fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 1, color: T.mute }}>ADD</span>
    </div>
  );
}
function Step5() {
  return (
    <Shell step={5} kicker="GALLERY" title="Show it off" showBack primaryLabel="NEXT">
      <Field label="PHOTOS" optional>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
          <GalleryTile src="assets/car-4.png" lead/>
          <GalleryTile src="assets/car-3.png"/>
          <GalleryTile src="assets/car-2.png"/>
          <GalleryTile src="assets/car-1.png"/>
          <AddTile/>
        </div>
      </Field>
      <div style={{
        marginTop: 4, fontFamily: BODY, fontSize: 12.5, color: T.mute, lineHeight: 1.5,
      }}>Up to 8 photos. The cover leads your chassis card — drag to reorder.</div>
    </Shell>
  );
}

// ── STEP 6 · MODS ────────────────────────────────────────────
function ModRow({ tag, title, meta, thumb, gain }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", gap: 13, padding: 12, borderRadius: 16,
      background: T.surface, border: `1px solid ${T.line}`, boxShadow: T.shadowCard,
    }}>
      <div style={{ width: 52, height: 52, borderRadius: 12, overflow: "hidden", flexShrink: 0, background: T.bgSoft }}>
        <img src={thumb} style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 9, letterSpacing: 0.8, color: T.accent }}>{tag}</div>
        <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 15, color: T.ink, letterSpacing: -0.2, marginTop: 3 }}>{title}</div>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 5 }}>
          <span style={{ fontFamily: MONO, fontSize: 10, color: T.mute, letterSpacing: 0.3 }}>{meta}</span>
          {gain && <span style={{
            fontFamily: DISP, fontWeight: 700, fontSize: 9.5, letterSpacing: 0.5, color: T.ink,
            padding: "2px 7px", borderRadius: 6, background: T.bgSoft, border: `1px solid ${T.line2}`,
          }}>{gain}</span>}
        </div>
      </div>
      <div style={{ width: 36, height: 36, borderRadius: 11, display: "grid", placeItems: "center", border: `1px solid ${T.line}`, background: T.bgSoft }}>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
          <path d="M5 7h14M9 7V5h6v2M7 7l1 12h8l1-12" stroke={T.mute} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
    </div>
  );
}
function Step6() {
  return (
    <Shell step={6} kicker="MODS" title="Build log" showBack primaryLabel="REGISTER MACHINE">
      <div style={{ marginBottom: 14, fontFamily: BODY, fontSize: 13, color: T.mute, lineHeight: 1.5, marginTop: -8 }}>
        Optional — log the work that makes it yours.
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 11 }}>
        <ModRow tag="ECU & TUNING" title="ECU Remap" meta="JUL 2026 · €1,250" thumb="assets/car-3.png" gain="+10% 0–100"/>
        <ModRow tag="SUSPENSION" title="KW V4 Coilovers" meta="JUN 2026 · €2,400" thumb="assets/car-4.png" gain="−25 MM"/>
      </div>
      <button style={{
        marginTop: 12, width: "100%", height: 54, borderRadius: 16,
        background: T.surface, border: `1.5px dashed ${T.muteSoft}`, cursor: "pointer",
        display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
        fontFamily: DISP, fontWeight: 700, fontSize: 12, letterSpacing: 1.3, color: T.ink,
      }}>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke={T.accent} strokeWidth="2.6" strokeLinecap="round"/></svg>
        ADD MODIFICATION
      </button>
    </Shell>
  );
}

// ── ADD MODIFICATION — bottom sheet ──────────────────────────
function BeforeAfter() {
  const Slot = ({ src, label }) => (
    <div style={{ position: "relative", aspectRatio: "4 / 3", borderRadius: 14, overflow: "hidden", background: T.bgSoft, border: `1px solid ${T.line}` }}>
      <img src={src} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }}/>
      <div style={{
        position: "absolute", top: 8, left: 8, padding: "3px 8px", borderRadius: 7,
        background: "rgba(255,255,255,0.92)", backdropFilter: "blur(6px)",
        fontFamily: MONO, fontWeight: 700, fontSize: 8.5, letterSpacing: 1, color: T.ink,
      }}>{label}</div>
    </div>
  );
  return (
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 11 }}>
      <Slot src="assets/car-2.png" label="BEFORE"/>
      <Slot src="assets/car-3.png" label="AFTER"/>
    </div>
  );
}

function AddModSheet() {
  return (
    <div style={{
      width: 390, height: 844, position: "relative", overflow: "hidden",
      fontFamily: BODY, color: T.ink,
    }}>
      {/* dimmed backdrop (mods screen) */}
      <div style={{ position: "absolute", inset: 0, background: "#2A2724" }}/>
      <div style={{ position: "absolute", inset: 0, background: "rgba(11,11,12,0.45)" }}/>
      {/* sheet */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0, top: 54,
        background: T.bg, borderRadius: "26px 26px 0 0",
        boxShadow: "0 -16px 50px rgba(0,0,0,0.35)",
        display: "flex", flexDirection: "column", overflow: "hidden",
      }}>
        {/* grabber + header */}
        <div style={{ flexShrink: 0, padding: "12px 0 0" }}>
          <div style={{ width: 44, height: 5, borderRadius: 99, background: T.muteSoft, margin: "0 auto 14px" }}/>
          <div style={{ padding: "0 20px 14px", display: "flex", alignItems: "flex-start", justifyContent: "space-between" }}>
            <div>
              <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 11, letterSpacing: 1, color: T.accent }}>— MODIFICATION</div>
              <div style={{ fontFamily: DISP, fontWeight: 700, fontSize: 26, letterSpacing: -0.8, color: T.ink, marginTop: 6 }}>Add a build item</div>
            </div>
            <div style={{ width: 36, height: 36, borderRadius: 12, background: T.surface, border: `1px solid ${T.line}`, display: "grid", placeItems: "center", boxShadow: T.shadowCard }}>
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M6 6l12 12M18 6L6 18" stroke={T.ink} strokeWidth="2.4" strokeLinecap="round"/></svg>
            </div>
          </div>
          <div style={{ height: 1, background: T.line }}/>
        </div>
        {/* scroll body */}
        <div style={{ flex: 1, minHeight: 0, overflowY: "auto", padding: "18px 20px 20px" }}>
          <Field label="CATEGORY"><Dropdown value="ECU & Tuning"/></Field>
          <Field label="TITLE"><Input value="ECU Remap" focus/></Field>
          <Field label="DESCRIPTION" optional>
            <Textarea value="Installed a brand new ECU map. Boosted 0–100 by 10% with a stage-2 tune."/>
          </Field>
          <Field label="INSTALLATION DATE">
            <Dropdown value="7 Jun 2026"/>
          </Field>
          <FieldRow>
            <Field label="PRICE" optional><Input mono value="1,250" prefix={<span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 15, color: T.mute }}>€</span>}/></Field>
            <Field label="MILEAGE" optional><Input mono value="45,000" suffix="KM"/></Field>
          </FieldRow>
          {/* visibility toggle */}
          <div style={{ display: "flex", alignItems: "center", gap: 11, marginTop: 2, marginBottom: 18 }}>
            <div style={{ width: 24, height: 24, borderRadius: 8, background: T.accent, display: "grid", placeItems: "center", boxShadow: "0 2px 6px rgba(255,77,0,0.3)" }}>
              <Check w={13}/>
            </div>
            <span style={{ fontFamily: BODY, fontWeight: 600, fontSize: 14, color: T.ink2 }}>Make price visible to others</span>
          </div>
          <Field label="BEFORE & AFTER"><BeforeAfter/></Field>
        </div>
        {/* footer */}
        <div style={{ flexShrink: 0, padding: "14px 20px 26px", borderTop: `1px solid ${T.line}`, background: T.bg }}>
          <button style={{
            width: "100%", height: 54, borderRadius: 16, border: "none",
            background: T.accent, color: "#fff", cursor: "pointer",
            fontFamily: DISP, fontWeight: 700, fontSize: 13, letterSpacing: 1.6,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
            boxShadow: "0 10px 24px rgba(255,77,0,0.30)", whiteSpace: "nowrap",
          }}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="#fff" strokeWidth="2.6" strokeLinecap="round"/></svg>
            ADD TO BUILD LOG
          </button>
        </div>
      </div>
    </div>
  );
}

// ── PROGRESS BAR DEMO STRIP (component only) ─────────────────
function ProgressDemo({ step }) {
  return (
    <div style={{ width: 380, background: T.bg, fontFamily: BODY, padding: "10px 0 14px", borderRadius: 20, border: `1px solid ${T.line}` }}>
      <FlowHeader step={step}/>
      <ProgressWindow current={step}/>
    </div>
  );
}

Object.assign(window, {
  Step1, Step2, Step3, Step4, Step5, Step6, AddModSheet, ProgressDemo,
});
