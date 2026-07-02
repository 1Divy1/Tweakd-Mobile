import '../../domain/entities/feedback_type.dart';

class FeedbackTypeModel {
  final String id;
  final String type;

  const FeedbackTypeModel({required this.id, required this.type});

  factory FeedbackTypeModel.fromJson(Map<String, dynamic> json) {
    return FeedbackTypeModel(
      id: json['id'] as String,
      type: json['type'] as String,
    );
  }

  FeedbackTypeEntity toEntity() => FeedbackTypeEntity(id: id, label: type);
}
