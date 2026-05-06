import '../../domain/entities/search_result.dart';

class SearchResultModel {
  final String id;
  final String username;
  final String? avatarUrl;

  const SearchResultModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  SearchResultEntity toEntity() {
    return SearchResultEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
    );
  }
}
