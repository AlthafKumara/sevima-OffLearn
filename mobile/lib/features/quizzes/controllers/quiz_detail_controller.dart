import 'package:get/get.dart';
import 'package:mobile/data/remote/quiz_repository.dart';
import 'package:mobile/data/remote/sync_repository.dart';
import 'package:mobile/shared/models/quiz_model.dart';
import 'package:mobile/shared/models/sync_model.dart';

/// Controller for the Quiz Detail / Play screen.
/// Handles fetching quiz, tracking answers, and submitting via sync.
class QuizDetailController extends GetxController {
  final QuizRepository _quizRepo = QuizRepository();
  final SyncRepository _syncRepo = SyncRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString submitResult = ''.obs;
  final Rx<QuizModel?> quiz = Rx<QuizModel?>(null);

  /// Maps questionId → selectedOptionId
  final RxMap<String, String> selectedAnswers = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final quizId = Get.arguments as String?;
    if (quizId != null) fetchQuiz(quizId);
  }

  Future<void> fetchQuiz(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _quizRepo.fetchById(id, view: 'siswa');
      quiz.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Records the selected option for a question.
  void selectAnswer(String questionId, String optionId) {
    selectedAnswers[questionId] = optionId;
  }

  /// Returns true if all questions have been answered.
  bool get isComplete =>
      quiz.value != null &&
      selectedAnswers.length == quiz.value!.questions.length;

  /// Submits answers via POST /sync/quiz-attempts.
  /// [userId] is the currently logged-in siswa UUID.
  Future<void> submitAttempt(String userId) async {
    if (quiz.value == null) return;

    isSubmitting.value = true;
    errorMessage.value = '';
    submitResult.value = '';
    try {
      final answers = selectedAnswers.entries
          .map(
            (e) => QuizAnswerItem(questionId: e.key, selectedOptionId: e.value),
          )
          .toList();

      final attempt = QuizAttemptItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        quizId: quiz.value!.id,
        clientTimestamp: DateTime.now().toUtc().toIso8601String(),
        jawaban: answers,
      );

      final results = await _syncRepo.syncQuizAttempts(
        userId: userId,
        items: [attempt],
      );

      if (results.isNotEmpty) {
        final skor = results.first['skor'];
        submitResult.value = 'Kuis selesai! Skor kamu: $skor';
      } else {
        submitResult.value = 'Kuis berhasil dikumpulkan.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }
}
