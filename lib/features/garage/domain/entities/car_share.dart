import 'package:equatable/equatable.dart';

/// A car's public share link, as its owner sees it.
///
/// Owner-only: the backend exposes this shape on
/// `/garage/cars/{carId}/share` and nowhere else, so nobody but the owner can
/// discover that a car is shared or what its code is.
///
/// [url] deliberately carries no query string. Every share target appends its
/// own `?s=<channel>` tag (see [CarShareChannel]) so the backend can tell a QR
/// scan apart from a tapped link — which is the one number that answers "is
/// the printed sticker doing anything?".
class CarShareEntity extends Equatable {
  /// Canonical uppercase code, e.g. `7KQ3M9XA2F`.
  final String code;

  /// `https://web.tweakdapp.com/c/{code}` — no `?s=` tag.
  final String url;

  /// What the QR code encodes: [url] + `?s=qr`.
  final String qrUrl;

  /// False = paused by the owner. The public page answers 410, but the code —
  /// and therefore any printed sticker — stays valid and can be resumed.
  final bool enabled;

  final DateTime? createdAt;

  /// Counted visits that were not QR scans. Crawler previews are excluded
  /// server-side.
  final int viewCount;

  /// Counted visits that carried `?s=qr`.
  final int qrScanCount;

  final DateTime? lastViewedAt;

  const CarShareEntity({
    required this.code,
    required this.url,
    required this.qrUrl,
    required this.enabled,
    this.createdAt,
    this.viewCount = 0,
    this.qrScanCount = 0,
    this.lastViewedAt,
  });

  /// [url] with a channel tag appended, ready to hand to a share target.
  String urlFor(CarShareChannel channel) => '$url?s=${channel.tag}';

  /// [url] without its scheme — what the "Copy link" row previews
  /// (`web.tweakdapp.com/c/7KQ3M9XA2F`).
  String get displayUrl =>
      url.replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'/$'), '');

  /// The code in `7KQ3-M9XA-2F` groups, for the line under the QR: a sticker
  /// damaged past scanning can still be typed into the website by hand.
  String get groupedCode {
    final buffer = StringBuffer();
    for (var i = 0; i < code.length; i += 4) {
      if (i > 0) buffer.write('-');
      buffer.write(code.substring(i, i + 4 > code.length ? code.length : i + 4));
    }
    return buffer.toString();
  }

  CarShareEntity copyWith({bool? enabled}) => CarShareEntity(
    code: code,
    url: url,
    qrUrl: qrUrl,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt,
    viewCount: viewCount,
    qrScanCount: qrScanCount,
    lastViewedAt: lastViewedAt,
  );

  @override
  List<Object?> get props => [
    code,
    url,
    qrUrl,
    enabled,
    createdAt,
    viewCount,
    qrScanCount,
    lastViewedAt,
  ];
}

/// Where a share was sent from, appended to the URL as `?s=<tag>`.
///
/// The backend collapses everything except [qr] into one "link" counter today.
/// The app tags every channel anyway, from day one: turning that into
/// per-channel numbers then costs one migration instead of a client release
/// plus the months it takes users to update.
enum CarShareChannel {
  qr('qr'),
  copy('copy'),
  messages('sms'),
  whatsapp('wa'),
  instagram('ig'),
  x('x'),
  telegram('tg'),

  /// The OS share sheet, used as the fallback when a target app is missing.
  system('app');

  const CarShareChannel(this.tag);

  final String tag;
}

/// What the app gets back after resolving a scanned or tapped share code:
/// enough to open the native car screen, and nothing more.
class CarShareResolutionEntity extends Equatable {
  final String carId;
  final String ownerUsername;

  const CarShareResolutionEntity({
    required this.carId,
    required this.ownerUsername,
  });

  @override
  List<Object?> get props => [carId, ownerUsername];
}
