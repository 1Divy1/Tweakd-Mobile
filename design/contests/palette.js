// Shared palette — Kinetic Edge
// Warm-neutral whites, near-black ink, orange used only as a sparing accent.
// Imported by both Search and Profile pages so they stay in lockstep.

window.KE = {
  // Backgrounds (warm-neutral whites)
  bg:        "#F6F4F1",   // page background — slightly darker warm white
  bgSoft:    "#FAF8F5",   // gentle alt panel
  surface:   "#FFFFFF",   // cards, inputs — pure white to pop off bg

  // Ink — true near-black for hard contrast
  ink:       "#0A0A0A",   // primary text, logos, wordmark, active tab
  ink2:      "#3F3F46",   // secondary text
  mute:      "#8A8680",   // tertiary / metadata (warm grey)
  muteSoft:  "#B8B3AC",   // dimmest

  // Hairline borders (warm)
  line:      "#ECE8E2",
  line2:     "#F2EFE9",

  // Orange — used sparingly: primary CTAs, highlight, verified dot
  accent:    "#FF4D00",
  accentHot: "#E64500",   // pressed
  accentSoft:"#FFE4D6",   // tint behind highlight chip
  accentWash:"rgba(255,77,0,0.06)",
  onAccent:  "#FFFFFF",

  // Business — same lightness/chroma as accent, blue hue. Marks business organizers.
  business:     "oklch(65% 0.19 258)",
  businessWash: "oklch(65% 0.19 258 / 0.08)",
};

window.KE_FONT_DISPLAY = `"Space Grotesk", system-ui, sans-serif`;
window.KE_FONT_BODY    = `"Manrope", system-ui, sans-serif`;
