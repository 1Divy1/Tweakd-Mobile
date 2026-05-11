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
import '../../features/follow/domain/usecases/unfollow_user.dart' as _i31;
import '../../features/follow/presentation/bloc/bloc.dart' as _i236;
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
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i981.SupabaseAuthDataSource>(
      () => _i981.SupabaseAuthDataSource(gh<_i454.SupabaseClient>()),
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
    gh.lazySingleton<_i31.UnfollowUserUseCase>(
      () => _i31.UnfollowUserUseCase(gh<_i760.FollowRepository>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i77.ProfileApiDataSource>()),
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
    gh.factory<_i180.ProfileBloc>(
      () => _i180.ProfileBloc(
        getCurrentUserProfile: gh<_i424.GetCurrentUserProfileUseCase>(),
        getProfileByUsername: gh<_i320.GetProfileByUsernameUseCase>(),
        submitOnboarding: gh<_i1055.SubmitOnboardingUseCase>(),
      ),
    );
    gh.factory<_i236.FollowStatusBloc>(
      () => _i236.FollowStatusBloc(
        getFollowStatus: gh<_i28.GetFollowStatusUseCase>(),
        followUser: gh<_i757.FollowUserUseCase>(),
        unfollowUser: gh<_i31.UnfollowUserUseCase>(),
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
