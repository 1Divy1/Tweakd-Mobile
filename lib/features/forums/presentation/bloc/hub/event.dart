import 'package:equatable/equatable.dart';

import '../../../domain/entities/forum_filter.dart';
import '../../../domain/entities/forum_thread.dart';
import '../../../domain/entities/forum_topic.dart';

sealed class ForumHubEvent extends Equatable {
  const ForumHubEvent();

  @override
  List<Object?> get props => [];
}

/// First load of a hub: its thread list plus reference data (models for a
/// brand hub, topics for the refine chips).
class LoadForumHub extends ForumHubEvent {
  final ForumFilter filter;
  const LoadForumHub(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Switches the Hot / New / Active tab and reloads the thread list.
class ChangeForumHubSort extends ForumHubEvent {
  final ForumThreadSort sort;
  const ChangeForumHubSort(this.sort);

  @override
  List<Object?> get props => [sort];
}

/// In-page topic refinement via the chip row; null selects "All".
class SelectForumHubTopic extends ForumHubEvent {
  final ForumTopicEntity? topic;
  const SelectForumHubTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// Fetches the next page. No-op while loading or on the last page.
class LoadMoreForumHub extends ForumHubEvent {
  const LoadMoreForumHub();
}

/// Saves the hub's current filter as a shortcut (from the bottom sheet).
class SaveForumShortcut extends ForumHubEvent {
  final String name;
  final bool notify;
  const SaveForumShortcut({required this.name, required this.notify});

  @override
  List<Object?> get props => [name, notify];
}
