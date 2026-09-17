import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_autocomplete_field.dart';
import '../widgets/user_avatar.dart';

/// Layar buat postingan — dibuka dari tombol "+" di nav bar, bukan sebagai tab.
///
/// Susunannya: batal di kiri, tombol Posting di kanan, isi tulisan sebagai
/// fokus utama, dan toolbar kecil di bawah untuk lampiran gambar + sisa
/// karakter.
///
/// Nilai balik `Navigator.pop(true)` menandakan postingan berhasil dibuat,
/// supaya pemanggil (feed) tahu harus memuat ulang.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const int _maxChars = 1000;

  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();

  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _captionController.removeListener(_onTextChanged);
    _captionController.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  int get _length => _captionController.text.trim().length;

  bool get _canPost => _length > 0 && _length <= _maxChars && !_isLoading;

  // =========================
  // GAMBAR (opsional)
  // =========================
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
    });
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  // =========================
  // SIMPAN
  // =========================
  Future<void> _submit() async {
    if (!ApiClient.isLoggedIn) {
      _showSnack('Login dulu untuk membuat postingan');
      return;
    }

    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      _showSnack('Tulisan tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _postService.createPost(
        caption: caption,
        userId: ApiClient.userId ?? 1,
        fileBytes: _imageBytes,
        fileName: _imageName,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Gagal memposting: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxChars - _length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _canPost ? _submit : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Posting'),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl: ApiClient.avatarUrl,
                    username: ApiClient.username ?? '?',
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HashtagAutocompleteField(
                          controller: _captionController,
                          hintText: 'Lagi mikirin apa?',
                          helperText: 'Ketik # untuk lihat saran topik',
                          minLines: 6,
                          maxLines: 10,
                          enabled: !_isLoading,
                        ),
                        if (_imageBytes != null) ...[
                          const SizedBox(height: 12),
                          _buildImagePreview(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomToolbar(remaining),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Semantics(
            button: true,
            label: 'Hapus gambar',
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.6),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(int remaining) {
    final progress = (_length / _maxChars).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
              color: AppColors.primary,
              tooltip: _imageBytes == null ? 'Tambah gambar' : 'Ganti gambar',
            ),
            const Spacer(),
            if (remaining < 200)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '$remaining',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.4,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining < 0 ? AppColors.textMuted : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
