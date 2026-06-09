import 'package:equatable/equatable.dart';

class SearchResultEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const SearchResultEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}
