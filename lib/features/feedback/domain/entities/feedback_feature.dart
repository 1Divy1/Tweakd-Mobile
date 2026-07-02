import 'package:equatable/equatable.dart';

/// An app feature the feedback can optionally be tied to (e.g. Feed, Garage).
/// [id] is the stable key sent back on submit; [name] is the display label.
class FeedbackFeatureEntity extends Equatable {
  final String id;
  final String name;

  const FeedbackFeatureEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
