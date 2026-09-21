import 'package:equatable/equatable.dart';

import 'car_modification.dart';
import 'car_summary.dart';

/// A build-log modification as the feed draws it, when a post shares one.
///
/// Not stored anywhere: the backend derives it on read from the modification
/// id the post carries, so an edited mod updates wherever it was shared and a
/// deleted one simply leaves the post plain. It reaches the app one way —
/// `mod_share_card` on a post.
///
/// [price] arrives only when the owner published it; there is nothing for the
/// app to hide.
class ModShareCardEntity extends Equatable {
  final String modificationId;
  final CarSummaryEntity car;
  final String categoryName;
  final String title;
  final String? description;
  final List<ModificationMediaEntity> beforeMedia;
  final List<ModificationMediaEntity> afterMedia;
  final DateTime installationDate;
  final double? price;
  final String? priceCurrency;
  final int? mileageAtInstall;

  const ModShareCardEntity({
    required this.modificationId,
    required this.car,
    required this.categoryName,
    required this.title,
    this.description,
    this.beforeMedia = const [],
    this.afterMedia = const [],
    required this.installationDate,
    this.price,
    this.priceCurrency,
    this.mileageAtInstall,
  });

  /// What the card shows as its photo: the result if there is one, otherwise
  /// the "before" — a mod photographed only beforehand still deserves a card.
  List<ModificationMediaEntity> get displayMedia =>
      afterMedia.isNotEmpty ? afterMedia : beforeMedia;

  /// Whether both phases exist, which is what earns the before/after switcher.
  bool get hasBeforeAndAfter =>
      beforeMedia.isNotEmpty && afterMedia.isNotEmpty;

  @override
  List<Object?> get props => [
        modificationId,
        car,
        categoryName,
        title,
        description,
        beforeMedia,
        afterMedia,
        installationDate,
        price,
        priceCurrency,
        mileageAtInstall,
      ];
}
