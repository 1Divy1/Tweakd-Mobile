import 'package:equatable/equatable.dart';

sealed class ForumBrowseEvent extends Equatable {
  const ForumBrowseEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the brand catalog shown on the browse page.
class LoadForumBrowse extends ForumBrowseEvent {
  const LoadForumBrowse();
}
