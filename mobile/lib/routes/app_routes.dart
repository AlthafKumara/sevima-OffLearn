// ignore_for_file: camel_case_types, constant_identifier_names

abstract class Routes {
  Routes._();

  static const SPLASH = _paths.SPLASH;
  static const LOGIN = _paths.LOGIN;
  static const REGISTER = _paths.REGISTER;

  // ── Home ───────────────────────────────────────────────────────────────────
  static const STUDENT_HOME = _paths.STUDENT_HOME;
  static const TEACHER_HOME = _paths.TEACHER_HOME;

  // ── Subjects ───────────────────────────────────────────────────────────────
  static const SUBJECTS = _paths.SUBJECTS;

  // ── Modules ────────────────────────────────────────────────────────────────
  static const MODULES = _paths.MODULES;
  static const MODULE_DETAIL = _paths.MODULE_DETAIL;

  // ── Quizzes ────────────────────────────────────────────────────────────────
  static const QUIZZES = _paths.QUIZZES;
  static const QUIZ_DETAIL = _paths.QUIZ_DETAIL;

  // ── Sync ───────────────────────────────────────────────────────────────────
  static const SYNC = _paths.SYNC;
}

abstract class _paths {
  _paths._();

  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';

  static const STUDENT_HOME = '/home/student';
  static const TEACHER_HOME = '/home/teacher';

  static const SUBJECTS = '/subjects';

  static const MODULES = '/modules';
  static const MODULE_DETAIL = '/modules/detail';

  static const QUIZZES = '/quizzes';
  static const QUIZ_DETAIL = '/quizzes/detail';

  static const SYNC = '/sync';
}
