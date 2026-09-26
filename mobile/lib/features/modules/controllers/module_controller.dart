import 'package:get/get.dart';
import 'package:mobile/data/remote/module_repository.dart';
import 'package:mobile/shared/models/module_model.dart';

class ModuleController extends GetxController {
  final ModuleRepository _repository = ModuleRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ModuleModel> modules = <ModuleModel>[].obs;

  // Optional filters
  String? filterTargetKelas;
  String? filterSubjectId;
  String? filterStatus;

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  /// Fetches all modules, optionally filtered by kelas / subject / status.
  Future<void> fetchModules({
    String? targetKelas,
    String? subjectId,
    String? status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.fetchAll(
        targetKelas: targetKelas ?? filterTargetKelas,
        subjectId: subjectId ?? filterSubjectId,
        status: status ?? filterStatus,
      );
      modules.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears filters and re-fetches all modules.
  void clearFilters() {
    filterTargetKelas = null;
    filterSubjectId = null;
    filterStatus = null;
    fetchModules();
  }

  Future<void> createModule({
    required String subjectId,
    required String judul,
    required String konten,
    required String targetKelas,
    required String guruId,
  }) async {
    isLoading.value = true;
    try {
      final newModule = await _repository.create(
        subjectId: subjectId,
        createdBy: guruId,
        judul: judul,
        konten: konten,
        targetKelas: targetKelas,
      );
      modules.add(newModule);
      Get.snackbar('Berhasil', 'Modul berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteModule(String id, String guruId) async {
    isLoading.value = true;
    try {
      await _repository.delete(id, requestedBy: guruId);
      modules.removeWhere((e) => e.id == id);
      Get.snackbar('Berhasil', 'Modul berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
