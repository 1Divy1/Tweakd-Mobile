// Garage section — Kinetic Edge
// Two screens:
//  • CarDetailScreen — hero shot, stat grid, modification timeline.
//  • AddCarScreen    — comprehensive registration form (identity, performance, drivetrain, etc.)
// Same warm-neutral palette + Space Grotesk / Manrope pairing as Profile + Search.

const KE = window.KE;
const FONT_DISPLAY = window.KE_FONT_DISPLAY;
const FONT_BODY    = window.KE_FONT_BODY;

// ─────────────────────────────────────────────────────────
// Shared chrome bits
// ─────────────────────────────────────────────────────────
function ModalTopBar({ title = "KINETIC EDGE", onClose }) {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface, cursor: "pointer",
      }} onClick={onClose}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
          <path d="M6 6l12 12M18 6L6 18" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink,
      }}>{title}</div>
      <div style={{ width: 36, height: 36 }}/>
    </div>
  );
}

function DetailTopBar({ onBack }) {
  return (
    <div style={{
      height: 56, padding: "0 16px",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      background: KE.bg, borderBottom: `1px solid ${KE.line}`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface, cursor: "pointer",
      }} onClick={onBack}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M15 6l-6 6 6 6" stroke={KE.ink} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14, letterSpacing: 2, color: KE.ink,
      }}>CHASSIS</div>
      <div style={{
        width: 36, height: 36, borderRadius: 12, display: "grid", placeItems: "center",
        border: `1px solid ${KE.line}`, background: KE.surface,
      }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M4 12h16M4 6h16M4 18h10" stroke={KE.ink} strokeWidth="2" strokeLinecap="round"/>
        </svg>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// CAR DETAIL — matches user's reference screenshot
// ─────────────────────────────────────────────────────────
function StatCell({ label, value, unit }) {
  return (
    <div style={{
      background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14,
      padding: "14px 16px",
      display: "flex", flexDirection: "column", gap: 8,
    }}>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
        letterSpacing: 1.4, color: KE.mute,
      }}>{label}</div>
      <div style={{ display: "flex", alignItems: "baseline", gap: 4 }}>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 26,
          color: KE.ink, letterSpacing: -0.6,
        }}>{value}</span>
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11,
          letterSpacing: 1.2, color: KE.mute, textTransform: "uppercase",
        }}>{unit}</span>
      </div>
    </div>
  );
}

function SpecRow({ label, value }) {
  return (
    <div style={{
      display: "flex", justifyContent: "space-between", alignItems: "baseline",
      padding: "12px 0", borderBottom: `1px solid ${KE.line}`,
    }}>
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
        letterSpacing: 1.4, color: KE.mute,
      }}>{label}</span>
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13,
        color: KE.ink, letterSpacing: -0.1, textAlign: "right",
      }}>{value}</span>
    </div>
  );
}

function ModEntry({ date, title, body, image, image2, gains, isLast }) {
  return (
    <div style={{ position: "relative", paddingLeft: 28, paddingBottom: isLast ? 0 : 22 }}>
      {/* timeline dot */}
      <div style={{
        position: "absolute", left: 0, top: 4,
        width: 12, height: 12, borderRadius: 999, background: KE.accent,
        border: `3px solid ${KE.bg}`, boxShadow: `0 0 0 1px ${KE.accent}`,
      }}/>
      <div style={{
        background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14,
        padding: 14,
      }}>
        <div style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
          letterSpacing: 1.4, color: KE.mute, textTransform: "uppercase",
        }}>{date}</div>
        <div style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 15,
          color: KE.ink, letterSpacing: -0.2, marginTop: 4,
        }}>{title}</div>

        {(image || image2) && (
          <div style={{
            marginTop: 12, display: "grid",
            gridTemplateColumns: image2 ? "1fr 1fr" : "1fr",
            gap: 6, borderRadius: 10, overflow: "hidden",
          }}>
            {image && <div style={{
              aspectRatio: image2 ? "1 / 1" : "16 / 9",
              background: `${KE.bgSoft} url(${image}) center/cover no-repeat`,
              borderRadius: image2 ? 8 : 10,
            }}/>}
            {image2 && <div style={{
              aspectRatio: "1 / 1",
              background: `${KE.bgSoft} url(${image2}) center/cover no-repeat`,
              borderRadius: 8,
            }}/>}
          </div>
        )}

        <div style={{
          marginTop: 12, fontFamily: FONT_BODY, fontSize: 12.5,
          lineHeight: 1.55, color: KE.ink2, textWrap: "pretty",
        }}>{body}</div>

        {gains && gains.length > 0 && (
          <div style={{ marginTop: 12, display: "flex", flexWrap: "wrap", gap: 6 }}>
            {gains.map((g, i) => (
              <span key={i} style={{
                padding: "5px 9px", borderRadius: 7,
                background: KE.bgSoft, border: `1px solid ${KE.line}`,
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
                letterSpacing: 0.6, color: KE.ink,
              }}>{g}</span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function CarDetailScreen() {
  const owner = {
    name: "Marek_Turbo",
    role: "MASTER TUNER",
    location: "MUNICH, DE",
    avatar: "assets/avatar.jpg",
  };

  const mods = [
    {
      date: "OCTOBER 2023",
      title: "ECU REMAP & DOWNPIPES",
      body: "Stage 2 software optimization. Increased turbo pressure and throttle response mapped for track use. Decat pipes installed for thermal efficiency.",
      image: "assets/car-2.png",
      gains: ["+110 HP", "+180 NM"],
    },
    {
      date: "AUGUST 2023",
      title: "COILOVER SUSPENSION",
      body: "KW Variant 4 installation. Lowered center of gravity by 25mm. 3-way adjustable compression and rebound for high-speed stability.",
      image: "assets/car-3.png",
      gains: ["−25 MM RIDE", "3-WAY ADJ."],
    },
    {
      date: "JUNE 2023",
      title: "FORGED MONOBLOCKS",
      body: "Unsprung weight reduction of 4.2kg per corner. Finished in Satin Bronze with Michelin Pilot Sport 4S tires.",
      image: "assets/car-4.png",
      image2: "assets/car-1.png",
      gains: ["−4.2 KG / CORNER", "PS4S 275/30"],
    },
  ];

  return (
    <div style={{
      width: 390, height: 844, background: KE.bg, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <DetailTopBar/>

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {/* Owner strip */}
        <div style={{ padding: "18px 20px 6px", display: "flex", alignItems: "center", gap: 12 }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12, overflow: "hidden",
            border: `1px solid ${KE.line}`, padding: 2, background: KE.surface,
            flexShrink: 0,
          }}>
            <img src={owner.avatar} style={{
              width: "100%", height: "100%", borderRadius: 9, objectFit: "cover",
            }}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 17,
              color: KE.ink, letterSpacing: -0.3,
            }}>{owner.name}</div>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginTop: 4 }}>
              <span style={{
                padding: "3px 7px", borderRadius: 6,
                background: KE.surface, border: `1px solid ${KE.line}`,
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                letterSpacing: 1.2, color: KE.ink,
              }}>{owner.role}</span>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                letterSpacing: 1.2, color: KE.mute,
              }}>{owner.location}</span>
            </div>
          </div>
        </div>

        {/* Title block */}
        <div style={{ padding: "6px 20px 14px", display: "flex", alignItems: "baseline", gap: 10 }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 32,
            lineHeight: 1.0, letterSpacing: -1.0, color: KE.ink,
          }}>ACTIVE</div>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 32,
            lineHeight: 1.0, letterSpacing: -1.0, color: KE.accent,
          }}>CHASSIS.</div>
        </div>

        {/* CTAs */}
        <div style={{ padding: "0 20px", display: "flex", gap: 10, justifyContent: "center" }}>
          <button style={{
            flex: "0 1 140px", height: 44, borderRadius: 10, border: "none",
            background: KE.line2, color: KE.ink,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.6,
            cursor: "pointer",
          }}>MESSAGE</button>
          <button style={{
            flex: "0 1 140px", height: 44, borderRadius: 10, border: "none",
            background: KE.accent, color: KE.onAccent,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.6,
            cursor: "pointer",
          }}>FOLLOW</button>
        </div>

        {/* Hero card */}
        <div style={{ padding: "20px 20px 0" }}>
          <div style={{
            position: "relative", borderRadius: 18, overflow: "hidden",
            background: "#1a1a1a",
            aspectRatio: "16 / 10",
          }}>
            <img src="assets/car-2.png" style={{
              position: "absolute", inset: 0, width: "100%", height: "100%",
              objectFit: "cover", filter: "brightness(0.78) saturate(1.05)",
            }}/>
            <div style={{
              position: "absolute", inset: 0,
              background: "linear-gradient(180deg, rgba(0,0,0,0.0) 35%, rgba(0,0,0,0.55) 75%, rgba(0,0,0,0.85) 100%)",
            }}/>
            <div style={{
              position: "absolute", left: 18, right: 18, bottom: 18,
            }}>
              <div style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                letterSpacing: 2, color: "rgba(255,255,255,0.7)", marginBottom: 6,
              }}>BUILD IDENTIFIER: G82-M4-01</div>
              <div style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 28,
                color: "#fff", letterSpacing: -0.6, lineHeight: 1.05,
              }}>BMW M4<br/>COMPETITION</div>
            </div>
            {/* corner badge */}
            <div style={{
              position: "absolute", top: 14, right: 14,
              padding: "5px 9px", borderRadius: 7,
              background: "rgba(255,255,255,0.92)",
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
              letterSpacing: 1.2, color: KE.ink,
            }}>2024 · INKA ORANGE</div>
          </div>
        </div>

        {/* Stat grid — Power / Torque / 0-100 / Weight */}
        <div style={{
          padding: "16px 20px 0",
          display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10,
        }}>
          <StatCell label="POWER"   value="620" unit="HP"/>
          <StatCell label="TORQUE"  value="750" unit="NM"/>
          <StatCell label="0-100"   value="3.2" unit="SEC"/>
          <StatCell label="WEIGHT"  value="1645" unit="KG"/>
        </div>

        {/* Drivetrain & engine specs */}
        <div style={{
          margin: "12px 20px 0", padding: "4px 16px",
          background: KE.surface, border: `1px solid ${KE.line}`, borderRadius: 14,
        }}>
          <SpecRow label="DRIVETRAIN"     value="REAR-WHEEL DRIVE"/>
          <SpecRow label="TRANSMISSION"   value="8-SPD M-STEPTRONIC"/>
          <SpecRow label="ENGINE"         value="S58 · 3.0L TWIN-TURBO I6"/>
          <SpecRow label="DISPLACEMENT"   value="2,993 CC"/>
          <SpecRow label="REDLINE"        value="7,200 RPM"/>
          <div style={{ borderBottom: "none" }}>
            <div style={{
              display: "flex", justifyContent: "space-between", alignItems: "baseline",
              padding: "12px 0",
            }}>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
                letterSpacing: 1.4, color: KE.mute,
              }}>TOP SPEED</span>
              <span style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13,
                color: KE.ink, letterSpacing: -0.1,
              }}>305 KM/H (LIMITER OFF)</span>
            </div>
          </div>
        </div>

        {/* Modification log */}
        <div style={{ padding: "26px 20px 0" }}>
          <div style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            marginBottom: 18,
          }}>
            <div style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13,
              letterSpacing: 2, color: KE.ink,
            }}>MODIFICATION LOG</div>
            <div style={{
              width: 28, height: 28, borderRadius: 8, display: "grid", placeItems: "center",
              background: KE.accentSoft,
            }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="9" stroke={KE.accent} strokeWidth="2"/>
                <path d="M12 7v5l3 2" stroke={KE.accent} strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
          </div>

          {/* timeline */}
          <div style={{ position: "relative" }}>
            <div style={{
              position: "absolute", left: 5, top: 6, bottom: 6, width: 2,
              background: `repeating-linear-gradient(to bottom, ${KE.line} 0 4px, transparent 4px 8px)`,
            }}/>
            {mods.map((m, i) => (
              <ModEntry key={i} {...m} isLast={i === mods.length - 1}/>
            ))}
          </div>
        </div>

        <div style={{ height: 30 }}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// ADD CAR — comprehensive form
// ─────────────────────────────────────────────────────────
function FormLabel({ children, optional }) {
  return (
    <div style={{
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
      letterSpacing: 1.4, color: KE.ink, marginBottom: 8,
      display: "flex", alignItems: "center", gap: 6,
    }}>
      {children}
      {optional && <span style={{ color: KE.mute, letterSpacing: 1.2 }}>(OPTIONAL)</span>}
    </div>
  );
}

function TextField({ placeholder, value, suffix }) {
  return (
    <div style={{
      height: 48, borderRadius: 10, background: KE.surface,
      border: `1px solid ${KE.line}`, display: "flex", alignItems: "center",
      padding: "0 14px",
    }}>
      <span style={{
        flex: 1, fontFamily: FONT_BODY, fontSize: 14,
        color: value ? KE.ink : KE.muteSoft,
      }}>{value || placeholder}</span>
      {suffix && (
        <span style={{
          fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
          letterSpacing: 1.2, color: KE.mute,
        }}>{suffix}</span>
      )}
    </div>
  );
}

function SelectField({ placeholder, value }) {
  return (
    <div style={{
      height: 48, borderRadius: 10, background: KE.surface,
      border: `1px solid ${KE.line}`, display: "flex", alignItems: "center",
      padding: "0 14px",
    }}>
      <span style={{
        flex: 1, fontFamily: FONT_BODY, fontSize: 14,
        color: value ? KE.ink : KE.muteSoft,
      }}>{value || placeholder}</span>
      <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
        <path d="M6 9l6 6 6-6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function SegRow({ options, value }) {
  return (
    <div style={{
      display: "flex", gap: 6,
    }}>
      {options.map(o => {
        const on = o === value;
        return (
          <div key={o} style={{
            flex: 1, height: 42, borderRadius: 8,
            background: on ? KE.ink : KE.surface,
            border: `1px solid ${on ? KE.ink : KE.line}`,
            color: on ? KE.surface : KE.ink,
            display: "grid", placeItems: "center",
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.3,
          }}>{o}</div>
        );
      })}
    </div>
  );
}

function SectionTitle({ kicker, title }) {
  return (
    <div style={{ marginTop: 24, marginBottom: 14 }}>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
        letterSpacing: 2, color: KE.accent,
      }}>{kicker}</div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 18,
        color: KE.ink, letterSpacing: -0.3, marginTop: 4,
      }}>{title}</div>
    </div>
  );
}

function FieldGroup({ children }) {
  return <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>{children}</div>;
}

function FieldRow({ children }) {
  return <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>{children}</div>;
}

function AddCarScreen() {
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <ModalTopBar/>

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {/* Header */}
        <div style={{ padding: "20px 20px 4px" }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            letterSpacing: 2, color: KE.accent,
          }}>GARAGE ENTRY</div>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 36,
            lineHeight: 1.05, letterSpacing: -1.0, color: KE.ink, marginTop: 6,
          }}>Register Your<br/>Machine</div>
          <div style={{
            fontFamily: FONT_BODY, fontSize: 14, color: KE.ink2,
            marginTop: 12, lineHeight: 1.5,
          }}>Initialize your vehicle’s digital twin on the Kinetic grid.</div>
        </div>

        {/* Step indicator */}
        <div style={{ padding: "20px 20px 0", display: "flex", alignItems: "center", gap: 8 }}>
          {["IDENTITY", "PERFORMANCE", "DRIVETRAIN", "STORY"].map((s, i) => (
            <React.Fragment key={s}>
              <div style={{
                display: "flex", alignItems: "center", gap: 6,
                opacity: i === 0 ? 1 : 0.45,
              }}>
                <div style={{
                  width: 18, height: 18, borderRadius: 5,
                  background: i === 0 ? KE.ink : KE.surface,
                  border: `1px solid ${i === 0 ? KE.ink : KE.line}`,
                  color: i === 0 ? KE.surface : KE.mute,
                  display: "grid", placeItems: "center",
                  fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                }}>{i + 1}</div>
                <span style={{
                  fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                  letterSpacing: 1.1, color: i === 0 ? KE.ink : KE.mute,
                }}>{s}</span>
              </div>
              {i < 3 && <div style={{ flex: 1, height: 1, background: KE.line }}/>}
            </React.Fragment>
          ))}
        </div>

        <div style={{ padding: "0 20px 32px" }}>
          {/* Primary asset */}
          <SectionTitle kicker="01 — IDENTITY" title="Visual & basics"/>

          <FormLabel>PRIMARY ASSET</FormLabel>
          <div style={{
            position: "relative", borderRadius: 14, height: 200,
            background: KE.bgSoft, border: `1.5px dashed ${KE.muteSoft}`,
            display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
            overflow: "hidden",
          }}>
            {/* faint car silhouette */}
            <svg width="280" height="120" viewBox="0 0 280 120" style={{
              position: "absolute", opacity: 0.08,
            }}>
              <path d="M20 80 L40 50 Q70 30 130 28 Q200 28 230 50 L260 60 L260 85 Q260 92 253 92 L233 92 Q230 78 218 78 Q206 78 203 92 L77 92 Q74 78 62 78 Q50 78 47 92 L27 92 Q20 92 20 85 Z" fill={KE.ink}/>
              <circle cx="62" cy="92" r="14" fill={KE.ink}/>
              <circle cx="218" cy="92" r="14" fill={KE.ink}/>
            </svg>
            <div style={{
              width: 64, height: 64, borderRadius: 14, background: KE.surface,
              display: "grid", placeItems: "center", border: `1px solid ${KE.line}`,
              zIndex: 1,
            }}>
              <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
                <path d="M3 7h3l2-3h8l2 3h3v12H3z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/>
                <circle cx="12" cy="13" r="4" stroke={KE.accent} strokeWidth="2"/>
                <path d="M19 5l3 0M20.5 3.5L20.5 6.5" stroke={KE.accent} strokeWidth="1.8" strokeLinecap="round"/>
              </svg>
            </div>
            <div style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 14,
              color: KE.ink, letterSpacing: -0.2, marginTop: 12, zIndex: 1,
            }}>Upload Studio Shot</div>
            <div style={{
              fontFamily: FONT_BODY, fontSize: 12, color: KE.mute, marginTop: 4, zIndex: 1,
            }}>Drag and drop high-res image (PNG, JPG)</div>
          </div>

          <div style={{ height: 18 }}/>

          <FieldGroup>
            <div>
              <FormLabel>BUILD NICKNAME</FormLabel>
              <TextField placeholder="e.g. Inka Beast"/>
            </div>
            <FieldRow>
              <div>
                <FormLabel>MAKE</FormLabel>
                <TextField placeholder="e.g. Porsche"/>
              </div>
              <div>
                <FormLabel>MODEL</FormLabel>
                <TextField placeholder="e.g. 911 GT3 RS"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel>YEAR</FormLabel>
                <TextField placeholder="2024"/>
              </div>
              <div>
                <FormLabel>TRIM / SPEC</FormLabel>
                <TextField placeholder="e.g. Weissach"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel>EXTERIOR COLOR</FormLabel>
                <SelectField placeholder="Select hue"/>
              </div>
              <div>
                <FormLabel>BODY STYLE</FormLabel>
                <SelectField placeholder="Coupe"/>
              </div>
            </FieldRow>
            <div>
              <FormLabel optional>BUILD IDENTIFIER</FormLabel>
              <TextField placeholder="e.g. G82-M4-01"/>
            </div>
          </FieldGroup>

          {/* Performance */}
          <SectionTitle kicker="02 — PERFORMANCE" title="Numbers on the dyno"/>
          <FieldGroup>
            <FieldRow>
              <div>
                <FormLabel>POWER</FormLabel>
                <TextField placeholder="620" suffix="HP"/>
              </div>
              <div>
                <FormLabel>TORQUE</FormLabel>
                <TextField placeholder="750" suffix="NM"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel>0-100 KM/H</FormLabel>
                <TextField placeholder="3.2" suffix="SEC"/>
              </div>
              <div>
                <FormLabel>TOP SPEED</FormLabel>
                <TextField placeholder="305" suffix="KM/H"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel>WEIGHT</FormLabel>
                <TextField placeholder="1645" suffix="KG"/>
              </div>
              <div>
                <FormLabel>POWER / WEIGHT</FormLabel>
                <TextField placeholder="auto-calc" suffix="HP/T"/>
              </div>
            </FieldRow>
          </FieldGroup>

          {/* Drivetrain */}
          <SectionTitle kicker="03 — DRIVETRAIN" title="Mechanical fingerprint"/>
          <FieldGroup>
            <div>
              <FormLabel>DRIVETRAIN</FormLabel>
              <SegRow options={["RWD", "FWD", "AWD"]} value="RWD"/>
            </div>
            <div>
              <FormLabel>TRANSMISSION</FormLabel>
              <SegRow options={["MANUAL", "AUTO", "DCT"]} value="DCT"/>
            </div>
            <FieldRow>
              <div>
                <FormLabel>ENGINE LAYOUT</FormLabel>
                <SelectField placeholder="Inline-6 Twin Turbo"/>
              </div>
              <div>
                <FormLabel>DISPLACEMENT</FormLabel>
                <TextField placeholder="2993" suffix="CC"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel>REDLINE</FormLabel>
                <TextField placeholder="7200" suffix="RPM"/>
              </div>
              <div>
                <FormLabel>FUEL</FormLabel>
                <SelectField placeholder="98 RON"/>
              </div>
            </FieldRow>
          </FieldGroup>

          {/* Story */}
          <SectionTitle kicker="04 — STORY" title="Tags & narrative"/>
          <FieldGroup>
            <div>
              <FormLabel>BUILD STATUS</FormLabel>
              <SegRow options={["DAILY", "WEEKEND", "TRACK"]} value="WEEKEND"/>
            </div>
            <div>
              <FormLabel optional>MODIFICATIONS</FormLabel>
              <div style={{
                minHeight: 96, borderRadius: 10, background: KE.surface,
                border: `1px solid ${KE.line}`, padding: "12px 14px",
                fontFamily: FONT_BODY, fontSize: 14, color: KE.muteSoft,
              }}>List performance upgrades or aesthetic modifications…</div>
            </div>
            <div>
              <FormLabel optional>HOME GARAGE</FormLabel>
              <TextField placeholder="Munich, DE"/>
            </div>
            <div>
              <FormLabel>VISIBILITY</FormLabel>
              <SegRow options={["PUBLIC", "FRIENDS", "PRIVATE"]} value="PUBLIC"/>
            </div>
          </FieldGroup>

          {/* Submit */}
          <button style={{
            marginTop: 28, width: "100%", height: 56, borderRadius: 12, border: "none",
            background: KE.accent, color: KE.onAccent,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            cursor: "pointer",
          }}>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.8,
            }}>REGISTER MACHINE</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill={KE.onAccent}>
              <path d="M13 2L3 14h7l-1 8 11-14h-7z"/>
            </svg>
          </button>

          <div style={{
            marginTop: 12, textAlign: "center",
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
            letterSpacing: 1.2, color: KE.mute, lineHeight: 1.6,
          }}>
            BY REGISTERING, YOU AGREE TO THE <span style={{ color: KE.accent }}>KINETIC TERMS OF ENGAGEMENT</span>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────
// ADD MODIFICATION — log entry form
// ─────────────────────────────────────────────────────────
function PhotoSlot({ label, hint }) {
  return (
    <div style={{
      position: "relative", aspectRatio: "1 / 1", borderRadius: 12,
      background: KE.bgSoft, border: `1.5px dashed ${KE.muteSoft}`,
      display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
      gap: 6, overflow: "hidden",
    }}>
      <div style={{
        position: "absolute", top: 8, left: 8,
        padding: "3px 7px", borderRadius: 6, background: KE.surface,
        border: `1px solid ${KE.line}`,
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9, letterSpacing: 1.4, color: KE.ink,
      }}>{label}</div>
      <div style={{
        width: 40, height: 40, borderRadius: 10, background: KE.surface,
        border: `1px solid ${KE.line}`, display: "grid", placeItems: "center",
      }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
          <path d="M3 7h3l2-3h8l2 3h3v12H3z" stroke={KE.accent} strokeWidth="2" strokeLinejoin="round"/>
          <circle cx="12" cy="13" r="3.5" stroke={KE.accent} strokeWidth="2"/>
        </svg>
      </div>
      <div style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
        letterSpacing: 1.2, color: KE.mute,
      }}>{hint}</div>
    </div>
  );
}

function ChangeChip({ label, onRemove }) {
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 6,
      padding: "6px 10px", borderRadius: 8, background: KE.bgSoft,
      border: `1px solid ${KE.line}`,
    }}>
      <span style={{
        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1, color: KE.ink,
      }}>{label}</span>
      <svg width="10" height="10" viewBox="0 0 24 24" fill="none">
        <path d="M6 6l12 12M18 6L6 18" stroke={KE.mute} strokeWidth="2.5" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function CategoryPill({ label, on }) {
  return (
    <div style={{
      padding: "8px 12px", borderRadius: 999,
      background: on ? KE.ink : KE.surface,
      border: `1px solid ${on ? KE.ink : KE.line}`,
      color: on ? KE.surface : KE.ink,
      fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2,
      whiteSpace: "nowrap",
    }}>{label}</div>
  );
}

function AddModificationScreen() {
  return (
    <div style={{
      width: 390, height: 844, background: KE.bg, position: "relative",
      fontFamily: FONT_BODY, color: KE.ink, overflow: "hidden",
      display: "flex", flexDirection: "column",
    }}>
      <div style={{ height: 54, flexShrink: 0, background: KE.bg }}/>
      <ModalTopBar/>

      <div style={{ flex: 1, minHeight: 0, overflowY: "auto" }}>
        {/* Header */}
        <div style={{ padding: "20px 20px 4px" }}>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
            letterSpacing: 2, color: KE.accent,
          }}>MODIFICATION LOG · NEW ENTRY</div>
          <div style={{
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 32,
            lineHeight: 1.05, letterSpacing: -1.0, color: KE.ink, marginTop: 6,
          }}>Log a Build<br/>Iteration</div>
          <div style={{
            display: "flex", alignItems: "center", gap: 8, marginTop: 14,
            padding: "10px 12px", borderRadius: 10, background: KE.surface,
            border: `1px solid ${KE.line}`,
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 7, overflow: "hidden",
              background: KE.bgSoft, flexShrink: 0,
              display: "grid", placeItems: "center",
            }}>
              <img src="assets/car-2.png" style={{ width: "100%", height: "100%", objectFit: "cover" }}/>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10,
                letterSpacing: 1.2, color: KE.mute,
              }}>FOR CHASSIS</div>
              <div style={{
                fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13,
                color: KE.ink, letterSpacing: -0.2, marginTop: 1,
              }}>BMW M4 Competition · G82-M4-01</div>
            </div>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
              <path d="M6 9l6 6 6-6" stroke={KE.mute} strokeWidth="2.2" strokeLinecap="round"/>
            </svg>
          </div>
        </div>

        <div style={{ padding: "0 20px 32px" }}>
          {/* Before / After */}
          <SectionTitle kicker="01 — DOCUMENTATION" title="Before & after"/>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
            <PhotoSlot label="BEFORE" hint="Tap to upload"/>
            <PhotoSlot label="AFTER"  hint="Tap to upload"/>
          </div>
          <div style={{
            marginTop: 8, fontFamily: FONT_BODY, fontSize: 12, color: KE.mute, lineHeight: 1.5,
          }}>Side-by-side shots will appear in your build timeline. Add up to 4 reference photos.</div>
          <div style={{
            marginTop: 12, display: "inline-flex", alignItems: "center", gap: 6,
            padding: "8px 12px", borderRadius: 8, background: KE.surface,
            border: `1px dashed ${KE.muteSoft}`, cursor: "pointer",
          }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14m-7-7h14" stroke={KE.ink} strokeWidth="2.5" strokeLinecap="round"/>
            </svg>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.ink,
            }}>ADD MORE PHOTOS</span>
          </div>

          {/* Identity */}
          <SectionTitle kicker="02 — IDENTITY" title="What did you do?"/>
          <FieldGroup>
            <div>
              <FormLabel>MODIFICATION TITLE</FormLabel>
              <TextField placeholder="e.g. Stage 2 ECU Remap & Downpipes"/>
            </div>
            <div>
              <FormLabel>CATEGORY</FormLabel>
              <div style={{ display: "flex", flexWrap: "wrap", gap: 6 }}>
                <CategoryPill label="ENGINE" on/>
                <CategoryPill label="EXHAUST" on/>
                <CategoryPill label="SUSPENSION"/>
                <CategoryPill label="WHEELS"/>
                <CategoryPill label="BRAKES"/>
                <CategoryPill label="AERO"/>
                <CategoryPill label="INTERIOR"/>
                <CategoryPill label="ELECTRONICS"/>
              </div>
            </div>
            <FieldRow>
              <div>
                <FormLabel>INSTALL DATE</FormLabel>
                <TextField placeholder="OCT 2023"/>
              </div>
              <div>
                <FormLabel>INSTALLER</FormLabel>
                <SelectField placeholder="Self / Shop"/>
              </div>
            </FieldRow>
          </FieldGroup>

          {/* Performance changes */}
          <SectionTitle kicker="03 — IMPACT" title="What changed?"/>
          <FieldGroup>
            <FieldRow>
              <div>
                <FormLabel>POWER</FormLabel>
                <TextField placeholder="+110" suffix="HP"/>
              </div>
              <div>
                <FormLabel>TORQUE</FormLabel>
                <TextField placeholder="+180" suffix="NM"/>
              </div>
            </FieldRow>
            <FieldRow>
              <div>
                <FormLabel optional>0-100 KM/H</FormLabel>
                <TextField placeholder="−0.4" suffix="SEC"/>
              </div>
              <div>
                <FormLabel optional>WEIGHT</FormLabel>
                <TextField placeholder="−4.2" suffix="KG"/>
              </div>
            </FieldRow>
            <div>
              <FormLabel optional>CUSTOM TAGS</FormLabel>
              <div style={{
                minHeight: 48, padding: "10px 12px", borderRadius: 10,
                background: KE.surface, border: `1px solid ${KE.line}`,
                display: "flex", flexWrap: "wrap", gap: 6, alignItems: "center",
              }}>
                <ChangeChip label="STAGE 2"/>
                <ChangeChip label="DECAT"/>
                <ChangeChip label="98 RON"/>
                <span style={{
                  fontFamily: FONT_BODY, fontSize: 13, color: KE.muteSoft,
                }}>Add tag…</span>
              </div>
            </div>
          </FieldGroup>

          {/* Description */}
          <SectionTitle kicker="04 — STORY" title="The details"/>
          <FieldGroup>
            <div>
              <FormLabel>DESCRIPTION</FormLabel>
              <div style={{
                minHeight: 110, borderRadius: 10, background: KE.surface,
                border: `1px solid ${KE.line}`, padding: "12px 14px",
                fontFamily: FONT_BODY, fontSize: 14, color: KE.muteSoft, lineHeight: 1.5,
              }}>Walk us through the install. What did you change, why, and how does it drive now?</div>
            </div>
            <FieldRow>
              <div>
                <FormLabel optional>PARTS COST</FormLabel>
                <TextField placeholder="2,400" suffix="EUR"/>
              </div>
              <div>
                <FormLabel optional>LABOR COST</FormLabel>
                <TextField placeholder="600" suffix="EUR"/>
              </div>
            </FieldRow>
            <div>
              <FormLabel>SHOW PRICE</FormLabel>
              <SegRow options={["PUBLIC", "FOLLOWERS", "HIDDEN"]} value="FOLLOWERS"/>
            </div>
            <div>
              <FormLabel optional>PARTS LIST</FormLabel>
              <div style={{
                borderRadius: 10, background: KE.surface,
                border: `1px solid ${KE.line}`, overflow: "hidden",
              }}>
                {[
                  { name: "BM3 Stage 2 Map", brand: "Bootmod3" },
                  { name: "Catless Downpipes", brand: "Akrapovič" },
                ].map((p, i, arr) => (
                  <div key={i} style={{
                    padding: "12px 14px", display: "flex", alignItems: "center", gap: 10,
                    borderBottom: i < arr.length - 1 ? `1px solid ${KE.line}` : "none",
                  }}>
                    <div style={{
                      width: 26, height: 26, borderRadius: 7, background: KE.bgSoft,
                      display: "grid", placeItems: "center", flexShrink: 0,
                    }}>
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none">
                        <path d="M14 3l7 7-11 11H3v-7z" stroke={KE.ink} strokeWidth="2" strokeLinejoin="round"/>
                      </svg>
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{
                        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13,
                        color: KE.ink, letterSpacing: -0.2,
                      }}>{p.name}</div>
                      <div style={{
                        fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 9,
                        letterSpacing: 1.2, color: KE.mute, marginTop: 2,
                      }}>{p.brand}</div>
                    </div>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <path d="M6 6l12 12M18 6L6 18" stroke={KE.mute} strokeWidth="2" strokeLinecap="round"/>
                    </svg>
                  </div>
                ))}
                <div style={{
                  padding: "12px 14px", display: "flex", alignItems: "center", gap: 8,
                  borderTop: `1px dashed ${KE.line}`, cursor: "pointer",
                }}>
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                    <path d="M12 5v14m-7-7h14" stroke={KE.accent} strokeWidth="2.5" strokeLinecap="round"/>
                  </svg>
                  <span style={{
                    fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 10, letterSpacing: 1.2, color: KE.accent,
                  }}>ADD PART</span>
                </div>
              </div>
            </div>
          </FieldGroup>

          {/* Preview card */}
          <SectionTitle kicker="PREVIEW" title="How it will appear"/>
          <ModEntry
            date="OCTOBER 2023"
            title="ECU REMAP & DOWNPIPES"
            body="Stage 2 software optimization. Increased turbo pressure and throttle response mapped for track use. Decat pipes installed for thermal efficiency."
            image="assets/car-2.png"
            image2="assets/car-3.png"
            gains={["+110 HP", "+180 NM", "STAGE 2"]}
            isLast
          />

          {/* Submit */}
          <button style={{
            marginTop: 24, width: "100%", height: 56, borderRadius: 12, border: "none",
            background: KE.accent, color: KE.onAccent,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            cursor: "pointer",
          }}>
            <span style={{
              fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 13, letterSpacing: 1.8,
            }}>PUBLISH ENTRY</span>
            <svg width="16" height="16" viewBox="0 0 24 24" fill={KE.onAccent}>
              <path d="M13 2L3 14h7l-1 8 11-14h-7z"/>
            </svg>
          </button>

          <button style={{
            marginTop: 8, width: "100%", height: 48, borderRadius: 12,
            background: "transparent", color: KE.ink2, border: `1px solid ${KE.line}`,
            fontFamily: FONT_DISPLAY, fontWeight: 700, fontSize: 11, letterSpacing: 1.6,
          }}>SAVE AS DRAFT</button>
        </div>
      </div>
    </div>
  );
}

window.CarDetailScreen        = CarDetailScreen;
window.AddCarScreen           = AddCarScreen;
window.AddModificationScreen  = AddModificationScreen;
