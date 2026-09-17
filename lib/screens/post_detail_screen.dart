import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_text.dart';
import '../widgets/like_action.dart';
import '../widgets/user_avatar.dart';
import 'category_posts_screen.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Post _post;
  bool _isDeleting = false;
  bool _isLoadingComments = true;
  bool _isSendingComment = false;

  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isOwner {
    if (ApiClient.userId == null) return false;
    return _post.userId == ApiClient.userId;
  }

  bool get _canComment => ApiClient.isLoggedIn;

  // =========================
  // LIKE
  // =========================
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() => _post = updated);
  }

  // =========================
  // COMMENTS
  // =========================
  Future<void> _loadComments() async {
    if (_post.id == null) return;
    setState(() => _isLoadingComments = true);
    try {
      final list = await _postService.getComments(_post.id!);
      if (!mounted) return;
      setState(() {
        _comments = list;
        _isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    if (!_canComment) {
      _showSnack('Login dulu untuk berkomentar');
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) {
      _showSnack('Komentar gak boleh kosong');
      return;
    }

    setState(() => _isSendingComment = true);
    try {
      final newComment = await _postService.createComment(
        postId: _post.id!,
        userId: ApiClient.userId!,
        comment: text,
      );
      if (!mounted) return;
      setState(() {
        _comments.insert(0, newComment);
        _isSendingComment = false;
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _showSnack('Komentar terkirim');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingComment = false);
      _showSnack('Gagal kirim komentar: $e');
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus komentar?',
      confirmLabel: 'Hapus',
    );

    if (confirm != true) return;

    try {
      await _postService.deleteComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
      });
      _showSnack('Komentar dihapus');
    } catch (e) {
      _showSnack('Gagal hapus: $e');
    }
  }

  // =========================
  // EDIT / DELETE POST
  // =========================
  Future<void> _openEdit() async {
    final result = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => EditPostScreen(post: _post)),
    );
    if (result != null && mounted) {
      setState(() => _post = result);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus postingan?',
      message: 'Postingan ini akan dihapus permanen.',
      confirmLabel: 'Hapus',
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _postService.deletePost(_post.id!);
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
      _showSnack('Postingan berhasil dihapus');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showSnack('Gagal menghapus: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }

  void _scrollToComments() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postingan'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
        actions: [
          if (_isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit',
              onPressed: _isDeleting ? null : _openEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Hapus',
              onPressed: _isDeleting ? null : _confirmDelete,
            ),
          ],
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostContent(),
                        const Divider(height: 1, color: AppColors.border),
                        _buildCommentsSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildCommentInput(),
              ],
            ),
    );
  }

  // =========================
  // POST CONTENT
  // =========================
  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris akun: @username, waktu, dan tombol Ikuti di kanan.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: _post.author?.avatarUrl,
                username: _post.displayName,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '@${_post.displayName} · ${formatRelativeTime(_post.createdAt)}',
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
              const SizedBox(width: 8),
              // Tidak ada tombol Ikuti di artikel sendiri.
              if (!_isOwner)
                OutlinedButton(
                  onPressed: () => showNotAvailable(context, 'Mengikuti akun'),
                  child: const Text('Ikuti'),
                ),
            ],
          ),
        ),

        // Isi tulisan; hashtag jadi teks putih tebal yang bisa diketuk.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: HashtagText(
            text: _post.content,
            fontSize: 16.5,
            color: AppColors.textPrimary,
            onTagTap: _openCategory,
          ),
        ),

        // Gambar — dibulatkan dan diberi jarak, konsisten dengan kartu feed.
        if (_post.hasImage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: _post.imageUrl!,
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
            ),
          ),

        // Topik yang menempel di artikel (kolom `categories`).
        if (_post.hasCategories)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _post.categories!
                  .map(
                    (tag) => _TagChip(
                      label: tag,
                      onTap: () => _openCategory(tag),
                    ),
                  )
                  .toList(),
            ),
          ),

        // Action row
        _buildActionRow(),
      ],
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          _DetailAction(
            icon: Icons.mode_comment_outlined,
            label: _comments.isEmpty ? null : '${_comments.length}',
            tooltip: 'Komentar',
            onTap: _scrollToComments,
          ),
          const SizedBox(width: 20),
          LikeAction(
            post: _post,
            onPostChanged: _onPostChanged,
            iconSize: 20,
          ),
          const Spacer(),
          _DetailAction(
            icon: Icons.bookmark_border_rounded,
            tooltip: 'Simpan',
            onTap: () => showNotAvailable(context, 'Menyimpan postingan'),
          ),
          const SizedBox(width: 10),
          _DetailAction(
            icon: Icons.ios_share_rounded,
            tooltip: 'Bagikan',
            onTap: () => showNotAvailable(context, 'Membagikan postingan'),
          ),
        ],
      ),
    );
  }

  // =========================
  // COMMENTS SECTION
  // =========================
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (!_isLoadingComments && _comments.isNotEmpty)
                Text(
                  '${_comments.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (_isLoadingComments)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
        else if (_comments.isEmpty)
          _buildEmptyComments()
        else
          Column(
            children:
                _comments.map((c) => _buildCommentItem(c)).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyComments() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 36,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada komentar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final user = comment.user;
    final canDelete = ApiClient.userId != null &&
        (comment.userId == ApiClient.userId ||
            _post.userId == ApiClient.userId);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: user?.avatarUrl,
            username: user?.username ?? '?',
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.username ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatRelativeTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                HashtagText(
                  text: comment.comment,
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                  onTagTap: _openCategory,
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              onPressed: () => _deleteComment(comment),
              icon: const Icon(Icons.more_horiz_rounded, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Hapus',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    if (!_canComment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Login dulu untuk berkomentar',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, '/login');
                  if (result == true && mounted) setState(() {});
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !_isSendingComment,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendComment(),
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSendingComment
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Semantics(
                    button: true,
                    label: 'Kirim komentar',
                    child: GestureDetector(
                      onTap: _sendComment,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Ikon aksi di bawah artikel pada halaman detail.
class _DetailAction extends StatelessWidget {
  const _DetailAction({
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
              Icon(icon, size: 20, color: AppColors.textSecondary),
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

/// Chip topik (hashtag) yang bisa diketuk menuju daftar artikel topik itu.
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '#$label',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
