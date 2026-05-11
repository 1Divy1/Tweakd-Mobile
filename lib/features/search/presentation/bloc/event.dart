import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

/// Internal event dispatched by the bloc after the debounce window elapses.
/// External callers should use [SearchQueryChanged] instead.
class PerformSearch extends SearchEvent {
  final String query;

  const PerformSearch(this.query);

  @override
  List<Object?> get props => [query];
}
