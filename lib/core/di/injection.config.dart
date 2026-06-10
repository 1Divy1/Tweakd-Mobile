// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/authentication/data/datasources/supabase_auth_data_source.dart'
    as _i981;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/domain/usecases/auth/check_auth_status.dart'
    as _i192;
import '../../features/authentication/domain/usecases/login/email_password_signin.dart'
    as _i263;
import '../../features/authentication/domain/usecases/login/google_signin.dart'
    as _i920;
import '../../features/authentication/presentation/bloc/bloc.dart' as _i636;
import '../../features/follow/data/datasource/follow_api_data_source.dart'
    as _i587;
import '../../features/follow/data/repositories/follow_repository_impl.dart'
    as _i299;
import '../../features/follow/domain/repositories/follow_repository.dart'
    as _i760;
import '../../features/follow/domain/usecases/accept_follow_request.dart'
    as _i256;
import '../../features/follow/domain/usecases/follow_user.dart' as _i757;
import '../../features/follow/domain/usecases/get_follow_status.dart' as _i28;
import '../../features/follow/domain/usecases/get_followers.dart' as _i1027;
import '../../features/follow/domain/usecases/get_following.dart' as _i495;
import '../../features/follow/domain/usecases/get_pending_requests.dart'
    as _i422;
import '../../features/follow/domain/usecases/reject_follow_request.dart'
    as _i669;
import '../../features/follow/domain/usecases/remove_follower.dart' as _i164;
import '../../features/follow/domain/usecases/unfollow_user.dart' as _i31;
import '../../features/follow/presentation/bloc/bloc.dart' as _i236;
import '../../features/garage/data/datasources/garage_api_data_source.dart'
    as _i879;
import '../../features/garage/data/datasources/storage_api_data_source.dart'
    as _i526;
import '../../features/garage/data/repositories/garage_repository_impl.dart'
    as _i107;
import '../../features/garage/domain/repositories/garage_repository.dart'
    as _i511;
import '../../features/garage/domain/usecases/add_car.dart' as _i292;
import '../../features/garage/domain/usecases/add_modification.dart' as _i352;
import '../../features/garage/domain/usecases/delete_car.dart' as _i287;
import '../../features/garage/domain/usecases/delete_modification.dart'
    as _i621;
import '../../features/garage/domain/usecases/get_car.dart' as _i409;
import '../../features/garage/domain/usecases/get_cover_upload_url.dart'
    as _i932;
import '../../features/garage/domain/usecases/get_gallery_upload_url.dart'
    as _i205;
import '../../features/garage/domain/usecases/get_garage_by_username.dart'
    as _i543;
import '../../features/garage/domain/usecases/get_modification_upload_urls.dart'
    as _i2;
import '../../features/garage/domain/usecases/get_my_garage.dart' as _i391;
import '../../features/garage/domain/usecases/get_reference_data.dart' as _i408;
import '../../features/garage/domain/usecases/patch_modification.dart' as _i49;
import '../../features/garage/domain/usecases/save_cover_url.dart' as _i519;
import '../../features/garage/domain/usecases/save_gallery_urls.dart' as _i235;
import '../../features/garage/domain/usecases/update_car.dart' as _i219;
import '../../features/garage/presentation/bloc/add_car/bloc.dart' as _i160;
import '../../features/garage/presentation/bloc/bloc.dart' as _i121;
import '../../features/garage/presentation/bloc/car_detail/bloc.dart' as _i807;
import '../../features/garage/presentation/bloc/log_mod/bloc.dart' as _i375;
import '../../features/profile/data/datasource/profile_api_data_source.dart'
    as _i77;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/get_current_user_profile.dart'
    as _i424;
import '../../features/profile/domain/usecases/get_profile_by_username.dart'
    as _i320;
import '../../features/profile/domain/usecases/submit_onboarding.dart'
    as _i1055;
import '../../features/profile/presentation/bloc/bloc.dart' as _i180;
import '../../features/search/data/datasource/search_api_data_source.dart'
    as _i592;
import '../../features/search/data/repositories/search_repository_impl.dart'
    as _i1017;
import '../../features/search/domain/repositories/search_repository.dart'
    as _i357;
import '../../features/search/domain/usecases/search_users.dart' as _i14;
import '../../features/search/presentation/bloc/bloc.dart' as _i462;
import '../network/abstract_http.dart' as _i311;
import '../network/dio_http_client.dart' as _i554;
import '../services/car_image_service.dart' as _i185;
import 'modules/dio_module.dart' as _i983;
import 'modules/supabase_module.dart' as _i388;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final supabaseModule = _$SupabaseModule();
    final dioModule = _$DioModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.lazySingleton<_i185.CarImageService>(() => _i185.CarImageService());
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i981.SupabaseAuthDataSource>(
      () => _i981.SupabaseAuthDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i526.StorageApiDataSource>(
      () => _i526.StorageApiDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i311.AbstractHTTP>(
      () => _i554.DioHttpClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i317.AuthRepositoryImpl(gh<_i981.SupabaseAuthDataSource>()),
    );
    gh.lazySingleton<_i587.FollowApiDataSource>(
      () => _i587.FollowApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i879.GarageApiDataSource>(
      () => _i879.GarageApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i77.ProfileApiDataSource>(
      () => _i77.ProfileApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i592.SearchApiDataSource>(
      () => _i592.SearchApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i192.CheckAuthStatusUseCase>(
      () => _i192.CheckAuthStatusUseCase(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i263.EmailPasswordSignIn>(
      () => _i263.EmailPasswordSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i920.GoogleSignIn>(
      () => _i920.GoogleSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i760.FollowRepository>(
      () => _i299.FollowRepositoryImpl(gh<_i587.FollowApiDataSource>()),
    );
    gh.lazySingleton<_i357.SearchRepository>(
      () => _i1017.SearchRepositoryImpl(gh<_i592.SearchApiDataSource>()),
    );
    gh.lazySingleton<_i256.AcceptFollowRequestUseCase>(
      () => _i256.AcceptFollowRequestUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i757.FollowUserUseCase>(
      () => _i757.FollowUserUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i28.GetFollowStatusUseCase>(
      () => _i28.GetFollowStatusUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i1027.GetFollowersUseCase>(
      () => _i1027.GetFollowersUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i495.GetFollowingUseCase>(
      () => _i495.GetFollowingUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i422.GetPendingRequestsUseCase>(
      () => _i422.GetPendingRequestsUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i669.RejectFollowRequestUseCase>(
      () => _i669.RejectFollowRequestUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i164.RemoveFollowerUseCase>(
      () => _i164.RemoveFollowerUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i31.UnfollowUserUseCase>(
      () => _i31.UnfollowUserUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i77.ProfileApiDataSource>()),
    );
    gh.lazySingleton<_i511.GarageRepository>(
      () => _i107.GarageRepositoryImpl(
        gh<_i879.GarageApiDataSource>(),
        gh<_i526.StorageApiDataSource>(),
        gh<_i185.CarImageService>(),
      ),
    );
    gh.lazySingleton<_i292.AddCarUseCase>(
      () => _i292.AddCarUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i352.AddModificationUseCase>(
      () => _i352.AddModificationUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i287.DeleteCarUseCase>(
      () => _i287.DeleteCarUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i621.DeleteModificationUseCase>(
      () => _i621.DeleteModificationUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i409.GetCarUseCase>(
      () => _i409.GetCarUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i932.GetCoverUploadUrlUseCase>(
      () => _i932.GetCoverUploadUrlUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i205.GetGalleryUploadUrlUseCase>(
      () => _i205.GetGalleryUploadUrlUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i543.GetGarageByUsernameUseCase>(
      () => _i543.GetGarageByUsernameUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i2.GetModificationUploadUrlsUseCase>(
      () => _i2.GetModificationUploadUrlsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i391.GetMyGarageUseCase>(
      () => _i391.GetMyGarageUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetBrandsUseCase>(
      () => _i408.GetBrandsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetModelsByBrandUseCase>(
      () => _i408.GetModelsByBrandUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetDrivetrainsUseCase>(
      () => _i408.GetDrivetrainsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetColorsUseCase>(
      () => _i408.GetColorsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetDistanceUnitsUseCase>(
      () => _i408.GetDistanceUnitsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetStatusOptionsUseCase>(
      () => _i408.GetStatusOptionsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i408.GetModCategoriesUseCase>(
      () => _i408.GetModCategoriesUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i49.PatchModificationUseCase>(
      () => _i49.PatchModificationUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i519.SaveCoverUrlUseCase>(
      () => _i519.SaveCoverUrlUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i235.SaveGalleryUrlsUseCase>(
      () => _i235.SaveGalleryUrlsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i219.UpdateCarUseCase>(
      () => _i219.UpdateCarUseCase(gh<_i511.GarageRepository>()),
    );
    gh.factory<_i121.GarageBloc>(
      () => _i121.GarageBloc(
        getMyGarage: gh<_i391.GetMyGarageUseCase>(),
        getGarageByUsername: gh<_i543.GetGarageByUsernameUseCase>(),
        deleteCarUseCase: gh<_i287.DeleteCarUseCase>(),
      ),
    );
    gh.lazySingleton<_i14.SearchUsersUseCase>(
      () => _i14.SearchUsersUseCase(gh<_i357.SearchRepository>()),
    );
    gh.factory<_i636.AuthBloc>(
      () => _i636.AuthBloc(
        checkAuthStatus: gh<_i192.CheckAuthStatusUseCase>(),
        loginUser: gh<_i263.EmailPasswordSignIn>(),
        googleSignIn: gh<_i920.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i424.GetCurrentUserProfileUseCase>(
      () => _i424.GetCurrentUserProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i320.GetProfileByUsernameUseCase>(
      () => _i320.GetProfileByUsernameUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i1055.SubmitOnboardingUseCase>(
      () => _i1055.SubmitOnboardingUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i160.AddCarBloc>(
      () => _i160.AddCarBloc(
        getBrands: gh<_i408.GetBrandsUseCase>(),
        getModelsByBrand: gh<_i408.GetModelsByBrandUseCase>(),
        getDrivetrains: gh<_i408.GetDrivetrainsUseCase>(),
        getColors: gh<_i408.GetColorsUseCase>(),
        getDistanceUnits: gh<_i408.GetDistanceUnitsUseCase>(),
        getStatusOptions: gh<_i408.GetStatusOptionsUseCase>(),
        getModCategories: gh<_i408.GetModCategoriesUseCase>(),
        addCar: gh<_i292.AddCarUseCase>(),
        deleteCar: gh<_i287.DeleteCarUseCase>(),
        getCoverUploadUrl: gh<_i932.GetCoverUploadUrlUseCase>(),
        saveCoverUrl: gh<_i519.SaveCoverUrlUseCase>(),
        getGalleryUploadUrl: gh<_i205.GetGalleryUploadUrlUseCase>(),
        saveGalleryUrls: gh<_i235.SaveGalleryUrlsUseCase>(),
        getModificationUploadUrls: gh<_i2.GetModificationUploadUrlsUseCase>(),
        patchModification: gh<_i49.PatchModificationUseCase>(),
        imageService: gh<_i185.CarImageService>(),
      ),
    );
    gh.factory<_i180.ProfileBloc>(
      () => _i180.ProfileBloc(
        getCurrentUserProfile: gh<_i424.GetCurrentUserProfileUseCase>(),
        getProfileByUsername: gh<_i320.GetProfileByUsernameUseCase>(),
        submitOnboarding: gh<_i1055.SubmitOnboardingUseCase>(),
      ),
    );
    gh.factory<_i236.FollowBloc>(
      () => _i236.FollowBloc(
        getFollowStatus: gh<_i28.GetFollowStatusUseCase>(),
        followUser: gh<_i757.FollowUserUseCase>(),
        unfollowUser: gh<_i31.UnfollowUserUseCase>(),
        getFollowers: gh<_i1027.GetFollowersUseCase>(),
        getFollowing: gh<_i495.GetFollowingUseCase>(),
        removeFollower: gh<_i164.RemoveFollowerUseCase>(),
      ),
    );
    gh.factory<_i807.CarDetailBloc>(
      () => _i807.CarDetailBloc(
        getCarUseCase: gh<_i409.GetCarUseCase>(),
        deleteCarUseCase: gh<_i287.DeleteCarUseCase>(),
        saveGalleryUrlsUseCase: gh<_i235.SaveGalleryUrlsUseCase>(),
        deleteModificationUseCase: gh<_i621.DeleteModificationUseCase>(),
      ),
    );
    gh.factory<_i375.LogModBloc>(
      () => _i375.LogModBloc(
        getModCategories: gh<_i408.GetModCategoriesUseCase>(),
        addModification: gh<_i352.AddModificationUseCase>(),
        deleteModification: gh<_i621.DeleteModificationUseCase>(),
        getModificationUploadUrls: gh<_i2.GetModificationUploadUrlsUseCase>(),
        patchModification: gh<_i49.PatchModificationUseCase>(),
        imageService: gh<_i185.CarImageService>(),
      ),
    );
    gh.factory<_i462.SearchBloc>(
      () => _i462.SearchBloc(searchUsers: gh<_i14.SearchUsersUseCase>()),
    );
    return this;
  }
}

class _$SupabaseModule extends _i388.SupabaseModule {}

class _$DioModule extends _i983.DioModule {}
