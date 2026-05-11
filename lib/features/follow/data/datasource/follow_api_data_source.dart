import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/follow_request_model.dart';
import '../models/follow_status_model.dart';
import '../models/follow_user_model.dart';

@lazySingleton
class FollowApiDataSource {
  final AbstractHTTP http;

  FollowApiDataSource(this.http);

  Future<FollowStatusModel> follow(String username) async {
    final data = await http.post('/follow/$username');
    return FollowStatusModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> unfollow(String username) async {
    await http.delete('/follow/$username');
  }

  Future<FollowStatusModel> getFollowStatus(String username) async {
    final data = await http.get('/follow/$username/status');
    return FollowStatusModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<FollowRequestModel>> getPendingRequests() async {
    final data = await http.get('/follow/requests');
    return (data as List<dynamic>)
        .map((e) => FollowRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptRequest(String username) async {
    await http.post('/follow/requests/$username/accept');
  }

  Future<void> rejectRequest(String username) async {
    await http.delete('/follow/requests/$username');
  }

  Future<List<FollowUserModel>> getFollowers(String username) async {
    final data = await http.get('/follow/$username/followers');
    return (data as List<dynamic>)
        .map((e) => FollowUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FollowUserModel>> getFollowing(String username) async {
    final data = await http.get('/follow/$username/following');
    return (data as List<dynamic>)
        .map((e) => FollowUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
