import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/feedback_feature.dart';
import '../entities/feedback_type.dart';
import '../entities/my_feedback.dart';

/// Draft of a feedback submission gathered on the submit screen. [feature] and
/// [reproductionSteps] are optional and omitted from the request when null.
class FeedbackSubmission {
  final String content;
  final String typeId;
  final String? featureId;
  final String? reproductionSteps;

  const FeedbackSubmission({
    required this.content,
    required this.typeId,
    this.featureId,
    this.reproductionSteps,
  });
}

abstract class FeedbackRepository {
  /// The feedback categories offered in the type picker.
  Future<Either<Failure, List<FeedbackTypeEntity>>> getTypes();

  /// The app features the feedback can optionally be tied to.
  Future<Either<Failure, List<FeedbackFeatureEntity>>> getFeatures();

  /// Submits a piece of feedback for the current user.
  Future<Either<Failure, void>> submitFeedback(FeedbackSubmission submission);

  /// The feedback the current user has filed, newest-first.
  Future<Either<Failure, List<MyFeedbackEntity>>> getMyFeedback();
}
