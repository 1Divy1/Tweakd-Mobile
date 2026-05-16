import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/car_detail_model.dart';
import '../models/car_image_model.dart';
import '../models/create_car_response_model.dart';
import '../models/garage_model.dart';
import '../models/reference_data_models.dart';

@lazySingleton
class GarageApiDataSource {
  final AbstractHTTP http;

  GarageApiDataSource(this.http);

  // ── Garage ────────────────────────────────────────────────────────────────

  Future<GarageModel> getMyGarage() async {
    final data = await http.get('/garage/me');
    return GarageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<GarageModel> getGarageByUsername(String username) async {
    final data = await http.get('/garage/by-username/$username');
    return GarageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Cars ──────────────────────────────────────────────────────────────────

  Future<CarDetailModel> getCar(String carId) async {
    final data = await http.get('/garage/cars/$carId');
    return CarDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CreateCarResponseModel> addCar(Map<String, dynamic> body) async {
    final data = await http.post('/garage/cars', body: body);
    return CreateCarResponseModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CarDetailModel> updateCar(
      String carId, Map<String, dynamic> body) async {
    final data = await http.put('/garage/cars/$carId', body: body);
    return CarDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCar(String carId) async {
    await http.delete('/garage/cars/$carId');
  }

  // ── Modifications ─────────────────────────────────────────────────────────

  Future<AddModificationResponseModel> addModification(
    String carId,
    Map<String, dynamic> body,
  ) async {
    final data =
        await http.post('/garage/cars/$carId/modifications', body: body);
    return AddModificationResponseModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateModification(
    String carId,
    String modId,
    Map<String, dynamic> body,
  ) async {
    await http.put('/garage/cars/$carId/modifications/$modId', body: body);
  }

  Future<void> deleteModification(String carId, String modId) async {
    await http.delete('/garage/cars/$carId/modifications/$modId');
  }

  // ── Gallery images ────────────────────────────────────────────────────────

  Future<List<CarImageModel>> listCarImages(String carId) async {
    final data = await http.get('/garage/cars/$carId/images');
    return (data as List<dynamic>)
        .map((e) => CarImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCarImage(String carId, String imageId) async {
    await http.delete('/garage/cars/$carId/images/$imageId');
  }

  Future<String> generateDownloadUrl(String storagePath) async {
    final data = await http.post(
      '/garage/storage/download-url',
      body: {'storage_path': storagePath},
    );
    return (data as Map<String, dynamic>)['signed_url'] as String;
  }

  // ── Reference data ────────────────────────────────────────────────────────

  Future<List<CarBrandModel>> getBrands() async {
    final data = await http.get('/garage/reference/brands');
    return (data as List<dynamic>)
        .map((e) => CarBrandModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarModelModel>> getModelsByBrand(String brandId) async {
    final data = await http.get('/garage/reference/brands/$brandId/models');
    return (data as List<dynamic>)
        .map((e) => CarModelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarDrivetrainModel>> getDrivetrains() async {
    final data = await http.get('/garage/reference/drivetrains');
    return (data as List<dynamic>)
        .map((e) => CarDrivetrainModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarColorModel>> getColors() async {
    final data = await http.get('/garage/reference/colors');
    return (data as List<dynamic>)
        .map((e) => CarColorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarDistanceUnitModel>> getDistanceUnits() async {
    final data = await http.get('/garage/reference/distance-units');
    return (data as List<dynamic>)
        .map((e) => CarDistanceUnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarStatusOptionRefModel>> getStatusOptions() async {
    final data = await http.get('/garage/reference/status-options');
    return (data as List<dynamic>)
        .map((e) => CarStatusOptionRefModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarModCategoryModel>> getModCategories() async {
    final data = await http.get('/garage/reference/mod-categories');
    return (data as List<dynamic>)
        .map((e) => CarModCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
