import 'package:equatable/equatable.dart';

/// A single dream-car the user wants to follow. [modelId] is optional (a brand
/// on its own is allowed); when set it must belong to [brandId].
class DreamCarEntity extends Equatable {
  final String brandId;
  final String? modelId;
  final String? note;

  const DreamCarEntity({
    required this.brandId,
    this.modelId,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        if (modelId != null) 'model_id': modelId,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  @override
  List<Object?> get props => [brandId, modelId, note];
}
