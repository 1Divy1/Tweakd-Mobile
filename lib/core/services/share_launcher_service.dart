import 'dart:io' show File, Platform;
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/garage/domain/entities/car_share.dart';
import '../utils/qr_png_rasterizer.dart';

/// How [ShareLauncherService.saveQrImage] ended. Cancelled is separate from
/// failed because only one of the two is worth telling the user about.
enum QrSaveResult { saved, cancelled, failed }

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

  /// The OS share sheet for a public URL — the link and nothing else.
  ///
  /// Shared as a `uri`, not as text, so the sheet's own "Copy" puts a bare URL
  /// on the clipboard that pastes straight into a browser; a sentence in front
  /// of it would break that. Nothing is lost: messaging apps build their
  /// preview card (title, photo) from the page's og tags, and iOS shows the
  /// page's title and icon at the top of the sheet. [title] is not part of the
  /// payload — it only labels the chooser on Android and becomes the subject
  /// when the user picks email.
  ///
  /// Used for shared events, which have no per-channel tags: nothing counts an
  /// event's views.
  Future<void> shareLink({
    required String url,
    String? title,
    Rect? origin,
  }) async {
    await _share(ShareParams(
      uri: Uri.parse(url),
      title: title,
      subject: title,
      sharePositionOrigin: origin,
    ));
  }

  /// Rasterises [svg] to a PNG and opens the OS *save* dialog on it.
  ///
  /// PNG and not the SVG the backend serves, even though the vector is the
  /// better print master — see [rasterizeQrToPng] for why.
  ///
  /// Deliberately the save dialog and not the share sheet. The share sheet
  /// hands the file to another app, and what the user actually asked for is a
  /// copy on the phone. This is `ACTION_CREATE_DOCUMENT` on Android and the
  /// Files "export" picker on iOS: the user chooses a folder and the file
  /// lands there.
  ///
  /// Needs no storage permission on either platform — the user picking the
  /// destination is what grants the write.
  Future<QrSaveResult> saveQrImage({
    required String svg,
    required String fileName,
  }) async {
    final File file;
    try {
      final png = await rasterizeQrToPng(svg);
      final dir = await getTemporaryDirectory();
      file = File('${dir.path}/$fileName');
      await file.writeAsBytes(png, flush: true);
    } catch (e) {
      debugPrint('🔗 writing $fileName failed: $e');
      return QrSaveResult.failed;
    }

    try {
      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: fileName,
          mimeTypesFilter: const ['image/png'],
        ),
      );
      // Null means the user backed out of the picker, which is not a failure
      // and must not raise an error toast at them.
      return savedPath == null ? QrSaveResult.cancelled : QrSaveResult.saved;
    } catch (e) {
      debugPrint('🔗 saving $fileName failed: $e');
      return QrSaveResult.failed;
    }
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

  /// Hands an in-memory image to the OS share sheet — the winner card, drawn
  /// by the app and never stored. The bytes go through a temp file because
  /// share_plus shares files by path; the file is small and the OS reaps
  /// the temp directory.
  Future<void> shareImage(
    Uint8List bytes, {
    required String fileName,
    String? text,
    Rect? origin,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await _share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
        sharePositionOrigin: origin,
      ));
    } catch (e) {
      debugPrint('🔗 image share failed: $e');
    }
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
