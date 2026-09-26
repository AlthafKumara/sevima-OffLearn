import 'package:get/get.dart';
import 'package:mobile/data/remote/quiz_repository.dart';
import 'package:mobile/shared/models/quiz_model.dart';

class QuizController extends GetxController {
  final QuizRepository _repository = QuizRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<QuizModel> quizzes = <QuizModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes({
    String? targetKelas,
    String? subjectId,
    String? status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.fetchAll(
        targetKelas: targetKelas,
        subjectId: subjectId,
        status: status,
      );
      quizzes.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createQuiz({
    required String subjectId,
    required String namaQuiz,
    required String targetKelas,
    required String guruId,
  }) async {
    isLoading.value = true;
    try {
      final newQuiz = await _repository.create(
        subjectId: subjectId,
        createdBy: guruId,
        namaQuiz: namaQuiz,
        targetKelas: targetKelas,
      );
      quizzes.add(newQuiz);
      Get.snackbar('Berhasil', 'Kuis berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
