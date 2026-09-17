import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/post_model.dart';
import '../routes.dart';
import '../services/post_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'category_posts_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Kerangka utama aplikasi.
///
/// Nav bar bawah cuma punya 3 item: Beranda, tombol "+" di tengah, dan Profil.
/// Tombol "+" bukan tab — dia membuka layar buat postingan sebagai halaman
/// baru (nav bar ikut tertutup), jadi isi tab tetap cuma dua.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();

  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  int _currentIndex = 0;

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Topik yang muncul di baris filter feed (dari /categories/trending).
  List<String> _topics = [];
  String? _activeTag; // null = semua topik

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadTopics();
  }

  // =========================
  // DATA
  // =========================
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // `isLiked` per artikel sudah dikirim server (middleware optionalAuth),
      // jadi feed hanya butuh satu request untuk tahu status suka semuanya.
      final posts = await _postService.getPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat postingan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTopics() async {
    try {
      final data = await _postService.getTrendingCategories();
      if (!mounted) return;
      setState(() {
        _topics = data
            .map((c) => c['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .take(10)
            .toList();
      });
    } catch (_) {
      // Filter topik bersifat opsional: kalau gagal, feed tetap tampil semua.
    }
  }

  Future<void> _refreshPosts() async {
    await Future.wait([_loadPosts(), _loadTopics()]);
  }

  List<Post> get _visiblePosts {
    if (_activeTag == null) return _posts;
    final tag = _activeTag!.toLowerCase();
    return _posts
        .where((post) =>
            (post.categories ?? []).any((c) => c.toLowerCase() == tag))
        .toList();
  }

  /// Ganti satu artikel di daftar setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _posts = _posts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();
    });
  }

  // =========================
  // NAVIGASI
  // =========================
  Future<void> _onTabChanged(int index) async {
    if (index == 1 && !ApiClient.isLoggedIn) {
      final loggedIn = await Navigator.pushNamed(context, AppRoutes.login);
      if (!mounted) return;
      if (loggedIn != true) return;
    }

    setState(() => _currentIndex = index);
    if (index == 1) _profileKey.currentState?.reload();
  }

  void _onLoggedOut() {
    setState(() => _currentIndex = 0);
    _loadPosts();
  }

  /// Tombol "+": buka layar buat postingan sebagai halaman penuh.
  Future<void> _openCompose() async {
    if (!ApiClient.isLoggedIn) {
      final loggedIn = await Navigator.pushNamed(context, AppRoutes.login);
      if (!mounted || loggedIn != true) return;
    }

    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(),
        fullscreenDialog: true,
      ),
    );

    if (posted == true && mounted) {
      setState(() => _currentIndex = 0);
      await _loadPosts();
      _profileKey.currentState?.reload();
    }
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
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

  Future<void> _openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (result != null && mounted) _loadPosts();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Judul mengikuti tab yang sedang dibuka, bukan nama aplikasi terus.
        title: _currentIndex == 0
            ? const Text(
                'KATA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: AppColors.primary,
                ),
              )
            : const Text('Profil'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _openSearch,
              tooltip: 'Cari',
            ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadPosts,
              tooltip: 'Refresh',
            ),
        ],
        bottom: _currentIndex == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(54),
                child: _TopicFilterBar(
                  topics: _topics,
                  activeTag: _activeTag,
                  onSelected: (tag) => setState(() => _activeTag = tag),
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedTab(),
          ProfileScreen(
            key: _profileKey,
            onLoggedOut: _onLoggedOut,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onTabChanged,
        onComposePressed: _openCompose,
      ),
    );
  }

  // =========================
  // FEED
  // =========================
  Widget _buildFeedTab() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Memuat postingan...');
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorStateView(
          message: _errorMessage!,
          onRetry: _loadPosts,
        ),
      );
    }

    final posts = _visiblePosts;

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: posts.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _activeTag == null
                        ? const EmptyStateView(
                            icon: Icons.photo_library_outlined,
                            title: 'Belum ada postingan',
                            subtitle: 'Tap tombol + untuk mulai menulis.',
                          )
                        : EmptyStateView(
                            icon: Icons.tag_rounded,
                            title: 'Belum ada tulisan di topik ini',
                            subtitle:
                                'Jadi yang pertama menulis soal #${_activeTag!}.',
                          ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(
                post: posts[index],
                onTap: () => _openDetail(posts[index]),
                onTagTap: _openCategory,
                onPostChanged: _onPostChanged,
              ),
            ),
    );
  }
}

/// Baris filter topik di bawah AppBar: "Semua" + hashtag yang sedang tren.
class _TopicFilterBar extends StatelessWidget {
  const _TopicFilterBar({
    required this.topics,
    required this.activeTag,
    required this.onSelected,
  });

  final List<String> topics;
  final String? activeTag;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: topics.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TopicChip(
              label: 'Semua',
              selected: activeTag == null,
              onTap: () => onSelected(null),
            );
          }
          final tag = topics[index - 1];
          return _TopicChip(
            label: '#$tag',
            selected: activeTag?.toLowerCase() == tag.toLowerCase(),
            onTap: () => onSelected(tag),
          );
        },
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
