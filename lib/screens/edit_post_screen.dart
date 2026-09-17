import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_autocomplete_field.dart';

/// Menyunting artikel yang sudah ada. Mengembalikan artikel hasil perubahan
/// lewat `Navigator.pop` supaya halaman detail bisa langsung memperbarui diri.
class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final PostService _postService = PostService();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.length < 3) {
      _showSnack('Judul minimal 3 karakter');
      return;
    }
    if (content.length < 10) {
      _showSnack('Konten minimal 10 karakter');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await _postService.updatePost(
        postId: widget.post.id!,
        title: title,
        content: content,
      );
      if (!mounted) return;
      _showSnack('Postingan berhasil diupdate');
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Gagal: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Postingan'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Judul',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                hintText: 'Judul postingan',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 20),

            const Text(
              'Konten',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            HashtagAutocompleteField(
              controller: _contentController,
              hintText: 'Tulis konten... #kuliner #jakarta',
              helperText: 'Ketik # untuk lihat saran hashtag',
              minLines: 6,
              maxLines: 10,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor:
                    _isSaving ? AppColors.surfaceLight : AppColors.primary,
              ),
              // Tombol memakai bidang putih, jadi isinya harus hitam.
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Menyimpan...',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                      ],
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}