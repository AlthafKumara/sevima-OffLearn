import 'dart:developer';

import 'package:get/get.dart';
import 'package:mobile/data/remote/auth_repository.dart';
import 'package:mobile/features/home/views/ui/student_home_page.dart';
import 'package:mobile/features/home/views/ui/teacher_home_page.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/models/user_model.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Small delay to show splash branding
      await Future.delayed(const Duration(milliseconds: 800));

      // getCurrentUser fetches Supabase session + GET /profiles/:id
      final user = await _authRepo.getCurrentUser();

      log(user?.id ?? 'null');

      if (user != null) {
        Get.put<UserModel>(user, permanent: true);
        // Already logged in — route by role
        if (user.isGuru) {
          Get.offAll(() => const TeacherHomePage(), arguments: user);
        } else {
          Get.offAll(() => const StudentHomePage(), arguments: user);
        }
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      // On error, fall back to login
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }
}
