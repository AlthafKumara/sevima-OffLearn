import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/remote/auth_repository.dart';
import 'package:mobile/features/home/views/ui/student_home_page.dart';
import 'package:mobile/features/home/views/ui/teacher_home_page.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/models/user_model.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  // ── State ──────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final kelasController = TextEditingController(); // only relevant for siswa

  /// Role options: API uses 'siswa' / 'guru'
  final RxString selectedRole = 'siswa'.obs;
  final List<String> roles = ['siswa', 'guru'];

  /// Whether the kelas field should be shown (only for siswa)
  bool get showKelas => selectedRole.value == 'siswa';

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    kelasController.dispose();
    super.onClose();
  }

  // ── Methods ──────────────────────────────────────────────

  /// Registers the user:
  /// 1. Supabase Auth signUp
  /// 2. POST /profiles (create profile with nama, role, kelas)
  /// 3. Route to appropriate home page
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final kelas = kelasController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Nama, email, dan password wajib diisi.';
      return;
    }

    if (selectedRole.value == 'siswa' && kelas.isEmpty) {
      errorMessage.value = 'Kelas wajib diisi untuk siswa.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final UserModel user = await _authRepo.signUp(
        email,
        password,
        name,
        selectedRole.value,
        kelas: selectedRole.value == 'siswa' ? kelas : null,
      );

      Get.snackbar(
        'Berhasil',
        'Akun berhasil dibuat! Selamat datang, ${user.name}.',
        snackPosition: SnackPosition.BOTTOM,
      );

      _navigateByRole(user);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateByRole(UserModel user) {
    Get.put<UserModel>(user, permanent: true);
    if (user.isGuru) {
      Get.offAll(() => const TeacherHomePage(), arguments: user);
    } else {
      Get.offAll(() => const StudentHomePage(), arguments: user);
    }
  }

  void goToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
