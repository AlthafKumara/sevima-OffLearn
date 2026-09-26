// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

// Auth
import 'package:mobile/features/auth/login/bindings/login_binding.dart';
import 'package:mobile/features/auth/login/views/ui/login_page.dart';
import 'package:mobile/features/auth/register/bindings/register_binding.dart';
import 'package:mobile/features/auth/register/views/ui/register_page.dart';
import 'package:mobile/features/auth/splash/bindings/splash_binding.dart';
import 'package:mobile/features/auth/splash/views/ui/splash_page.dart';

// Home
import 'package:mobile/features/home/views/ui/student_home_page.dart';
import 'package:mobile/features/home/views/ui/teacher_home_page.dart';

// Subjects
import 'package:mobile/features/subjects/bindings/subject_binding.dart';
import 'package:mobile/features/subjects/views/ui/subject_page.dart';

// Modules
import 'package:mobile/features/modules/bindings/module_binding.dart';
import 'package:mobile/features/modules/views/ui/module_page.dart';
import 'package:mobile/features/modules/views/ui/module_detail_page.dart';

// Quizzes
import 'package:mobile/features/quizzes/bindings/quiz_binding.dart';
import 'package:mobile/features/quizzes/views/ui/quiz_page.dart';
import 'package:mobile/features/quizzes/views/ui/quiz_detail_page.dart';

// Sync
import 'package:mobile/features/sync/bindings/sync_binding.dart';
import 'package:mobile/features/sync/views/ui/sync_page.dart';

import 'package:mobile/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // ── Auth ───────────────────────────────────────────────────────────────
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),

    // ── Home ───────────────────────────────────────────────────────────────
    GetPage(name: Routes.STUDENT_HOME, page: () => const StudentHomePage()),
    GetPage(name: Routes.TEACHER_HOME, page: () => const TeacherHomePage()),

    // ── Subjects ───────────────────────────────────────────────────────────
    GetPage(
      name: Routes.SUBJECTS,
      page: () => const SubjectPage(),
      binding: SubjectBinding(),
    ),

    // ── Modules ────────────────────────────────────────────────────────────
    GetPage(
      name: Routes.MODULES,
      page: () => const ModulePage(),
      binding: ModuleBinding(),
    ),
    GetPage(
      name: Routes.MODULE_DETAIL,
      page: () => const ModuleDetailPage(),
      binding: ModuleDetailBinding(),
    ),

    // ── Quizzes ────────────────────────────────────────────────────────────
    GetPage(
      name: Routes.QUIZZES,
      page: () => const QuizPage(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: Routes.QUIZ_DETAIL,
      page: () => const QuizDetailPage(),
      binding: QuizDetailBinding(),
    ),

    // ── Sync ───────────────────────────────────────────────────────────────
    GetPage(
      name: Routes.SYNC,
      page: () => const SyncPage(),
      binding: SyncBinding(),
    ),
  ];
}
