import 'package:equatable/equatable.dart';

/// A car linked to a post. The backend returns a lightweight car summary; only
/// the fields the post UI needs are modelled here.
class PostTaggedCarEntity extends Equatable {
  final String id;
  final String make;
  final String model;

  const PostTaggedCarEntity({
    required this.id,
    required this.make,
    required this.model,
  });

  @override
  List<Object?> get props => [id, make, model];
}
