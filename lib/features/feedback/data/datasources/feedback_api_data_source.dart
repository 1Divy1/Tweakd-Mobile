import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/feedback_feature_model.dart';
import '../models/feedback_type_model.dart';
import '../models/my_feedback_model.dart';

/// Talks to the feedback endpoints under the shared API base
/// (`$API_BASE_URL/api/v1`). The submit POST returns 204 No Content; the GETs
/// return JSON arrays.
@lazySingleton
class FeedbackApiDataSource {
  final AbstractHTTP http;

  FeedbackApiDataSource(this.http);

  Future<List<FeedbackTypeModel>> getTypes() async {
    final data = await http.get('/feedback/types');
    return (data as List<dynamic>)
        .map((e) => FeedbackTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeedbackFeatureModel>> getFeatures() async {
    final data = await http.get('/feedback/features');
    return (data as List<dynamic>)
        .map((e) => FeedbackFeatureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submits a feedback. Optional [feature] / [reproductionSteps] are only put on
  /// the wire when present. Keys are snake_case per the backend contract.
  Future<void> submitFeedback({
    required String content,
    required String type,
    String? feature,
    String? reproductionSteps,
  }) async {
    final body = <String, dynamic>{'content': content, 'type': type};
    if (feature != null) body['feature'] = feature;
    if (reproductionSteps != null) {
      body['reproduction_steps'] = reproductionSteps;
    }
    await http.post('/feedback', body: body);
  }

  /// The feedback the current user has filed (reporter taken from the JWT).
  Future<List<MyFeedbackModel>> getMyFeedback() async {
    final data = await http.get('/feedback/mine');
    return (data as List<dynamic>)
        .map((e) => MyFeedbackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
