import 'user_model.dart';

/// Artikel (tabel `posts`) beserta data ringkas penulisnya.
class Post {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final List<String>? categories;
  final String? imageUrl;
  final String? imagePublicId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final UserSummary? author;

  /// Jumlah suka artikel ini.
  final int likesCount;

  /// True bila artikel ini sudah disukai pengguna yang sedang login.
  final bool isLiked;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.categories,
    this.imageUrl,
    this.imagePublicId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      categories: (json['categories'] as List?)?.cast<String>(),
      imageUrl: json['imageUrl'],
      imagePublicId: json['imagePublicId'],
      status: json['status'] ?? 'published',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      author: json['author'] is Map<String, dynamic>
          ? UserSummary.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      likesCount: asInt(json['likesCount']),
      isLiked: json['isLiked'] == true,
    );
  }

  /// Konversi angka dari API yang bisa datang sebagai int, num, atau string.
  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  /// Salinan post dengan status suka terbaru.
  /// Model sengaja dibuat immutable supaya perubahan data lewat satu jalur ini.
  Post copyWithLike({required bool liked, required int count}) {
    return Post(
      id: id,
      userId: userId,
      title: title,
      content: content,
      categories: categories,
      imageUrl: imageUrl,
      imagePublicId: imagePublicId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author,
      likesCount: count,
      isLiked: liked,
    );
  }

  String get hashtagsText => (categories ?? []).map((t) => '#$t').join(' ');

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasCategories => categories != null && categories!.isNotEmpty;

  /// Caption tanpa hashtag — dipakai di tempat yang tidak muat menampilkan
  /// seluruh teks (mis. thumbnail di grid profil).
  String get contentWithoutHashtags {
    final stripped = content
        .replaceAll(RegExp(r'#\w+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped;
  }

  /// Nama yang ditampilkan sebagai identitas penulis di kartu: nama akun.
  String get displayName => author?.username ?? 'Unknown';
}

/// Hasil pemanggilan endpoint like.
class LikeResult {
  final int postId;
  final bool liked;
  final int likesCount;

  LikeResult({
    required this.postId,
    required this.liked,
    required this.likesCount,
  });

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      postId: Post.asInt(json['postId']),
      liked: json['liked'] == true,
      likesCount: Post.asInt(json['likesCount']),
    );
  }
}
