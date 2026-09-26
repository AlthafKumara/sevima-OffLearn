import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:mobile/data/remote/api_client.dart';
import 'package:mobile/data/remote/network_info.dart';
import 'package:mobile/shared/models/quiz_model.dart';

/// Repository for all Quiz-related API calls (`/quizzes`, `/quiz-questions`, `/quiz-options`).
class QuizRepository {
  final _api = ApiClient.instance;
  final _network = NetworkInfo.instance;

  /// Returns list of [QuizModel] from GET /quizzes.
  /// Optionally filter by [targetKelas], [subjectId], [status].
  Future<List<QuizModel>> fetchAll({
    String? targetKelas,
    String? subjectId,
    String? status,
  }) async {
    try {
      final box = Hive.box<String>('quizzes');

      if (await _network.isConnected) {
        final params = <String, String>{};
        if (targetKelas != null) params['target_kelas'] = targetKelas;
        if (subjectId != null) params['subject_id'] = subjectId;
        if (status != null) params['status'] = status;

        final data = await _api.get(
          '/quizzes',
          queryParams: params.isNotEmpty ? params : null,
        );
        final items = (data as List<dynamic>)
            .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // If no filters are applied, cache the full list
        if (params.isEmpty) {
          await box.clear();
          final mapToSave = {for (var e in items) e.id: jsonEncode(e.toJson())};
          await box.putAll(mapToSave);
        }
        return items;
      } else {
        // Offline: Read from Hive and manually filter
        var items = box.values
            .map(
              (e) => QuizModel.fromJson(jsonDecode(e) as Map<String, dynamic>),
            )
            .toList();

        if (targetKelas != null)
          items = items.where((e) => e.targetKelas == targetKelas).toList();
        if (subjectId != null)
          items = items.where((e) => e.subjectId == subjectId).toList();
        if (status != null)
          items = items.where((e) => e.status == status).toList();

        return items;
      }
    } catch (e) {
      throw Exception('QuizRepository.fetchAll: $e');
    }
  }

  /// Returns a detailed [QuizModel] from GET /quizzes/:id.
  /// [view] is either `"siswa"` (hides answers) or `"guru"` (shows answers).
  Future<QuizModel> fetchById(String id, {String view = 'siswa'}) async {
    try {
      final box = Hive.box<String>('quizzes');

      if (await _network.isConnected) {
        final data = await _api.get(
          '/quizzes/$id',
          queryParams: {'view': view},
        );
        final item = QuizModel.fromJson(data as Map<String, dynamic>);

        // Update item in cache
        await box.put(id, jsonEncode(item.toJson()));

        return item;
      } else {
        final localData = box.get(id);
        if (localData != null) {
          return QuizModel.fromJson(
            jsonDecode(localData) as Map<String, dynamic>,
          );
        }
        throw Exception('Not found offline');
      }
    } catch (e) {
      throw Exception('QuizRepository.fetchById: $e');
    }
  }

  /// Creates a quiz. Only accessible by `guru`.
  Future<QuizModel> create({
    required String subjectId,
    required String createdBy,
    required String namaQuiz,
    required String targetKelas,
    String status = 'draft',
  }) async {
    try {
      final data = await _api.post('/quizzes', {
        'subject_id': subjectId,
        'created_by': createdBy,
        'nama_quiz': namaQuiz,
        'target_kelas': targetKelas,
        'status': status,
      });
      return QuizModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('QuizRepository.create: $e');
    }
  }

  /// Adds a question to a quiz. Only accessible by `guru`.
  Future<QuizQuestionModel> createQuestion({
    required String quizId,
    required String createdBy,
    required String pertanyaan,
    required List<Map<String, dynamic>> opsi,
    String tipeSoal = 'pilihan_ganda',
    int urutan = 1,
  }) async {
    try {
      final data = await _api.post('/quizzes/$quizId/questions', {
        'created_by': createdBy,
        'pertanyaan': pertanyaan,
        'tipe_soal': tipeSoal,
        'urutan': urutan,
        'opsi': opsi,
      });
      return QuizQuestionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('QuizRepository.createQuestion: $e');
    }
  }
}
