import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/forum_thread.dart';
import '../../../domain/entities/forum_topic.dart';

sealed class ForumsHomeEvent extends Equatable {
  const ForumsHomeEvent();

  @override
  List<Object?> get props => [];
}

/// First load: shortcuts + hot feed + topics (for the empty-state hub
/// suggestions), with a full-screen loading state.
class LoadForumsHome extends ForumsHomeEvent {
  const LoadForumsHome();
}

/// Pull-to-refresh / re-sync after returning from another forums screen.
/// [completer], when provided, is completed once the refresh settles so the
/// indicator can stop even when nothing changed.
class RefreshForumsHome extends ForumsHomeEvent {
  final Completer<void>? completer;
  const RefreshForumsHome([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Switches the Hot / New / Active tab and reloads the thread list.
class ChangeForumsHomeSort extends ForumsHomeEvent {
  final ForumThreadSort sort;
  const ChangeForumsHomeSort(this.sort);

  @override
  List<Object?> get props => [sort];
}

/// Fetches the next feed page. No-op while loading or on the last page.
class LoadMoreForumsHome extends ForumsHomeEvent {
  const LoadMoreForumsHome();
}

/// Pins a topic from the empty state's "popular hubs" suggestions.
class PinForumTopicShortcut extends ForumsHomeEvent {
  final ForumTopicEntity topic;
  const PinForumTopicShortcut(this.topic);

  @override
  List<Object?> get props => [topic];
}

/// Deletes a shortcut (edit mode), optimistically.
class RemoveForumShortcut extends ForumsHomeEvent {
  final String shortcutId;
  const RemoveForumShortcut(this.shortcutId);

  @override
  List<Object?> get props => [shortcutId];
}

/// Moves a shortcut within the row (edit mode), optimistically, then persists
/// the full order.
class MoveForumShortcut extends ForumsHomeEvent {
  final int oldIndex;
  final int newIndex;
  const MoveForumShortcut(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
