import 'package:equatable/equatable.dart';

/// A feedback category the user can file under (e.g. bug, feature request,
/// general). [id] is the stable machine key sent back on submit; [label] is the
/// human-readable name shown in the picker.
class FeedbackTypeEntity extends Equatable {
  final String id;
  final String label;

  const FeedbackTypeEntity({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}
