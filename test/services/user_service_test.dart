import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kata/core/api_client.dart';
import 'package:kata/core/constants.dart';
import 'package:kata/models/user_model.dart';
import 'package:kata/services/user_service.dart';

import '../helpers/test_env.dart';

void main() {
  late UserService userService;

  setUp(() {
    setupTestEnv();
    userService = UserService();
  });

  group('UserService — API calls', () {
    test('getCurrentUser() mengambil dari data.user', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'user': {
                'id': 3,
                'username': 'budi',
                'email': 'budi@example.com',
              },
            },
          }),
          200,
        );
      });

      final user = await userService.getCurrentUser();

      expect(captured!.url.toString(), ApiConstants.meEndpoint);
      expect(user.id, 3);
      expect(user.username, 'budi');
      expect(user.email, 'budi@example.com');
    });

    test('getCurrentUser() error dari server jadi ApiException', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"data":{"message":"Belum login"}}', 401);
      });

      await expectLater(
        userService.getCurrentUser(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Belum login')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('updateAvatar() kirim multipart PUT dengan file "image"', () async {
      final client = CapturingClient(
        http.Response(
          jsonEncode({
            'data': {
              'user': {
                'id': 3,
                'username': 'budi',
                'avatarUrl': 'https://cdn.example.com/budi.png',
              },
            },
          }),
          200,
        ),
      );
      ApiClient.httpClient = client;

      final user = await userService.updateAvatar(
        Uint8List.fromList([9, 9, 9]),
        'avatar.png',
      );

      final multipart = client.lastRequest! as http.MultipartRequest;
      expect(multipart.method, 'PUT');
      expect(multipart.url.toString(), ApiConstants.avatarEndpoint);
      expect(multipart.files.first.field, 'image');
      expect(multipart.files.first.filename, 'avatar.png');
      expect(user.avatarUrl, 'https://cdn.example.com/budi.png');
    });

    test('deleteAvatar() DELETE dan mengembalikan User', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {'user': {'id': 3, 'username': 'budi'}},
          }),
          200,
        );
      });

      final user = await userService.deleteAvatar();

      expect(captured!.method, 'DELETE');
      expect(captured!.url.toString(), ApiConstants.deleteAvatarEndpoint);
      expect(user.username, 'budi');
    });

    test('updateProfile() PUT username & email sebagai JSON', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'user': {
                'id': 3,
                'username': 'budi_baru',
                'email': 'baru@example.com',
              },
            },
          }),
          200,
        );
      });

      final user = await userService.updateProfile(
        username: 'budi_baru',
        email: 'baru@example.com',
      );

      expect(captured!.method, 'PUT');
      expect(captured!.url.toString(), ApiConstants.meEndpoint);
      expect(
        captured!.body,
        jsonEncode({
          'username': 'budi_baru',
          'email': 'baru@example.com',
        }),
      );
      expect(user.username, 'budi_baru');
    });

    test('changePassword() PUT password lama & baru', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await userService.changePassword(
        currentPassword: 'lama123',
        newPassword: 'baru456',
      );

      expect(captured!.method, 'PUT');
      expect(
        captured!.url.toString(),
        ApiConstants.changePasswordEndpoint,
      );
      expect(
        captured!.body,
        jsonEncode({
          'currentPassword': 'lama123',
          'newPassword': 'baru456',
        }),
      );
    });

    test('deleteAccount() DELETE dengan password di body', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await userService.deleteAccount('rahasia');

      expect(captured!.method, 'DELETE');
      expect(captured!.url.toString(), ApiConstants.meEndpoint);
      expect(captured!.body, jsonEncode({'password': 'rahasia'}));
    });
  });

  group('User model', () {
    test('User model parses JSON correctly', () {
      final user = User.fromJson({
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
      });
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });

    test('fromJson memakai fallback "name" bila username kosong', () {
      final user = User.fromJson({'name': 'dari-name', 'email': 'x@y.com'});
      expect(user.username, 'dari-name');
    });

    test('fromJson memberi nilai default untuk data kosong', () {
      final user = User.fromJson({});

      expect(user.id, isNull);
      expect(user.username, '');
      expect(user.email, '');
      expect(user.role, 'user');
      expect(user.avatarUrl, isNull);
      expect(user.token, isNull);
    });

    test('User hasAvatar returns correct boolean', () {
      final userWithAvatar = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
      );
      expect(userWithAvatar.hasAvatar, true);

      final userWithoutAvatar = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
      );
      expect(userWithoutAvatar.hasAvatar, false);
    });

    test('User initials generated correctly', () {
      final user = User(
        id: 1,
        username: 'John',
        email: 'john@example.com',
      );
      expect(user.initial, 'J');

      final lowercase = User(username: 'alice', email: 'a@b.com');
      expect(lowercase.initial, 'A');

      final empty = User(username: '', email: 'a@b.com');
      expect(empty.initial, '?');
    });

    test('toJson menyertakan token bila ada', () {
      final withToken = User(username: 'a', email: 'b', token: 'tok');
      expect(withToken.toJson(), {
        'username': 'a',
        'email': 'b',
        'token': 'tok',
      });

      final noToken = User(username: 'a', email: 'b');
      expect(noToken.toJson().containsKey('token'), isFalse);
    });
  });

  group('UserSummary model', () {
    test('UserSummary model parses JSON correctly', () {
      final summary = UserSummary.fromJson({
        'id': 1,
        'username': 'testuser',
        'avatarUrl': 'https://example.com/avatar.jpg',
      });
      expect(summary.id, 1);
      expect(summary.username, 'testuser');
      expect(summary.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('fromJson memberi default untuk data kosong', () {
      final summary = UserSummary.fromJson({});

      expect(summary.id, 0);
      expect(summary.username, '');
      expect(summary.hasAvatar, isFalse);
      expect(summary.initial, '?');
    });
  });
}
