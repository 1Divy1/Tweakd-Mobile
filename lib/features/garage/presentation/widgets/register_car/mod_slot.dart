import '../../../../../core/services/image_service.dart';
import '../../../domain/entities/car_modification.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../bloc/add_car/event.dart';

/// How many photos a single before/after phase can hold.
const maxModImagesPerPhase = 3;

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
  String? get thumbFilePath =>
      _firstOrNull(input.after)?.path ?? _firstOrNull(input.before)?.path;
  @override
  String? get thumbUrl => null;
}

/// An existing mod being edited. Holds the current text values plus the image
/// delta: newly picked before/after images to upload+add, the existing media
/// kept as-is, and the existing media (by R2 key) the user removed.
class ExistingModSlot extends ModSlot {
  final CarModificationEntity original;
  final ModRequestParams request;

  /// Freshly picked images to upload, per phase.
  final List<CompressedImage> newBefore;
  final List<CompressedImage> newAfter;

  /// Existing media kept as-is, per phase. Never re-uploaded.
  final List<ModificationMediaEntity> keptBefore;
  final List<ModificationMediaEntity> keptAfter;

  final List<String> removeMediaKeys;

  const ExistingModSlot({
    required this.original,
    required this.request,
    this.newBefore = const [],
    this.newAfter = const [],
    this.keptBefore = const [],
    this.keptAfter = const [],
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
  String? get thumbFilePath =>
      _firstOrNull(newAfter)?.path ?? _firstOrNull(newBefore)?.path;
  @override
  String? get thumbUrl => thumbFilePath != null
      ? null
      : (_firstOrNull(keptAfter)?.url ?? _firstOrNull(keptBefore)?.url);

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
        newBefore.isNotEmpty ||
        newAfter.isNotEmpty ||
        removeMediaKeys.isNotEmpty;
  }
}

T? _firstOrNull<T>(List<T> items) => items.isEmpty ? null : items.first;
