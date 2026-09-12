import 'package:flutter/material.dart';

/// The app's colour tokens, resolved against the active [brightness].
///
/// Every token is a **getter**, not a `const`. The app has ~2,300 colour
/// references across ~300 files, so threading a `BuildContext` through them
/// (the `ThemeExtension` approach) would mean editing all of them; resolving
/// against one process-wide brightness instead leaves every call site
/// unchanged. The brightness is set once per frame at the root — see
/// `TweakdApp` — and the whole tree rebuilds beneath it.
///
/// The consequence is that `const` expressions can no longer embed a token:
/// `const TextStyle(color: AppColors.ink)` stops compiling and becomes
/// `TextStyle(color: AppColors.ink)`. That is deliberate — a `const` colour is
/// a colour frozen at compile time, which is precisely the bug this file
/// exists to prevent, and the analyzer lists every occurrence.
///
/// **Never cache a token, or anything derived from one, in a `final` field.**
/// A top-level or `static final` binding is initialized once and then survives
/// every theme change, so it silently keeps the palette that happened to be
/// active on first build. Read tokens inside `build`/`paint` instead.
class AppColors {
  AppColors._();

  static Brightness _brightness = Brightness.light;

  static Brightness get brightness => _brightness;

  static bool get isDark => _brightness == Brightness.dark;

  /// Switches the palette. Returns whether the value actually changed, so the
  /// caller can skip a rebuild when it did not.
  static bool applyBrightness(Brightness value) {
    if (_brightness == value) return false;
    _brightness = value;
    return true;
  }

  // ---------------------------------------------------------------------
  // Surfaces. Layered ground -> raised: `bg` is the darkest thing on screen
  // in dark mode and anything sitting "on top" (cards, inputs, sheets, the
  // tab bar) is lighter. `bg` and `surface` are never the same value.
  // ---------------------------------------------------------------------

  /// The screen ground, behind everything.
  static Color get bg =>
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF6F4F1);

  /// A secondary panel: less prominent than a card, more than bare ground.
  static Color get bgSoft =>
      isDark ? const Color(0xFF141416) : const Color(0xFFFAF8F5);

  /// Cards, input fields, bottom sheets, the tab bar.
  static Color get surface =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Ink. Three distinct steps, always: primary -> secondary -> tertiary.
  // Never drop straight from `ink` to `mute`.
  // ---------------------------------------------------------------------

  /// Primary copy, headings, active tab, the wordmark.
  static Color get ink =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0A0A0A);

  /// Secondary copy: subtitles, helper text, bios.
  static Color get ink2 =>
      isDark ? const Color(0xFFC7C7CC) : const Color(0xFF3F3F46);

  /// Tertiary: timestamps, counts, metadata, idle tab glyphs.
  static Color get mute =>
      isDark ? const Color(0xFF8E8E93) : const Color(0xFF8A8680);

  /// Dimmest: placeholders and disabled states.
  ///
  /// The dark value is `#6E6E73` rather than the `#8A8A90` originally
  /// specified: that sat four units from [mute], which would have left
  /// disabled controls and hint text indistinguishable from ordinary
  /// metadata. `#6E6E73` restores the visible gap the light palette has.
  static Color get muteSoft =>
      isDark ? const Color(0xFF6E6E73) : const Color(0xFFB8B3AC);

  /// Text and icons on an inverted panel or button.
  ///
  /// Pairs with [ink] as a *fill*: a solid CTA is `ink` fill + `inkPanel`
  /// glyphs in both themes, so it un-inverts across the switch (dark fill with
  /// white text in light mode; white fill with dark text in dark mode) rather
  /// than merely getting darker.
  static Color get inkPanel =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

  /// Glyphs on a chip that is deliberately light in *both* themes — a white
  /// glass badge over a photo, say. Rare; prefer [inkPanel].
  static Color get onLight => const Color(0xFF0A0A0A);

  // ---------------------------------------------------------------------
  // Lines. For separation, not decoration — don't introduce a border where
  // the light design had none.
  // ---------------------------------------------------------------------

  /// Real dividers: list row separators, card edges.
  static Color get line =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFECE8E2);

  /// Hairlines that should barely register, e.g. under a header.
  static Color get line2 =>
      isDark ? const Color(0xFF242426) : const Color(0xFFF2EFE9);

  // ---------------------------------------------------------------------
  // Accent. Sparing: primary CTA fills, the verified badge, active-state
  // highlights, small indicator dots. Never body text, never large surfaces.
  // ---------------------------------------------------------------------

  // TODO: testing only
  // static Color get accent => const Color(0xFFFF4D00);
  static Color get accent => const Color.fromARGB(255, 219, 70, 15);

  /// Pressed state of [accent].
  static Color get accentHot => const Color(0xFFE64500);

  /// Solid tint behind a highlighted chip or row. Also the avatar placeholder
  /// fill — every glyph drawn on it uses [accent]/[accentHot], which stays
  /// legible in both themes.
  static Color get accentSoft =>
      isDark ? const Color(0xFF3A1608) : const Color(0xFFFFE4D6);

  /// Translucent press/hover overlay, laid *over* existing content. For a
  /// solid tint behind content use [accentSoft] instead.
  static Color get accentWash =>
      const Color(0xFFFF4D00).withValues(alpha: 0.10);

  /// Text and icons on an [accent] fill.
  static Color get onAccent => const Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Business / organizer marker. Theme-independent in hue: blue in both
  // themes, only lightness and chroma shift. Not affected by the accent
  // choice — don't recolour it to match.
  // ---------------------------------------------------------------------

  /// `oklch(72% 0.16 258)` in dark; `oklch(55% 0.17 258)` in light. The dark
  /// value sits fractionally outside sRGB, so its blue channel is clipped.
  static Color get business =>
      isDark ? const Color(0xFF61A4FF) : const Color(0xFF276ED2);

  /// [business] at 14% — the tint behind an organizer chip or row.
  static Color get businessWash => business.withValues(alpha: 0.14);

  // ---------------------------------------------------------------------
  // Destructive / error
  //
  // Not in the supplied spec, which covers no error colour. The light value is
  // the one already in `AppTheme`; the dark value lifts it to stay legible on
  // a near-black ground, where `#B3261E` reads as muddy brown. Both replace
  // the raw `Colors.red` (Material `#F44336`) scattered through delete flows,
  // which is harsher than anything else in the palette.
  // ---------------------------------------------------------------------

  /// Destructive actions, error text, invalid field borders.
  static Color get danger =>
      isDark ? const Color(0xFFFF6369) : const Color(0xFFB3261E);

  /// Text and icons on a [danger] fill.
  static Color get onDanger =>
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);

  /// Solid tint behind a destructive row or chip.
  static Color get dangerSoft =>
      isDark ? const Color(0xFF3A0F11) : const Color(0xFFFDECEE);

  // ---------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------

  /// Drop-shadow colour for raised elements.
  ///
  /// Transparent in dark mode: a black shadow over a `#0A0A0A` ground is
  /// invisible, and separation there already comes from [surface] being
  /// lighter than [bg]. Faking it with a light glow would read as a border
  /// the light design never had.
  static Color get shadow =>
      isDark ? const Color(0x00000000) : const Color(0x1F000000);

  /// Same policy as [shadow] but for call sites that need a specific
  /// intensity (e.g. a stronger shadow on a selected card) instead of the
  /// default one. [lightAlpha] is the 0-255 alpha used in light mode; dark
  /// mode always zeroes it out.
  static Color shadowAlpha(int lightAlpha) =>
      Color.fromARGB(isDark ? 0 : lightAlpha, 0, 0, 0);
}
