import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Perbarui Profil / Update Profile ────────────────────────
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui! ✨'),
          backgroundColor: AppConfig.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage),
          backgroundColor: AppConfig.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Keluar / Logout ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Kamu akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    final itemProvider = context.read<ItemProvider>();

    await authProvider.signOut();
    itemProvider.clearItems();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppConfig.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppConfig.secondaryColor,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Avatar / Avatar ─────────────────────────
                  _buildAvatar(user?.fullName ?? 'User'),
                  const SizedBox(height: 12),

                  Text(
                    user?.fullName ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppConfig.secondaryColor,
                    ),
                  ),
                  Text(
                    '@${user?.username ?? ''}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),

                  const SizedBox(height: 28),

                  // ── Formulir Edit / Edit Form ───────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppConfig.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Lengkap (bisa diubah) / Full Name (editable)
                        CustomTextField(
                          label: 'Nama Lengkap',
                          controller: _fullNameController,
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            if (v.trim().length < 5) {
                              return 'Nama minimal 5 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Nomor Telepon (bisa diubah) / Phone Number (editable)
                        CustomTextField(
                          label: 'Nomor Telepon',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Nomor telepon tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Username (hanya baca) / Username (read only)
                        CustomTextField(
                          label: 'Username',
                          controller: _usernameController,
                          prefixIcon: Icons.alternate_email,
                          readOnly: true,
                        ),
                        const SizedBox(height: 14),

                        // Email (hanya baca) / Email (read only)
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                        ),
                        const SizedBox(height: 6),

                        // Catatan hanya baca / Read-only note
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '* Username dan email tidak dapat diubah',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Simpan / Save Button
                        CustomButton(
                          text: 'Simpan Perubahan',
                          onPressed: _handleUpdate,
                          isLoading: auth.isLoading,
                          icon: Icons.save_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Tombol Keluar / Logout Button ──────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: _showLogoutDialog,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConfig.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: AppConfig.accentColor, size: 22),
                      ),
                      title: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppConfig.accentColor,
                        ),
                      ),
                      subtitle: const Text('Logout dari akun ini'),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppConfig.accentColor),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Versi aplikasi / App version
                  Text(
                    '${AppConfig.appName} v1.0.0',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bootcamp Calon Praetorian 2026',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : 'U';
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConfig.primaryColor, Color(0xFF9C94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppConfig.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
