import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/photo_picker.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/avatar_options_sheet.dart';
import '../widgets/user_avatar.dart';

/// Halaman menyunting profil: foto, username, dan email.
///
/// Sengaja dipisah dari halaman Pengaturan. Pengaturan mengurus hal akun yang
/// sifatnya teknis (password, sesi, hapus akun), sedangkan halaman ini murni
/// data profil yang tampil ke orang lain.
///
/// Mengembalikan [User] terbaru lewat `Navigator.pop` bila ada perubahan.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.user});

  final User? user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  late User? _user;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _usernameController =
        TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================
  // FOTO PROFIL
  // =========================
  /// Avatar diketuk → muncul pilihan ganti / hapus foto.
  Future<void> _onAvatarTap() async {
    if (_isBusy) return;

    await showAvatarOptionsSheet(
      context,
      onChangePhoto: _changePhoto,
      onRemovePhoto: (_user?.hasAvatar ?? false) ? _removeAvatar : null,
    );
  }

  Future<void> _changePhoto() async {
    final photo = await pickPhotoFromGallery(maxWidth: 512, maxHeight: 512);
    if (photo == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated =
          await _userService.updateAvatar(photo.bytes, photo.fileName);
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Foto profil diperbarui');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal mengunggah foto: $e');
    }
  }

  Future<void> _removeAvatar() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus foto profil?',
      message: 'Avatar akan kembali memakai inisial username.',
      confirmLabel: 'Hapus',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated = await _userService.deleteAvatar();
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Foto profil dihapus');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal menghapus foto: $e');
    }
  }

  // =========================
  // SIMPAN
  // =========================
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isBusy = true);
    try {
      final updated = await _userService.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );
      await ApiClient.updateProfileCache(newUsername: updated.username);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Profil diperbarui');
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal memperbarui profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit profil'),
        actions: [
          TextButton(
            onPressed: _isBusy ? null : _save,
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _onAvatarTap,
                  child: Stack(
                    children: [
                      UserAvatar(
                        imageUrl: user?.avatarUrl ?? ApiClient.avatarUrl,
                        username: user?.username ?? ApiClient.username ?? '?',
                        size: 96,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.6,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ketuk foto untuk mengganti atau menghapusnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _usernameController,
                enabled: !_isBusy,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Username wajib diisi';
                  if (text.length < 3) return 'Username minimal 3 karakter';
                  if (text.length > 50) return 'Username maksimal 50 karakter';
                  // Pola sama dengan validasi di server.
                  if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(text)) {
                    return 'Hanya huruf, angka, titik, _ dan -';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isBusy,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isBusy ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Simpan perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
