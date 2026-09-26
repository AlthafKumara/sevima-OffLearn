/// Represents a downloaded content bundle from GET /sync/download
class SyncContentModel {
  final List<Map<String, dynamic>> modules;
  final List<Map<String, dynamic>> quizzes;

  const SyncContentModel({required this.modules, required this.quizzes});

  factory SyncContentModel.fromJson(Map<String, dynamic> json) =>
      SyncContentModel(
        modules: (json['modules'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        quizzes: (json['quizzes'] as List<dynamic>? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
}

/// Item for syncing student progress (POST /sync/student-progress)
class StudentProgressItem {
  final String id;
  final String moduleId;
  final String status;
  final String clientTimestamp;

  const StudentProgressItem({
    required this.id,
    required this.moduleId,
    required this.status,
    required this.clientTimestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'module_id': moduleId,
    'status': status,
    'client_timestamp': clientTimestamp,
  };
}

/// Answer item for quiz attempt sync (POST /sync/quiz-attempts)
class QuizAnswerItem {
  final String questionId;
  final String selectedOptionId;

  const QuizAnswerItem({
    required this.questionId,
    required this.selectedOptionId,
  });

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'selected_option_id': selectedOptionId,
  };
}

/// Quiz attempt item for sync
class QuizAttemptItem {
  final String id;
  final String quizId;
  final String clientTimestamp;
  final List<QuizAnswerItem> jawaban;

  const QuizAttemptItem({
    required this.id,
    required this.quizId,
    required this.clientTimestamp,
    required this.jawaban,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'quiz_id': quizId,
    'client_timestamp': clientTimestamp,
    'jawaban': jawaban.map((e) => e.toJson()).toList(),
  };
}
