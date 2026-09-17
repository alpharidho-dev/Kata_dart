import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'category_posts_screen.dart';
import 'post_detail_screen.dart';

/// Halaman pencarian: ketik kata kunci, hasilnya langsung tersaring.
///
/// Dua jenis hasil ditampilkan sekaligus:
/// - **topik** — dari `GET /categories/search?q=`
/// - **tulisan** — dari `GET /posts?q=`, disaring di server pada judul, isi,
///   nama penulis, dan hashtag di dalam caption
///
/// Karena penyaringan terjadi di server, hasilnya menjangkau seluruh artikel di
/// database — bukan hanya yang sedang tampil di layar. Selama kolom pencarian
/// masih kosong, halaman ini menampilkan topik populer sebagai titik awal.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Batas maksimum `limit` yang diterima server.
  static const int _resultLimit = 50;

  final PostService _postService = PostService();
  final TextEditingController _queryController = TextEditingController();

  Timer? _debounce;

  List<Map<String, dynamic>> _trending = [];
  List<String> _topicResults = [];
  List<Post> _postResults = [];

  bool _isLoadingTopics = true;
  bool _isSearching = false;
  String? _loadError;
  String? _searchError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  // =========================
  // DATA
  // =========================
  /// Topik populer sebagai titik awal sebelum pengguna mengetik apa pun.
  Future<void> _loadTrending() async {
    setState(() {
      _isLoadingTopics = true;
      _loadError = null;
    });

    try {
      final trending = await _postService.getTrendingCategories();
      if (!mounted) return;
      setState(() {
        _trending = trending;
        _isLoadingTopics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat data: $e';
        _isLoadingTopics = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    setState(() => _query = query);

    // Setiap ketukan membatalkan permintaan yang tertunda, jadi server hanya
    // menerima kata kunci yang benar-benar ditinggalkan pengguna.
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _topicResults = [];
        _postResults = [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await Future.wait([
        _postService.searchCategories(query),
        _postService.getPosts(limit: _resultLimit, query: query),
      ]);

      // Kalau pengguna sudah mengetik kata kunci lain, hasil ini sudah tidak
      // relevan — dibuang supaya tidak menimpa hasil yang lebih baru.
      if (!mounted || query != _query) return;

      setState(() {
        _topicResults = results[0] as List<String>;
        _postResults = results[1] as List<Post>;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted || query != _query) return;
      setState(() {
        _topicResults = [];
        _postResults = [];
        _searchError = 'Gagal mencari: $e';
        _isSearching = false;
      });
    }
  }

  void _clearQuery() {
    _queryController.clear();
    _onQueryChanged('');
  }

  // =========================
  // NAVIGASI
  // =========================
  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPostsScreen(category: tag)),
    );
  }

  Future<void> _openDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          style: const TextStyle(fontSize: 15.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceLight,
            hintText: 'Cari tulisan atau topik',
            hintStyle: const TextStyle(
              fontSize: 15.5,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: _clearQuery,
                    tooltip: 'Bersihkan',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.6, color: AppColors.border),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      if (_isLoadingTopics) {
        return const LoadingIndicator(message: 'Memuat...');
      }

      if (_loadError != null) {
        return Center(
          child: ErrorStateView(message: _loadError!, onRetry: _loadTrending),
        );
      }

      return _buildTrendingList();
    }

    if (_searchError != null) {
      return Center(
        child: ErrorStateView(
          message: _searchError!,
          onRetry: () => _runSearch(_query),
        ),
      );
    }

    // Masih menunggu jawaban server dan belum ada hasil lama untuk ditampilkan.
    if (_isSearching && _postResults.isEmpty && _topicResults.isEmpty) {
      return const LoadingIndicator(message: 'Mencari...');
    }

    final hasNoResult = _postResults.isEmpty && _topicResults.isEmpty;

    if (hasNoResult && _isSearching) {
      return const LoadingIndicator(message: 'Mencari...');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (_topicResults.isNotEmpty) ...[
          const _SectionLabel('Topik'),
          ..._topicResults.map(
            (tag) => _TopicRow(name: tag, onTap: () => _openCategory(tag)),
          ),
        ],
        if (_postResults.isNotEmpty) ...[
          const _SectionLabel('Tulisan'),
          ..._postResults.map(
            (post) => PostCard(
              post: post,
              onTap: () => _openDetail(post),
              onTagTap: _openCategory,
            ),
          ),
        ],
        if (hasNoResult)
          Center(
            child: EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'Tidak ada hasil untuk "$_query"',
              subtitle: 'Coba kata kunci lain, atau cek ejaannya.',
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingList() {
    if (_trending.isEmpty) {
      return const Center(
        child: EmptyStateView(
          icon: Icons.search_rounded,
          title: 'Cari tulisan atau topik',
          subtitle: 'Ketik kata kunci di kolom atas untuk mulai mencari.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _SectionLabel('Topik populer'),
        ..._trending.map((category) {
          final name = category['name']?.toString() ?? '';
          final count = Post.asInt(category['post_count']);
          if (name.isEmpty) return const SizedBox.shrink();

          return _TopicRow(
            name: name,
            postCount: count,
            onTap: () => _openCategory(name),
          );
        }),
      ],
    );
  }
}

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

/// Satu baris topik: #nama + jumlah tulisan.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.name, required this.onTap, this.postCount});

  final String name;
  final VoidCallback onTap;
  final int? postCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#$name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (postCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$postCount tulisan',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
