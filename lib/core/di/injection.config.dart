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
import '../../features/authentication/domain/usecases/auth/log_out.dart'
    as _i221;
import '../../features/authentication/domain/usecases/auth/watch_external_sign_in.dart'
    as _i910;
import '../../features/authentication/domain/usecases/login/apple_signin.dart'
    as _i502;
import '../../features/authentication/domain/usecases/login/email_password_signin.dart'
    as _i263;
import '../../features/authentication/domain/usecases/login/google_signin.dart'
    as _i920;
import '../../features/authentication/domain/usecases/password_reset/request_password_reset.dart'
    as _i847;
import '../../features/authentication/domain/usecases/password_reset/update_password.dart'
    as _i854;
import '../../features/authentication/domain/usecases/password_reset/verify_password_reset_code.dart'
    as _i542;
import '../../features/authentication/domain/usecases/signup/email_password_signup.dart'
    as _i644;
import '../../features/authentication/domain/usecases/signup/resend_signup_email.dart'
    as _i198;
import '../../features/authentication/domain/usecases/signup/verify_signup_code.dart'
    as _i447;
import '../../features/authentication/presentation/bloc/bloc.dart' as _i636;
import '../../features/authentication/presentation/bloc/password_reset/bloc.dart'
    as _i57;
import '../../features/authentication/presentation/bloc/signup/bloc.dart'
    as _i246;
import '../../features/feed/data/datasources/feed_api_data_source.dart'
    as _i194;
import '../../features/feed/data/repositories/feed_repository_impl.dart'
    as _i452;
import '../../features/feed/domain/repositories/feed_repository.dart' as _i430;
import '../../features/feed/domain/usecases/get_global_feed.dart' as _i199;
import '../../features/feed/presentation/bloc/feed/bloc.dart' as _i719;
import '../../features/feedback/data/datasources/feedback_api_data_source.dart'
    as _i239;
import '../../features/feedback/data/repositories/feedback_repository_impl.dart'
    as _i961;
import '../../features/feedback/domain/repositories/feedback_repository.dart'
    as _i619;
import '../../features/feedback/domain/usecases/get_feedback_features.dart'
    as _i383;
import '../../features/feedback/domain/usecases/get_feedback_types.dart'
    as _i258;
import '../../features/feedback/domain/usecases/get_my_feedback.dart' as _i311;
import '../../features/feedback/domain/usecases/submit_feedback.dart' as _i345;
import '../../features/feedback/presentation/bloc/feedback/bloc.dart' as _i862;
import '../../features/feedback/presentation/bloc/my_feedback/bloc.dart'
    as _i129;
import '../../features/feedback_feed/data/datasources/feedback_feed_api_data_source.dart'
    as _i11;
import '../../features/feedback_feed/data/repositories/feedback_feed_repository_impl.dart'
    as _i923;
import '../../features/feedback_feed/domain/repositories/feedback_feed_repository.dart'
    as _i807;
import '../../features/feedback_feed/domain/usecases/get_feedback_board.dart'
    as _i160;
import '../../features/feedback_feed/domain/usecases/get_feedback_options.dart'
    as _i560;
import '../../features/feedback_feed/domain/usecases/manage_feedback_message.dart'
    as _i468;
import '../../features/feedback_feed/domain/usecases/vote_feedback_message.dart'
    as _i67;
import '../../features/feedback_feed/presentation/bloc/board/bloc.dart'
    as _i488;
import '../../features/feedback_feed/presentation/bloc/completed/bloc.dart'
    as _i396;
import '../../features/feedback_feed/presentation/bloc/compose/bloc.dart'
    as _i651;
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
import '../../features/forums/data/datasources/forums_api_data_source.dart'
    as _i789;
import '../../features/forums/data/repositories/forums_repository_impl.dart'
    as _i737;
import '../../features/forums/domain/repositories/forums_repository.dart'
    as _i10;
import '../../features/forums/domain/usecases/create_forum_reply.dart' as _i99;
import '../../features/forums/domain/usecases/create_forum_thread.dart'
    as _i605;
import '../../features/forums/domain/usecases/forum_saves.dart' as _i302;
import '../../features/forums/domain/usecases/forum_shortcuts.dart' as _i846;
import '../../features/forums/domain/usecases/get_forum_replies.dart' as _i480;
import '../../features/forums/domain/usecases/get_forum_suggestions.dart'
    as _i542;
import '../../features/forums/domain/usecases/get_forum_thread.dart' as _i276;
import '../../features/forums/domain/usecases/get_forum_threads.dart' as _i669;
import '../../features/forums/domain/usecases/get_forum_topics.dart' as _i354;
import '../../features/forums/domain/usecases/modify_forum_reply.dart' as _i492;
import '../../features/forums/domain/usecases/modify_forum_thread.dart'
    as _i499;
import '../../features/forums/domain/usecases/toggle_forum_likes.dart' as _i390;
import '../../features/forums/presentation/bloc/browse/bloc.dart' as _i813;
import '../../features/forums/presentation/bloc/composer/bloc.dart' as _i188;
import '../../features/forums/presentation/bloc/home/bloc.dart' as _i197;
import '../../features/forums/presentation/bloc/hub/bloc.dart' as _i198;
import '../../features/forums/presentation/bloc/saved/bloc.dart' as _i619;
import '../../features/forums/presentation/bloc/thread/bloc.dart' as _i382;
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
import '../../features/garage/domain/usecases/delete_cover_image.dart' as _i282;
import '../../features/garage/domain/usecases/delete_gallery_images.dart'
    as _i631;
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
import '../../features/garage/domain/usecases/save_cover_key.dart' as _i401;
import '../../features/garage/domain/usecases/save_gallery_keys.dart' as _i472;
import '../../features/garage/domain/usecases/update_car.dart' as _i219;
import '../../features/garage/presentation/bloc/add_car/bloc.dart' as _i160;
import '../../features/garage/presentation/bloc/bloc.dart' as _i121;
import '../../features/garage/presentation/bloc/car_detail/bloc.dart' as _i807;
import '../../features/garage/presentation/bloc/log_mod/bloc.dart' as _i375;
import '../../features/map/data/datasources/business_api_data_source.dart'
    as _i979;
import '../../features/map/data/datasources/device_location_data_source.dart'
    as _i178;
import '../../features/map/data/repositories/map_repository_impl.dart' as _i457;
import '../../features/map/domain/repositories/map_repository.dart' as _i973;
import '../../features/map/domain/usecases/get_business_detail.dart' as _i107;
import '../../features/map/domain/usecases/get_current_position.dart' as _i958;
import '../../features/map/domain/usecases/get_nearby_businesses.dart' as _i642;
import '../../features/map/presentation/bloc/map/bloc.dart' as _i465;
import '../../features/map_events/data/datasources/map_event_storage_data_source.dart'
    as _i709;
import '../../features/map_events/data/datasources/map_events_api_data_source.dart'
    as _i394;
import '../../features/map_events/data/repositories/map_events_repository_impl.dart'
    as _i545;
import '../../features/map_events/domain/repositories/map_events_repository.dart'
    as _i365;
import '../../features/map_events/domain/usecases/manage_map_event.dart'
    as _i1055;
import '../../features/map_events/domain/usecases/map_event_attendance.dart'
    as _i192;
import '../../features/map_events/domain/usecases/map_event_organizers.dart'
    as _i211;
import '../../features/map_events/domain/usecases/map_event_participation.dart'
    as _i414;
import '../../features/map_events/domain/usecases/map_event_reads.dart'
    as _i997;
import '../../features/map_events/domain/usecases/map_event_withdrawals.dart'
    as _i295;
import '../../features/map_events/presentation/bloc/attendees/bloc.dart'
    as _i647;
import '../../features/map_events/presentation/bloc/create_event/bloc.dart'
    as _i634;
import '../../features/map_events/presentation/bloc/event_detail/bloc.dart'
    as _i506;
import '../../features/map_events/presentation/bloc/manage_event/bloc.dart'
    as _i340;
import '../../features/map_events/presentation/bloc/my_events/bloc.dart'
    as _i792;
import '../../features/messages/data/datasources/messages_data_source.dart'
    as _i637;
import '../../features/messages/data/repositories/messages_repository_impl.dart'
    as _i20;
import '../../features/messages/domain/repositories/messages_repository.dart'
    as _i794;
import '../../features/messages/domain/usecases/compose.dart' as _i231;
import '../../features/messages/domain/usecases/get_inbox.dart' as _i134;
import '../../features/messages/domain/usecases/get_messages.dart' as _i15;
import '../../features/messages/domain/usecases/get_unread_count.dart' as _i915;
import '../../features/messages/domain/usecases/message_actions.dart' as _i680;
import '../../features/messages/domain/usecases/presence.dart' as _i583;
import '../../features/messages/domain/usecases/send_message.dart' as _i162;
import '../../features/messages/domain/usecases/watch_chat.dart' as _i467;
import '../../features/messages/domain/usecases/watch_inbox.dart' as _i839;
import '../../features/messages/presentation/bloc/car_picker/cubit.dart'
    as _i439;
import '../../features/messages/presentation/bloc/chat/bloc.dart' as _i269;
import '../../features/messages/presentation/bloc/compose/bloc.dart' as _i681;
import '../../features/messages/presentation/bloc/inbox/bloc.dart' as _i245;
import '../../features/messages/presentation/bloc/unread/cubit.dart' as _i409;
import '../../features/notifications/data/datasources/notifications_api_data_source.dart'
    as _i830;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i201;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i563;
import '../../features/notifications/domain/usecases/get_notifications.dart'
    as _i163;
import '../../features/notifications/domain/usecases/get_unread_notifications_count.dart'
    as _i43;
import '../../features/notifications/domain/usecases/mark_all_notifications_read.dart'
    as _i852;
import '../../features/notifications/domain/usecases/mark_notification_read.dart'
    as _i29;
import '../../features/notifications/presentation/bloc/notifications/bloc.dart'
    as _i887;
import '../../features/notifications/presentation/bloc/unread/cubit.dart'
    as _i816;
import '../../features/onboarding/data/datasources/onboarding_api_data_source.dart'
    as _i1049;
import '../../features/onboarding/data/datasources/supabase_identity_data_source.dart'
    as _i532;
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart'
    as _i452;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i430;
import '../../features/onboarding/domain/usecases/check_username_availability.dart'
    as _i842;
import '../../features/onboarding/domain/usecases/get_cities.dart' as _i343;
import '../../features/onboarding/domain/usecases/get_countries.dart' as _i290;
import '../../features/onboarding/domain/usecases/get_provider_full_name.dart'
    as _i847;
import '../../features/onboarding/domain/usecases/submit_onboarding.dart'
    as _i1016;
import '../../features/onboarding/presentation/bloc/bloc.dart' as _i797;
import '../../features/onboarding/presentation/bloc/username_availability/bloc.dart'
    as _i94;
import '../../features/posts/data/datasources/posts_api_data_source.dart'
    as _i710;
import '../../features/posts/data/datasources/posts_storage_api_data_source.dart'
    as _i747;
import '../../features/posts/data/repositories/posts_repository_impl.dart'
    as _i675;
import '../../features/posts/domain/repositories/posts_repository.dart'
    as _i245;
import '../../features/posts/domain/usecases/add_comment.dart' as _i541;
import '../../features/posts/domain/usecases/comment_actions.dart' as _i326;
import '../../features/posts/domain/usecases/create_post.dart' as _i573;
import '../../features/posts/domain/usecases/delete_post.dart' as _i640;
import '../../features/posts/domain/usecases/get_comment_replies.dart' as _i567;
import '../../features/posts/domain/usecases/get_image_upload_urls.dart'
    as _i760;
import '../../features/posts/domain/usecases/get_my_posts.dart' as _i851;
import '../../features/posts/domain/usecases/get_post.dart' as _i601;
import '../../features/posts/domain/usecases/get_post_comments.dart' as _i235;
import '../../features/posts/domain/usecases/get_post_likers.dart' as _i528;
import '../../features/posts/domain/usecases/get_posts_by_username.dart'
    as _i677;
import '../../features/posts/domain/usecases/get_saved_posts.dart' as _i742;
import '../../features/posts/domain/usecases/post_like.dart' as _i111;
import '../../features/posts/domain/usecases/post_save.dart' as _i584;
import '../../features/posts/domain/usecases/save_image_keys.dart' as _i913;
import '../../features/posts/domain/usecases/share_post.dart' as _i1023;
import '../../features/posts/domain/usecases/update_post.dart' as _i310;
import '../../features/posts/domain/usecases/upload_post_image.dart' as _i708;
import '../../features/posts/presentation/bloc/comments/bloc.dart' as _i1002;
import '../../features/posts/presentation/bloc/create_post/bloc.dart' as _i969;
import '../../features/posts/presentation/bloc/edit_post/bloc.dart' as _i470;
import '../../features/posts/presentation/bloc/likers/bloc.dart' as _i905;
import '../../features/posts/presentation/bloc/post_detail/bloc.dart' as _i486;
import '../../features/posts/presentation/bloc/profile_posts/bloc.dart'
    as _i274;
import '../../features/posts/presentation/bloc/saved_posts/bloc.dart' as _i937;
import '../../features/posts/presentation/bloc/share_post/bloc.dart' as _i690;
import '../../features/profile/data/datasource/avatar_storage_api_data_source.dart'
    as _i347;
import '../../features/profile/data/datasource/profile_api_data_source.dart'
    as _i77;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/entities/profile.dart' as _i57;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/change_profile_avatar.dart'
    as _i717;
import '../../features/profile/domain/usecases/get_current_user_profile.dart'
    as _i424;
import '../../features/profile/domain/usecases/get_language_options.dart'
    as _i437;
import '../../features/profile/domain/usecases/get_profile_by_username.dart'
    as _i320;
import '../../features/profile/domain/usecases/set_app_language.dart' as _i856;
import '../../features/profile/domain/usecases/submit_onboarding.dart'
    as _i1055;
import '../../features/profile/domain/usecases/update_profile.dart' as _i78;
import '../../features/profile/presentation/bloc/bloc.dart' as _i180;
import '../../features/profile/presentation/bloc/edit_profile/bloc.dart' as _i0;
import '../../features/profile/presentation/bloc/language_picker/bloc.dart'
    as _i959;
import '../../features/profile/presentation/bloc/locale/cubit.dart' as _i516;
import '../../features/report/data/datasources/report_api_data_source.dart'
    as _i398;
import '../../features/report/data/repositories/report_repository_impl.dart'
    as _i420;
import '../../features/report/domain/repositories/report_repository.dart'
    as _i23;
import '../../features/report/domain/usecases/get_my_reports.dart' as _i75;
import '../../features/report/domain/usecases/get_report_reasons.dart' as _i935;
import '../../features/report/domain/usecases/submit_report.dart' as _i535;
import '../../features/report/presentation/bloc/my_reports/bloc.dart' as _i370;
import '../../features/report/presentation/bloc/report/bloc.dart' as _i668;
import '../../features/search/data/datasource/search_api_data_source.dart'
    as _i592;
import '../../features/search/data/repositories/search_repository_impl.dart'
    as _i1017;
import '../../features/search/domain/repositories/search_repository.dart'
    as _i357;
import '../../features/search/domain/usecases/search_users.dart' as _i14;
import '../../features/search/presentation/bloc/bloc.dart' as _i462;
import '../../features/tags/data/datasources/tags_api_data_source.dart'
    as _i446;
import '../../features/tags/data/repositories/tags_repository_impl.dart'
    as _i160;
import '../../features/tags/domain/repositories/tags_repository.dart' as _i1070;
import '../../features/tags/domain/usecases/get_my_tags.dart' as _i227;
import '../../features/tags/domain/usecases/get_tags_by_username.dart' as _i198;
import '../../features/tags/domain/usecases/remove_tag.dart' as _i369;
import '../../features/tags/presentation/bloc/tags/bloc.dart' as _i853;
import '../network/abstract_http.dart' as _i311;
import '../network/dio_http_client.dart' as _i554;
import '../realtime/dm_realtime_service.dart' as _i511;
import '../realtime/presence_service.dart' as _i784;
import '../realtime/supabase_dm_realtime_service.dart' as _i543;
import '../realtime/supabase_presence_service.dart' as _i1029;
import '../services/image_service.dart' as _i768;
import '../services/navigation_launcher_service.dart' as _i907;
import '../services/push_permission_service.dart' as _i792;
import '../shared/bloc/tag_picker/bloc.dart' as _i155;
import '../storage/locale_local_storage.dart' as _i1069;
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
    gh.lazySingleton<_i768.ImageService>(() => _i768.ImageService());
    gh.lazySingleton<_i907.NavigationLauncherService>(
      () => _i907.NavigationLauncherService(),
    );
    gh.lazySingleton<_i792.PushPermissionService>(
      () => _i792.PushPermissionService(),
    );
    gh.lazySingleton<_i1069.LocaleLocalStorage>(
      () => _i1069.LocaleLocalStorage(),
    );
    gh.lazySingleton<_i178.DeviceLocationDataSource>(
      () => _i178.DeviceLocationDataSource(),
    );
    gh.lazySingleton<_i784.PresenceService>(
      () => _i1029.SupabasePresenceService(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i516.LocaleCubit>(
      () => _i516.LocaleCubit(gh<_i1069.LocaleLocalStorage>()),
    );
    gh.lazySingleton<_i511.DmRealtimeService>(
      () => _i543.SupabaseDmRealtimeService(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i981.SupabaseAuthDataSource>(
      () => _i981.SupabaseAuthDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i526.StorageApiDataSource>(
      () => _i526.StorageApiDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i709.MapEventStorageDataSource>(
      () => _i709.MapEventStorageDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i532.SupabaseIdentityDataSource>(
      () => _i532.SupabaseIdentityDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i747.PostsStorageApiDataSource>(
      () => _i747.PostsStorageApiDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i347.AvatarStorageApiDataSource>(
      () => _i347.AvatarStorageApiDataSource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i311.AbstractHTTP>(
      () => _i554.DioHttpClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i637.MessagesDataSource>(
      () => _i637.MessagesApiDataSource(
        gh<_i311.AbstractHTTP>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.lazySingleton<_i194.FeedApiDataSource>(
      () => _i194.FeedApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i239.FeedbackApiDataSource>(
      () => _i239.FeedbackApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i11.FeedbackFeedApiDataSource>(
      () => _i11.FeedbackFeedApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i587.FollowApiDataSource>(
      () => _i587.FollowApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i789.ForumsApiDataSource>(
      () => _i789.ForumsApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i879.GarageApiDataSource>(
      () => _i879.GarageApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i979.BusinessApiDataSource>(
      () => _i979.BusinessApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i394.MapEventsApiDataSource>(
      () => _i394.MapEventsApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i1049.OnboardingApiDataSource>(
      () => _i1049.OnboardingApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i710.PostsApiDataSource>(
      () => _i710.PostsApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i77.ProfileApiDataSource>(
      () => _i77.ProfileApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i398.ReportApiDataSource>(
      () => _i398.ReportApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i592.SearchApiDataSource>(
      () => _i592.SearchApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i446.TagsApiDataSource>(
      () => _i446.TagsApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i830.NotificationsDataSource>(
      () => _i830.NotificationsApiDataSource(gh<_i311.AbstractHTTP>()),
    );
    gh.lazySingleton<_i23.ReportRepository>(
      () => _i420.ReportRepositoryImpl(gh<_i398.ReportApiDataSource>()),
    );
    gh.lazySingleton<_i563.NotificationsRepository>(
      () => _i201.NotificationsRepositoryImpl(
        gh<_i830.NotificationsDataSource>(),
      ),
    );
    gh.lazySingleton<_i973.MapRepository>(
      () => _i457.MapRepositoryImpl(
        gh<_i979.BusinessApiDataSource>(),
        gh<_i178.DeviceLocationDataSource>(),
      ),
    );
    gh.lazySingleton<_i245.PostsRepository>(
      () => _i675.PostsRepositoryImpl(
        gh<_i710.PostsApiDataSource>(),
        gh<_i747.PostsStorageApiDataSource>(),
        gh<_i768.ImageService>(),
      ),
    );
    gh.lazySingleton<_i430.OnboardingRepository>(
      () => _i452.OnboardingRepositoryImpl(
        gh<_i1049.OnboardingApiDataSource>(),
        gh<_i532.SupabaseIdentityDataSource>(),
      ),
    );
    gh.lazySingleton<_i541.AddCommentUseCase>(
      () => _i541.AddCommentUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i326.DeleteCommentUseCase>(
      () => _i326.DeleteCommentUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i326.LikeCommentUseCase>(
      () => _i326.LikeCommentUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i326.UnlikeCommentUseCase>(
      () => _i326.UnlikeCommentUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i573.CreatePostUseCase>(
      () => _i573.CreatePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i640.DeletePostUseCase>(
      () => _i640.DeletePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i567.GetCommentRepliesUseCase>(
      () => _i567.GetCommentRepliesUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i760.GetImageUploadUrlsUseCase>(
      () => _i760.GetImageUploadUrlsUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i851.GetMyPostsUseCase>(
      () => _i851.GetMyPostsUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i601.GetPostUseCase>(
      () => _i601.GetPostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i235.GetPostCommentsUseCase>(
      () => _i235.GetPostCommentsUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i528.GetPostLikersUseCase>(
      () => _i528.GetPostLikersUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i677.GetPostsByUsernameUseCase>(
      () => _i677.GetPostsByUsernameUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i742.GetSavedPostsUseCase>(
      () => _i742.GetSavedPostsUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i111.LikePostUseCase>(
      () => _i111.LikePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i111.UnlikePostUseCase>(
      () => _i111.UnlikePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i584.SavePostUseCase>(
      () => _i584.SavePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i584.UnsavePostUseCase>(
      () => _i584.UnsavePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i913.SaveImageKeysUseCase>(
      () => _i913.SaveImageKeysUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i1023.SharePostUseCase>(
      () => _i1023.SharePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i310.UpdatePostUseCase>(
      () => _i310.UpdatePostUseCase(gh<_i245.PostsRepository>()),
    );
    gh.lazySingleton<_i708.UploadPostImageUseCase>(
      () => _i708.UploadPostImageUseCase(gh<_i245.PostsRepository>()),
    );
    gh.factory<_i969.CreatePostBloc>(
      () => _i969.CreatePostBloc(
        createPost: gh<_i573.CreatePostUseCase>(),
        getImageUploadUrls: gh<_i760.GetImageUploadUrlsUseCase>(),
        uploadImage: gh<_i708.UploadPostImageUseCase>(),
        saveImageKeys: gh<_i913.SaveImageKeysUseCase>(),
        deletePost: gh<_i640.DeletePostUseCase>(),
        imageService: gh<_i768.ImageService>(),
      ),
    );
    gh.lazySingleton<_i107.GetBusinessDetailUseCase>(
      () => _i107.GetBusinessDetailUseCase(gh<_i973.MapRepository>()),
    );
    gh.lazySingleton<_i958.GetCurrentPositionUseCase>(
      () => _i958.GetCurrentPositionUseCase(gh<_i973.MapRepository>()),
    );
    gh.lazySingleton<_i642.GetNearbyBusinessesUseCase>(
      () => _i642.GetNearbyBusinessesUseCase(gh<_i973.MapRepository>()),
    );
    gh.lazySingleton<_i430.FeedRepository>(
      () => _i452.FeedRepositoryImpl(gh<_i194.FeedApiDataSource>()),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i317.AuthRepositoryImpl(gh<_i981.SupabaseAuthDataSource>()),
    );
    gh.lazySingleton<_i619.FeedbackRepository>(
      () => _i961.FeedbackRepositoryImpl(gh<_i239.FeedbackApiDataSource>()),
    );
    gh.lazySingleton<_i511.GarageRepository>(
      () => _i107.GarageRepositoryImpl(
        gh<_i879.GarageApiDataSource>(),
        gh<_i526.StorageApiDataSource>(),
        gh<_i768.ImageService>(),
      ),
    );
    gh.lazySingleton<_i192.CheckAuthStatusUseCase>(
      () => _i192.CheckAuthStatusUseCase(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i221.LogOut>(
      () => _i221.LogOut(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i910.WatchExternalSignIn>(
      () => _i910.WatchExternalSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i502.AppleSignIn>(
      () => _i502.AppleSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i263.EmailPasswordSignIn>(
      () => _i263.EmailPasswordSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i920.GoogleSignIn>(
      () => _i920.GoogleSignIn(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i847.RequestPasswordReset>(
      () => _i847.RequestPasswordReset(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i854.UpdatePassword>(
      () => _i854.UpdatePassword(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i542.VerifyPasswordResetCode>(
      () => _i542.VerifyPasswordResetCode(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i644.EmailPasswordSignUp>(
      () => _i644.EmailPasswordSignUp(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i198.ResendSignUpEmail>(
      () => _i198.ResendSignUpEmail(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i447.VerifySignUpCode>(
      () => _i447.VerifySignUpCode(gh<_i742.AuthRepository>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(
        gh<_i77.ProfileApiDataSource>(),
        gh<_i347.AvatarStorageApiDataSource>(),
        gh<_i768.ImageService>(),
      ),
    );
    gh.lazySingleton<_i1070.TagsRepository>(
      () => _i160.TagsRepositoryImpl(gh<_i446.TagsApiDataSource>()),
    );
    gh.lazySingleton<_i163.GetNotificationsUseCase>(
      () => _i163.GetNotificationsUseCase(gh<_i563.NotificationsRepository>()),
    );
    gh.lazySingleton<_i43.GetUnreadNotificationsCountUseCase>(
      () => _i43.GetUnreadNotificationsCountUseCase(
        gh<_i563.NotificationsRepository>(),
      ),
    );
    gh.lazySingleton<_i852.MarkAllNotificationsReadUseCase>(
      () => _i852.MarkAllNotificationsReadUseCase(
        gh<_i563.NotificationsRepository>(),
      ),
    );
    gh.lazySingleton<_i29.MarkNotificationReadUseCase>(
      () =>
          _i29.MarkNotificationReadUseCase(gh<_i563.NotificationsRepository>()),
    );
    gh.factory<_i486.PostDetailBloc>(
      () => _i486.PostDetailBloc(
        getPost: gh<_i601.GetPostUseCase>(),
        likePost: gh<_i111.LikePostUseCase>(),
        unlikePost: gh<_i111.UnlikePostUseCase>(),
        savePost: gh<_i584.SavePostUseCase>(),
        unsavePost: gh<_i584.UnsavePostUseCase>(),
        deletePost: gh<_i640.DeletePostUseCase>(),
      ),
    );
    gh.lazySingleton<_i760.FollowRepository>(
      () => _i299.FollowRepositoryImpl(gh<_i587.FollowApiDataSource>()),
    );
    gh.lazySingleton<_i199.GetGlobalFeedUseCase>(
      () => _i199.GetGlobalFeedUseCase(gh<_i430.FeedRepository>()),
    );
    gh.lazySingleton<_i717.ChangeProfileAvatarUseCase>(
      () => _i717.ChangeProfileAvatarUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i424.GetCurrentUserProfileUseCase>(
      () => _i424.GetCurrentUserProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i437.GetLanguageOptionsUseCase>(
      () => _i437.GetLanguageOptionsUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i320.GetProfileByUsernameUseCase>(
      () => _i320.GetProfileByUsernameUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i856.SetAppLanguageUseCase>(
      () => _i856.SetAppLanguageUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i1055.SubmitOnboardingUseCase>(
      () => _i1055.SubmitOnboardingUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i78.UpdateProfileUseCase>(
      () => _i78.UpdateProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i365.MapEventsRepository>(
      () => _i545.MapEventsRepositoryImpl(
        gh<_i394.MapEventsApiDataSource>(),
        gh<_i709.MapEventStorageDataSource>(),
      ),
    );
    gh.factory<_i690.SharePostBloc>(
      () => _i690.SharePostBloc(gh<_i1023.SharePostUseCase>()),
    );
    gh.lazySingleton<_i10.ForumsRepository>(
      () => _i737.ForumsRepositoryImpl(gh<_i789.ForumsApiDataSource>()),
    );
    gh.lazySingleton<_i357.SearchRepository>(
      () => _i1017.SearchRepositoryImpl(gh<_i592.SearchApiDataSource>()),
    );
    gh.lazySingleton<_i1055.CreateMapEventUseCase>(
      () => _i1055.CreateMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.UpdateMapEventUseCase>(
      () => _i1055.UpdateMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.ReplaceMapEventRulesUseCase>(
      () => _i1055.ReplaceMapEventRulesUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.GetMapEventCoverUploadUrlUseCase>(
      () => _i1055.GetMapEventCoverUploadUrlUseCase(
        gh<_i365.MapEventsRepository>(),
      ),
    );
    gh.lazySingleton<_i1055.SetMapEventCoverUseCase>(
      () => _i1055.SetMapEventCoverUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.CancelMapEventUseCase>(
      () => _i1055.CancelMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.FinishMapEventUseCase>(
      () => _i1055.FinishMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i1055.DeleteMapEventUseCase>(
      () => _i1055.DeleteMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i192.SetMapEventAttendanceUseCase>(
      () => _i192.SetMapEventAttendanceUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i192.ClearMapEventAttendanceUseCase>(
      () =>
          _i192.ClearMapEventAttendanceUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i211.SearchOrganizerCandidatesUseCase>(
      () => _i211.SearchOrganizerCandidatesUseCase(
        gh<_i365.MapEventsRepository>(),
      ),
    );
    gh.lazySingleton<_i211.AddMapEventOrganizerUseCase>(
      () => _i211.AddMapEventOrganizerUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i211.RemoveMapEventOrganizerUseCase>(
      () =>
          _i211.RemoveMapEventOrganizerUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i414.RegisterCarForMapEventUseCase>(
      () =>
          _i414.RegisterCarForMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i414.CancelCarRegistrationUseCase>(
      () => _i414.CancelCarRegistrationUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i414.ReviewCarRegistrationUseCase>(
      () => _i414.ReviewCarRegistrationUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetNearbyMapEventsUseCase>(
      () => _i997.GetNearbyMapEventsUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMapEventCategoriesUseCase>(
      () => _i997.GetMapEventCategoriesUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMapEventUseCase>(
      () => _i997.GetMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMyMapEventsUseCase>(
      () => _i997.GetMyMapEventsUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMapEventAttendeesUseCase>(
      () => _i997.GetMapEventAttendeesUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMapEventCarsUseCase>(
      () => _i997.GetMapEventCarsUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.GetMyMapEventCarsUseCase>(
      () => _i997.GetMyMapEventCarsUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i997.SearchMapEventLocationUseCase>(
      () =>
          _i997.SearchMapEventLocationUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i295.WithdrawFromMapEventUseCase>(
      () => _i295.WithdrawFromMapEventUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i295.GetMapEventWithdrawalsUseCase>(
      () =>
          _i295.GetMapEventWithdrawalsUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i295.ApproveWithdrawalUseCase>(
      () => _i295.ApproveWithdrawalUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.lazySingleton<_i295.RejectWithdrawalUseCase>(
      () => _i295.RejectWithdrawalUseCase(gh<_i365.MapEventsRepository>()),
    );
    gh.factory<_i57.PasswordResetBloc>(
      () => _i57.PasswordResetBloc(
        requestPasswordReset: gh<_i847.RequestPasswordReset>(),
        verifyPasswordResetCode: gh<_i542.VerifyPasswordResetCode>(),
        updatePassword: gh<_i854.UpdatePassword>(),
      ),
    );
    gh.lazySingleton<_i842.CheckUsernameAvailabilityUseCase>(
      () => _i842.CheckUsernameAvailabilityUseCase(
        gh<_i430.OnboardingRepository>(),
      ),
    );
    gh.lazySingleton<_i343.GetCitiesUseCase>(
      () => _i343.GetCitiesUseCase(gh<_i430.OnboardingRepository>()),
    );
    gh.lazySingleton<_i290.GetCountriesUseCase>(
      () => _i290.GetCountriesUseCase(gh<_i430.OnboardingRepository>()),
    );
    gh.lazySingleton<_i847.GetProviderFullName>(
      () => _i847.GetProviderFullName(gh<_i430.OnboardingRepository>()),
    );
    gh.lazySingleton<_i1016.SubmitOnboardingUseCase>(
      () => _i1016.SubmitOnboardingUseCase(gh<_i430.OnboardingRepository>()),
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
    gh.lazySingleton<_i282.DeleteCoverImageUseCase>(
      () => _i282.DeleteCoverImageUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i631.DeleteGalleryImagesUseCase>(
      () => _i631.DeleteGalleryImagesUseCase(gh<_i511.GarageRepository>()),
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
    gh.lazySingleton<_i408.GetFuelTypeOptionsUseCase>(
      () => _i408.GetFuelTypeOptionsUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i49.PatchModificationUseCase>(
      () => _i49.PatchModificationUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i401.SaveCoverKeyUseCase>(
      () => _i401.SaveCoverKeyUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i472.SaveGalleryKeysUseCase>(
      () => _i472.SaveGalleryKeysUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i219.UpdateCarUseCase>(
      () => _i219.UpdateCarUseCase(gh<_i511.GarageRepository>()),
    );
    gh.lazySingleton<_i75.GetMyReportsUseCase>(
      () => _i75.GetMyReportsUseCase(gh<_i23.ReportRepository>()),
    );
    gh.lazySingleton<_i935.GetReportReasonsUseCase>(
      () => _i935.GetReportReasonsUseCase(gh<_i23.ReportRepository>()),
    );
    gh.lazySingleton<_i535.SubmitReportUseCase>(
      () => _i535.SubmitReportUseCase(gh<_i23.ReportRepository>()),
    );
    gh.factory<_i813.ForumBrowseBloc>(
      () => _i813.ForumBrowseBloc(getBrands: gh<_i408.GetBrandsUseCase>()),
    );
    gh.factory<_i340.ManageMapEventBloc>(
      () => _i340.ManageMapEventBloc(
        getEvent: gh<_i997.GetMapEventUseCase>(),
        getCars: gh<_i997.GetMapEventCarsUseCase>(),
        getWithdrawals: gh<_i295.GetMapEventWithdrawalsUseCase>(),
        reviewCar: gh<_i414.ReviewCarRegistrationUseCase>(),
        approveWithdrawal: gh<_i295.ApproveWithdrawalUseCase>(),
        rejectWithdrawal: gh<_i295.RejectWithdrawalUseCase>(),
        removeOrganizer: gh<_i211.RemoveMapEventOrganizerUseCase>(),
        cancelEvent: gh<_i1055.CancelMapEventUseCase>(),
        finishEvent: gh<_i1055.FinishMapEventUseCase>(),
        deleteEvent: gh<_i1055.DeleteMapEventUseCase>(),
      ),
    );
    gh.lazySingleton<_i807.FeedbackFeedRepository>(
      () => _i923.FeedbackFeedRepositoryImpl(
        gh<_i11.FeedbackFeedApiDataSource>(),
      ),
    );
    gh.factory<_i937.SavedPostsBloc>(
      () =>
          _i937.SavedPostsBloc(getSavedPosts: gh<_i742.GetSavedPostsUseCase>()),
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
    gh.factory<_i375.LogModBloc>(
      () => _i375.LogModBloc(
        getModCategories: gh<_i408.GetModCategoriesUseCase>(),
        addModification: gh<_i352.AddModificationUseCase>(),
        deleteModification: gh<_i621.DeleteModificationUseCase>(),
        getModificationUploadUrls: gh<_i2.GetModificationUploadUrlsUseCase>(),
        patchModification: gh<_i49.PatchModificationUseCase>(),
        imageService: gh<_i768.ImageService>(),
      ),
    );
    gh.lazySingleton<_i794.MessagesRepository>(
      () => _i20.MessagesRepositoryImpl(
        gh<_i637.MessagesDataSource>(),
        gh<_i511.DmRealtimeService>(),
        gh<_i784.PresenceService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i470.EditPostBloc>(
      () => _i470.EditPostBloc(
        updatePost: gh<_i310.UpdatePostUseCase>(),
        deletePost: gh<_i640.DeletePostUseCase>(),
      ),
    );
    gh.lazySingleton<_i383.GetFeedbackFeaturesUseCase>(
      () => _i383.GetFeedbackFeaturesUseCase(gh<_i619.FeedbackRepository>()),
    );
    gh.lazySingleton<_i258.GetFeedbackTypesUseCase>(
      () => _i258.GetFeedbackTypesUseCase(gh<_i619.FeedbackRepository>()),
    );
    gh.lazySingleton<_i311.GetMyFeedbackUseCase>(
      () => _i311.GetMyFeedbackUseCase(gh<_i619.FeedbackRepository>()),
    );
    gh.lazySingleton<_i345.SubmitFeedbackUseCase>(
      () => _i345.SubmitFeedbackUseCase(gh<_i619.FeedbackRepository>()),
    );
    gh.factory<_i905.LikersBloc>(
      () => _i905.LikersBloc(getLikers: gh<_i528.GetPostLikersUseCase>()),
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
    gh.factory<_i647.MapEventAttendeesBloc>(
      () => _i647.MapEventAttendeesBloc(
        getAttendees: gh<_i997.GetMapEventAttendeesUseCase>(),
      ),
    );
    gh.factory<_i129.MyFeedbackBloc>(
      () =>
          _i129.MyFeedbackBloc(getMyFeedback: gh<_i311.GetMyFeedbackUseCase>()),
    );
    gh.factory<_i246.SignUpBloc>(
      () => _i246.SignUpBloc(
        signUp: gh<_i644.EmailPasswordSignUp>(),
        verifySignUpCode: gh<_i447.VerifySignUpCode>(),
        resendSignUpEmail: gh<_i198.ResendSignUpEmail>(),
      ),
    );
    gh.factory<_i439.GarageCarsCubit>(
      () => _i439.GarageCarsCubit(getMyGarage: gh<_i391.GetMyGarageUseCase>()),
    );
    gh.factory<_i1002.CommentsBloc>(
      () => _i1002.CommentsBloc(
        getComments: gh<_i235.GetPostCommentsUseCase>(),
        getReplies: gh<_i567.GetCommentRepliesUseCase>(),
        addComment: gh<_i541.AddCommentUseCase>(),
        deleteComment: gh<_i326.DeleteCommentUseCase>(),
        likeComment: gh<_i326.LikeCommentUseCase>(),
        unlikeComment: gh<_i326.UnlikeCommentUseCase>(),
      ),
    );
    gh.factory<_i634.CreateMapEventBloc>(
      () => _i634.CreateMapEventBloc(
        getCategories: gh<_i997.GetMapEventCategoriesUseCase>(),
        createEvent: gh<_i1055.CreateMapEventUseCase>(),
        updateEvent: gh<_i1055.UpdateMapEventUseCase>(),
        replaceRules: gh<_i1055.ReplaceMapEventRulesUseCase>(),
        getCoverUploadUrl: gh<_i1055.GetMapEventCoverUploadUrlUseCase>(),
        setCover: gh<_i1055.SetMapEventCoverUseCase>(),
        addOrganizer: gh<_i211.AddMapEventOrganizerUseCase>(),
        removeOrganizer: gh<_i211.RemoveMapEventOrganizerUseCase>(),
        imageService: gh<_i768.ImageService>(),
      ),
    );
    gh.factory<_i719.FeedBloc>(
      () => _i719.FeedBloc(
        getGlobalFeed: gh<_i199.GetGlobalFeedUseCase>(),
        likePost: gh<_i111.LikePostUseCase>(),
        unlikePost: gh<_i111.UnlikePostUseCase>(),
        savePost: gh<_i584.SavePostUseCase>(),
        unsavePost: gh<_i584.UnsavePostUseCase>(),
        addComment: gh<_i541.AddCommentUseCase>(),
      ),
    );
    gh.lazySingleton<_i231.GetComposeSuggestionsUseCase>(
      () => _i231.GetComposeSuggestionsUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i134.GetInboxUseCase>(
      () => _i134.GetInboxUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i15.GetMessagesUseCase>(
      () => _i15.GetMessagesUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i915.GetUnreadCountUseCase>(
      () => _i915.GetUnreadCountUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i680.DeleteMessageUseCase>(
      () => _i680.DeleteMessageUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i680.HideConversationUseCase>(
      () => _i680.HideConversationUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i680.MarkConversationReadUseCase>(
      () => _i680.MarkConversationReadUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i680.SendTypingUseCase>(
      () => _i680.SendTypingUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i583.GetPresenceUseCase>(
      () => _i583.GetPresenceUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i583.WatchPresenceUseCase>(
      () => _i583.WatchPresenceUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i162.SendMessageUseCase>(
      () => _i162.SendMessageUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i467.WatchChatUseCase>(
      () => _i467.WatchChatUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.lazySingleton<_i839.WatchInboxMessagesUseCase>(
      () => _i839.WatchInboxMessagesUseCase(gh<_i794.MessagesRepository>()),
    );
    gh.factory<_i274.ProfilePostsBloc>(
      () => _i274.ProfilePostsBloc(
        getMyPosts: gh<_i851.GetMyPostsUseCase>(),
        getPostsByUsername: gh<_i677.GetPostsByUsernameUseCase>(),
      ),
    );
    gh.factory<_i792.MyMapEventsBloc>(
      () =>
          _i792.MyMapEventsBloc(getMyEvents: gh<_i997.GetMyMapEventsUseCase>()),
    );
    gh.factory<_i94.UsernameAvailabilityBloc>(
      () => _i94.UsernameAvailabilityBloc(
        checkUsername: gh<_i842.CheckUsernameAvailabilityUseCase>(),
      ),
    );
    gh.lazySingleton<_i160.GetFeedbackBoardUseCase>(
      () => _i160.GetFeedbackBoardUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i160.GetCompletedFeedbackUseCase>(
      () =>
          _i160.GetCompletedFeedbackUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i560.GetFeedbackTypesUseCase>(
      () => _i560.GetFeedbackTypesUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i560.GetFeedbackStatusesUseCase>(
      () =>
          _i560.GetFeedbackStatusesUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i468.CreateFeedbackMessageUseCase>(
      () => _i468.CreateFeedbackMessageUseCase(
        gh<_i807.FeedbackFeedRepository>(),
      ),
    );
    gh.lazySingleton<_i468.DeleteFeedbackMessageUseCase>(
      () => _i468.DeleteFeedbackMessageUseCase(
        gh<_i807.FeedbackFeedRepository>(),
      ),
    );
    gh.lazySingleton<_i468.GetFeedbackMessageUseCase>(
      () => _i468.GetFeedbackMessageUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i67.VoteFeedbackMessageUseCase>(
      () => _i67.VoteFeedbackMessageUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.lazySingleton<_i67.WithdrawFeedbackVoteUseCase>(
      () =>
          _i67.WithdrawFeedbackVoteUseCase(gh<_i807.FeedbackFeedRepository>()),
    );
    gh.factory<_i807.CarDetailBloc>(
      () => _i807.CarDetailBloc(
        getCarUseCase: gh<_i409.GetCarUseCase>(),
        deleteCarUseCase: gh<_i287.DeleteCarUseCase>(),
        deleteGalleryImagesUseCase: gh<_i631.DeleteGalleryImagesUseCase>(),
        deleteModificationUseCase: gh<_i621.DeleteModificationUseCase>(),
      ),
    );
    gh.factory<_i269.ChatBloc>(
      () => _i269.ChatBloc(
        getMessages: gh<_i15.GetMessagesUseCase>(),
        sendMessage: gh<_i162.SendMessageUseCase>(),
        deleteMessage: gh<_i680.DeleteMessageUseCase>(),
        markConversationRead: gh<_i680.MarkConversationReadUseCase>(),
        sendTyping: gh<_i680.SendTypingUseCase>(),
        watchChat: gh<_i467.WatchChatUseCase>(),
        getPresence: gh<_i583.GetPresenceUseCase>(),
        watchPresence: gh<_i583.WatchPresenceUseCase>(),
      ),
    );
    gh.factory<_i506.MapEventDetailBloc>(
      () => _i506.MapEventDetailBloc(
        getEvent: gh<_i997.GetMapEventUseCase>(),
        getAttendees: gh<_i997.GetMapEventAttendeesUseCase>(),
        getCars: gh<_i997.GetMapEventCarsUseCase>(),
        getMyCars: gh<_i997.GetMyMapEventCarsUseCase>(),
        setAttendance: gh<_i192.SetMapEventAttendanceUseCase>(),
        clearAttendance: gh<_i192.ClearMapEventAttendanceUseCase>(),
        registerCar: gh<_i414.RegisterCarForMapEventUseCase>(),
        cancelCarRegistration: gh<_i414.CancelCarRegistrationUseCase>(),
        withdraw: gh<_i295.WithdrawFromMapEventUseCase>(),
      ),
    );
    gh.factory<_i409.DmUnreadCubit>(
      () => _i409.DmUnreadCubit(
        getUnreadCount: gh<_i915.GetUnreadCountUseCase>(),
        watchInboxMessages: gh<_i839.WatchInboxMessagesUseCase>(),
      ),
    );
    gh.factory<_i862.FeedbackBloc>(
      () => _i862.FeedbackBloc(
        getTypes: gh<_i258.GetFeedbackTypesUseCase>(),
        getFeatures: gh<_i383.GetFeedbackFeaturesUseCase>(),
        submitFeedback: gh<_i345.SubmitFeedbackUseCase>(),
      ),
    );
    gh.lazySingleton<_i14.SearchUsersUseCase>(
      () => _i14.SearchUsersUseCase(gh<_i357.SearchRepository>()),
    );
    gh.factory<_i959.LanguagePickerBloc>(
      () => _i959.LanguagePickerBloc(
        getLanguageOptions: gh<_i437.GetLanguageOptionsUseCase>(),
        setAppLanguage: gh<_i856.SetAppLanguageUseCase>(),
      ),
    );
    gh.lazySingleton<_i227.GetMyTagsUseCase>(
      () => _i227.GetMyTagsUseCase(gh<_i1070.TagsRepository>()),
    );
    gh.lazySingleton<_i198.GetTagsByUsernameUseCase>(
      () => _i198.GetTagsByUsernameUseCase(gh<_i1070.TagsRepository>()),
    );
    gh.lazySingleton<_i369.RemoveTagUseCase>(
      () => _i369.RemoveTagUseCase(gh<_i1070.TagsRepository>()),
    );
    gh.factory<_i488.FeedbackBoardBloc>(
      () => _i488.FeedbackBoardBloc(
        getBoard: gh<_i160.GetFeedbackBoardUseCase>(),
        voteMessage: gh<_i67.VoteFeedbackMessageUseCase>(),
        withdrawVote: gh<_i67.WithdrawFeedbackVoteUseCase>(),
        deleteMessage: gh<_i468.DeleteFeedbackMessageUseCase>(),
      ),
    );
    gh.lazySingleton<_i99.CreateForumReplyUseCase>(
      () => _i99.CreateForumReplyUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i605.CreateForumThreadUseCase>(
      () => _i605.CreateForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i302.SaveForumThreadUseCase>(
      () => _i302.SaveForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i302.UnsaveForumThreadUseCase>(
      () => _i302.UnsaveForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i302.GetSavedForumThreadsUseCase>(
      () => _i302.GetSavedForumThreadsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i846.GetForumShortcutsUseCase>(
      () => _i846.GetForumShortcutsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i846.CreateForumShortcutUseCase>(
      () => _i846.CreateForumShortcutUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i846.UpdateForumShortcutUseCase>(
      () => _i846.UpdateForumShortcutUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i846.ReorderForumShortcutsUseCase>(
      () => _i846.ReorderForumShortcutsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i846.DeleteForumShortcutUseCase>(
      () => _i846.DeleteForumShortcutUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i480.GetThreadRepliesUseCase>(
      () => _i480.GetThreadRepliesUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i480.GetReplyChildrenUseCase>(
      () => _i480.GetReplyChildrenUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i542.GetForumSuggestionsUseCase>(
      () => _i542.GetForumSuggestionsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i276.GetForumThreadUseCase>(
      () => _i276.GetForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i669.GetForumThreadsUseCase>(
      () => _i669.GetForumThreadsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i354.GetForumTopicsUseCase>(
      () => _i354.GetForumTopicsUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i492.EditForumReplyUseCase>(
      () => _i492.EditForumReplyUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i492.DeleteForumReplyUseCase>(
      () => _i492.DeleteForumReplyUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i499.EditForumThreadUseCase>(
      () => _i499.EditForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i499.DeleteForumThreadUseCase>(
      () => _i499.DeleteForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i390.LikeForumThreadUseCase>(
      () => _i390.LikeForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i390.UnlikeForumThreadUseCase>(
      () => _i390.UnlikeForumThreadUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i390.LikeForumReplyUseCase>(
      () => _i390.LikeForumReplyUseCase(gh<_i10.ForumsRepository>()),
    );
    gh.lazySingleton<_i390.UnlikeForumReplyUseCase>(
      () => _i390.UnlikeForumReplyUseCase(gh<_i10.ForumsRepository>()),
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
        getFuelTypeOptions: gh<_i408.GetFuelTypeOptionsUseCase>(),
        addCar: gh<_i292.AddCarUseCase>(),
        updateCar: gh<_i219.UpdateCarUseCase>(),
        deleteCar: gh<_i287.DeleteCarUseCase>(),
        getCoverUploadUrl: gh<_i932.GetCoverUploadUrlUseCase>(),
        saveCoverKey: gh<_i401.SaveCoverKeyUseCase>(),
        deleteCoverImage: gh<_i282.DeleteCoverImageUseCase>(),
        getGalleryUploadUrl: gh<_i205.GetGalleryUploadUrlUseCase>(),
        saveGalleryKeys: gh<_i472.SaveGalleryKeysUseCase>(),
        deleteGalleryImages: gh<_i631.DeleteGalleryImagesUseCase>(),
        addModification: gh<_i352.AddModificationUseCase>(),
        getModificationUploadUrls: gh<_i2.GetModificationUploadUrlsUseCase>(),
        patchModification: gh<_i49.PatchModificationUseCase>(),
        deleteModification: gh<_i621.DeleteModificationUseCase>(),
        imageService: gh<_i768.ImageService>(),
      ),
    );
    gh.factory<_i816.NotificationsUnreadCubit>(
      () => _i816.NotificationsUnreadCubit(
        getUnreadCount: gh<_i43.GetUnreadNotificationsCountUseCase>(),
      ),
    );
    gh.factory<_i121.GarageBloc>(
      () => _i121.GarageBloc(
        getMyGarage: gh<_i391.GetMyGarageUseCase>(),
        getGarageByUsername: gh<_i543.GetGarageByUsernameUseCase>(),
        deleteCarUseCase: gh<_i287.DeleteCarUseCase>(),
      ),
    );
    gh.factoryParam<_i0.EditProfileBloc, _i57.ProfileEntity, dynamic>(
      (profile, _) => _i0.EditProfileBloc(
        updateProfile: gh<_i78.UpdateProfileUseCase>(),
        changeProfileAvatar: gh<_i717.ChangeProfileAvatarUseCase>(),
        profile: profile,
      ),
    );
    gh.factory<_i887.NotificationsBloc>(
      () => _i887.NotificationsBloc(
        getNotifications: gh<_i163.GetNotificationsUseCase>(),
        markNotificationRead: gh<_i29.MarkNotificationReadUseCase>(),
        markAllNotificationsRead: gh<_i852.MarkAllNotificationsReadUseCase>(),
      ),
    );
    gh.factory<_i668.ReportBloc>(
      () => _i668.ReportBloc(
        getReasons: gh<_i935.GetReportReasonsUseCase>(),
        submitReport: gh<_i535.SubmitReportUseCase>(),
      ),
    );
    gh.factory<_i636.AuthBloc>(
      () => _i636.AuthBloc(
        checkAuthStatus: gh<_i192.CheckAuthStatusUseCase>(),
        loginUser: gh<_i263.EmailPasswordSignIn>(),
        googleSignIn: gh<_i920.GoogleSignIn>(),
        appleSignIn: gh<_i502.AppleSignIn>(),
        logOut: gh<_i221.LogOut>(),
        watchExternalSignIn: gh<_i910.WatchExternalSignIn>(),
      ),
    );
    gh.factory<_i370.MyReportsBloc>(
      () => _i370.MyReportsBloc(getMyReports: gh<_i75.GetMyReportsUseCase>()),
    );
    gh.factory<_i797.OnboardingBloc>(
      () => _i797.OnboardingBloc(
        getCountries: gh<_i290.GetCountriesUseCase>(),
        getCities: gh<_i343.GetCitiesUseCase>(),
        getBrands: gh<_i408.GetBrandsUseCase>(),
        getModelsByBrand: gh<_i408.GetModelsByBrandUseCase>(),
        submitOnboarding: gh<_i1016.SubmitOnboardingUseCase>(),
        getProviderFullName: gh<_i847.GetProviderFullName>(),
      ),
    );
    gh.factory<_i197.ForumsHomeBloc>(
      () => _i197.ForumsHomeBloc(
        getShortcuts: gh<_i846.GetForumShortcutsUseCase>(),
        getThreads: gh<_i669.GetForumThreadsUseCase>(),
        getSuggestions: gh<_i542.GetForumSuggestionsUseCase>(),
        createShortcut: gh<_i846.CreateForumShortcutUseCase>(),
        deleteShortcut: gh<_i846.DeleteForumShortcutUseCase>(),
        reorderShortcuts: gh<_i846.ReorderForumShortcutsUseCase>(),
        saveThread: gh<_i302.SaveForumThreadUseCase>(),
        unsaveThread: gh<_i302.UnsaveForumThreadUseCase>(),
      ),
    );
    gh.factory<_i465.MapBloc>(
      () => _i465.MapBloc(
        getNearbyBusinesses: gh<_i642.GetNearbyBusinessesUseCase>(),
        getBusinessDetail: gh<_i107.GetBusinessDetailUseCase>(),
        getCurrentPosition: gh<_i958.GetCurrentPositionUseCase>(),
        getNearbyEvents: gh<_i997.GetNearbyMapEventsUseCase>(),
      ),
    );
    gh.factory<_i681.ComposeBloc>(
      () => _i681.ComposeBloc(
        getSuggestions: gh<_i231.GetComposeSuggestionsUseCase>(),
      ),
    );
    gh.factory<_i382.ForumThreadBloc>(
      () => _i382.ForumThreadBloc(
        getThread: gh<_i276.GetForumThreadUseCase>(),
        getThreadReplies: gh<_i480.GetThreadRepliesUseCase>(),
        getReplyChildren: gh<_i480.GetReplyChildrenUseCase>(),
        createReply: gh<_i99.CreateForumReplyUseCase>(),
        likeThread: gh<_i390.LikeForumThreadUseCase>(),
        unlikeThread: gh<_i390.UnlikeForumThreadUseCase>(),
        likeReply: gh<_i390.LikeForumReplyUseCase>(),
        unlikeReply: gh<_i390.UnlikeForumReplyUseCase>(),
        editThread: gh<_i499.EditForumThreadUseCase>(),
        deleteThread: gh<_i499.DeleteForumThreadUseCase>(),
        editReply: gh<_i492.EditForumReplyUseCase>(),
        deleteReply: gh<_i492.DeleteForumReplyUseCase>(),
        saveThread: gh<_i302.SaveForumThreadUseCase>(),
        unsaveThread: gh<_i302.UnsaveForumThreadUseCase>(),
      ),
    );
    gh.factory<_i188.NewThreadBloc>(
      () => _i188.NewThreadBloc(
        getTopics: gh<_i354.GetForumTopicsUseCase>(),
        getBrands: gh<_i408.GetBrandsUseCase>(),
        getModelsByBrand: gh<_i408.GetModelsByBrandUseCase>(),
        createThread: gh<_i605.CreateForumThreadUseCase>(),
      ),
    );
    gh.factory<_i619.SavedThreadsBloc>(
      () => _i619.SavedThreadsBloc(
        getSavedThreads: gh<_i302.GetSavedForumThreadsUseCase>(),
        unsaveThread: gh<_i302.UnsaveForumThreadUseCase>(),
      ),
    );
    gh.factory<_i155.TagPickerBloc>(
      () => _i155.TagPickerBloc(
        searchUsers: gh<_i14.SearchUsersUseCase>(),
        getGarageByUsername: gh<_i543.GetGarageByUsernameUseCase>(),
        getMyGarage: gh<_i391.GetMyGarageUseCase>(),
      ),
    );
    gh.factory<_i462.SearchBloc>(
      () => _i462.SearchBloc(searchUsers: gh<_i14.SearchUsersUseCase>()),
    );
    gh.factory<_i245.InboxBloc>(
      () => _i245.InboxBloc(
        getInbox: gh<_i134.GetInboxUseCase>(),
        hideConversation: gh<_i680.HideConversationUseCase>(),
        watchPresence: gh<_i583.WatchPresenceUseCase>(),
        watchInboxMessages: gh<_i839.WatchInboxMessagesUseCase>(),
      ),
    );
    gh.factory<_i853.TagsBloc>(
      () => _i853.TagsBloc(
        getMyTags: gh<_i227.GetMyTagsUseCase>(),
        getTagsByUsername: gh<_i198.GetTagsByUsernameUseCase>(),
        removeTag: gh<_i369.RemoveTagUseCase>(),
      ),
    );
    gh.factory<_i396.CompletedFeedbackBloc>(
      () => _i396.CompletedFeedbackBloc(
        getCompleted: gh<_i160.GetCompletedFeedbackUseCase>(),
      ),
    );
    gh.factory<_i651.ComposeFeedbackBloc>(
      () => _i651.ComposeFeedbackBloc(
        getTypes: gh<_i560.GetFeedbackTypesUseCase>(),
        createMessage: gh<_i468.CreateFeedbackMessageUseCase>(),
      ),
    );
    gh.factory<_i198.ForumHubBloc>(
      () => _i198.ForumHubBloc(
        getThreads: gh<_i669.GetForumThreadsUseCase>(),
        getTopics: gh<_i354.GetForumTopicsUseCase>(),
        getModelsByBrand: gh<_i408.GetModelsByBrandUseCase>(),
        createShortcut: gh<_i846.CreateForumShortcutUseCase>(),
        saveThread: gh<_i302.SaveForumThreadUseCase>(),
        unsaveThread: gh<_i302.UnsaveForumThreadUseCase>(),
      ),
    );
    return this;
  }
}

class _$SupabaseModule extends _i388.SupabaseModule {}

class _$DioModule extends _i983.DioModule {}
