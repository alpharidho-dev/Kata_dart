import 'user_model.dart';

/// Satu komentar pada sebuah artikel (tabel `comments`).
///
/// Ditulis di file terpisah supaya tiap model punya satu file sendiri:
/// `user_model.dart`, `post_model.dart`, `comment_model.dart`.
class Comment {
  final int id;
  final int postId;
  final int userId;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final UserSummary? user;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      userId: json['userId'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserSummary.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
