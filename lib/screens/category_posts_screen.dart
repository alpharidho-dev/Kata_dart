import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'post_detail_screen.dart';

/// Daftar artikel yang memakai satu hashtag/topik tertentu.
///
/// Dipakai dari chip topik di feed, halaman trending, dan hashtag yang
/// diketuk di dalam caption.
class CategoryPostsScreen extends StatefulWidget {
  final String category;
  const CategoryPostsScreen({super.key, required this.category});

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _postService.getPostsByCategory(widget.category);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat: $e';
        _isLoading = false;
      });
    }
  }

  /// Perbarui satu artikel setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _posts = _posts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();
    });
  }

  Future<void> _openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (result != null && mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.category}'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Memuat...');
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorStateView(message: _errorMessage!, onRetry: _load),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: EmptyStateView(
          icon: Icons.tag_rounded,
          title: 'Belum ada tulisan di #${widget.category}',
          subtitle: 'Jadi yang pertama menulis soal topik ini.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        // PostCard sudah punya padding horizontalnya sendiri, jadi daftar ini
        // tidak boleh menambah lagi — kalau tidak, isinya menjorok ke kanan.
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _posts.length,
        // Baris artikel yang sama dengan feed: nama akun, caption (hashtag
        // putih tebal), gambar, lalu tombol suka yang tersambung ke database.
        itemBuilder: (context, index) => PostCard(
          post: _posts[index],
          onTap: () => _openDetail(_posts[index]),
          onTagTap: _openCategory,
          onPostChanged: _onPostChanged,
        ),
      ),
    );
  }

  /// Buka hashtag lain dari dalam caption (mis. #kuliner → #jakarta).
  void _openCategory(String tag) {
    if (tag == widget.category) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }
}