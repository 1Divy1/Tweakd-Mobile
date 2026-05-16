import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';

import '../error/base_exceptions.dart';

/// Handles the client side of the presigned-upload flow.
///
/// The backend creates the DB rows with deterministic storage paths and hands
/// back Supabase presigned upload URLs (token embedded in the query string).
/// This service compresses a picked image to webp and PUTs the bytes straight
/// to that URL. It deliberately uses a bare [Dio] with no interceptors so the
/// app's backend JWT is never sent to Supabase storage.
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

  /// Compresses [filePath] and uploads the bytes to a backend-issued presigned
  /// [uploadUrl]. Throws [ServerException] on any failure so the caller can
  /// trigger the car/modification rollback.
  Future<void> uploadToSignedUrl(String uploadUrl, String filePath) async {
    final bytes = await compressToWebp(filePath);
    await uploadBytes(uploadUrl, bytes);
  }

  Future<void> uploadBytes(String uploadUrl, Uint8List bytes) async {
    try {
      await _uploader.putUri(
        Uri.parse(uploadUrl),
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': 'image/webp',
            'Content-Length': bytes.length,
            'x-upsert': 'true',
          },
        ),
      );
    } on DioException catch (e) {
      throw ServerException('Image upload failed: ${e.message}');
    }
  }
}
