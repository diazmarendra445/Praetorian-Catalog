import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Validasi / Validation ────────────────────────────────────
  String? _validateFullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama lengkap wajib diisi';
    if (v.trim().length < 5) return 'Nama minimal 5 karakter';
    return null;
  }

  String? _validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
    if (v.trim().length < 3) return 'Username minimal 3 karakter';
    if (v.contains(' ')) return 'Username tidak boleh mengandung spasi';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor telepon wajib diisi';
    if (v.trim().length < 9) return 'Nomor telepon tidak valid';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    if (!v.contains('@')) return 'Email harus mengandung karakter "@"';
    if (!v.contains('.')) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _passwordController.text) return 'Password tidak sama';
    return null;
  }

  // ─── Daftar / Register ───────────────────────────────────────
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim().toLowerCase(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final itemProvider = context.read<ItemProvider>();
      await itemProvider.fetchItems(authProvider.user!.id);
      _showSuccessAndNavigate();
    } else if (mounted) {
      _showError(authProvider.errorMessage);
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Akun berhasil dibuat! Selamat datang 🎉'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── UI / UI ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppConfig.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header / Header ──────────────────────────
                const Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppConfig.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daftar dan mulai kelola koleksimu!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 28),

                // ── Formulir / Form ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. Nama Lengkap / Full Name
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hint: 'Minimal 5 karakter',
                        controller: _fullNameController,
                        prefixIcon: Icons.badge_outlined,
                        validator: _validateFullName,
                      ),
                      const SizedBox(height: 16),

                      // 2. Username / Username
                      CustomTextField(
                        label: 'Username',
                        hint: 'Tanpa spasi',
                        controller: _usernameController,
                        prefixIcon: Icons.alternate_email,
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 16),

                      // 3. Nomor Telepon / Phone Number
                      CustomTextField(
                        label: 'Nomor Telepon',
                        hint: '08xxxxxxxxxx',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 16),

                      // 4. Email / Email
                      CustomTextField(
                        label: 'Email',
                        hint: 'contoh@email.com',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // 5. Password / Password
                      CustomTextField(
                        label: 'Password',
                        hint: 'Minimal 6 karakter',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // 6. Konfirmasi Password / Confirm Password
                      CustomTextField(
                        label: 'Konfirmasi Password',
                        hint: 'Ulangi password',
                        controller: _confirmPasswordController,
                        prefixIcon: Icons.lock_reset_outlined,
                        isPassword: true,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 24),

                      // Tombol Daftar / Register Button
                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => CustomButton(
                          text: 'Daftar',
                          onPressed: _handleSignUp,
                          isLoading: auth.isLoading,
                          icon: Icons.person_add_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Tautan Login / Login Link ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
