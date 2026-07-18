/// A presigned avatar upload slot minted by `GET /api/storage/avatar`.
///
/// [key] is the R2 object key to hand back to `PATCH /profile/me/avatar`;
/// [uploadUrl] is the presigned URL the WebP bytes are PUT to (no auth header).
class AvatarUploadSlot {
  final String key;
  final String uploadUrl;

  const AvatarUploadSlot({required this.key, required this.uploadUrl});
}
