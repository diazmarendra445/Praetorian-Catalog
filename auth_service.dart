import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── DAFTAR / SIGN UP ────────────────────────────────────────
  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    // 1. Daftarkan akun ke Supabase Auth / Register account to Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Gagal membuat akun. Coba lagi.');
    }

    final uid = authResponse.user!.id;

    // 2. Simpan data profil ke tabel profiles / Save profile data to profiles table
    final profileData = {
      'id': uid,
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'email': email,
    };

    await _client.from('profiles').insert(profileData);

    return UserModel(
      id: uid,
      fullName: fullName,
      username: username,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  // ─── MASUK / SIGN IN ─────────────────────────────────────────
  Future<UserModel> signIn({
    required String username,
    required String password,
  }) async {
    // Cari email dari username / Find email from username
    final profileData = await _client
        .from('profiles')
        .select('email')
        .eq('username', username)
        .maybeSingle();

    if (profileData == null) {
      throw Exception('Username tidak ditemukan.');
    }

    final email = profileData['email'] as String;

    // Login dengan email + password / Login with email + password
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Password salah. Coba lagi.');
    }

    return await getProfile(authResponse.user!.id);
  }

  // ─── AMBIL PROFIL / GET PROFILE ──────────────────────────────
  Future<UserModel> getProfile(String uid) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();

    return UserModel.fromMap(data);
  }

  // ─── PERBARUI PROFIL / UPDATE PROFILE ────────────────────────
  Future<UserModel> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    await _client.from('profiles').update({
      'full_name': fullName,
      'phone': phone,
    }).eq('id', uid);

    return await getProfile(uid);
  }

  // ─── KELUAR / SIGN OUT ───────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── USER SAAT INI / CURRENT USER ────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
}
