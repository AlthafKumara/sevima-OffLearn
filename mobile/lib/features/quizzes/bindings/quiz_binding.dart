import 'package:get/get.dart';
import 'package:mobile/features/quizzes/controllers/quiz_controller.dart';
import 'package:mobile/features/quizzes/controllers/quiz_detail_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizController>(() => QuizController());
  }
}

class QuizDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizDetailController>(() => QuizDetailController());
  }
}
