import 'package:dartz/dartz.dart';

import '../error/base_failures.dart';

// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Used when there are no parameters to pass to the UseCase
class NoParams {}