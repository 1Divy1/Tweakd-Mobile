// About car page — Kinetic Edge
// Owner's editable view of a chassis: identity, specs, gallery, and the
// redesigned modification LOG (timeline cards — based on user reference,
// but rebuilt in the warm-neutral KE palette, not the reference colors).

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Top bar — back · ABOUT · more
// ─────────────────────────────────────────────────────────
function IconBtn({ children }) {
  return (
    <div style={{
      width: 38, height: 38, borderRadius: 13, display: "grid", placeItems: "center",
      border: `1px solid ${KE.line}`, background: KE.surface, cursor: "pointer",
      boxShadow: "0 1px 2px rgba(10,10,10,0.04)",
    }}>{children}</div>
  );
}

function AboutTopBar() {
  return (
    <div style={{
      height: 56, padding: "0 16px", flexShrink: 0,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <IconBtn>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </IconBtn>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 3, color: KE.ink,
      }}>ABOUT</div>
      <IconBtn>
        <svg width="18" height="5" viewBox="0 0 22 6">
          <circle cx="3" cy="3" r="2.4" fill={KE.ink}/>
          <circle cx="11" cy="3" r="2.4" fill={KE.ink}/>
          <circle cx="19" cy="3" r="2.4" fill={KE.ink}/>
        </svg>
      </IconBtn>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────
function StatCell({ label, value, unit }) {
  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14,
      padding: "13px 15px", display: "flex", flexDirection: "column", gap: 7,
    }}>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
        letterSpacing: 1.4, color: KE.mute,
      }}>{label}</div>
      <div style={{ display: "flex", alignItems: "baseline", gap: 4 }}>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 25, color: KE.ink, letterSpacing: -0.6,
        }}>{value}</span>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.2,
          color: KE.mute, textTransform: "uppercase",
        }}>{unit}</span>
      </div>
    </div>
  );
}

function SpecRow({ label, value, accent, isLast }) {
  return (
    <div style={{
      display: "flex", justifyContent: "space-between", alignItems: "baseline",
      padding: "13px 0", borderBottom: isLast ? "none" : `1px solid ${KE.line}`,
    }}>
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.4, color: KE.mute,
      }}>{label}</span>
      {accent ? (
        <span style={{
          padding: "4px 9px", borderRadius: 7, background: KE.accentSoft, whiteSpace: "nowrap",
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.2, color: KE.accentHot,
        }}>{value}</span>
      ) : (
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, color: KE.ink, letterSpacing: -0.1,
          textAlign: "right",
        }}>{value}</span>
      )}
    </div>
  );
}

function SectionHead({ children, trailing }) {
  return (
    <div style={{
      display: "flex", justifyContent: "space-between", alignItems: "center",
    }}>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 2.2, color: KE.ink,
        whiteSpace: "nowrap",
      }}>{children}</div>
      {trailing}
    </div>
  );
}

// Striped charcoal placeholder for photos the owner hasn't dropped yet.
function PhotoPlaceholder({ label, radius = 10, ratio = "16 / 9" }) {
  return (
    <div style={{
      aspectRatio: ratio, borderRadius: radius, overflow: "hidden", position: "relative",
      background: `repeating-linear-gradient(135deg, #1b1b1d 0 12px, #202022 12px 24px)`,
      display: "grid", placeItems: "center",
    }}>
      <span style={{
        fontFamily: `"Space Mono", ui-monospace, monospace`, fontSize: 10.5, letterSpacing: 1,
        color: "rgba(255,255,255,0.55)", textTransform: "lowercase",
        border: "1px solid rgba(255,255,255,0.18)", borderRadius: 6, padding: "4px 9px",
        background: "rgba(0,0,0,0.25)",
      }}>{label}</span>
    </div>
  );
}

function Photo({ src, radius = 10, ratio = "16 / 9", filter }) {
  return (
    <div style={{
      aspectRatio: ratio, borderRadius: radius, overflow: "hidden",
      background: KE.bgSoft,
    }}>
      <img src={src} alt="" style={{
        width: "100%", height: "100%", objectFit: "cover", display: "block", filter,
      }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// MODIFICATION LOG — timeline card (the redesign)
// ─────────────────────────────────────────────────────────
function GainChip({ children }) {
  return (
    <span style={{
      padding: "6px 11px", borderRadius: 8,
      background: KE.bgSoft, border: `1px solid ${KE.line}`, whiteSpace: "nowrap",
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10.5, letterSpacing: 0.8, color: KE.ink,
    }}>{children}</span>
  );
}

function ModEntry({ mod, isLast }) {
  return (
    <div style={{ position: "relative", paddingLeft: 30, paddingBottom: isLast ? 4 : 26 }}>
      {/* node */}
      <div style={{
        position: "absolute", left: -0.5, top: 5,
        width: 14, height: 14, borderRadius: 999,
        background: isLast ? KE.accentSoft : KE.accent,
        border: `3px solid ${KE.bg}`,
        boxShadow: `0 0 0 1.5px ${KE.accent}`,
      }}/>
      {/* card */}
      <div style={{
        background: KE.surface, borderRadius: 16, border: `1px solid ${KE.line}`,
        padding: 16, boxShadow: "0 8px 24px rgba(10,10,10,0.05), 0 1px 2px rgba(10,10,10,0.04)",
      }}>
        <div style={{
          display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 10,
        }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10.5,
            letterSpacing: 1.8, color: KE.accent, textTransform: "uppercase",
          }}>{mod.date}</div>
          {mod.cost && (
            <div style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12.5,
              letterSpacing: -0.2, color: KE.ink, whiteSpace: "nowrap", flexShrink: 0,
              padding: "4px 10px", borderRadius: 9,
              background: KE.bg, border: `1px solid ${KE.line}`,
            }}>{mod.cost}</div>
          )}
        </div>
        <div style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 19,
          color: KE.ink, letterSpacing: -0.3, lineHeight: 1.12, marginTop: 5,
        }}>{mod.title}</div>

        {/* media */}
        <div style={{ marginTop: 13 }}>
          {mod.beforeAfter ? (
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 7 }}>
              {[["BEFORE", mod.beforeAfter[0]], ["AFTER", mod.beforeAfter[1]]].map(([tag, src]) => (
                <div key={tag} style={{ position: "relative" }}>
                  {src
                    ? <Photo src={src} ratio="4 / 3" radius={10}/>
                    : <PhotoPlaceholder label={tag.toLowerCase()} ratio="4 / 3"/>}
                  <span style={{
                    position: "absolute", top: 8, left: 8, padding: "3px 8px", borderRadius: 6,
                    background: "rgba(10,10,10,0.78)", color: "#fff",
                    fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.3,
                  }}>{tag}</span>
                </div>
              ))}
            </div>
          ) : mod.image
            ? <Photo src={mod.image} ratio="16 / 9"/>
            : <PhotoPlaceholder label={mod.placeholder}/>}
        </div>

        <p style={{
          margin: "13px 0 0", fontFamily: FONT_BODY, fontSize: 13.5, lineHeight: 1.6,
          color: KE.ink2, textWrap: "pretty",
        }}>{mod.body}</p>

        {mod.gains && mod.gains.length > 0 && (
          <div style={{ marginTop: 14, display: "flex", flexWrap: "wrap", gap: 7 }}>
            {mod.gains.map((g, i) => <GainChip key={i}>{g}</GainChip>)}
          </div>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────
function AboutScreen() {
  const gallery = [
    { src: "assets/car-4.png" },
    { src: "assets/car-2.png" },
    { src: "assets/car-3.png" },
    { label: "front 3/4" },
    { label: "wheels" },
  ];

  const mods = [
    {
      date: "OCTOBER 2023",
      title: "ECU REMAP & DOWNPIPES",
      image: "assets/car-3.png",
      cost: "£2,450",
      body: "Stage 2 software optimization. Increased turbo pressure and throttle response mapped for track use. Decat pipes installed for thermal efficiency.",
      gains: ["+110 HP", "+180 NM", "STAGE 2"],
    },
    {
      date: "AUGUST 2023",
      title: "COILOVER SUSPENSION",
      placeholder: "coilover · kw v4",
      cost: "£3,180",
      body: "KW Variant 4 installation. Lowered the centre of gravity by 25mm with 3-way adjustable compression and rebound for high-speed stability.",
      gains: ["−25 MM RIDE", "3-WAY ADJ."],
    },
    {
      date: "JUNE 2023",
      title: "CERAMIC BRAKES",
      beforeAfter: [null, null],
      cost: "£6,900",
      body: "Front six-piston carbon-ceramic upgrade. Major unsprung weight reduction and zero brake fade after repeated back-to-back track laps.",
      gains: ["−9.4 KG", "NO FADE"],
    },
  ];

  return (
    <div style={{
      width: 390, height: 844, background: KE.bg, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 50, flexShrink: 0, background: KE.bg }}/>
      <AboutTopBar/>

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {/* Identity */}
        <div style={{ padding: "18px 20px 0" }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            letterSpacing: 2, color: KE.accent,
          }}>BUILD IDENTIFIER · G82-M4-01</div>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 33, lineHeight: 1.02,
            letterSpacing: -1.1, color: KE.ink, marginTop: 7,
          }}>BMW M4<br/>COMPETITION</div>
        </div>

        {/* Hero */}
        <div style={{ padding: "16px 20px 0" }}>
          <div style={{
            position: "relative", borderRadius: 18, overflow: "hidden", background: "#1a1a1a",
            aspectRatio: "16 / 10",
          }}>
            <img src="assets/car-4.png" alt="" style={{
              position: "absolute", inset: 0, width: "100%", height: "100%",
              objectFit: "cover", filter: "saturate(1.04)",
            }}/>
            <div style={{
              position: "absolute", inset: 0,
              background: "linear-gradient(180deg, rgba(0,0,0,0) 45%, rgba(0,0,0,0.45) 100%)",
            }}/>
            <div style={{
              position: "absolute", top: 14, right: 14, padding: "5px 9px", borderRadius: 7,
              background: "rgba(255,255,255,0.92)", whiteSpace: "nowrap",
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.2, color: KE.ink,
            }}>2024 · INKA ORANGE</div>
          </div>
        </div>

        {/* Stats */}
        <div style={{
          padding: "16px 20px 0", display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10,
        }}>
          <StatCell label="POWER" value="620" unit="HP"/>
          <StatCell label="TORQUE" value="750" unit="NM"/>
          <StatCell label="0-100" value="3.2" unit="SEC"/>
          <StatCell label="WEIGHT" value="1645" unit="KG"/>
        </div>

        {/* Spec list — ends in STATUS: SHOW CAR */}
        <div style={{
          margin: "12px 20px 0", padding: "2px 16px",
          background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14,
        }}>
          <SpecRow label="DRIVETRAIN" value="REAR-WHEEL DRIVE"/>
          <SpecRow label="ENGINE" value="S58 · 3.0L TWIN-TURBO"/>
          <SpecRow label="TRANSMISSION" value="8-SPD M-STEPTRONIC"/>
          <SpecRow label="STATUS" value="SHOW CAR" accent isLast/>
        </div>

        {/* Gallery */}
        <div style={{ padding: "26px 20px 0" }}>
          <SectionHead trailing={
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.mute,
            }}>5 PHOTOS</span>
          }>GALLERY</SectionHead>
          <div style={{
            marginTop: 16, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8,
          }}>
            {gallery.map((g, i) => (
              g.src
                ? <Photo key={i} src={g.src} ratio="4 / 3" radius={12}/>
                : <PhotoPlaceholder key={i} label={g.label} ratio="4 / 3" radius={12}/>
            ))}
          </div>
        </div>

        {/* Log build iteration CTA */}
        <div style={{ padding: "22px 20px 0" }}>
          <button style={{
            width: "100%", height: 54, borderRadius: 13, border: "none", cursor: "pointer",
            background: KE.accent, color: KE.onAccent,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 9,
            boxShadow: "0 8px 20px rgba(255,77,0,0.22)",
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14m-7-7h14" stroke={KE.onAccent} strokeWidth="2.6" strokeLinecap="round"/>
            </svg>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 12.5, letterSpacing: 1.8,
              whiteSpace: "nowrap",
            }}>LOG BUILD ITERATION</span>
          </button>
        </div>

        {/* Modification log — timeline */}
        <div style={{ padding: "28px 20px 0" }}>
          <SectionHead trailing={
            <div style={{
              width: 30, height: 30, borderRadius: 9, display: "grid", placeItems: "center",
              background: KE.accentSoft,
            }}>
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="9" stroke={KE.accent} strokeWidth="2"/>
                <path d="M12 7v5l3 2" stroke={KE.accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
          }>MODIFICATION LOG</SectionHead>

          <div style={{ position: "relative", marginTop: 20 }}>
            {/* timeline line */}
            <div style={{
              position: "absolute", left: 6, top: 8, bottom: 14, width: 2, borderRadius: 2,
              background: `linear-gradient(180deg, ${KE.accent} 0%, ${KE.accent} 12%, ${KE.line} 92%)`,
            }}/>
            {mods.map((m, i) => (
              <ModEntry key={i} mod={m} isLast={i === mods.length - 1}/>
            ))}
          </div>
        </div>

        <div style={{ height: 34 }}/>
      </div>
    </div>
  );
}

window.AboutScreen = AboutScreen;
