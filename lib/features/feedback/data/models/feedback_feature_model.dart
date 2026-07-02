import '../../domain/entities/feedback_feature.dart';

class FeedbackFeatureModel {
  final String id;
  final String name;

  const FeedbackFeatureModel({required this.id, required this.name});

  factory FeedbackFeatureModel.fromJson(Map<String, dynamic> json) {
    return FeedbackFeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  FeedbackFeatureEntity toEntity() => FeedbackFeatureEntity(id: id, name: name);
}
