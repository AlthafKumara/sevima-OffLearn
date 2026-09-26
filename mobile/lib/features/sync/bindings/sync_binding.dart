import 'package:get/get.dart';
import 'package:mobile/features/sync/controllers/sync_controller.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SyncController>(() => SyncController());
  }
}
