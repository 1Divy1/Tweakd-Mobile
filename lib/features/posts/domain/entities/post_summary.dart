import 'package:car_social_media_app/core/shared/entities/image_ref.dart';
import 'package:equatable/equatable.dart';

class PostSummaryEntity extends Equatable {
  final String id;
  final ImageRef image;

  const PostSummaryEntity({
    required this.id,
    required this.image
  });
  
  @override
  List<Object?> get props => [id, image];
}