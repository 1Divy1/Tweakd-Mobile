import 'package:equatable/equatable.dart';

import '../../utils/post_error_mapper.dart';

enum ShareStatus { idle, submitting, success, failure }

class SharePostState extends Equatable {
  final ShareStatus status;

  /// Set only when [status] is [ShareStatus.failure].
  final PostErrorCode? errorCode;

  const SharePostState({this.status = ShareStatus.idle, this.errorCode});

  bool get isSubmitting => status == ShareStatus.submitting;

  SharePostState copyWith({ShareStatus? status, PostErrorCode? errorCode}) {
    return SharePostState(
      status: status ?? this.status,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [status, errorCode];
}
