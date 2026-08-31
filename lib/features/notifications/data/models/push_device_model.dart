import '../../domain/entities/push_device.dart';

/// Outbound wire model for `POST /notifications/devices` (snake_case).
///
/// Write-only, so unlike the other models in this feature it carries a
/// `toJson` and no `fromJson`/`toEntity` — the endpoint answers with no body
/// worth parsing.
class PushDeviceModel {
  final PushDeviceEntity device;

  const PushDeviceModel(this.device);

  Map<String, dynamic> toJson() => {
        'token': device.token,
        'platform': device.platform.wire,
        'app_version': device.appVersion,
        if (device.locale != null) 'locale': device.locale,
      };
}
