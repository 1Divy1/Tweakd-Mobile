import 'package:equatable/equatable.dart';

sealed class ForumBrowseEvent extends Equatable {
  const ForumBrowseEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the brand catalog and the topic groups for the two browse tabs.
class LoadForumBrowse extends ForumBrowseEvent {
  const LoadForumBrowse();
}
