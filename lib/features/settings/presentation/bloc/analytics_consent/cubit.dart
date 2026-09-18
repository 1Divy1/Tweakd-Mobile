import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_events.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_analytics_consent.dart';
import '../../../domain/usecases/set_analytics_consent.dart';
import 'state.dart';

/// Settings → "Share usage analytics". Reads and saves the opt-in stored on
/// the account; the repository switches tracking on or off once it is saved.
@injectable
class AnalyticsConsentCubit extends Cubit<AnalyticsConsentState> {
  final GetAnalyticsConsent getConsent;
  final SetAnalyticsConsent setConsent;
  final AnalyticsService analytics;

  AnalyticsConsentCubit(
    this.getConsent,
    this.setConsent, {
    this.analytics = const NoopAnalyticsService(),
  }) : super(const AnalyticsConsentState());

  Future<void> load() async {
    final result = await getConsent(NoParams());
    if (isClosed) return;
    result.fold(
      (_) => emit(const AnalyticsConsentState(failed: true)),
      (granted) => emit(AnalyticsConsentState(granted: granted)),
    );
  }

  Future<void> toggle(bool granted) async {
    final previous = state.granted;
    if (state.saving || previous == granted) return;
    emit(AnalyticsConsentState(granted: granted, saving: true));

    // A withdrawal is recorded while tracking is still on — afterwards nothing
    // can be sent, and withdrawals are worth seeing.
    if (!granted) {
      analytics.track(AnalyticsEvents.analyticsConsentChanged, {
        'granted': false,
      });
    }

    final result = await setConsent(granted);
    if (isClosed) return;
    result.fold(
      (_) => emit(AnalyticsConsentState(granted: previous, failed: true)),
      (_) {
        if (granted) {
          analytics.track(AnalyticsEvents.analyticsConsentChanged, {
            'granted': true,
          });
        }
        emit(AnalyticsConsentState(granted: granted));
      },
    );
  }
}
