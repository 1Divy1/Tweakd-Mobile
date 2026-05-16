import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/utils/core_error_mapper.dart';

import '../../domain/failures/garage_failures.dart';

class GarageErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is CarNotFoundFailure) return failure.message;
    if (failure is GarageNotFoundFailure) return failure.message;
    if (failure is PrivateGarageFailure) return failure.message;
    if (failure is NotCarOwnerFailure) return failure.message;
    if (failure is InvalidReferenceFailure) return failure.message;
    return CoreErrorMapper.getMessage(failure);
  }
}
