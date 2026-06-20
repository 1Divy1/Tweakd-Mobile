import 'package:equatable/equatable.dart';

/// A car category / scene the user is into (JDM, muscle, …).
class CarCategoryEntity extends Equatable {
  final String id;
  final String name;

  const CarCategoryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}