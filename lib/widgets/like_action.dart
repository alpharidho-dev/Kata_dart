import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/post_model.dart';
import '../routes.dart';
import '../services/post_service.dart';

/// Tombol suka dengan animasi hati yang tersambung ke database.
///
/// Alur: ketuk → server membalik status di tabel `likes` → nilai final dari
/// server dipakai untuk memperbarui tampilan. Kalau gagal, tampilan tidak
/// berubah (dikembalikan `null` ke LikeButton) sehingga UI tidak pernah
/// menampilkan status yang tidak tersimpan di database.
class LikeAction extends StatefulWidget {
  final Post post;
  final ValueChanged<Post>? onPostChanged;
  final double iconSize;
  final Color? labelColor;

  const LikeAction({
    super.key,
    required this.post,
    this.onPostChanged,
    this.iconSize = 22,
    this.labelColor,
  });

  @override
  State<LikeAction> createState() => _LikeActionState();
}

class _LikeActionState extends State<LikeAction> {
  final PostService _postService = PostService();

  Future<bool?> _handleTap(bool isLiked) async {
    final postId = widget.post.id;
    if (postId == null) return null;

    if (!ApiClient.isLoggedIn) {
      _showMessage(
        'Login dulu untuk menyukai postingan',
        action: SnackBarAction(
          label: 'Login',
          textColor: AppColors.primary,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.login),
        ),
      );
      return null;
    }

    try {
      final result = await _postService.toggleLike(postId);
      widget.onPostChanged?.call(
        widget.post.copyWithLike(
          liked: result.liked,
          count: result.likesCount,
        ),
      );
      return result.liked;
    } catch (e) {
      _showMessage('Gagal menyukai postingan: $e');
      return null;
    }
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLiked;
    final labelColor = widget.labelColor ?? AppColors.textSecondary;

    return LikeButton(
      size: widget.iconSize,
      isLiked: isLiked,
      likeCount: widget.post.likesCount,
      countPostion: CountPostion.right,
      // Semua warna di bawah ini monokrom: putih saat disukai, abu-abu saat
      // belum — konsisten dengan tema hitam-putih aplikasi.
      bubblesColor: const BubblesColor(
        dotPrimaryColor: AppColors.textPrimary,
        dotSecondaryColor: AppColors.textSecondary,
      ),
      circleColor: const CircleColor(
        start: AppColors.textPrimary,
        end: AppColors.textSecondary,
      ),
      likeBuilder: (liked) => Icon(
        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.iconSize,
        color: liked ? AppColors.textPrimary : labelColor,
      ),
      countBuilder: (count, liked, text) => Text(
        count == null || count == 0 ? 'Suka' : text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: liked ? AppColors.textPrimary : labelColor,
        ),
      ),
      onTap: _handleTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }
}
