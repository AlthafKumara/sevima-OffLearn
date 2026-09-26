import 'package:mobile/data/remote/api_client.dart';
import 'package:mobile/shared/models/sync_model.dart';

/// Repository for offline-first Sync API calls (`/sync/*`).
class SyncRepository {
  final _api = ApiClient.instance;

  /// Downloads all published content from GET /sync/download.
  /// Returns a [SyncContentModel] containing raw modules and quizzes lists.
  ///
  /// [targetKelas] — optional class filter (e.g. "Kelas 5").
  /// [updatedSince] — ISO 8601 string for incremental sync.
  Future<SyncContentModel> downloadContent({
    String? targetKelas,
    String? updatedSince,
  }) async {
    try {
      final params = <String, String>{};
      if (targetKelas != null) params['target_kelas'] = targetKelas;
      if (updatedSince != null) params['updated_since'] = updatedSince;

      final data = await _api.get(
        '/sync/download',
        queryParams: params.isNotEmpty ? params : null,
      );
      return SyncContentModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('SyncRepository.downloadContent: $e');
    }
  }

  /// Syncs student module progress to backend via POST /sync/student-progress.
  /// [userId] — siswa UUID; [items] — list of progress records.
  Future<void> syncStudentProgress({
    required String userId,
    required List<StudentProgressItem> items,
  }) async {
    try {
      await _api.post('/sync/student-progress', {
        'user_id': userId,
        'items': items.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('SyncRepository.syncStudentProgress: $e');
    }
  }

  /// Submits quiz attempts to backend via POST /sync/quiz-attempts.
  /// Score is calculated strictly on the backend.
  /// [userId] — siswa UUID; [items] — list of attempts with answers.
  Future<List<Map<String, dynamic>>> syncQuizAttempts({
    required String userId,
    required List<QuizAttemptItem> items,
  }) async {
    try {
      final data = await _api.post('/sync/quiz-attempts', {
        'user_id': userId,
        'items': items.map((e) => e.toJson()).toList(),
      });
      return (data as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('SyncRepository.syncQuizAttempts: $e');
    }
  }
}
