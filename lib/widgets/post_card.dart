import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/post_model.dart';
import 'hashtag_text.dart';
import 'like_action.dart';
import 'user_avatar.dart';

/// Satu baris artikel di linimasa feed:
/// avatar, baris akun (@username · waktu), isi tulisan, gambar opsional,
/// lalu baris aksi.
///
/// Tiap artikel tidak dibungkus kotak ber-border — pemisahnya cukup garis
/// tipis di bawah, jadi feed terasa lebih ringan dan tidak seperti daftar kartu.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final void Function(String tag) onTagTap;
  final ValueChanged<Post>? onPostChanged;
  final int commentCount;
  final bool showCommentCount;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onTagTap,
    this.onPostChanged,
    this.commentCount = 0,
    this.showCommentCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              imageUrl: post.author?.avatarUrl,
              username: post.displayName,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              // Isi tulisan diberi jarak 12 dari tepi kanan; tombol titik tiga
              // ditaruh di luar kolom ini supaya bisa mepet ke tepi.
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountRow(),
                    if (post.content.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      HashtagText(
                        text: post.content,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                        maxLines: 6,
                        onTagTap: onTagTap,
                      ),
                    ],
                    if (post.hasImage) ...[
                      const SizedBox(height: 10),
                      _buildImage(),
                    ],
                    const SizedBox(height: 4),
                    _buildActionRow(context),
                  ],
                ),
              ),
            ),
            _buildMoreButton(context),
          ],
        ),
      ),
    );
  }

  // =========================
  // BARIS AKUN
  // =========================
  Widget _buildAccountRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            post.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text('·', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        Text(
          formatRelativeTime(post.createdAt),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Tombol "..." di pojok kanan atas kartu.
  Widget _buildMoreButton(BuildContext context) {
    return InkWell(
      onTap: () => showNotAvailable(context, 'Menu postingan'),
      borderRadius: BorderRadius.circular(999),
      child: const Padding(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Icon(
          Icons.more_horiz,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // =========================
  // GAMBAR
  // =========================
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) => Container(
            color: AppColors.surfaceLight,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          errorWidget: (_, _, _) => Container(
            color: AppColors.surfaceLight,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // BARIS AKSI
  // =========================
  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        _CardAction(
          icon: Icons.mode_comment_outlined,
          label: showCommentCount && commentCount > 0 ? '$commentCount' : null,
          tooltip: 'Komentar',
          onTap: onTap,
        ),
        const SizedBox(width: 24),
        LikeAction(post: post, onPostChanged: onPostChanged),
        const Spacer(),
        _CardAction(
          icon: Icons.bookmark_border_rounded,
          tooltip: 'Simpan',
          onTap: () => showNotAvailable(context, 'Menyimpan postingan'),
        ),
        const SizedBox(width: 12),
        _CardAction(
          icon: Icons.ios_share_rounded,
          tooltip: 'Bagikan',
          onTap: () => showNotAvailable(context, 'Membagikan postingan'),
        ),
      ],
    );
  }
}

/// Ikon aksi kecil di bawah artikel (komentar, simpan, bagikan).
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.tooltip,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
