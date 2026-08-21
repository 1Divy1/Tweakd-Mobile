import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

/// Emits whenever a session appears that the app did not explicitly request —
/// in practice when the sign-up confirmation deep link is opened and the
/// Supabase SDK exchanges the PKCE code for a session in the background.
///
/// Not a [UseCase] because that contract returns a `Future<Either<...>>`; a
/// stream has no failure to fold. The bloc still goes through this class rather
/// than touching the repository directly.
@lazySingleton
class WatchExternalSignIn {
  final AuthRepository repository;

  WatchExternalSignIn(this.repository);

  Stream<void> call() => repository.onExternalSignIn;
}
