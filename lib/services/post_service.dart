import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// Semua panggilan API seputar artikel: feed, detail, suka, topik, dan
/// komentar.
///
/// Tidak menyimpan state apa pun — hasilnya dikembalikan ke pemanggil supaya
/// tiap halaman bebas mengatur tampilannya sendiri.
class PostService {
  final ApiClient _apiClient = ApiClient.instance;

  // =========================
  // GET ALL POSTS
  // =========================
  /// Daftar artikel terbaru, atau hasil pencarian bila [query] diisi.
  ///
  /// [limit] bersifat opsional dan dibatasi server (maksimum 50).
  /// [query] dikirim sebagai `?q=` dan disaring **di server** — server mencari
  /// pada judul, isi, dan nama penulis, sehingga hasilnya menjangkau seluruh
  /// artikel di database, bukan hanya yang sedang tampil di layar.
  Future<List<Post>> getPosts({int? limit, String? query}) async {
    final keyword = query?.trim() ?? '';
    final queryParams = <String, String>{
      if (limit != null) 'limit': '$limit',
      if (keyword.isNotEmpty) 'q': keyword,
    };

    final response = await _apiClient.get(
      ApiConstants.postsEndpoint,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> postsJson =
        jsonResponse['data']?['posts'] ?? jsonResponse['posts'] ?? [];
    return postsJson.map((json) => Post.fromJson(json)).toList();
  }

  // =========================
  // GET POST DETAIL
  // =========================
  Future<Post> getPostById(int id) async {
    final response =
        await _apiClient.get('${ApiConstants.postsEndpoint}/$id');
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // LIKE — TOGGLE
  // =========================
  /// Suka / batal suka satu artikel.
  ///
  /// Server yang menentukan status akhir (toggle), jadi client tidak perlu
  /// mengirim status yang diinginkan — cukup memakai nilai yang dikembalikan.
  Future<LikeResult> toggleLike(int postId) async {
    final response =
        await _apiClient.post(ApiConstants.likePostEndpoint(postId));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return LikeResult.fromJson(jsonResponse['data'] ?? jsonResponse);
  }

  // =========================
  // LIKE — POST YANG SAYA SUKAI
  // =========================
  /// Daftar id artikel yang disukai pengguna yang sedang login.
  Future<Set<int>> getMyLikedPostIds() async {
    final response = await _apiClient.get(ApiConstants.myLikesEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> ids = jsonResponse['data']?['postIds'] ?? [];
    return ids.map(Post.asInt).where((id) => id > 0).toSet();
  }

  // =========================
  // CREATE POST (gambar opsional)
  // =========================
  Future<Post> createPost({
    required String caption,
    int userId = 1,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final cleanCaption = caption.trim();
    final title =
        cleanCaption.length >= 3 ? cleanCaption : 'Postingan baru';
    final content = cleanCaption.length >= 10
        ? cleanCaption
        : '${cleanCaption.isEmpty ? "Postingan" : cleanCaption} dari aplikasi';

    final fields = {
      'userId': userId.toString(),
      'title': title,
      'content': content,
    };

    final List<http.MultipartFile> files = [];
    if (fileBytes != null && fileName != null) {
      files.add(
        http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await _apiClient.postMultipart(
      ApiConstants.postsEndpoint,
      fields: fields,
      files: files.isEmpty ? null : files,
    );

    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // UPDATE POST
  // =========================
  Future<Post> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.postsEndpoint}/$postId',
      body: {'title': title, 'content': content},
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // DELETE POST
  // =========================
  Future<void> deletePost(int postId) async {
    await _apiClient.delete('${ApiConstants.postsEndpoint}/$postId');
  }

  // =========================
  // CATEGORIES — AUTOCOMPLETE
  // =========================
  Future<List<String>> searchCategories(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _apiClient.get(
      ApiConstants.categoriesSearchEndpoint,
      queryParams: {'q': query.trim().toLowerCase()},
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['categories'] ?? [];
    return data.map<String>((c) => c['name'] as String).toList();
  }

  // =========================
  // CATEGORIES — TRENDING
  // =========================
  Future<List<Map<String, dynamic>>> getTrendingCategories() async {
    final response =
        await _apiClient.get(ApiConstants.categoriesTrendingEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['categories'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  // =========================
  // CATEGORIES — POSTS BY CATEGORY
  // =========================
  Future<List<Post>> getPostsByCategory(String name) async {
    final response =
        await _apiClient.get(ApiConstants.categoryPostsEndpoint(name));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['posts'] ?? [];
    return data.map((json) => Post.fromJson(json)).toList();
  }

  // =========================
  // COMMENTS — GET BY POST
  // =========================
  Future<List<Comment>> getComments(int postId) async {
    final response =
        await _apiClient.get(ApiConstants.postCommentsEndpoint(postId));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['comments'] ?? [];
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  // =========================
  // COMMENTS — CREATE
  // =========================
  Future<Comment> createComment({
    required int postId,
    required int userId,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.postCommentsEndpoint(postId),
      body: {
        'userId': userId,
        'comment': comment,
      },
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Comment.fromJson(jsonResponse['data']?['comment'] ?? jsonResponse);
  }

  // =========================
  // COMMENTS — DELETE
  // =========================
  Future<void> deleteComment(int commentId) async {
    await _apiClient.delete(ApiConstants.deleteCommentEndpoint(commentId));
  }
}
