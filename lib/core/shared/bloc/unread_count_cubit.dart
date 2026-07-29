import 'package:flutter_bloc/flutter_bloc.dart';

/// Base for app-level unread-counter cubits (DMs, notifications). State is the
/// unread count; concrete cubits implement [refresh] to pull the authoritative
/// value from the backend, and may bump the count from live events in between.
///
/// Failures inside [refresh] must be swallowed — badges are cosmetic and never
/// surface an error.
abstract class UnreadCountCubit extends Cubit<int> {
  UnreadCountCubit() : super(0);

  /// Re-fetch the authoritative count.
  Future<void> refresh();

  /// Zero the badge immediately (e.g. optimistically on opening the source
  /// screen or on "mark all read").
  void clear() {
    if (!isClosed) emit(0);
  }
}
