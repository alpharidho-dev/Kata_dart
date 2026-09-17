import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:like_button/like_button.dart';

import 'package:kata/core/api_client.dart';
import 'package:kata/models/post_model.dart';
import 'package:kata/models/user_model.dart';
import 'package:kata/widgets/post_card.dart';

import '../helpers/test_env.dart';

Post _post({
  String? imageUrl,
  String? username,
  String? createdAt,
  bool isLiked = false,
  int likesCount = 0,
}) {
  return Post(
    id: 1,
    userId: 2,
    title: 'Judul',
    content: 'Isi tulisan #flutter',
    status: 'published',
    createdAt: createdAt ?? DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    imageUrl: imageUrl,
    author: username == null
        ? null
        : UserSummary(id: 2, username: username),
    isLiked: isLiked,
    likesCount: likesCount,
  );
}

Widget _wrap(
  Post post, {
  void Function(Post)? onPostChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PostCard(
        post: post,
        onTap: () {},
        onTagTap: (_) {},
        onPostChanged: onPostChanged,
      ),
    ),
  );
}

void main() {
  setUp(() {
    setupTestEnv();
  });

  group('PostCard — tampilan', () {
    testWidgets('menampilkan nama penulis, waktu, dan isi tulisan',
        (tester) async {
      await tester.pumpWidget(_wrap(_post(username: 'sinta')));

      expect(find.text('sinta'), findsOneWidget);
      expect(find.text('baru saja'), findsOneWidget);
      expect(find.text('Isi tulisan #flutter'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('tanpa data penulis menampilkan "Unknown"', (tester) async {
      await tester.pumpWidget(_wrap(_post()));

      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('post dengan gambar merender CachedNetworkImage dengan URL benar',
        (tester) async {
      await tester.pumpWidget(
        _wrap(_post(username: 'sinta', imageUrl: 'https://cdn.example.com/foto.jpg')),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(
        tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        ).imageUrl,
        'https://cdn.example.com/foto.jpg',
      );
    });
  });

  group('PostCard — aksi sekunder', () {
    testWidgets('jumlah komentar tampil bila lebih dari nol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: _post(username: 'sinta'),
              onTap: () {},
              onTagTap: (_) {},
              commentCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tombol simpan & bagikan memunculkan info belum tersedia',
        (tester) async {
      await tester.pumpWidget(_wrap(_post(username: 'sinta')));

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('Menyimpan postingan belum tersedia di versi ini'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('Membagikan postingan belum tersedia di versi ini'),
        findsOneWidget,
      );
    });

    testWidgets('tombol titik tiga memunculkan info menu', (tester) async {
      await tester.pumpWidget(_wrap(_post(username: 'sinta')));

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(
        find.text('Menu postingan belum tersedia di versi ini'),
        findsOneWidget,
      );
    });
  });

  group('PostCard — alur like (LikeAction)', () {
    testWidgets('belum login: muncul ajakan login, status tidak berubah',
        (tester) async {
      Post? changed;

      await tester.pumpWidget(
        _wrap(
          _post(username: 'sinta'),
          onPostChanged: (p) => changed = p,
        ),
      );

      await tester.tap(find.byType(LikeButton));
      await tester.pumpAndSettle();

      expect(find.text('Login dulu untuk menyukai postingan'), findsOneWidget);
      expect(changed, isNull);
    });

    testWidgets('login & sukses: onPostChanged menerima status baru',
        (tester) async {
      await ApiClient.saveAuth(newToken: 'token-abc');
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          '{"data":{"postId":1,"liked":true,"likesCount":10}}',
          200,
        );
      });

      Post? changed;

      await tester.pumpWidget(
        _wrap(
          _post(username: 'sinta'),
          onPostChanged: (p) => changed = p,
        ),
      );

      await tester.tap(find.byType(LikeButton));
      await tester.pumpAndSettle();

      expect(changed, isNotNull);
      expect(changed!.isLiked, isTrue);
      expect(changed!.likesCount, 10);
    });

    testWidgets('gagal dari server: tampil pesan error, status tidak berubah',
        (tester) async {
      await ApiClient.saveAuth(newToken: 'token-abc');
      ApiClient.httpClient = MockClient((request) async {
        return http.Response('{"error":"db down"}', 500);
      });

      Post? changed;

      await tester.pumpWidget(
        _wrap(
          _post(username: 'sinta', isLiked: true, likesCount: 2),
          onPostChanged: (p) => changed = p,
        ),
      );

      await tester.tap(find.byType(LikeButton));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Gagal menyukai postingan'),
        findsOneWidget,
      );
      expect(changed, isNull);
    });
  });
}
