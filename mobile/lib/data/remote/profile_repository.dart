import 'package:mobile/data/remote/api_client.dart';
import 'package:mobile/shared/models/user_model.dart';

/// Repository for all Profile-related API calls (`/profiles`).
class ProfileRepository {
  final _api = ApiClient.instance;

  /// Fetches a profile by [userId] from GET /profiles/:id.
  /// Returns [UserModel] on success, or null if not found.
  Future<UserModel?> getProfile(String userId) async {
    try {
      final data = await _api.get('/profiles/$userId');
      final map = data as Map<String, dynamic>;
      return UserModel(
        id: map['id'] as String,
        email: '', // email comes from Supabase Auth, not profiles table
        name: map['nama'] as String?,
        role: map['role'] as String?,
        kelas: map['kelas'] as String?,
      );
    } catch (e) {
      // If 404 / not found, return null instead of throwing
      final msg = e.toString().toLowerCase();
      if (msg.contains('not found') || msg.contains('404')) return null;
      throw Exception('ProfileRepository.getProfile: $e');
    }
  }

  /// Creates a profile entry via POST /profiles.
  /// Called right after Supabase Auth sign-up.
  Future<void> createProfile({
    required String id,
    required String nama,
    required String role,
    String? kelas,
  }) async {
    try {
      final body = <String, dynamic>{'id': id, 'nama': nama, 'role': role};
      if (kelas != null && kelas.isNotEmpty) body['kelas'] = kelas;

      await _api.post('/profiles', body);
    } catch (e) {
      // Ignore 409 Conflict (profile already exists)
      final msg = e.toString().toLowerCase();
      if (msg.contains('conflict') ||
          msg.contains('409') ||
          msg.contains('already'))
        return;
      throw Exception('ProfileRepository.createProfile: $e');
    }
  }
}
