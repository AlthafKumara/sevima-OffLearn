import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/remote/auth_repository.dart';
import 'package:mobile/features/home/views/ui/student_home_page.dart';
import 'package:mobile/features/home/views/ui/teacher_home_page.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/models/user_model.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  // ── State ──────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Methods ──────────────────────────────────────────────

  /// Signs in the user, fetches their profile (name, role, kelas),
  /// then routes to the appropriate home page based on role.
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan password tidak boleh kosong.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Supabase Auth → get id
      // 2. GET /profiles/:id → complete name, role, kelas
      final UserModel user = await _authRepo.signIn(email, password);

      Get.snackbar(
        'Berhasil',
        'Selamat datang, ${user.name ?? user.email}!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 3. Route based on role
      _navigateByRole(user);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Routes authenticated user to the correct home page.
  void _navigateByRole(UserModel user) {
    Get.put<UserModel>(user, permanent: true);

    if (user.isGuru) {
      Get.offAll(() => const TeacherHomePage(), arguments: user);
    } else {
      // Default to siswa home for 'siswa' or any unknown role
      Get.offAll(() => const StudentHomePage(), arguments: user);
    }
  }

  void goToRegister() {
    Get.offAllNamed(Routes.REGISTER);
  }
}
