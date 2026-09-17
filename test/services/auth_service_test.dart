import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kata/core/api_client.dart';
import 'package:kata/core/constants.dart';
import 'package:kata/services/auth_service.dart';

import '../helpers/test_env.dart';

void main() {
  late AuthService authService;
  late Map<String, String> secureStore;

  setUp(() {
    secureStore = setupTestEnv();
    authService = AuthService();
  });

  group('AuthService.login', () {
    test('sukses: simpan token & data user, kembalikan User', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'token': 'jwt-token',
              'user': {
                'id': 1,
                'username': 'budi',
                'email': 'budi@example.com',
              },
            },
          }),
          200,
        );
      });

      final user = await authService.login(
        email: 'budi@example.com',
        password: 'rahasia',
      );

      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), ApiConstants.loginEndpoint);
      expect(
        captured!.body,
        jsonEncode({'email': 'budi@example.com', 'password': 'rahasia'}),
      );
      // Endpoint login tidak boleh membawa token lama.
      expect(
        captured!.headers.containsKey(ApiConstants.authorizationHeader),
        isFalse,
      );

      expect(user.username, 'budi');
      expect(ApiClient.isLoggedIn, isTrue);
      expect(ApiClient.token, 'jwt-token');
      expect(ApiClient.userId, 1);
      expect(ApiClient.username, 'budi');
      expect(secureStore['auth_token'], 'jwt-token');
    });

    test('sukses: menerima bentuk access_token', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'access_token': 'jwt-lama',
              'id': 2,
              'username': 'sinta',
            },
          }),
          200,
        );
      });

      final user = await authService.login(
        email: 'sinta@example.com',
        password: 'rahasia',
      );

      expect(ApiClient.token, 'jwt-lama');
      expect(ApiClient.userId, 2);
      expect(user.username, 'sinta');
    });

    test('gagal: respons tanpa token melempar ApiException', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'user': {'id': 1, 'username': 'budi'}},
          }),
          200,
        );
      });

      await expectLater(
        authService.login(email: 'budi@example.com', password: 'x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Login gagal: token tidak ditemukan di respons',
          ),
        ),
      );
      expect(ApiClient.isLoggedIn, isFalse);
    });

    test('gagal: kredensial salah meneruskan pesan server', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          '{"data":{"message":"Email atau password salah"}}',
          401,
        );
      });

      await expectLater(
        authService.login(email: 'budi@example.com', password: 'salah'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Email atau password salah')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });

  group('AuthService.register', () {
    test('sukses dengan token: sesi langsung aktif', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'token': 'jwt-baru',
              'user': {'id': 5, 'username': 'baru'},
            },
          }),
          201,
        );
      });

      final user = await authService.register(
        username: 'baru',
        email: 'baru@example.com',
        password: 'rahasia1',
      );

      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), ApiConstants.registerEndpoint);
      expect(
        captured!.body,
        jsonEncode({
          'username': 'baru',
          'email': 'baru@example.com',
          'password': 'rahasia1',
        }),
      );

      expect(user.username, 'baru');
      expect(ApiClient.isLoggedIn, isTrue);
      expect(ApiClient.token, 'jwt-baru');
      expect(secureStore['auth_token'], 'jwt-baru');
    });

    test('tanpa token: sukses daftar tapi sesi tetap kosong', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'user': {'id': 6, 'username': 'tanpatoken'},
            },
          }),
          201,
        );
      });

      final user = await authService.register(
        username: 'tanpatoken',
        email: 't@example.com',
        password: 'rahasia1',
      );

      expect(user.username, 'tanpatoken');
      expect(ApiClient.isLoggedIn, isFalse);
    });

    test('gagal: email sudah terdaftar meneruskan pesan server', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"data":{"message":"Email sudah dipakai"}}', 409);
      });

      await expectLater(
        authService.register(
          username: 'baru',
          email: 'sudah@ada.com',
          password: 'rahasia1',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Email sudah dipakai')
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });
  });

  group('AuthService.logout', () {
    test('membersihkan sesi walau endpoint logout gagal', () async {
      await ApiClient.saveAuth(newToken: 'token-abc');
      expect(ApiClient.isLoggedIn, isTrue);

      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"error":"network down"}', 500);
      });

      await authService.logout();

      expect(ApiClient.isLoggedIn, isFalse);
      expect(ApiClient.token, isNull);
      expect(secureStore.containsKey('auth_token'), isFalse);
    });

    test('sukses: panggil endpoint lalu bersihkan sesi', () async {
      await ApiClient.saveAuth(newToken: 'token-abc');

      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await authService.logout();

      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), ApiConstants.logoutEndpoint);
      expect(ApiClient.isLoggedIn, isFalse);
    });
  });
}
