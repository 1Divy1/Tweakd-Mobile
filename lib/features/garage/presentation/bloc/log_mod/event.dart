import 'package:equatable/equatable.dart';

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
  final String? beforeFilePath;
  final String? afterFilePath;

  const SubmitModification({
    required this.carId,
    required this.params,
    this.beforeFilePath,
    this.afterFilePath,
  });

  @override
  List<Object?> get props => [carId, params, beforeFilePath, afterFilePath];
}
