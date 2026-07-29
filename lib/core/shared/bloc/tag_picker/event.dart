import 'package:equatable/equatable.dart';

sealed class TagPickerEvent extends Equatable {
  const TagPickerEvent();

  @override
  List<Object?> get props => [];
}

/// The people-search query changed. Debounced before hitting the network.
class PeopleQueryChanged extends TagPickerEvent {
  final String query;
  const PeopleQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Internal — fired after the debounce elapses to actually run the search.
class PeopleSearchRequested extends TagPickerEvent {
  final String query;
  const PeopleSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clears the people typeahead results (e.g. after one is picked).
class PeopleResultsCleared extends TagPickerEvent {
  const PeopleResultsCleared();
}

/// Loads a tagged person's garage so the user can pick a car to tag.
class OwnerCarsRequested extends TagPickerEvent {
  final String username;
  const OwnerCarsRequested(this.username);

  @override
  List<Object?> get props => [username];
}

/// Loads the viewer's own garage. Own cars can be tagged without tagging
/// yourself — the backend exempts the author's cars from the
/// owner-must-be-tagged rule. Loaded once and kept for the session.
class MyCarsRequested extends TagPickerEvent {
  const MyCarsRequested();
}
