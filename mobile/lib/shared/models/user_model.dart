class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? kelas; // Only relevant for siswa

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.kelas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String?,
      kelas: json['kelas'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'kelas': kelas,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? kelas,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      kelas: kelas ?? this.kelas,
    );
  }

  /// True when this user is a teacher (guru).
  bool get isGuru => role == 'guru';

  /// True when this user is a student (siswa).
  bool get isSiswa => role == 'siswa';
}
