import '../../domain/entities/sign_up_result.dart';
import 'user_model.dart';

/// Outcome of a sign-up call.
///
/// With email confirmation on, [requiresEmailConfirmation] is true and [user]
/// is null — there is no session until the confirmation link is opened. If the
/// project ever turns confirmation off, Supabase returns a live session and
/// both fields flip, so the UI handles either shape without a code change.
class SignUpResultModel {
  final bool requiresEmailConfirmation;
  final UserModel? user;

  const SignUpResultModel({
    required this.requiresEmailConfirmation,
    this.user,
  });

  SignUpResultEntity toEntity() {
    return SignUpResultEntity(
      requiresEmailConfirmation: requiresEmailConfirmation,
      user: user?.toEntity(),
    );
  }
}
