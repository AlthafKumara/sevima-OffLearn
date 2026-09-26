import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:mobile/data/remote/api_client.dart';
import 'package:mobile/data/remote/network_info.dart';
import 'package:mobile/shared/models/module_model.dart';

/// Repository for all Module-related API calls (`/modules`).
class ModuleRepository {
  final _api = ApiClient.instance;
  final _network = NetworkInfo.instance;

  /// Returns list of [ModuleModel] from GET /modules.
  /// Optionally filter by [createdBy], [targetKelas], [subjectId], [status].
  Future<List<ModuleModel>> fetchAll({
    String? createdBy,
    String? targetKelas,
    String? subjectId,
    String? status,
  }) async {
    try {
      final box = Hive.box<String>('modules');

      if (await _network.isConnected) {
        final params = <String, String>{};
        if (createdBy != null) params['created_by'] = createdBy;
        if (targetKelas != null) params['target_kelas'] = targetKelas;
        if (subjectId != null) params['subject_id'] = subjectId;
        if (status != null) params['status'] = status;

        final data = await _api.get(
          '/modules',
          queryParams: params.isNotEmpty ? params : null,
        );
        final items = (data as List<dynamic>)
            .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
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
              (e) =>
                  ModuleModel.fromJson(jsonDecode(e) as Map<String, dynamic>),
            )
            .toList();

        if (createdBy != null)
          items = items.where((e) => e.createdBy == createdBy).toList();
        if (targetKelas != null)
          items = items.where((e) => e.targetKelas == targetKelas).toList();
        if (subjectId != null)
          items = items.where((e) => e.subjectId == subjectId).toList();
        if (status != null)
          items = items.where((e) => e.status == status).toList();

        return items;
      }
    } catch (e) {
      throw Exception('ModuleRepository.fetchAll: $e');
    }
  }

  /// Returns a single [ModuleModel] from GET /modules/:id.
  Future<ModuleModel> fetchById(String id) async {
    try {
      final box = Hive.box<String>('modules');

      if (await _network.isConnected) {
        final data = await _api.get('/modules/$id');
        final item = ModuleModel.fromJson(data as Map<String, dynamic>);

        // Update item in cache
        await box.put(id, jsonEncode(item.toJson()));

        return item;
      } else {
        final localData = box.get(id);
        if (localData != null) {
          return ModuleModel.fromJson(
            jsonDecode(localData) as Map<String, dynamic>,
          );
        }
        throw Exception('Not found offline');
      }
    } catch (e) {
      throw Exception('ModuleRepository.fetchById: $e');
    }
  }

  /// Creates a module. Only accessible by `guru`.
  Future<ModuleModel> create({
    required String subjectId,
    required String createdBy,
    required String judul,
    required String konten,
    required String targetKelas,
    String status = 'draft',
    int urutan = 1,
  }) async {
    try {
      final data = await _api.post('/modules', {
        'subject_id': subjectId,
        'created_by': createdBy,
        'judul': judul,
        'konten': konten,
        'target_kelas': targetKelas,
        'status': status,
        'urutan': urutan,
      });
      return ModuleModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('ModuleRepository.create: $e');
    }
  }

  /// Updates a module. Requires [requestedBy] for ownership validation.
  Future<ModuleModel> update(
    String id, {
    required String requestedBy,
    String? konten,
    String? status,
    String? judul,
  }) async {
    try {
      final body = <String, dynamic>{'requested_by': requestedBy};
      if (konten != null) body['konten'] = konten;
      if (status != null) body['status'] = status;
      if (judul != null) body['judul'] = judul;

      final data = await _api.put('/modules/$id', body);
      return ModuleModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('ModuleRepository.update: $e');
    }
  }

  /// Deletes a module. Requires [requestedBy] for ownership validation.
  Future<void> delete(String id, {required String requestedBy}) async {
    try {
      await _api.delete('/modules/$id', body: {'requested_by': requestedBy});
    } catch (e) {
      throw Exception('ModuleRepository.delete: $e');
    }
  }
}
