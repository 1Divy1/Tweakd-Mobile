import 'package:equatable/equatable.dart';

import '../../../../core/shared/entities/search_result.dart';
import '../utils/search_error_mapper.dart';

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
  final SearchErrorCode code;

  const SearchError({required this.query, required this.code});

  @override
  List<Object?> get props => [query, code];
}
