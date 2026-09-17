import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/photo_picker.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/avatar_options_sheet.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import '../widgets/user_avatar.dart';
import 'category_posts_screen.dart';
import 'edit_profile_screen.dart';
import 'post_detail_screen.dart';
import 'settings_screen.dart';

/// Tab profil: header akun, lalu tiga tab (Tulisan / Disukai / Disimpan)
/// dan daftar artikel dalam bentuk linimasa — bukan grid.
///
/// Catatan: tabel `bookmark` belum ada di database, jadi tab **Disimpan** cuma
/// memberi tahu bahwa fiturnya belum tersedia dan tidak menampilkan data palsu.
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLoggedOut;

  const ProfileScreen({super.key, this.onLoggedOut});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  static const int _tabPosts = 0;
  static const int _tabLiked = 1;
  static const int _tabSaved = 2;

  int _tab = _tabPosts;

  bool _isLoadingPosts = false;
  bool _isUploadingPhoto = false;
  List<Post> _allPosts = [];
  Set<int> _likedPostIds = {};
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    reload();
    ApiClient.authNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    ApiClient.authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      _allPosts = [];
      _likedPostIds = {};
      _currentUser = null;
      _tab = _tabPosts;
    });
    reload();
  }

  Future<void> reload() async {
    await Future.wait([_loadCurrentUser(), _loadPosts()]);
  }

  // =========================
  // DATA
  // =========================
  Future<void> _loadCurrentUser() async {
    if (!ApiClient.isLoggedIn) return;
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() => _currentUser = user);
      // Sync ke cache juga
      await ApiClient.updateAvatarCache(user.avatarUrl);
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> _loadPosts() async {
    if (!ApiClient.isLoggedIn) {
      if (mounted) {
        setState(() {
          _allPosts = [];
          _likedPostIds = {};
          _isLoadingPosts = false;
        });
      }
      return;
    }

    setState(() => _isLoadingPosts = true);
    try {
      // Dua request: daftar artikel + id artikel yang disukai (endpoint
      // /likes/me). `isLiked` di feed hanya berlaku untuk artikel di halaman
      // itu, jadi id-nya diambil terpisah supaya tab Disukai akurat.
      final results = await Future.wait([
        _postService.getPosts(),
        _postService.getMyLikedPostIds(),
      ]);

      final posts = results[0] as List<Post>;
      final likedIds = results[1] as Set<int>;

      if (!mounted) return;
      setState(() {
        _allPosts = posts;
        _likedPostIds = likedIds;
        _isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPosts = false);
    }
  }

  List<Post> get _visiblePosts {
    switch (_tab) {
      case _tabLiked:
        return _allPosts
            .where((p) => p.id != null && _likedPostIds.contains(p.id))
            .toList();
      case _tabPosts:
      default:
        if (ApiClient.userId == null) return const [];
        return _allPosts.where((p) => p.userId == ApiClient.userId).toList();
    }
  }

  /// Ganti satu artikel di daftar setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _allPosts = _allPosts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();

      final id = updated.id;
      if (id != null) {
        if (updated.isLiked) {
          _likedPostIds.add(id);
        } else {
          _likedPostIds.remove(id);
        }
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // =========================
  // FOTO PROFIL
  // =========================
  /// Avatar diketuk → muncul pilihan ganti / hapus foto.
  Future<void> _onAvatarTap() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }
    if (_isUploadingPhoto) return;

    final hasPhoto = _currentUser?.hasAvatar ??
        (ApiClient.avatarUrl?.isNotEmpty ?? false);

    await showAvatarOptionsSheet(
      context,
      onChangePhoto: _changePhoto,
      onRemovePhoto: hasPhoto ? _removePhoto : null,
    );
  }

  Future<void> _changePhoto() async {
    final photo = await pickPhotoFromGallery(maxWidth: 512, maxHeight: 512);
    if (photo == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final updated =
          await _userService.updateAvatar(photo.bytes, photo.fileName);
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _currentUser = updated;
        _isUploadingPhoto = false;
      });
      _showSnack('Foto profil diperbarui');
      await _loadPosts();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Gagal mengunggah foto: $e');
    }
  }

  Future<void> _removePhoto() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus foto profil?',
      message: 'Avatar akan kembali memakai inisial username.',
      confirmLabel: 'Hapus',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final updated = await _userService.deleteAvatar();
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _currentUser = updated;
        _isUploadingPhoto = false;
      });
      _showSnack('Foto profil dihapus');
      await _loadPosts();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Gagal menghapus foto: $e');
    }
  }

  // =========================
  // EDIT PROFIL & PENGATURAN
  // =========================
  /// Menyunting data profil (foto, username, email).
  Future<void> _openEditProfile() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }

    final updated = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _currentUser),
      ),
    );

    if (!mounted) return;
    if (updated != null) setState(() => _currentUser = updated);
    await reload();
  }

  /// Pengaturan akun: password, sesi, dan info aplikasi.
  Future<void> _openSettings() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(user: _currentUser),
      ),
    );

    if (!mounted) return;

    if (result == 'logout') {
      _showSnack('Berhasil logout');
      widget.onLoggedOut?.call();
    } else if (result == 'deleted') {
      _showSnack('Akun berhasil dihapus');
      widget.onLoggedOut?.call();
    } else {
      await reload();
    }
  }

  Future<void> _goToLogin() async {
    await Navigator.pushNamed(context, AppRoutes.login);
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

  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }

  void _onTabSelected(int index) {
    // Tab Disimpan belum punya tabelnya, jadi tidak pernah jadi tab aktif.
    if (index == _tabSaved) return;
    setState(() => _tab = index);
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ApiClient.authNotifier,
      builder: (context, isLoggedIn, _) {
        return ValueListenableBuilder<int>(
          valueListenable: ApiClient.profileNotifier,
          builder: (context, _, _) {
            if (!isLoggedIn) return _buildLoggedOut();

            final posts = _visiblePosts;

            return RefreshIndicator(
              onRefresh: reload,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ProfileTabBarDelegate(
                      activeIndex: _tab,
                      onChanged: _onTabSelected,
                      onUnavailable: (label) => showNotAvailable(context, label),
                    ),
                  ),
                  if (_isLoadingPosts)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (posts.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyTab(_tab == _tabLiked),
                    )
                  else
                    SliverList.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () => _openDetail(post),
                          onTagTap: _openCategory,
                          onPostChanged: _onPostChanged,
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoggedOut() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Padding horizontal 16 supaya sejajar dengan header profil dan feed.
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      children: [
        Center(
          child: UserAvatar(
            imageUrl: null,
            username: 'Tamu',
            size: 96,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '@tamu',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Login untuk menulis, menyukai, dan berkomentar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _goToLogin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Login'),
        ),
      ],
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    final user = _currentUser;
    final username = user?.username ?? ApiClient.username ?? 'Pengguna';
    final email = user?.email;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _onAvatarTap,
                child: Stack(
                  children: [
                    UserAvatar(
                      imageUrl: user?.avatarUrl ?? ApiClient.avatarUrl,
                      username: username,
                      size: 84,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.border, width: 0.6),
                        ),
                        child: _isUploadingPhoto
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openSettings,
                tooltip: 'Pengaturan',
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '@$username',
            style:
                const TextStyle(fontSize: 14.5, color: AppColors.textSecondary),
          ),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _openEditProfile,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
            ),
            child: const Text('Edit profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(bool isLikedTab) {
    return EmptyStateView(
      icon: isLikedTab ? Icons.favorite_border_rounded : Icons.edit_note_rounded,
      title: isLikedTab
          ? 'Belum ada postingan yang kamu sukai'
          : 'Belum ada tulisan',
      subtitle: isLikedTab
          ? 'Tap ikon hati di postingan untuk melihatnya di sini.'
          : 'Tap tombol + untuk menulis yang pertama.',
    );
  }
}

/// Tab bar lengket (pinned) dengan garis penanda di bawah tab aktif.
class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  _ProfileTabBarDelegate({
    required this.activeIndex,
    required this.onChanged,
    required this.onUnavailable,
  });

  final int activeIndex;
  final ValueChanged<int> onChanged;

  /// Dipanggil untuk tab yang belum punya dukungan backend (Disimpan).
  final ValueChanged<String> onUnavailable;

  static const List<String> _labels = ['Tulisan', 'Disukai', 'Disimpan'];
  static const int _unavailableIndex = 2;

  @override
  double get minExtent => 49;

  @override
  double get maxExtent => 49;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_labels.length, (index) {
                final active = index == activeIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => index == _unavailableIndex
                        ? onUnavailable(_labels[index])
                        : onChanged(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: active ? 44 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 0.6),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarDelegate oldDelegate) =>
      oldDelegate.activeIndex != activeIndex;
}
