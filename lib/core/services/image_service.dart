import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';

import '../error/base_exceptions.dart';

/// A picked image whose WebP compression is kicked off immediately on
/// selection, so the (relatively slow) compression work overlaps with the user
/// filling in the rest of the wizard instead of blocking the submit button.
///
/// [path] is the original local file path, kept for showing a preview.
/// [bytes] is the compression future — already in flight; `await` it at upload
/// time, by which point it is usually already complete.
class CompressedImage {
  final String path;
  final Future<Uint8List> bytes;

  const CompressedImage._(this.path, this.bytes);

  factory CompressedImage.compress(String path, ImageService service) {
    final bytes = service.compressToWebp(path);
    // Attach a no-op observer so that, if compression fails before anything
    // awaits [bytes] (e.g. the user abandons the wizard), it is not reported as
    // an unhandled async error. The original future still surfaces the error to
    // the `await` at upload time.
    bytes.then((_) {}, onError: (_) {});
    return CompressedImage._(path, bytes);
  }
}

@lazySingleton
class ImageService {
  final Dio _uploader = Dio();

  Future<Uint8List> compressToWebp(String filePath) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      filePath,
      format: CompressFormat.webp,
      quality: 80,
    );
    if (compressed == null) {
      debugPrint('⚠️  WebP compression returned null for: $filePath');
      throw ServerException('Image compression failed.');
    }
    return compressed;
  }

  /// Compresses [filePath] to webp and uploads the bytes to [uploadUrl] on R2.
  Future<void> uploadToSignedUrl(String uploadUrl, String filePath) async {
    final bytes = await compressToWebp(filePath);
    await uploadToR2(uploadUrl, bytes);
  }

  /// PUT [bytes] directly to Cloudflare R2 via a presigned [uploadUrl].
  /// No JWT is added — auth is embedded in the presigned URL query parameters.
  /// [contentType] must match what the backend hard-coded when it generated the
  /// URL (image/webp for cover and gallery, image/webp or video/mp4 for mods).
  Future<void> uploadToR2(
    String uploadUrl,
    Uint8List bytes, {
    String contentType = 'image/webp',
  }) async {
    try {
      await _uploader.putUri(
        Uri.parse(uploadUrl),
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
      );
    } on DioException catch (e) {
      throw ServerException(
        'R2 upload failed (${e.response?.statusCode}): '
        '${e.response?.data ?? e.message}',
      );
    }
  }
}
