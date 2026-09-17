import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

/// Operasi pada akun pengguna: membaca profil sendiri, avatar, dan password.
class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Ambil data user yang sedang login.
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.meEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return User.fromJson(jsonResponse['data']?['user'] ?? jsonResponse);
  }

  /// Upload / ganti avatar. File field name: "image".
  Future<User> updateAvatar(Uint8List fileBytes, String fileName) async {
    final file = http.MultipartFile.fromBytes(
      'image',
      fileBytes,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );

    final response = await _apiClient.putMultipart(
      ApiConstants.avatarEndpoint,
      files: [file],
    );

    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return User.fromJson(jsonResponse['data']?['user'] ?? jsonResponse);
  }

  /// Hapus avatar (profil kembali memakai inisial nama).
  Future<User> deleteAvatar() async {
    final response =
        await _apiClient.delete(ApiConstants.deleteAvatarEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return User.fromJson(jsonResponse['data']?['user'] ?? jsonResponse);
  }

  /// Ubah username dan email.
  Future<User> updateProfile({
    required String username,
    required String email,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.meEndpoint,
      body: {'username': username, 'email': email},
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return User.fromJson(jsonResponse['data']?['user'] ?? jsonResponse);
  }

  /// Ganti password. Password lama diverifikasi di server.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.put(
      ApiConstants.changePasswordEndpoint,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Hapus akun permanen (dikonfirmasi dengan password).
  Future<void> deleteAccount(String password) async {
    await _apiClient.delete(
      ApiConstants.meEndpoint,
      body: {'password': password},
    );
  }
}
