import 'package:equatable/equatable.dart';

sealed class ComposeEvent extends Equatable {
  const ComposeEvent();

  @override
  List<Object?> get props => [];
}

/// Search-as-you-type over the users the viewer can message.
class ComposeQueryChanged extends ComposeEvent {
  final String query;
  const ComposeQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
