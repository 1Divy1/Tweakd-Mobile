import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Seeds the bloc with the current profile (passed via router `extra`).
class EditProfileStarted extends EditProfileEvent {
  final ProfileEntity profile;

  const EditProfileStarted(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// A new local image was picked — kicks off the immediate 3-step avatar upload.
class EditProfileAvatarSelected extends EditProfileEvent {
  final String imagePath;

  const EditProfileAvatarSelected(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Save the name/bio edits. The bloc diffs the raw values against the original
/// profile before sending only what changed.
class EditProfileSaved extends EditProfileEvent {
  final String name;
  final String bio;

  const EditProfileSaved({required this.name, required this.bio});

  @override
  List<Object?> get props => [name, bio];
}
