import '../../domain/entities/language_option.dart';

class LanguageOptionModel {
  final String id;
  final String language;

  const LanguageOptionModel({required this.id, required this.language});

  factory LanguageOptionModel.fromJson(Map<String, dynamic> json) {
    return LanguageOptionModel(
      id: json['id'] as String,
      language: json['language'] as String,
    );
  }

  LanguageOptionEntity toEntity() =>
      LanguageOptionEntity(id: id, label: language);
}
