/// Kumpulan alamat endpoint REST API dan nama header yang dipakai client.
///
/// Semua alamat ditulis di satu tempat supaya perubahan base URL atau versi
/// API tidak perlu diburu ke seluruh aplikasi.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:3006';

  // Auth
  static const String loginEndpoint = '$baseUrl/api/v1/auth/login';
  static const String registerEndpoint = '$baseUrl/api/v1/auth/register';
  static const String logoutEndpoint = '$baseUrl/api/v1/auth/logout';

  // Posts
  static const String postsEndpoint = '$baseUrl/api/v1/posts';
  static String likePostEndpoint(int postId) =>
      '$baseUrl/api/v1/posts/$postId/like';

  // Likes
  static const String myLikesEndpoint = '$baseUrl/api/v1/likes/me';

  // Users
  static const String meEndpoint = '$baseUrl/api/v1/users/me';
  static const String avatarEndpoint = '$baseUrl/api/v1/users/avatar';
  static const String changePasswordEndpoint =
      '$baseUrl/api/v1/users/me/password';
  static const String deleteAvatarEndpoint = '$baseUrl/api/v1/users/me/avatar';

  // Categories
  static const String categoriesSearchEndpoint = '$baseUrl/api/v1/categories/search';
  static const String categoriesTrendingEndpoint = '$baseUrl/api/v1/categories/trending';
  static String categoryPostsEndpoint(String categoryName) =>
      '$baseUrl/api/v1/categories/$categoryName/posts';

  // Comments
  static String postCommentsEndpoint(int postId) => '$baseUrl/api/v1/posts/$postId/comments';
  static String deleteCommentEndpoint(int commentId) => '$baseUrl/api/v1/comments/$commentId';

  // Header
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
}