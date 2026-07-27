import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../utils/forum_error_mapper.dart';

sealed class ForumBrowseState extends Equatable {
  const ForumBrowseState();

  @override
  List<Object?> get props => [];
}

class ForumBrowseInitial extends ForumBrowseState {
  const ForumBrowseInitial();
}

class ForumBrowseLoading extends ForumBrowseState {
  const ForumBrowseLoading();
}

class ForumBrowseLoaded extends ForumBrowseState {
  final List<CarBrandEntity> brands;

  const ForumBrowseLoaded({required this.brands});

  @override
  List<Object?> get props => [brands];
}

class ForumBrowseError extends ForumBrowseState {
  final ForumErrorCode code;
  const ForumBrowseError(this.code);

  @override
  List<Object?> get props => [code];
}
