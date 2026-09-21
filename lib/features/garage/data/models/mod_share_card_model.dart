import '../../domain/entities/mod_share_card.dart';
import 'car_modification_model.dart';
import 'car_summary_model.dart';

/// A shared modification's card as the API sends it — `mod_share_card` on a
/// post. Decoded defensively: a card that fails to parse is dropped and the
/// post renders as an ordinary one, rather than one bad row breaking a whole
/// feed page.
class ModShareCardModel {
  final String modificationId;
  final CarSummaryModel car;
  final String categoryName;
  final String title;
  final String? description;
  final List<ModificationMediaItemModel> beforeMedia;
  final List<ModificationMediaItemModel> afterMedia;
  final DateTime installationDate;
  final double? price;
  final String? priceCurrency;
  final int? mileageAtInstall;

  const ModShareCardModel({
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

  static ModShareCardModel? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final car = json['car'];
    final modificationId = json['modification_id'];
    final installationDate = json['installation_date'];
    if (car is! Map<String, dynamic> ||
        modificationId is! String ||
        installationDate is! String) {
      return null;
    }
    // CarSummaryModel.fromJson hard-casts its required keys, so a car missing
    // `brand` (say) throws a TypeError — caught here so the promise above holds.
    try {
      return ModShareCardModel(
        modificationId: modificationId,
        car: CarSummaryModel.fromJson(car),
        categoryName: json['category_name'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        beforeMedia: _media(json['before_media']),
        afterMedia: _media(json['after_media']),
        installationDate: DateTime.parse(installationDate),
        price: (json['price'] as num?)?.toDouble(),
        priceCurrency: json['price_currency'] as String?,
        mileageAtInstall: (json['mileage_at_install'] as num?)?.toInt(),
      );
    } on TypeError {
      return null;
    } on FormatException {
      return null;
    }
  }

  static List<ModificationMediaItemModel> _media(dynamic raw) => [
        for (final m in (raw as List<dynamic>? ?? const []))
          if (m is Map<String, dynamic>) ModificationMediaItemModel.fromJson(m),
      ];

  ModShareCardEntity toEntity() => ModShareCardEntity(
        modificationId: modificationId,
        car: car.toEntity(),
        categoryName: categoryName,
        title: title,
        description: description,
        beforeMedia: beforeMedia.map((m) => m.toEntity()).toList(),
        afterMedia: afterMedia.map((m) => m.toEntity()).toList(),
        installationDate: installationDate,
        price: price,
        priceCurrency: priceCurrency,
        mileageAtInstall: mileageAtInstall,
      );
}
