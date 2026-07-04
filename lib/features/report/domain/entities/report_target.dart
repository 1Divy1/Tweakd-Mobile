import 'package:equatable/equatable.dart';

/// What the user is reporting. Each variant carries the identifiers the backend
/// needs and, implicitly, which set of preset reasons applies. The report
/// repository switches on this to pick the right endpoints.
sealed class ReportTarget extends Equatable {
  const ReportTarget();

  @override
  List<Object?> get props => [];
}

class PostReportTarget extends ReportTarget {
  final String postId;
  const PostReportTarget(this.postId);

  @override
  List<Object?> get props => [postId];
}

class CommentReportTarget extends ReportTarget {
  final String postId;
  final String commentId;
  const CommentReportTarget({required this.postId, required this.commentId});

  @override
  List<Object?> get props => [postId, commentId];
}

class ProfileReportTarget extends ReportTarget {
  final String username;
  const ProfileReportTarget(this.username);

  @override
  List<Object?> get props => [username];
}

class ForumThreadReportTarget extends ReportTarget {
  final String threadId;
  const ForumThreadReportTarget(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

class ForumReplyReportTarget extends ReportTarget {
  final String postId;
  const ForumReplyReportTarget(this.postId);

  @override
  List<Object?> get props => [postId];
}
