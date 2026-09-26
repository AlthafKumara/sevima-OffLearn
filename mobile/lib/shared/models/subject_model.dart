class SubjectModel {
  final String id;
  final String namaSubject;
  final String? createdBy;
  final String? createdAt;

  const SubjectModel({
    required this.id,
    required this.namaSubject,
    this.createdBy,
    this.createdAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'] as String,
    namaSubject: json['nama_subject'] as String,
    createdBy: json['created_by'] as String?,
    createdAt: json['created_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_subject': namaSubject,
    'created_by': createdBy,
    'created_at': createdAt,
  };
}
