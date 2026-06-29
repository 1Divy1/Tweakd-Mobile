import 'package:equatable/equatable.dart';

import '../../../../../core/services/image_service.dart';
import '../../../domain/repositories/garage_repository.dart';

abstract class LogModEvent extends Equatable {
  const LogModEvent();

  @override
  List<Object?> get props => [];
}

class LoadModCategories extends LogModEvent {
  const LoadModCategories();
}

class SubmitModification extends LogModEvent {
  final String carId;
  final ModRequestParams params;

  /// Before/after images, each already being compressed since selection time.
  final CompressedImage? before;
  final CompressedImage? after;

  const SubmitModification({
    required this.carId,
    required this.params,
    this.before,
    this.after,
  });

  @override
  List<Object?> get props => [carId, params, before, after];
}
