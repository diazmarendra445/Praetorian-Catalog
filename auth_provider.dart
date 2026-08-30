import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';

  // ─── Getters / Getters ───────────────────────────────────────
  UserModel? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _user != null;

  // ─── DAFTAR / SIGN UP ────────────────────────────────────────
  Future<bool> signUp({
    required String fullName,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await _authService.signUp(
        fullName: fullName,
        username: username,
        phone: phone,
        email: email,
        password: password,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ─── MASUK / SIGN IN ─────────────────────────────────────────
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await _authService.signIn(
        username: username,
        password: password,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ─── MUAT PROFIL / LOAD PROFILE ──────────────────────────────
  Future<void> loadProfile(String uid) async {
    try {
      _user = await _authService.getProfile(uid);
      notifyListeners();
    } catch (e) {
      // Gagal diam-diam, user masih bisa pakai aplikasi / silent fail, user can still use the app
    }
  }

  // ─── PERBARUI PROFIL / UPDATE PROFILE ────────────────────────
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    if (_user == null) return false;
    _setLoading();
    try {
      _user = await _authService.updateProfile(
        uid: _user!.id,
        fullName: fullName,
        phone: phone,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    }
  }

  // ─── KELUAR / SIGN OUT ───────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }

  // ─── Helpers / Helpers ───────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _status = AuthStatus.idle;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('Username tidak ditemukan')) return 'Username tidak ditemukan.';
    if (raw.contains('Password salah')) return 'Password salah.';
    if (raw.contains('already registered')) return 'Email sudah terdaftar.';
    if (raw.contains('duplicate key') || raw.contains('unique')) {
      return 'Username sudah dipakai. Coba yang lain.';
    }
    if (raw.contains('Invalid login')) return 'Email atau password salah.';
    if (raw.contains('network')) return 'Cek koneksi internet kamu.';
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
