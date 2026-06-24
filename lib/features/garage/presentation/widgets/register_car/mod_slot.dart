import '../../../../../core/services/car_image_service.dart';
import '../../../domain/entities/car_modification.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../bloc/add_car/event.dart';

/// A modification row in the register/edit wizard. Either a brand-new mod to be
/// created ([NewModSlot]) or an existing mod being edited ([ExistingModSlot]).
sealed class ModSlot {
  const ModSlot();

  String get categoryId;
  String get title;
  DateTime get installationDate;
  double? get price;

  /// Local file path for the card thumbnail, when a new image is set.
  String? get thumbFilePath;

  /// Remote url for the card thumbnail, when showing an existing image.
  String? get thumbUrl;
}

/// A new mod, created on submit (text + optional before/after uploads).
class NewModSlot extends ModSlot {
  final NewModInput input;
  const NewModSlot(this.input);

  @override
  String get categoryId => input.request.categoryId;
  @override
  String get title => input.request.title;
  @override
  DateTime get installationDate => input.request.installationDate;
  @override
  double? get price => input.request.price;
  @override
  String? get thumbFilePath => (input.after ?? input.before)?.path;
  @override
  String? get thumbUrl => null;
}

/// An existing mod being edited. Holds the current text values plus the image
/// delta: newly picked before/after images to upload+add, the remaining
/// existing image urls, and the existing media (by R2 key) the user removed.
class ExistingModSlot extends ModSlot {
  final CarModificationEntity original;
  final ModRequestParams request;
  final CompressedImage? newBefore;
  final CompressedImage? newAfter;
  final String? beforeUrl;
  final String? afterUrl;
  final List<String> removeMediaKeys;

  const ExistingModSlot({
    required this.original,
    required this.request,
    this.newBefore,
    this.newAfter,
    this.beforeUrl,
    this.afterUrl,
    this.removeMediaKeys = const [],
  });

  String get modId => original.id;

  @override
  String get categoryId => request.categoryId;
  @override
  String get title => request.title;
  @override
  DateTime get installationDate => request.installationDate;
  @override
  double? get price => request.price;
  @override
  String? get thumbFilePath => (newAfter ?? newBefore)?.path;
  @override
  String? get thumbUrl =>
      thumbFilePath != null ? null : (afterUrl ?? beforeUrl);

  /// Text-only partial update vs the original. Only changed fields are set, so
  /// an untouched mod with no media changes yields an empty patch.
  ModPatchParams toPatchParams({List<ModMediaInput>? addMedia}) {
    return ModPatchParams(
      title: request.title != original.title ? request.title : null,
      description: request.description != original.description
          ? (request.description ?? '')
          : null,
      installationDate: request.installationDate != original.installationDate
          ? request.installationDate
          : null,
      price: request.price != original.price ? request.price : null,
      mileageAtInstall: request.mileageAtInstall != original.mileageAtInstall
          ? request.mileageAtInstall
          : null,
      addMedia: addMedia,
      removeMediaKeys: removeMediaKeys.isEmpty ? null : removeMediaKeys,
    );
  }

  /// Whether anything actually changed (text, new images, or removals).
  bool get hasChanges {
    final patch = toPatchParams();
    return patch.toJson().isNotEmpty ||
        newBefore != null ||
        newAfter != null ||
        removeMediaKeys.isNotEmpty;
  }
}
