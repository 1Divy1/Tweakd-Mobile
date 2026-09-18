import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final bool requiresOnboarding;

  /// The account went through sign-up — the terms were accepted there. False
  /// for an account Supabase created because a social identity it had never
  /// seen was used on the *login* page. Data-layer only: the sign-in path
  /// rejects such an account before it can reach the domain.
  final bool isRegistered;

  /// `profiles.analytics_consent` — the account's opt-in to product analytics.
  /// Data-layer only: the repository hands it to `AnalyticsService`.
  final bool analyticsConsent;

  const UserModel({
    required this.id,
    required this.requiresOnboarding,
    this.isRegistered = true,
    this.analyticsConsent = false,
  });

  factory UserModel.fromProfile(User supabaseUser, Map<String, dynamic> profile) {
    return UserModel(
      id: supabaseUser.id,
      requiresOnboarding: profile['requires_onboarding'] as bool? ?? true,
      isRegistered: profile['terms_accepted_at'] != null,
      analyticsConsent: profile['analytics_consent'] as bool? ?? false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      requiresOnboarding: json['requires_onboarding'] as bool? ?? false,
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, requiresOnboarding: requiresOnboarding);
  }
}
