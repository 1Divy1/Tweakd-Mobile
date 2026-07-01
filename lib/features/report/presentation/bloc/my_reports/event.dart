import 'package:equatable/equatable.dart';

sealed class MyReportsEvent extends Equatable {
  const MyReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads, for pull-to-refresh / retry) the user's submitted reports.
class LoadMyReports extends MyReportsEvent {
  const LoadMyReports();
}
