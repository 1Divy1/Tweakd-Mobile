import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/car_share.dart';
import 'share_origin.dart';

/// The look of one app in the share row: the squircle's fill and the white
/// mark drawn on it.
///
/// The marks are inline SVG rather than Material lookalikes (a camera outline
/// standing in for Instagram, a cross for X) because a share row is read by
/// shape at a glance — a wrong glyph makes the row look unfinished. They are
/// drawn as flat white on the brand fill, the way iOS draws its own row.
class ShareChannelStyle {
  final List<Color> fill;
  final String glyph;

  /// Fraction of the tile the mark occupies. Brand marks have different
  /// natural weights, so a couple are nudged to look optically equal.
  final double glyphScale;

  const ShareChannelStyle({
    required this.fill,
    required this.glyph,
    this.glyphScale = 0.5,
  });
}

const _messagesGlyph =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#fff" d="M12 2.6c-5.52 0-10 3.63-10 8.11 0 2.55 1.45 4.83 3.72 6.32.2.13.29.37.23.6l-.72 2.66c-.13.48.38.87.8.62l3.34-1.97c.16-.1.35-.13.53-.09.68.14 1.39.21 2.1.21 5.52 0 10-3.63 10-8.11S17.52 2.6 12 2.6Z"/>'
    '</svg>';

const _whatsappGlyph =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#fff" d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413Z"/>'
    '</svg>';

const _instagramGlyph =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#fff" d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069M12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24s3.668-.014 4.948-.072c4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0m0 5.838a6.162 6.162 0 1 0 0 12.325 6.162 6.162 0 0 0 0-12.325M12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8m6.406-11.845a1.44 1.44 0 1 0 0 2.881 1.44 1.44 0 0 0 0-2.881"/>'
    '</svg>';

const _xGlyph =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 1227">'
    '<path fill="#fff" d="M714.163 519.284 1160.89 0h-105.86L667.137 450.887 357.328 0H0l468.492 681.821L0 1226.37h105.866l409.625-476.152 327.181 476.152H1200L714.137 519.284zM569.165 687.828l-47.468-67.894L144.011 79.694h162.604l304.797 435.991 47.468 67.894 396.2 566.721H892.476z"/>'
    '</svg>';

const _telegramGlyph =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
    '<path fill="#fff" d="M9.78 18.65l.28-4.23 7.68-6.92c.34-.31-.07-.46-.52-.19L7.74 13.3 3.64 12c-.88-.25-.89-.86.2-1.3l15.97-6.16c.73-.33 1.43.18 1.15 1.3l-2.72 12.81c-.19.91-.74 1.13-1.5.71L12.6 16.3l-1.99 1.93c-.23.23-.42.42-.83.42z"/>'
    '</svg>';

/// Brand fills. Two-stop lists paint a top-left → bottom-right gradient, which
/// is what Messages and Telegram actually look like; Instagram needs three.
ShareChannelStyle shareChannelStyle(CarShareChannel channel) =>
    switch (channel) {
      CarShareChannel.messages => const ShareChannelStyle(
        fill: [Color(0xFF5BF675), Color(0xFF1FC44A)],
        glyph: _messagesGlyph,
        glyphScale: 0.54,
      ),
      CarShareChannel.whatsapp => const ShareChannelStyle(
        fill: [Color(0xFF5BF675), Color(0xFF25D366)],
        glyph: _whatsappGlyph,
        glyphScale: 0.52,
      ),
      CarShareChannel.instagram => const ShareChannelStyle(
        fill: [Color(0xFFFEDA75), Color(0xFFD62976), Color(0xFF4F5BD5)],
        glyph: _instagramGlyph,
        glyphScale: 0.52,
      ),
      CarShareChannel.x => const ShareChannelStyle(
        fill: [Color(0xFF1A1A1A), Color(0xFF000000)],
        glyph: _xGlyph,
        glyphScale: 0.44,
      ),
      CarShareChannel.telegram => const ShareChannelStyle(
        fill: [Color(0xFF37BBFE), Color(0xFF007DBB)],
        glyph: _telegramGlyph,
        glyphScale: 0.54,
      ),
      // qr, copy and system never render as a tile — they have their own
      // rows in the sheet — but the switch has to be total.
      _ => ShareChannelStyle(
        fill: [AppColors.ink2, AppColors.ink],
        glyph: _messagesGlyph,
      ),
    };

/// One app in the share row, iOS-style: a brand-filled squircle with a white
/// mark and the app's name underneath, dimming on press.
class ShareChannelTile extends StatefulWidget {
  final CarShareChannel channel;
  final String label;
  final double size;

  /// Handed the tile's position on screen, which iPad needs to anchor the
  /// system share popover when a channel falls back to it.
  final void Function(Rect? origin) onTap;

  const ShareChannelTile({
    super.key,
    required this.channel,
    required this.label,
    required this.onTap,
    this.size = 60,
  });

  @override
  State<ShareChannelTile> createState() => _ShareChannelTileState();
}

class _ShareChannelTileState extends State<ShareChannelTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final style = shareChannelStyle(widget.channel);
    final size = widget.size;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () => widget.onTap(shareOriginOf(context)),
        child: SizedBox(
          width: size + 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _pressed ? 0.92 : 1,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOut,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: style.fill,
                    ),
                    // iOS app icons sit at roughly 22% of their side.
                    borderRadius: BorderRadius.circular(size * 0.22),
                    boxShadow: [
                      BoxShadow(
                        color: style.fill.last.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.string(
                    style.glyph,
                    width: size * style.glyphScale,
                    height: size * style.glyphScale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
