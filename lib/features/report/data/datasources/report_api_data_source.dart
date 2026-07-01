import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/my_report_model.dart';
import '../models/report_reason_model.dart';

/// Talks to the report endpoints under the shared API base (`$API_BASE_URL/api/v1`).
/// The `report-reasons` GETs are the only ones with a body; the POSTs return
/// 204 No Content.
@lazySingleton
class ReportApiDataSource {
  final AbstractHTTP http;

  ReportApiDataSource(this.http);

  // ── Preset reasons ───────────────────────────────────────────────────────────

  Future<List<ReportReasonModel>> getPostReasons() =>
      _getReasons('/posts/report-reasons');

  Future<List<ReportReasonModel>> getCommentReasons() =>
      _getReasons('/posts/comments/report-reasons');

  Future<List<ReportReasonModel>> getProfileReasons() =>
      _getReasons('/profile/report-reasons');

  Future<List<ReportReasonModel>> _getReasons(String path) async {
    final data = await http.get(path);
    return (data as List<dynamic>)
        .map((e) => ReportReasonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Submit report ────────────────────────────────────────────────────────────

  Future<void> reportPost(String postId, String reasonId) async {
    await http.post('/posts/$postId/report', body: {'reason_id': reasonId});
  }

  Future<void> reportComment(
    String postId,
    String commentId,
    String reasonId,
  ) async {
    await http.post(
      '/posts/$postId/comments/$commentId/report',
      body: {'reason_id': reasonId},
    );
  }

  Future<void> reportProfile(String username, String reasonId) async {
    await http.post(
      '/profile/$username/report',
      body: {'reason_id': reasonId},
    );
  }

  // ── My reports ───────────────────────────────────────────────────────────────

  /// The reports the current user has filed (reporter taken from the JWT).
  Future<List<MyReportModel>> getMyReports() async {
    final data = await http.get('/reports/mine');
    return (data as List<dynamic>)
        .map((e) => MyReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
