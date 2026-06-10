import 'package:equatable/equatable.dart';

import '../../../../core/shared/entities/search_result.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSuccess extends SearchState {
  final String query;
  final List<SearchResultEntity> results;

  const SearchSuccess({required this.query, required this.results});

  @override
  List<Object?> get props => [query, results];
}

class SearchError extends SearchState {
  final String query;
  final String message;

  const SearchError({required this.query, required this.message});

  @override
  List<Object?> get props => [query, message];
}
