import '../../../../core/error/base_failures.dart';

/// The user tried to block their own account (backend 400).
class CannotBlockSelfFailure extends Failure {
  const CannotBlockSelfFailure()
      : super(message: 'You cannot block your own account.');
}

/// The account does not exist, or a block already hides it from the user
/// (backend 404 — the two are deliberately indistinguishable).
class BlockTargetNotFoundFailure extends Failure {
  const BlockTargetNotFoundFailure() : super(message: 'Account not found.');
}
