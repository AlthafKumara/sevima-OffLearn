import 'dart:developer';

import 'package:mobile/data/remote/profile_repository.dart';
import 'package:mobile/shared/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = Supabase.instance.client;
  final _profileRepo = ProfileRepository();

  /// Returns the current [UserModel] (with profile data) if logged in, or null.
  Future<UserModel?> getCurrentUser() async {
    try {
      log('CHECK USER LOGIN DIJALANKAN');
      final session = _client.auth.currentSession;
      if (session == null) {
        log('SESSION KOSONG');
        return null;
      }

      log('SESSION ADA — fetching profile for ${session.user.id}');

      // Build base user from session
      final base = UserModel(
        id: session.user.id,
        email: session.user.email ?? '',
        name: session.user.userMetadata?['name'] as String?,
        role: session.user.userMetadata?['role'] as String?,
      );

      // Enrich with profile data (name, role, kelas from profiles table)
      final profile = await _profileRepo.getProfile(session.user.id);
      if (profile != null) {
        return base.copyWith(
          name: profile.name ?? base.name,
          role: profile.role ?? base.role,
          kelas: profile.kelas,
        );
      }

      return base;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Signs in the user, then fetches their profile to get name/role/kelas.
  /// Returns a complete [UserModel] on success, throws on failure.
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal, tidak ada data pengguna.');
      }

      final authUser = response.user!;
      log('SIGN IN SUCCESS — fetching profile for ${authUser.id}');

      // Fetch profile to complete name, role, kelas
      final profile = await _profileRepo.getProfile(authUser.id);

      return UserModel(
        id: authUser.id,
        email: authUser.email ?? email,
        name: profile?.name ?? authUser.userMetadata?['name'] as String?,
        role: profile?.role ?? authUser.userMetadata?['role'] as String?,
        kelas: profile?.kelas,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Registers user via Supabase Auth, then creates profile via POST /profiles.
  /// [role] must be either `"siswa"` or `"guru"`.
  /// [kelas] is optional (only for siswa).
  Future<UserModel> signUp(
    String email,
    String password,
    String name,
    String role, {
    String? kelas,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      if (response.user == null) {
        throw Exception('Registrasi gagal, tidak ada data pengguna.');
      }

      final authUser = response.user!;
      log('SIGN UP SUCCESS — creating profile for ${authUser.id}');

      // Create profile entry in backend profiles table
      await _profileRepo.createProfile(
        id: authUser.id,
        nama: name,
        role: role,
        kelas: kelas,
      );

      return UserModel(
        id: authUser.id,
        email: authUser.email ?? email,
        name: name,
        role: role,
        kelas: kelas,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
