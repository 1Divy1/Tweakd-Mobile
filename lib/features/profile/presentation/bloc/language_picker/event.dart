import 'package:equatable/equatable.dart';

sealed class LanguagePickerEvent extends Equatable {
  const LanguagePickerEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the selectable languages. [currentCode] is the active locale code
/// (from `LocaleCubit`/profile), used to pre-check the current selection.
class LoadLanguageOptions extends LanguagePickerEvent {
  final String currentCode;

  const LoadLanguageOptions(this.currentCode);

  @override
  List<Object?> get props => [currentCode];
}

/// The user tapped an option — PATCHes the backend immediately (no separate
/// confirm step).
class SelectLanguage extends LanguagePickerEvent {
  final String code;

  const SelectLanguage(this.code);

  @override
  List<Object?> get props => [code];
}
