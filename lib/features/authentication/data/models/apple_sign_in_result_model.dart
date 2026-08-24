import '../../domain/entities/apple_sign_in_result.dart';
import 'user_model.dart';

/// Outcome of an Apple sign-in call. See [AppleSignInResultEntity] for the two
/// shapes and why the platforms differ.
class AppleSignInResultModel {
  final bool awaitingRedirect;
  final UserModel? user;

  const AppleSignInResultModel({required this.awaitingRedirect, this.user});

  AppleSignInResultEntity toEntity() {
    return AppleSignInResultEntity(
      awaitingRedirect: awaitingRedirect,
      user: user?.toEntity(),
    );
  }
}
