import 'package:equatable/equatable.dart';

/// A single image attached to a post, already resolved to a public URL by the
/// backend. [displayOrder] is the position in the post's carousel (0 = first).
class PostImageEntity extends Equatable {
  final String id;
  final String imageUrl;
  final int displayOrder;

  const PostImageEntity({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, imageUrl, displayOrder];
}
