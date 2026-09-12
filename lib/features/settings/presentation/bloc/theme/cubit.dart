import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/storage/theme_local_storage.dart';

/// App-wide theme preference. [ThemeMode.system] — the default — follows the
/// OS setting; the other two pin the app regardless of it.
///
/// Provided once at the app root, like [LocaleCubit], so the whole tree can
/// rebuild when it changes. This only holds the user's *preference*; resolving
/// it against the platform brightness happens in `TweakdApp`, which is the
/// only place that can see the current `MediaQuery`.
@injectable
class ThemeModeCubit extends Cubit<ThemeMode> {
  final ThemeLocalStorage localStorage;

  ThemeModeCubit(this.localStorage) : super(ThemeMode.system);

  /// Seeds from local persistence. Fire-and-forget at startup, matching the
  /// other root cubits: the first frame may briefly use the system theme
  /// until this resolves, which is near-instant for secure storage.
  Future<void> loadPersisted() async {
    final mode = await localStorage.getThemeMode();
    if (mode != null && !isClosed) emit(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await localStorage.setThemeMode(mode);
  }
}
