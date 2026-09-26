import 'package:get/get.dart';
import 'package:mobile/data/remote/subject_repository.dart';
import 'package:mobile/shared/models/subject_model.dart';

class SubjectController extends GetxController {
  final SubjectRepository _repository = SubjectRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.fetchAll();
      subjects.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSubject(String name, String guruId) async {
    isLoading.value = true;
    try {
      final newSubject = await _repository.create(
        namaSubject: name,
        createdBy: guruId,
      );
      subjects.add(newSubject);
      Get.snackbar('Berhasil', 'Mata pelajaran berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
