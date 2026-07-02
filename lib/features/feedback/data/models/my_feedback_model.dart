import '../../domain/entities/my_feedback.dart';

class MyFeedbackStatusModel {
  final String id;
  final String name;
  final String? color;

  const MyFeedbackStatusModel({
    required this.id,
    required this.name,
    required this.color,
  });

  factory MyFeedbackStatusModel.fromJson(Map<String, dynamic> json) {
    return MyFeedbackStatusModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }

  MyFeedbackStatusEntity toEntity() {
    return MyFeedbackStatusEntity(id: id, name: name, color: color);
  }
}

class MyFeedbackModel {
  final String id;
  final String content;
  final String type;
  final String? feature;
  final String? reproductionSteps;
  final String? response;
  final MyFeedbackStatusModel status;
  final String createdAt;

  const MyFeedbackModel({
    required this.id,
    required this.content,
    required this.type,
    required this.feature,
    required this.reproductionSteps,
    required this.response,
    required this.status,
    required this.createdAt,
  });

  factory MyFeedbackModel.fromJson(Map<String, dynamic> json) {
    return MyFeedbackModel(
      id: json['id'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      feature: json['feature'] as String?,
      reproductionSteps: json['reproduction_steps'] as String?,
      response: json['response'] as String?,
      status: MyFeedbackStatusModel.fromJson(
        json['status'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
    );
  }

  MyFeedbackEntity toEntity() {
    return MyFeedbackEntity(
      id: id,
      content: content,
      type: type,
      feature: feature,
      reproductionSteps: reproductionSteps,
      response: response,
      status: status.toEntity(),
      createdAt: DateTime.parse(createdAt),
    );
  }
}
