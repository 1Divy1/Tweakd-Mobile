import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../domain/entities/forum_topic.dart';
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
  final List<ForumTopicGroupEntity> topicGroups;

  const ForumBrowseLoaded({required this.brands, required this.topicGroups});

  @override
  List<Object?> get props => [brands, topicGroups];
}

class ForumBrowseError extends ForumBrowseState {
  final ForumErrorCode code;
  const ForumBrowseError(this.code);

  @override
  List<Object?> get props => [code];
}
