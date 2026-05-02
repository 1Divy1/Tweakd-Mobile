import '../../../../core/error/base_failures.dart';
import '../../../../core/utils/core_error_mapper.dart';

class ProfileErrorMapper {
  static String getMessage(Failure failure) {
    return CoreErrorMapper.getMessage(failure);
  }
}
