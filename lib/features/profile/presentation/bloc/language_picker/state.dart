import 'package:equatable/equatable.dart';

import '../../../domain/entities/language_option.dart';
import '../../utils/profile_error_mapper.dart';

enum LanguagePickerStatus { loading, loaded, error }

class LanguagePickerState extends Equatable {
  final LanguagePickerStatus status;
  final List<LanguageOptionEntity> options;

  /// The checkmarked option. Set from the caller's current locale on load,
  /// then only updated after a successful PATCH — never optimistically.
  final String activeCode;

  /// True while a `SelectLanguage` PATCH is in flight.
  final bool updating;

  /// Set when a PATCH fails; paired with [updateErrorNonce] so the sheet's
  /// one-shot snackbar listener fires even for repeated identical errors.
  final ProfileErrorCode? updateErrorCode;
  final int updateErrorNonce;

  /// Bumped only on a successful PATCH — the sheet listens on this (not on
  /// [activeCode] directly, which is also set once at load time) to know
  /// when to flip `LocaleCubit`.
  final int confirmNonce;

  const LanguagePickerState({
    this.status = LanguagePickerStatus.loading,
    this.options = const [],
    this.activeCode = '',
    this.updating = false,
    this.updateErrorCode,
    this.updateErrorNonce = 0,
    this.confirmNonce = 0,
  });

  LanguagePickerState copyWith({
    LanguagePickerStatus? status,
    List<LanguageOptionEntity>? options,
    String? activeCode,
    bool? updating,
    ProfileErrorCode? updateErrorCode,
    int? updateErrorNonce,
    int? confirmNonce,
  }) {
    return LanguagePickerState(
      status: status ?? this.status,
      options: options ?? this.options,
      activeCode: activeCode ?? this.activeCode,
      updating: updating ?? this.updating,
      updateErrorCode: updateErrorCode ?? this.updateErrorCode,
      updateErrorNonce: updateErrorNonce ?? this.updateErrorNonce,
      confirmNonce: confirmNonce ?? this.confirmNonce,
    );
  }

  @override
  List<Object?> get props => [
        status,
        options,
        activeCode,
        updating,
        updateErrorCode,
        updateErrorNonce,
        confirmNonce,
      ];
}
