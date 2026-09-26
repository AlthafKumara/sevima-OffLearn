class ModuleModel {
  final String id;
  final String? subjectId;
  final String? createdBy;
  final String judul;
  final String? konten;
  final String? targetKelas;
  final String? status;
  final int? urutan;
  final String? createdAt;
  final String? updatedAt;

  const ModuleModel({
    required this.id,
    this.subjectId,
    this.createdBy,
    required this.judul,
    this.konten,
    this.targetKelas,
    this.status,
    this.urutan,
    this.createdAt,
    this.updatedAt,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) => ModuleModel(
    id: json['id'] as String,
    subjectId: json['subject_id'] as String?,
    createdBy: json['created_by'] as String?,
    judul: json['judul'] as String? ?? '',
    konten: json['konten'] as String?,
    targetKelas: json['target_kelas'] as String?,
    status: json['status'] as String?,
    urutan: json['urutan'] as int?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_id': subjectId,
    'created_by': createdBy,
    'judul': judul,
    'konten': konten,
    'target_kelas': targetKelas,
    'status': status,
    'urutan': urutan,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
