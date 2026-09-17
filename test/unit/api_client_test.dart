import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kata/core/api_client.dart';
import 'package:kata/core/constants.dart';

void main() {
  // Secure storage in-memory: setMockInitialValues memasang platform palsu
  // yang memegang referensi map ini, jadi isi token bisa diinspeksi langsung.
  final secureStore = <String, String>{};

  setUp(() {
    secureStore.clear();
    FlutterSecureStorage.setMockInitialValues(secureStore);
    SharedPreferences.setMockInitialValues({});
    ApiClient.token = null;
    ApiClient.userId = null;
    ApiClient.username = null;
    ApiClient.avatarUrl = null;
    // Handler default: request yang tidak dipasangi handler sengaja dibuat
    // gagal supaya test tidak "lolos" diam-diam karena mock yang salah.
    ApiClient.httpClient = MockClient(
      (request) async => http.Response('{"error":"no handler"}', 500),
    );
  });

  tearDown(() async {
    await ApiClient.clearAuth();
  });

  group('ApiClient request', () {
    test('get() mengirim Bearer token, Content-Type, dan query params',
        () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"data":[]}', 200);
      });

      ApiClient.token = 'token-abc';
      await ApiClient.instance.get(
        ApiConstants.postsEndpoint,
        queryParams: {'page': '2'},
      );

      expect(captured!.url.toString(), startsWith(ApiConstants.postsEndpoint));
      expect(captured!.url.queryParameters['page'], '2');
      expect(
        captured!.headers[ApiConstants.contentTypeHeader],
        ApiConstants.applicationJson,
      );
      expect(
        captured!.headers[ApiConstants.authorizationHeader],
        'Bearer token-abc',
      );
    });

    test('tanpa token, header Authorization tidak dikirim', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      ApiClient.token = null;
      await ApiClient.instance.get(ApiConstants.postsEndpoint);

      expect(
        captured!.headers.containsKey(ApiConstants.authorizationHeader),
        isFalse,
      );
    });

    test('withToken: false tidak mengirim Authorization walau token ada',
        () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"data":{"token":"t"}}', 200);
      });

      ApiClient.token = 'token-abc';
      await ApiClient.instance.post(
        ApiConstants.loginEndpoint,
        body: {'email': 'a@b.com', 'password': 'secret'},
        withToken: false,
      );

      expect(
        captured!.headers.containsKey(ApiConstants.authorizationHeader),
        isFalse,
      );
      expect(
        captured!.body,
        jsonEncode({'email': 'a@b.com', 'password': 'secret'}),
      );
    });

    test('post() meneruskan body String tanpa encode ulang', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await ApiClient.instance.post(
        ApiConstants.postsEndpoint,
        body: 'raw-body',
      );

      expect(captured!.body, 'raw-body');
    });

    test('put() mengirim body JSON', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await ApiClient.instance.put(
        ApiConstants.postsEndpoint,
        body: {'title': 'Judul baru'},
      );

      expect(captured!.body, jsonEncode({'title': 'Judul baru'}));
    });

    test('delete() mengirim body JSON', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await ApiClient.instance.delete(
        ApiConstants.deleteCommentEndpoint(7),
        body: {'reason': 'spam'},
      );

      expect(captured!.body, jsonEncode({'reason': 'spam'}));
    });
  });

  group('ApiClient response handling', () {
    test('200 mengembalikan body JSON yang sudah di-decode', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"data":{"id":1}}', 200);
      });

      final result = await ApiClient.instance.get(ApiConstants.meEndpoint);

      expect(result, <String, dynamic>{'data': <String, dynamic>{'id': 1}});
    });

    test('200 dengan body non-JSON dikembalikan apa adanya (String)', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('pong', 200);
      });

      final result = await ApiClient.instance.get(ApiConstants.meEndpoint);

      expect(result, 'pong');
    });

    test('error dengan data.message jadi ApiException', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          '{"data":{"message":"Email sudah dipakai"}}',
          409,
        );
      });

      await expectLater(
        ApiClient.instance.post(ApiConstants.registerEndpoint),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Email sudah dipakai')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('error dengan message di level atas jadi ApiException', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"message":"Tidak diizinkan"}', 403);
      });

      await expectLater(
        ApiClient.instance.get(ApiConstants.meEndpoint),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Tidak diizinkan'),
        ),
      );
    });

    test('error tanpa message memakai pesan default', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('oops', 500);
      });

      await expectLater(
        ApiClient.instance.get(ApiConstants.meEndpoint),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Terjadi kesalahan (500)'),
        ),
      );
    });
  });

  group('ApiClient sesi saat 401', () {
    test('401 otomatis menghapus sesi (clearAuth)', () async {
      await ApiClient.saveAuth(
        newToken: 'token-abc',
        newUserId: 1,
        newUsername: 'kata',
      );
      expect(ApiClient.isLoggedIn, isTrue);
      expect(secureStore['auth_token'], 'token-abc');

      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"data":{"message":"Sesi berakhir"}}', 401);
      });

      await expectLater(
        ApiClient.instance.get(ApiConstants.meEndpoint),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );

      // clearAuth dipanggil tanpa await di _handleResponse; flush microtask.
      await Future<void>.delayed(Duration.zero);

      expect(ApiClient.token, isNull);
      expect(ApiClient.isLoggedIn, isFalse);
      expect(secureStore.containsKey('auth_token'), isFalse);
    });

    test('403 tidak menghapus sesi', () async {
      await ApiClient.saveAuth(newToken: 'token-abc');

      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"message":"Forbidden"}', 403);
      });

      await expectLater(
        ApiClient.instance.get(ApiConstants.meEndpoint),
        throwsA(isA<ApiException>()),
      );

      expect(ApiClient.isLoggedIn, isTrue);
      expect(secureStore['auth_token'], 'token-abc');
    });
  });

  group('ApiClient saveAuth / clearAuth', () {
    test('saveAuth menyimpan token & data user', () async {
      await ApiClient.saveAuth(
        newToken: 'token-xyz',
        newUserId: 5,
        newUsername: 'budi',
      );

      expect(ApiClient.isLoggedIn, isTrue);
      expect(ApiClient.userId, 5);
      expect(ApiClient.username, 'budi');
      expect(secureStore['auth_token'], 'token-xyz');
      expect(ApiClient.authNotifier.value, isTrue);
    });

    test('clearAuth menghapus semua data sesi', () async {
      await ApiClient.saveAuth(
        newToken: 'token-xyz',
        newUserId: 5,
        newUsername: 'budi',
        newAvatarUrl: 'https://example.com/a.png',
      );

      await ApiClient.clearAuth();

      expect(ApiClient.isLoggedIn, isFalse);
      expect(ApiClient.userId, isNull);
      expect(ApiClient.username, isNull);
      expect(ApiClient.avatarUrl, isNull);
      expect(secureStore, isEmpty);
      expect(ApiClient.authNotifier.value, isFalse);
    });
  });
}
