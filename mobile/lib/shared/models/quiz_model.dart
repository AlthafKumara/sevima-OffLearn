class QuizOptionModel {
  final String id;
  final String teksOpsi;
  final bool? isBenar;

  const QuizOptionModel({
    required this.id,
    required this.teksOpsi,
    this.isBenar,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) =>
      QuizOptionModel(
        id: json['id'] as String,
        teksOpsi: json['teks_opsi'] as String? ?? '',
        isBenar: json['is_benar'] as bool?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'teks_opsi': teksOpsi,
    'is_benar': isBenar,
  };
}

class QuizQuestionModel {
  final String id;
  final String pertanyaan;
  final String? tipeSoal;
  final int? urutan;
  final List<QuizOptionModel> opsi;

  const QuizQuestionModel({
    required this.id,
    required this.pertanyaan,
    this.tipeSoal,
    this.urutan,
    this.opsi = const [],
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      QuizQuestionModel(
        id: json['id'] as String,
        pertanyaan: json['pertanyaan'] as String? ?? '',
        tipeSoal: json['tipe_soal'] as String?,
        urutan: json['urutan'] as int?,
        opsi: (json['opsi'] as List<dynamic>? ?? [])
            .map((e) => QuizOptionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'pertanyaan': pertanyaan,
    'tipe_soal': tipeSoal,
    'urutan': urutan,
    'opsi': opsi.map((e) => e.toJson()).toList(),
  };
}

class QuizModel {
  final String id;
  final String? subjectId;
  final String? createdBy;
  final String namaQuiz;
  final String? targetKelas;
  final String? status;
  final String? createdAt;
  final List<QuizQuestionModel> questions;

  const QuizModel({
    required this.id,
    this.subjectId,
    this.createdBy,
    required this.namaQuiz,
    this.targetKelas,
    this.status,
    this.createdAt,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    id: json['id'] as String,
    subjectId: json['subject_id'] as String?,
    createdBy: json['created_by'] as String?,
    namaQuiz: json['nama_quiz'] as String? ?? '',
    targetKelas: json['target_kelas'] as String?,
    status: json['status'] as String?,
    createdAt: json['created_at'] as String?,
    questions: (json['questions'] as List<dynamic>? ?? [])
        .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_id': subjectId,
    'created_by': createdBy,
    'nama_quiz': namaQuiz,
    'target_kelas': targetKelas,
    'status': status,
    'created_at': createdAt,
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}
