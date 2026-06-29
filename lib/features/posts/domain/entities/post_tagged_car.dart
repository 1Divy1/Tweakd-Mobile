import 'package:equatable/equatable.dart';

/// A car linked to a post. The backend returns a lightweight car summary; only
/// the fields the post UI needs are modelled here.
class PostTaggedCarEntity extends Equatable {
  final String id;
  final String make;
  final String model;

  /// The car's owner (backend `CarOwnerDto`). Needed by the edit screen so a
  /// tagged car can be auto-removed when its owner is untagged — the backend
  /// rejects a car whose owner isn't also tagged. Null on older payloads.
  final String? ownerId;
  final String? ownerUsername;

  const PostTaggedCarEntity({
    required this.id,
    required this.make,
    required this.model,
    this.ownerId,
    this.ownerUsername,
  });

  @override
  List<Object?> get props => [id, make, model, ownerId, ownerUsername];
}
