import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class UploadPostImageParams {
  final String uploadUrl;
  final Uint8List bytes;
  const UploadPostImageParams({required this.uploadUrl, required this.bytes});
}

@lazySingleton
class UploadPostImageUseCase implements UseCase<void, UploadPostImageParams> {
  final PostsRepository repository;

  UploadPostImageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadPostImageParams params) {
    return repository.uploadImageToR2(params.uploadUrl, params.bytes);
  }
}
