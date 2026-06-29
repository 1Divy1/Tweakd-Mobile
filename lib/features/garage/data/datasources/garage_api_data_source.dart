import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/car_model.dart';
import '../models/car_modification_model.dart';
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

  Future<CarModel> getCar(String carId) async {
    final data = await http.get('/garage/cars/$carId');
    debugPrint("Raw data: $data");
    final response = CarModel.fromJson(data as Map<String, dynamic>);
    debugPrint("Car fuel: ${response.fuelTypeId}, ${response.fuelTypeName}");
    debugPrint("Car mileage: ${response.mileage}");

    return response;
  }

  Future<CarModel> addCar(Map<String, dynamic> body) async {
    final data = await http.post('/garage/cars', body: body);
    final json = data as Map<String, dynamic>;
    return CarModel.fromJson(
        json.containsKey('car') ? json['car'] as Map<String, dynamic> : json);
  }

  Future<CarModel> updateCar(
      String carId, Map<String, dynamic> body) async {
    final data = await http.put('/garage/cars/$carId', body: body);
    return CarModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCar(String carId) async {
    await http.delete('/garage/cars/$carId');
  }

  // ── Media ───────────────────────────────────────────────────────────

  Future<void> saveCoverKey(String carId, String key) async {
    await http.patch(
      '/garage/cars/$carId/cover',
      queryParameters: {'key': key},
    );
  }

  Future<void> saveGalleryKeys(String carId, List<String> keys) async {
    await http.patch(
      '/garage/cars/$carId/gallery',
      body: {'keys': keys},
    );
  }

  /// Removes the given gallery photos from the car (DB) and from R2 storage.
  Future<void> deleteGalleryImages(String carId, List<String> keys) async {
    await http.delete(
      '/garage/cars/$carId/gallery',
      body: {'keys': keys},
    );
  }

  /// Removes the car's current cover photo object from R2 and nulls the DB
  /// pointer. The backend resolves the cover from the car id — no param/body.
  Future<void> deleteCoverImage(String carId) async {
    await http.delete('/garage/cars/$carId/cover');
  }

  // ── Modifications ─────────────────────────────────────────────────────────

  Future<CarModificationModel> addModification(
    String carId,
    Map<String, dynamic> body,
  ) async {
    final data =
        await http.post('/garage/cars/$carId/modifications', body: body);
    final json = data as Map<String, dynamic>;
    return CarModificationModel.fromJson(
        json.containsKey('modification')
            ? json['modification'] as Map<String, dynamic>
            : json);
  }

  Future<CarModificationModel> patchModification(
    String carId,
    String modId,
    Map<String, dynamic> body,
  ) async {
    final data = await http.patch(
        '/garage/cars/$carId/modifications/$modId',
        body: body);
    return CarModificationModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteModification(String carId, String modId) async {
    await http.delete('/garage/cars/$carId/modifications/$modId');
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

  Future<List<CarFuelTypeOptionModel>> getFuelTypeOptions() async {
    final data = await http.get('/garage/reference/fuel-type-options');
    return (data as List<dynamic>)
        .map((e) => CarFuelTypeOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
