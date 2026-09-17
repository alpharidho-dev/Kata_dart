import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

/// Masuk, daftar, dan keluar.
///
/// Tanggung jawabnya cuma dua: memanggil endpoint auth dan menyimpan atau
/// membersihkan sesi lewat [ApiClient].
class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.loginEndpoint,
      body: {'email': email, 'password': password},
      withToken: false,
    );

    final data = _extractData(response);
    final token = data['token'] ?? data['access_token'] ?? data['accessToken'];
    if (token == null) {
      throw ApiException('Login gagal: token tidak ditemukan di respons');
    }

    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;

    final userId = _extractInt(userJson['id']) ?? _extractInt(data['id']);
    final username = (userJson['username'] ?? data['username'] ?? '').toString();
    final avatarUrl = (userJson['avatarUrl'] ?? '').toString();

    await ApiClient.saveAuth(
      newToken: token.toString(),
      newUserId: userId,
      newUsername: username.isEmpty ? null : username,
      newAvatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
    );

    return User.fromJson({...userJson, 'token': token});
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.registerEndpoint,
      body: {'username': username, 'email': email, 'password': password},
      withToken: false,
    );

    final data = _extractData(response);
    final token = data['token'] ?? data['access_token'] ?? data['accessToken'];

    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;

    final userId = _extractInt(userJson['id']) ?? _extractInt(data['id']);
    final uname = (userJson['username'] ?? data['username'] ?? username).toString();

    if (token != null) {
      await ApiClient.saveAuth(
        newToken: token.toString(),
        newUserId: userId,
        newUsername: uname,
      );
    }

    return User.fromJson({...userJson, 'token': token});
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logoutEndpoint);
    } catch (_) {}
    await ApiClient.clearAuth();
  }

  int? _extractInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return <String, dynamic>{};
  }
}