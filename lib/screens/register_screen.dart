import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';

/// Halaman pendaftaran akun baru.
///
/// Kalau server langsung mengembalikan token, sesi ikut aktif dan halaman
/// pemanggil menerima `true` lewat `Navigator.pop`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      // Halaman pemanggil menunggu nilai `true` sebagai tanda berhasil daftar.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol kembali dibiarkan otomatis supaya pengguna bisa membatalkan.
      appBar: AppBar(
        title: const Text('Daftar'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Buat akun KATA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cukup username, email, dan password.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Nama akun
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'username',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    if (v.trim().length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Format email salah';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    // Aturan ini disamakan dengan validasi server (Zod).
                    if (v.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                      return 'Password harus memuat huruf';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(v)) {
                      return 'Password harus memuat angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol daftar. Saat memproses, tombol tetap putih supaya
                // spinner hitam di atasnya masih terbaca.
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    disabledBackgroundColor:
                        _isLoading ? AppColors.primary : AppColors.surfaceLight,
                    disabledForegroundColor:
                        _isLoading ? AppColors.onPrimary : AppColors.textMuted,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Memuat...',
                              style: TextStyle(color: AppColors.onPrimary),
                            ),
                          ],
                        )
                      : const Text('Daftar'),
                ),
                const SizedBox(height: 12),

                // Tautan balik ke halaman masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}