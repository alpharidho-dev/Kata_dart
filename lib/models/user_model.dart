/// Data akun yang sedang login, termasuk token sesi (kalau server
/// mengirimkannya saat login/daftar).
class User {
  final int? id;
  final String username;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? avatarPublicId;
  final String? token;

  User({
    this.id,
    required this.username,
    required this.email,
    this.role = 'user',
    this.avatarUrl,
    this.avatarPublicId,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatarUrl: json['avatarUrl'],
      avatarPublicId: json['avatarPublicId'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      if (token != null) 'token': token,
    };
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Initial untuk avatar fallback (huruf pertama username)
  String get initial =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';
}

/// Data penulis yang ikut menempel pada artikel dan komentar.
///
/// Server hanya menyertakan kolom ini untuk relasi penulis, jadi isinya lebih
/// sedikit daripada [User] — cukup untuk menampilkan nama akun dan avatar
/// tanpa ikut membawa email atau token.
class UserSummary {
  final int id;
  final String username;
  final String? avatarUrl;

  UserSummary({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  String get initial =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';
}