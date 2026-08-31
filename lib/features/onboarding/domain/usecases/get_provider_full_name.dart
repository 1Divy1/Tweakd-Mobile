import 'package:injectable/injectable.dart';

import '../repositories/onboarding_repository.dart';

/// The display name the sign-up provider supplied, used to prefill the
/// onboarding name field. Null when the provider gave none.
///
/// Not a [UseCase] because that contract returns a `Future<Either<...>>`; this
/// is a synchronous read of the already-cached session with no failure to fold
/// — the caller either gets a name or gets nothing. The bloc still goes through
/// this class rather than touching the repository directly.
@lazySingleton
class GetProviderFullName {
  final OnboardingRepository repository;

  GetProviderFullName(this.repository);

  String? call() => repository.providerFullName;
}
