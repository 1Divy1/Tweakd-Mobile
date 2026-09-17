import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/blocked_account_model.dart';

/// `GET /blocks`, `POST /blocks/{username}`, `DELETE /blocks/{username}`.
@lazySingleton
class BlockApiDataSource {
  final AbstractHTTP http;

  BlockApiDataSource(this.http);

  Future<List<BlockedAccountModel>> getBlockedAccounts() async {
    final data = await http.get('/blocks');
    return (data as List<dynamic>)
        .map((e) => BlockedAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> block(String username) async {
    await http.post('/blocks/$username');
  }

  Future<void> unblock(String username) async {
    await http.delete('/blocks/$username');
  }
}
