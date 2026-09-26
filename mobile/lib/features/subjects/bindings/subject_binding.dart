import 'package:get/get.dart';
import 'package:mobile/features/subjects/controllers/subject_controller.dart';

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectController>(() => SubjectController());
  }
}
