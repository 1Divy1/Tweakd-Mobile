import 'package:equatable/equatable.dart';

/// A selectable app language, as returned by `GET /profile/language-options`.
/// [id] is the locale code sent back as `language_id` on the PATCH; [label]
/// is the backend's display name, rendered as-is (no local translation map).
class LanguageOptionEntity extends Equatable {
  final String id;
  final String label;

  const LanguageOptionEntity({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}
