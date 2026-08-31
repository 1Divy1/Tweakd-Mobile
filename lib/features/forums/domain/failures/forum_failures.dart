import 'package:tweakd/core/error/base_failures.dart';

/// 404 — thread / reply / shortcut doesn't exist.
class ForumNotFoundFailure extends Failure {
  const ForumNotFoundFailure() : super(message: 'Not found.');
}

/// 403 — editing or deleting content the viewer doesn't own.
class ForumForbiddenFailure extends Failure {
  const ForumForbiddenFailure() : super(message: 'Not allowed.');
}

/// 409 — the thread is locked, or the target thread/reply was deleted.
class ForumConflictFailure extends Failure {
  const ForumConflictFailure(String message) : super(message: message);
}

/// 400 — validation (blank name, bad cursor, unknown brand/model/topic, …).
class ForumValidationFailure extends Failure {
  const ForumValidationFailure(String message) : super(message: message);
}
