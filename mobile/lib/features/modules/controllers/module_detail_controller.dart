import 'package:get/get.dart';
import 'package:mobile/data/remote/module_repository.dart';
import 'package:mobile/shared/models/module_model.dart';

/// Controller for the Module Detail screen.
/// Receives [moduleId] from GetX arguments.
class ModuleDetailController extends GetxController {
  final ModuleRepository _repository = ModuleRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ModuleModel?> module = Rx<ModuleModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as String?;
    if (id != null) fetchModule(id);
  }

  Future<void> fetchModule(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.fetchById(id);
      module.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
