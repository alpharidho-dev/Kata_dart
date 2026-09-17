import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kata/core/api_client.dart';

/// HTTP client palsu yang meneruskan [BaseRequest] apa adanya — tidak seperti
/// [MockClient] yang mengonversi MultipartRequest menjadi Request biasa, jadi
/// fields & files multipart tetap bisa diperiksa oleh test.
///
/// Respons yang dikembalikan tetap berupa [http.Response] yang diberikan.
/// Request terakhir bisa diakses lewat [lastRequest].
class CapturingClient extends http.BaseClient {
  CapturingClient(this.response);

  http.BaseRequest? lastRequest;
  final http.Response response;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    final bytes = response.bodyBytes;
    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

/// Menyiapkan lingkungan test untuk kode yang menyentuh [ApiClient]:
///
/// - secure storage & SharedPreferences memakai implementasi in-memory,
/// - state statis [ApiClient] di-reset supaya test tidak saling memengaruhi,
/// - http.Client diganti [MockClient] yang selalu gagal (500) supaya request
///   yang lupa dipasangi handler tidak lolos diam-diam.
///
/// Mengembalikan map secure storage agar test bisa memeriksa isinya langsung.
Map<String, String> setupTestEnv() {
  final secureStore = <String, String>{};
  FlutterSecureStorage.setMockInitialValues(secureStore);
  SharedPreferences.setMockInitialValues({});

  ApiClient.token = null;
  ApiClient.userId = null;
  ApiClient.username = null;
  ApiClient.avatarUrl = null;
  ApiClient.httpClient = MockClient(
    (request) async => http.Response('{"error":"no handler"}', 500),
  );

  return secureStore;
}
