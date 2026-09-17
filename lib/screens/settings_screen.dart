import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

/// Halaman pengaturan akun (dibuka dari ikon gerigi di tab Profil).
///
/// Isinya hal-hal teknis akun — ganti password, sesi, dan info aplikasi.
/// Penyuntingan data profil (foto, username, email) ada di halaman terpisah,
/// `EditProfileScreen`.
///
/// Barisnya ditulis sendiri di file ini, bukan memakai paket pihak ketiga,
/// supaya gaya daftarnya sama dengan layar lain (garis pemisah tipis, tanpa
/// warna aksen selain putih).
///
/// Nilai kembalian (`Navigator.pop`):
/// - `'logout'`  → pengguna keluar, halaman pemanggil mereset state.
/// - `'deleted'` → akun dihapus permanen.
/// - `null`      → tidak ada perubahan sesi.
class SettingsScreen extends StatefulWidget {
  final User? user;

  const SettingsScreen({super.key, this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _appVersion = '1.0.0';

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  late User? _user;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!ApiClient.isLoggedIn) return;
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() => _user = user);
      await ApiClient.updateAvatarCache(user.avatarUrl);
    } catch (_) {
      // Gagal memuat profil tidak menghalangi halaman pengaturan tampil.
    }
  }

  // =========================
  // GANTI PASSWORD
  // =========================
  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password lama'),
                validator: (value) => (value ?? '').isEmpty
                    ? 'Password lama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password baru'),
                validator: (value) {
                  final text = value ?? '';
                  if (text.length < 8) return 'Minimal 8 karakter';
                  if (!RegExp(r'[A-Za-z]').hasMatch(text)) {
                    return 'Harus memuat huruf';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(text)) {
                    return 'Harus memuat angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Ulangi password baru'),
                validator: (value) => value != newController.text
                    ? 'Konfirmasi tidak sama'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (submitted != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await _userService.changePassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Password berhasil diganti');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal mengganti password: $e');
    } finally {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  // =========================
  // LOGOUT & HAPUS AKUN
  // =========================
  /// Menyunting data profil; daftar di halaman ini ikut disegarkan setelahnya.
  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _user),
      ),
    );

    if (!mounted) return;
    if (updated != null) setState(() => _user = updated);
  }

  Future<void> _logout() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Logout?',
      message: 'Kamu akan keluar dari akun ini.',
      confirmLabel: 'Logout',
    );
    if (confirm != true || !mounted) return;

    setState(() => _isBusy = true);
    await _authService.logout();
    if (!mounted) return;
    Navigator.pop(context, 'logout');
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus akun permanen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seluruh artikel, komentar, dan foto profilmu akan dihapus dan '
              'tidak bisa dikembalikan. Masukkan password untuk melanjutkan.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Hapus akun',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await _userService.deleteAccount(passwordController.text);
      await ApiClient.clearAuth();
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal menghapus akun: $e');
    } finally {
      passwordController.dispose();
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'KATA',
      applicationVersion: _appVersion,
      applicationIcon: const Icon(
        Icons.article_rounded,
        size: 40,
        color: AppColors.textPrimary,
      ),
      children: const [
        Text(
          'Aplikasi blog sederhana: menulis, menyukai, dan mengomentari '
          'artikel. Dibangun dengan Flutter (client) dan Express + MySQL '
          '(REST API).',
        ),
      ],
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        bottom: _isBusy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                ),
              )
            : null,
      ),
      body: _buildList(user),
    );
  }

  // =========================
  // DAFTAR PENGATURAN
  // =========================
  Widget _buildList(User? user) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _buildIdentityRow(user),
        const _SectionLabel('Keamanan'),
        _SettingRow(
          icon: Icons.lock_outline_rounded,
          title: 'Ganti password',
          subtitle: 'Wajib memasukkan password lama',
          onTap: _isBusy ? null : _changePassword,
        ),
        const _SectionLabel('Aplikasi'),
        _SettingRow(
          icon: Icons.info_outline_rounded,
          title: 'Tentang aplikasi',
          onTap: _showAbout,
        ),
        const _SettingRow(
          icon: Icons.numbers_rounded,
          title: 'Versi',
          value: _appVersion,
        ),
        const _SectionLabel('Sesi'),
        _SettingRow(
          icon: Icons.logout_rounded,
          title: 'Logout',
          onTap: _isBusy ? null : _logout,
        ),
        _SettingRow(
          icon: Icons.delete_forever_outlined,
          title: 'Hapus akun',
          subtitle: 'Permanen, tidak bisa dibatalkan',
          onTap: _isBusy ? null : _deleteAccount,
        ),
      ],
    );
  }

  /// Identitas akun sekaligus jalan pintas ke halaman edit profil.
  Widget _buildIdentityRow(User? user) {
    return InkWell(
      onTap: _openEditProfile,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: user?.avatarUrl,
              username: user?.username ?? '?',
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.username ?? 'Belum login',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul kelompok baris pengaturan.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Satu baris pengaturan: ikon, judul, penjelasan opsional, dan nilai di kanan.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
