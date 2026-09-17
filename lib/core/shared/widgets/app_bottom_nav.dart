import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import 'create_sheet.dart';
import '../layout/app_layout.dart';

/// The tabs that can be the current one. The map is absent — it runs
/// full-bleed without the bar — and create is an action, never a place.
enum AppBottomNavTab { feed, search, profile }

/// The app's tab bar: Feed · Map · Create · Search · Profile.
///
/// Icon-only and edge-to-edge with a hairline top edge. The active tab is its
/// filled glyph in ink, the rest are outlines in warm grey — no underline, no
/// second colour. Create sits in the centre as the one solid mark in the bar,
/// deliberately the loudest thing on screen: a young network lives or dies on
/// people posting.
class AppBottomNav extends StatelessWidget {
  final AppBottomNavTab activeTab;

  /// Called when a composer opened from the create button closes, so the host
  /// tab can refresh what it shows. The composers don't report whether
  /// anything was published, so this fires on a cancel too.
  final ValueChanged<CreateAction>? onCreateClosed;

  const AppBottomNav({super.key, required this.activeTab, this.onCreateClosed});

  Future<void> _create(BuildContext context) async {
    HapticFeedback.lightImpact();
    final action = await showCreateSheet(context);
    if (action == null || !context.mounted) return;
    await context.push(action.route);
    if (context.mounted) onCreateClosed?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      // The bar paints edge to edge; its slots stay within the reading column
      // so five icons don't spread across a tablet.
      child: SafeArea(
        top: false,
        minimum: AppLayout.inset(context),
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              Expanded(
                child: _TabSlot(
                  glyph: _Glyph.feed,
                  label: l10n.navFeed,
                  isActive: activeTab == AppBottomNavTab.feed,
                  onTap: () => context.go('/feed'),
                ),
              ),
              Expanded(
                child: _TabSlot(
                  glyph: _Glyph.map,
                  label: l10n.navMap,
                  isActive: false,
                  // The map takes the full screen, so it is pushed onto the
                  // stack rather than swapped in like the other tabs.
                  onTap: () => context.push('/map'),
                ),
              ),
              Expanded(
                child: _CreateSlot(
                  label: l10n.navCreate,
                  onTap: () => _create(context),
                ),
              ),
              Expanded(
                child: _TabSlot(
                  glyph: _Glyph.search,
                  label: l10n.navSearch,
                  isActive: activeTab == AppBottomNavTab.search,
                  onTap: () => context.go('/search'),
                ),
              ),
              Expanded(
                child: _TabSlot(
                  glyph: _Glyph.profile,
                  label: l10n.navProfile,
                  isActive: activeTab == AppBottomNavTab.profile,
                  onTap: () => context.go('/profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Glyph { feed, map, search, profile }

/// `#RRGGBB` for an SVG attribute.
String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// The tab glyphs, from the design's `tabbar.jsx`: an outline when idle, filled
/// when active. Search has nothing to fill, so it gets a heavier stroke; the
/// map is never active (it has no bar), so it only has the outline.
String _glyphSvg(_Glyph glyph, {required bool active}) {
  final ink = _hex(active ? AppColors.ink : AppColors.mute);
  final body = switch (glyph) {
    _Glyph.feed =>
      active
          ? '<path d="M12 3.3 20.7 11.4v7.9a1.7 1.7 0 0 1-1.7 1.7H5a1.7 1.7 0 0 1-1.7-1.7v-7.9z" fill="$ink"/>'
          : '<path d="M3.9 11.3 12 4.1l8.1 7.2v8a1.7 1.7 0 0 1-1.7 1.7H5.6a1.7 1.7 0 0 1-1.7-1.7z" fill="none" stroke="$ink" stroke-width="1.7" stroke-linejoin="round"/>',
    _Glyph.map =>
      '<path d="M9 3.8 3.4 5.7v14.5L9 18.3l6 1.9 5.6-1.9V3.8L15 5.7z" fill="none" stroke="$ink" stroke-width="1.7" stroke-linejoin="round"/>'
          '<path d="M9 3.8v14.5M15 5.7v14.5" fill="none" stroke="$ink" stroke-width="1.7" stroke-linejoin="round"/>',
    _Glyph.search =>
      '<circle cx="10.7" cy="10.7" r="6.8" fill="none" stroke="$ink" stroke-width="${active ? 2.6 : 1.8}"/>'
          '<path d="M15.7 15.7 20.4 20.4" fill="none" stroke="$ink" stroke-width="${active ? 2.6 : 1.8}" stroke-linecap="round"/>',
    _Glyph.profile =>
      active
          ? '<circle cx="12" cy="8.1" r="4" fill="$ink"/>'
                '<path d="M12 13.6c4 0 7.2 3.1 7.2 7H4.8c0-3.9 3.2-7 7.2-7z" fill="$ink"/>'
          : '<circle cx="12" cy="8.1" r="4" fill="none" stroke="$ink" stroke-width="1.7"/>'
                '<path d="M4.8 20.6c0-3.9 3.2-7 7.2-7s7.2 3.1 7.2 7" fill="none" stroke="$ink" stroke-width="1.7" stroke-linejoin="round"/>',
  };
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$body</svg>';
}

/// A solid ink disc with an un-inverting plus.
///
/// A function, not a `final`: a top-level binding is initialized once and
/// would keep serving whichever palette was active on the first build, so the
/// disc would stay black after a switch to dark mode. The plus is [inkPanel]
/// rather than a literal white for the same reason — in dark mode the disc is
/// white, and a white plus on it would be invisible.
String _createSvg() =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28">'
    '<circle cx="14" cy="14" r="12.2" fill="${_hex(AppColors.ink)}"/>'
    '<rect x="12.95" y="7.9" width="2.1" height="12.2" rx="1.05" fill="${_hex(AppColors.inkPanel)}"/>'
    '<rect x="7.9" y="12.95" width="12.2" height="2.1" rx="1.05" fill="${_hex(AppColors.inkPanel)}"/>'
    '</svg>';

class _TabSlot extends StatelessWidget {
  final _Glyph glyph;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabSlot({
    required this.glyph,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Re-tapping the current tab would only rebuild the page.
        onTap: isActive ? null : onTap,
        child: Center(
          child: SvgPicture.string(
            _glyphSvg(glyph, active: isActive),
            width: 25,
            height: 25,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

/// The centre create button. Sinks a little under the finger, so the most
/// important control in the bar also feels the most physical.
class _CreateSlot extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CreateSlot({required this.label, required this.onTap});

  @override
  State<_CreateSlot> createState() => _CreateSlotState();
}

class _CreateSlotState extends State<_CreateSlot> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.86 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: SvgPicture.string(
              _createSvg(),
              width: 30,
              height: 30,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
