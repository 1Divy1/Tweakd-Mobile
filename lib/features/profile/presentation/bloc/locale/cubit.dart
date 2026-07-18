import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/storage/locale_local_storage.dart';

const _supportedLocaleCodes = ['en', 'ro'];

/// App-wide active locale. `null` means "follow the system locale" (the
/// pre-existing default). Provided once at the app root — like
/// `DmUnreadCubit`/`NotificationsUnreadCubit` — so `MaterialApp.locale` can
/// bind to it and flip the whole app's language live, without a restart.
@injectable
class LocaleCubit extends Cubit<Locale?> {
  final LocaleLocalStorage localStorage;

  LocaleCubit(this.localStorage) : super(null);

  /// Seeds the locale from local persistence. Fire-and-forget at startup
  /// (mirrors the `..refresh()` pattern of the other root cubits): the first
  /// frame(s) may briefly render in the system locale until this resolves,
  /// which is near-instant for `flutter_secure_storage`.
  Future<void> loadPersisted() async {
    final code = await localStorage.getLocale();
    if (code != null && _supportedLocaleCodes.contains(code) && !isClosed) {
      emit(Locale(code));
    }
  }

  /// Applies a user-picked locale (already confirmed by the backend PATCH)
  /// and persists it locally.
  Future<void> setLocale(String code) async {
    if (!_supportedLocaleCodes.contains(code)) return;
    emit(Locale(code));
    await localStorage.setLocale(code);
  }

  /// Adopts the backend's `app_language` if it differs from the active
  /// locale — the backend is the cross-device source of truth. Called on
  /// every `/profile/me` fetch.
  Future<void> syncFromBackend(String code) async {
    if (!_supportedLocaleCodes.contains(code)) return;
    if (state?.languageCode == code) return;
    emit(Locale(code));
    await localStorage.setLocale(code);
  }
}
