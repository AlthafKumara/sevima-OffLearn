import 'package:get/get.dart';
import 'package:mobile/features/modules/controllers/module_controller.dart';
import 'package:mobile/features/modules/controllers/module_detail_controller.dart';

class ModuleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleController>(() => ModuleController());
  }
}

class ModuleDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModuleDetailController>(() => ModuleDetailController());
  }
}
