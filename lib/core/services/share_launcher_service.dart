import 'dart:io' show File, Platform;
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/garage/domain/entities/car_share.dart';

/// Hands a share link to one specific app, or to the OS share sheet.
///
/// Per-app tiles exist instead of a single system-sheet button for one reason:
/// each one appends its own `?s=<channel>` tag, so the backend can eventually
/// say *where* the taps came from.
///
/// Every deep link falls back to the system sheet rather than failing — a tile
/// for an app the user doesn't have should still share something — and the tag
/// stays the tile's, not the sheet's. Only a plain "share anywhere" entry
/// point, which the sheet does not have today, is tagged `app`.
@lazySingleton
class ShareLauncherService {
  /// Opens [channel]'s compose screen with [text] and the tagged link.
  ///
  /// [origin] is the tile's position on screen, needed only so iPad anchors the
  /// popover somewhere sensible when this falls through to the system sheet.
  Future<void> shareTo(
    CarShareChannel channel, {
    required CarShareEntity link,
    required String text,
    Rect? origin,
  }) async {
    final url = link.urlFor(channel);
    final uri = _composeUri(channel, url: url, text: text);

    if (uri != null && await _launch(uri)) return;

    // No target app (or it refused, or the channel never had a deep link —
    // Instagram): the system sheet always exists. The tag stays the one the
    // user asked for, because what we want to count is which tile was tapped,
    // not how the OS got there.
    await shareSystem(link: link, text: text, channel: channel, origin: origin);
  }

  /// The OS share sheet. [channel] is what the URL is tagged with; it defaults
  /// to [CarShareChannel.system] for a plain "share anywhere" entry point.
  Future<void> shareSystem({
    required CarShareEntity link,
    required String text,
    CarShareChannel channel = CarShareChannel.system,
    Rect? origin,
  }) async {
    // URL last and on its own line: that is the shape most apps unfurl into a
    // rich preview rather than swallowing into the sentence.
    final body = '$text\n\n${link.urlFor(channel)}';
    await _share(ShareParams(text: body, sharePositionOrigin: origin));
  }

  /// Writes [svg] to a temporary file and offers it to the share sheet.
  ///
  /// A file, not an image: on iOS this is what puts "Save to Files" in the
  /// sheet, which is how a print-ready vector actually leaves the phone. The
  /// gallery cannot hold an SVG, so there is deliberately no "save to photos".
  ///
  /// Returns false when the file could not be written; the caller shows the
  /// error, since the share sheet never opened.
  Future<bool> shareSvgFile({
    required String svg,
    required String fileName,
    Rect? origin,
  }) async {
    final File file;
    try {
      final dir = await getTemporaryDirectory();
      file = File('${dir.path}/$fileName');
      await file.writeAsString(svg, flush: true);
    } catch (e) {
      debugPrint('🔗 writing $fileName failed: $e');
      return false;
    }

    await _share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/svg+xml')],
        sharePositionOrigin: origin,
      ),
    );
    return true;
  }

  /// The compose URL for [channel], or null when the channel has no deep link
  /// of its own and should go straight to the system sheet.
  Uri? _composeUri(
    CarShareChannel channel, {
    required String url,
    required String text,
  }) {
    final body = '$text\n\n$url';

    return switch (channel) {
      // iOS wants `sms:&body=`, Android `sms:?body=`. Both are the documented
      // form for their platform and neither tolerates the other's.
      CarShareChannel.messages => Uri.parse(
        Platform.isIOS
            ? 'sms:&body=${Uri.encodeComponent(body)}'
            : 'sms:?body=${Uri.encodeComponent(body)}',
      ),
      CarShareChannel.whatsapp => Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(body)}',
      ),
      CarShareChannel.telegram => Uri.parse(
        'https://t.me/share/url?url=${Uri.encodeComponent(url)}'
        '&text=${Uri.encodeComponent(text)}',
      ),
      CarShareChannel.x => Uri.parse(
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}'
        '&url=${Uri.encodeComponent(url)}',
      ),
      // Instagram has no URL that pre-fills a DM or a post; the system sheet
      // lists it, which is the whole of what v1 promises. (Stories sharing
      // needs a Meta app id — see the plan's Phase 5.2.)
      CarShareChannel.instagram => null,
      CarShareChannel.qr ||
      CarShareChannel.copy ||
      CarShareChannel.system => null,
    };
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception catch (e) {
      debugPrint('🔗 launching $uri failed: $e');
      return false;
    }
  }

  Future<void> _share(ShareParams params) async {
    try {
      await SharePlus.instance.share(params);
    } catch (e) {
      // A dismissed sheet is not an error, and neither is a platform that
      // refuses one — there is nothing useful to tell the user here.
      debugPrint('🔗 system share failed: $e');
    }
  }
}
