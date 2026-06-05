import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';

import '../error/base_exceptions.dart';

@lazySingleton
class CarImageService {
  final Dio _uploader = Dio();

  Future<Uint8List> compressToWebp(String filePath) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      filePath,
      format: CompressFormat.webp,
      quality: 80,
    );
    if (compressed == null) {
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
      throw ServerException('R2 upload failed: ${e.message}');
    }
  }
}
