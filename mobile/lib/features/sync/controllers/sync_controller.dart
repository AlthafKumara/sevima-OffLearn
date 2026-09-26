import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/remote/sync_repository.dart';
import 'package:mobile/shared/models/module_model.dart';
import 'package:mobile/shared/models/quiz_model.dart';

/// Controller for the offline-first Sync screen.
/// Handles downloading all content from GET /sync/download.
class SyncController extends GetxController {
  final SyncRepository _repository = SyncRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Cached downloaded data
  final RxList<ModuleModel> downloadedModules = <ModuleModel>[].obs;
  final RxList<QuizModel> downloadedQuizzes = <QuizModel>[].obs;

  final TextEditingController kelasFilterCtrl = TextEditingController();

  @override
  void onClose() {
    kelasFilterCtrl.dispose();
    super.onClose();
  }

  /// Downloads all content from the server.
  Future<void> downloadContent() async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final kelas = kelasFilterCtrl.text.trim();
      final result = await _repository.downloadContent(
        targetKelas: kelas.isNotEmpty ? kelas : null,
      );

      // Parse modules and quizzes from raw maps
      downloadedModules.assignAll(
        result.modules.map((e) => ModuleModel.fromJson(e)).toList(),
      );
      downloadedQuizzes.assignAll(
        result.quizzes.map((e) => QuizModel.fromJson(e)).toList(),
      );

      successMessage.value =
          'Berhasil mengunduh ${downloadedModules.length} modul '
          'dan ${downloadedQuizzes.length} kuis.';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
