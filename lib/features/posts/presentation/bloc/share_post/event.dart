import 'package:equatable/equatable.dart';

abstract class SharePostEvent extends Equatable {
  const SharePostEvent();

  @override
  List<Object?> get props => [];
}

/// Shares [postId]; a non-blank [content] quote-shares with that note attached,
/// a null/blank one does a plain share.
class SubmitShare extends SharePostEvent {
  final String postId;
  final String? content;

  const SubmitShare({required this.postId, this.content});

  @override
  List<Object?> get props => [postId, content];
}
