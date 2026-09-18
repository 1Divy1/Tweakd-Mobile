import 'package:equatable/equatable.dart';

class AnalyticsConsentState extends Equatable {
  /// The account's current choice; null until it has loaded.
  final bool? granted;

  /// A change is being saved — the switch is disabled meanwhile.
  final bool saving;

  /// Set for one emit when loading or saving failed.
  final bool failed;

  const AnalyticsConsentState({
    this.granted,
    this.saving = false,
    this.failed = false,
  });

  @override
  List<Object?> get props => [granted, saving, failed];
}
