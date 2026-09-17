import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

/// Client HTTP tunggal untuk seluruh aplikasi.
///
/// Token JWT adalah kredensial: siapa pun yang memegangnya bisa mengakses akun.
/// Karena itu token disimpan di **secure storage** (Keychain di iOS, Keystore di
/// Android). Data non-sensitif (id, username, avatar) tetap di SharedPreferences
/// supaya bisa dibaca sinkron tanpa membuka penyimpanan terenkripsi.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  /// http.Client yang dipakai semua request. Di-test boleh diganti MockClient
  /// supaya tidak ada HTTP sungguhan yang terkirim.
  @visibleForTesting
  static http.Client httpClient = http.Client();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';
  static const String _avatarUrlKey = 'auth_avatar_url';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String? token;
  static int? userId;
  static String? username;
  static String? avatarUrl;

  static final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<int> profileNotifier = ValueNotifier<int>(0);

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = await _secureStorage.read(key: _tokenKey);

    // Migrasi sesi lama: versi sebelumnya menyimpan token di SharedPreferences.
    // Kalau ada, token dipindah ke secure storage lalu dihapus dari prefs.
    if (token == null || token!.isEmpty) {
      final legacyToken = prefs.getString(_tokenKey);
      if (legacyToken != null && legacyToken.isNotEmpty) {
        token = legacyToken;
        await _secureStorage.write(key: _tokenKey, value: legacyToken);
      }
    }
    await prefs.remove(_tokenKey);

    userId = prefs.getInt(_userIdKey);
    username = prefs.getString(_usernameKey);
    avatarUrl = prefs.getString(_avatarUrlKey);
    authNotifier.value = isLoggedIn;
  }

  static Future<void> saveAuth({
    required String newToken,
    int? newUserId,
    String? newUsername,
    String? newAvatarUrl,
  }) async {
    token = newToken;
    if (newUserId != null) userId = newUserId;
    if (newUsername != null) username = newUsername;
    if (newAvatarUrl != null) avatarUrl = newAvatarUrl;

    await _secureStorage.write(key: _tokenKey, value: newToken);

    final prefs = await SharedPreferences.getInstance();
    if (newUserId != null) await prefs.setInt(_userIdKey, newUserId);
    if (newUsername != null) await prefs.setString(_usernameKey, newUsername);
    if (newAvatarUrl != null) await prefs.setString(_avatarUrlKey, newAvatarUrl);

    authNotifier.value = isLoggedIn;
    profileNotifier.value++;
  }

  /// Update username & email yang tampil di aplikasi (dipakai halaman Setting).
  static Future<void> updateProfileCache({
    String? newUsername,
    int? newUserId,
  }) async {
    if (newUsername != null) username = newUsername;
    if (newUserId != null) userId = newUserId;

    final prefs = await SharedPreferences.getInstance();
    if (newUsername != null) await prefs.setString(_usernameKey, newUsername);
    if (newUserId != null) await prefs.setInt(_userIdKey, newUserId);
    profileNotifier.value++;
  }

  /// Update avatar di memory + prefs (dipanggil dari UserService).
  static Future<void> updateAvatarCache(String? newAvatarUrl) async {
    avatarUrl = newAvatarUrl;
    final prefs = await SharedPreferences.getInstance();
    if (newAvatarUrl != null) {
      await prefs.setString(_avatarUrlKey, newAvatarUrl);
    } else {
      await prefs.remove(_avatarUrlKey);
    }
    profileNotifier.value++;
  }

  static Future<void> clearAuth() async {
    token = null;
    userId = null;
    username = null;
    avatarUrl = null;

    // Token dihapus dari secure storage; data non-sensitif dibersihkan dari prefs.
    await _secureStorage.delete(key: _tokenKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_avatarUrlKey);

    authNotifier.value = false;
    profileNotifier.value++;
  }

  Map<String, String> _headers({bool withToken = true}) {
    final headers = <String, String>{
      ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
    };
    if (withToken && isLoggedIn) {
      headers[ApiConstants.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParams,
    bool withToken = true,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response =
        await httpClient.get(uri, headers: _headers(withToken: withToken));
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String url, {
    Object? body,
    bool withToken = true,
  }) async {
    final response = await httpClient.post(
      Uri.parse(url),
      headers: _headers(withToken: withToken),
      body: body is String ? body : jsonEncode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String url, {
    Object? body,
    bool withToken = true,
  }) async {
    final response = await httpClient.put(
      Uri.parse(url),
      headers: _headers(withToken: withToken),
      body: body is String ? body : jsonEncode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String url, {
    Object? body,
    bool withToken = true,
  }) async {
    final response = await httpClient.delete(
      Uri.parse(url),
      headers: _headers(withToken: withToken),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool withToken = true,
  }) async {
    return _sendMultipart('POST', url,
        fields: fields, files: files, withToken: withToken);
  }

  Future<dynamic> putMultipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool withToken = true,
  }) async {
    return _sendMultipart('PUT', url,
        fields: fields, files: files, withToken: withToken);
  }

  Future<dynamic> _sendMultipart(
    String method,
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    bool withToken = true,
  }) async {
    final request = http.MultipartRequest(method, Uri.parse(url));
    if (withToken && isLoggedIn) {
      request.headers[ApiConstants.authorizationHeader] = 'Bearer $token';
    }
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Terjadi kesalahan (${response.statusCode})';
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'].toString();
      } else if (body['message'] != null) {
        message = body['message'].toString();
      }
    }

    // 401 = sesi tidak valid/kedaluwarsa, 403 pada endpoint ini juga berarti
    // token tidak bisa dipakai lagi → bersihkan sesi supaya aplikasi kembali
    // ke keadaan "belum login" dan tidak mengirim token rusak terus-menerus.
    if (response.statusCode == 401) {
      clearAuth();
    }

    throw ApiException(message, statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
