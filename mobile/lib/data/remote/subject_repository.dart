import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:mobile/data/remote/api_client.dart';
import 'package:mobile/data/remote/network_info.dart';
import 'package:mobile/shared/models/subject_model.dart';

/// Repository for all Subject-related API calls (`/subjects`).
class SubjectRepository {
  final _api = ApiClient.instance;
  final _network = NetworkInfo.instance;

  /// Returns list of [SubjectModel] from GET /subjects or Hive if offline.
  Future<List<SubjectModel>> fetchAll() async {
    try {
      final box = Hive.box<String>('subjects');

      if (await _network.isConnected) {
        final data = await _api.get('/subjects');
        final items = (data as List<dynamic>)
            .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Save to Hive
        await box.clear();
        final mapToSave = {for (var e in items) e.id: jsonEncode(e.toJson())};
        await box.putAll(mapToSave);

        return items;
      } else {
        // Offline: Read from Hive
        final items = box.values
            .map(
              (e) =>
                  SubjectModel.fromJson(jsonDecode(e) as Map<String, dynamic>),
            )
            .toList();
        return items;
      }
    } catch (e) {
      throw Exception('SubjectRepository.fetchAll: $e');
    }
  }

  /// Creates a subject. Only accessible by `guru`.
  /// [namaSubject] — display name; [createdBy] — guru UUID.
  Future<SubjectModel> create({
    required String namaSubject,
    required String createdBy,
  }) async {
    try {
      final data = await _api.post('/subjects', {
        'nama_subject': namaSubject,
        'created_by': createdBy,
      });
      return SubjectModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('SubjectRepository.create: $e');
    }
  }
}
