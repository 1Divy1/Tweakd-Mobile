import 'package:equatable/equatable.dart';

class CarStatusOptionEntity extends Equatable {
  final String id;
  final String type;

  const CarStatusOptionEntity({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type];
}
