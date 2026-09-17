import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kata/core/api_client.dart';
import 'package:kata/core/constants.dart';
import 'package:kata/models/comment_model.dart';
import 'package:kata/models/post_model.dart';
import 'package:kata/services/post_service.dart';

import '../helpers/test_env.dart';

void main() {
  late PostService postService;

  setUp(() {
    setupTestEnv();
    postService = PostService();
  });

  group('PostService — feed & detail', () {
    test('getPosts() mem-parsing daftar post dari data.posts', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'posts': [
                {
                  'id': 1,
                  'userId': 1,
                  'title': 'Judul',
                  'content': 'Isi',
                  'status': 'published',
                  'createdAt': '2026-01-01T00:00:00Z',
                  'updatedAt': '2026-01-01T00:00:00Z',
                },
              ],
            },
          }),
          200,
        );
      });

      final posts = await postService.getPosts();

      expect(captured!.url.toString(), ApiConstants.postsEndpoint);
      expect(posts, hasLength(1));
      expect(posts.first.id, 1);
      expect(posts.first.title, 'Judul');
    });

    test('getPosts() juga menerima bentuk posts di level atas', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'posts': [
              {
                'id': 2,
                'userId': 1,
                'title': 'B',
                'content': 'C',
                'status': 'published',
                'createdAt': '',
                'updatedAt': '',
              },
            ],
          }),
          200,
        );
      });

      final posts = await postService.getPosts();

      expect(posts, hasLength(1));
      expect(posts.first.id, 2);
    });

    test('getPosts() mengirim limit dan q (sudah ditrim)', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"data":{"posts":[]}}', 200);
      });

      await postService.getPosts(limit: 5, query: '  flutter  ');

      expect(captured!.url.queryParameters['limit'], '5');
      expect(captured!.url.queryParameters['q'], 'flutter');
    });

    test('getPosts() tanpa parameter tidak mengirim query', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"data":{"posts":[]}}', 200);
      });

      await postService.getPosts();

      expect(captured!.url.queryParameters, isEmpty);
    });

    test('getPostById() mengambil dari data.post dengan URL yang benar',
        () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'post': {
                'id': 9,
                'userId': 1,
                'title': 'Detail',
                'content': 'Isi detail',
                'status': 'published',
                'createdAt': '',
                'updatedAt': '',
              },
            },
          }),
          200,
        );
      });

      final post = await postService.getPostById(9);

      expect(captured!.url.toString(), '${ApiConstants.postsEndpoint}/9');
      expect(post.id, 9);
      expect(post.title, 'Detail');
    });
  });

  group('PostService — like', () {
    test('toggleLike() POST dan mem-parsing LikeResult (angka string)',
        () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {'postId': '3', 'liked': true, 'likesCount': '8'},
          }),
          200,
        );
      });

      final result = await postService.toggleLike(3);

      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), ApiConstants.likePostEndpoint(3));
      expect(result.postId, 3);
      expect(result.liked, isTrue);
      expect(result.likesCount, 8);
    });

    test('getMyLikedPostIds() mengembalikan id unik dan membuang yang tidak valid',
        () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'postIds': [1, '2', 3.0, 'abc', 0, -5]},
          }),
          200,
        );
      });

      final ids = await postService.getMyLikedPostIds();

      expect(ids, {1, 2, 3});
    });
  });

  group('PostService — create/update/delete', () {
    test('createPost() caption pendek memakai fallback title & content',
        () async {
      final client = CapturingClient(
        http.Response(
          jsonEncode({
            'data': {
              'post': {
                'id': 4,
                'userId': 1,
                'title': 'Postingan baru',
                'content': 'ab dari aplikasi',
                'status': 'published',
                'createdAt': '',
                'updatedAt': '',
              },
            },
          }),
          201,
        ),
      );
      ApiClient.httpClient = client;

      final post = await postService.createPost(caption: 'ab');

      final multipart = client.lastRequest! as http.MultipartRequest;
      expect(multipart.fields['userId'], '1');
      expect(multipart.fields['title'], 'Postingan baru');
      expect(multipart.fields['content'], 'ab dari aplikasi');
      expect(multipart.files, isEmpty);
      expect(post.id, 4);
    });

    test('createPost() caption panjang dipakai apa adanya', () async {
      final client = CapturingClient(
        http.Response('{"data":{"post":{"id":5}}}', 201),
      );
      ApiClient.httpClient = client;

      await postService.createPost(caption: 'Caption panjang sepuluh');

      final multipart = client.lastRequest! as http.MultipartRequest;
      expect(multipart.fields['title'], 'Caption panjang sepuluh');
      expect(multipart.fields['content'], 'Caption panjang sepuluh');
    });

    test('createPost() dengan gambar melampirkan file "image"', () async {
      final client = CapturingClient(
        http.Response('{"data":{"post":{"id":6}}}', 201),
      );
      ApiClient.httpClient = client;

      await postService.createPost(
        caption: 'Ada gambar',
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'foto.jpg',
      );

      final multipart = client.lastRequest! as http.MultipartRequest;
      expect(multipart.files, hasLength(1));
      expect(multipart.files.first.field, 'image');
      expect(multipart.files.first.filename, 'foto.jpg');
    });

    test('updatePost() PUT dengan body JSON', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'post': {
                'id': 7,
                'userId': 1,
                'title': 'Baru',
                'content': 'Isi baru',
                'status': 'published',
                'createdAt': '',
                'updatedAt': '',
              },
            },
          }),
          200,
        );
      });

      final post = await postService.updatePost(
        postId: 7,
        title: 'Baru',
        content: 'Isi baru',
      );

      expect(captured!.method, 'PUT');
      expect(captured!.url.toString(), '${ApiConstants.postsEndpoint}/7');
      expect(
        captured!.body,
        jsonEncode({'title': 'Baru', 'content': 'Isi baru'}),
      );
      expect(post.title, 'Baru');
    });

    test('deletePost() DELETE ke URL yang benar', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await postService.deletePost(5);

      expect(captured!.method, 'DELETE');
      expect(captured!.url.toString(), '${ApiConstants.postsEndpoint}/5');
    });

    test('deletePost() error dari server dilempar sebagai ApiException',
        () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          '{"data":{"message":"Post tidak ditemukan"}}',
          404,
        );
      });

      await expectLater(
        postService.deletePost(99),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Post tidak ditemukan')
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('PostService — categories', () {
    test('searchCategories() query kosong tidak memanggil API', () async {
      final result = await postService.searchCategories('   ');

      // Mock default selalu 500 — kalau API terpanggil, test ini gagal.
      expect(result, isEmpty);
    });

    test('searchCategories() mengirim q lowercase dan mengembalikan nama',
        () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'categories': [
                {'name': 'flutter'},
                {'name': 'flutterweb'},
              ],
            },
          }),
          200,
        );
      });

      final names = await postService.searchCategories('Flutter');

      expect(captured!.url.queryParameters['q'], 'flutter');
      expect(names, ['flutter', 'flutterweb']);
    });

    test('getTrendingCategories() mengembalikan map mentah', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'categories': [
                {'name': 'flutter', 'count': 12},
                {'name': 'dart', 'count': 8},
              ],
            },
          }),
          200,
        );
      });

      final categories = await postService.getTrendingCategories();

      expect(categories, hasLength(2));
      expect(categories.first['name'], 'flutter');
      expect(categories.first['count'], 12);
    });

    test('getPostsByCategory() memakai URL kategori', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'posts': [
                {
                  'id': 3,
                  'userId': 1,
                  'title': 'T',
                  'content': 'C',
                  'status': 'published',
                  'createdAt': '',
                  'updatedAt': '',
                },
              ],
            },
          }),
          200,
        );
      });

      final posts = await postService.getPostsByCategory('flutter');

      expect(captured!.url.toString(),
          ApiConstants.categoryPostsEndpoint('flutter'));
      expect(posts, hasLength(1));
    });
  });

  group('PostService — comments', () {
    test('getComments() mem-parsing komentar beserta penulisnya', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'comments': [
                {
                  'id': 11,
                  'postId': 1,
                  'userId': 2,
                  'comment': 'Bagus!',
                  'createdAt': '2026-01-01T00:00:00Z',
                  'updatedAt': '2026-01-01T00:00:00Z',
                  'user': {'id': 2, 'username': 'sinta'},
                },
              ],
            },
          }),
          200,
        );
      });

      final comments = await postService.getComments(1);

      expect(comments, hasLength(1));
      expect(comments.first.comment, 'Bagus!');
      expect(comments.first.user?.username, 'sinta');
    });

    test('createComment() POST body JSON dan parsing hasilnya', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': {
              'comment': {
                'id': 12,
                'postId': 1,
                'userId': 1,
                'comment': 'Setuju',
                'createdAt': '',
                'updatedAt': '',
              },
            },
          }),
          201,
        );
      });

      final comment = await postService.createComment(
        postId: 1,
        userId: 1,
        comment: 'Setuju',
      );

      expect(captured!.method, 'POST');
      expect(
        captured!.body,
        jsonEncode({'userId': 1, 'comment': 'Setuju'}),
      );
      expect(comment.id, 12);
      expect(comment.comment, 'Setuju');
    });

    test('deleteComment() DELETE ke endpoint komentar', () async {
      http.Request? captured;
      ApiClient.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      await postService.deleteComment(4);

      expect(captured!.method, 'DELETE');
      expect(captured!.url.toString(),
          ApiConstants.deleteCommentEndpoint(4));
    });
  });

  group('Post model', () {
    test('Post.fromJson mem-parsing JSON minimal', () {
      final post = Post.fromJson({
        'id': 1,
        'userId': 1,
        'title': 'Test Post',
        'content': 'Test content',
        'status': 'published',
        'createdAt': '2026-09-17T00:48:53.798Z',
        'updatedAt': '2026-09-17T00:48:53.798Z',
      });
      expect(post.id, 1);
      expect(post.title, 'Test Post');
      expect(post.content, 'Test content');
      expect(post.isLiked, false);
      expect(post.likesCount, 0);
      expect(post.status, 'published');
    });

    test('Post.fromJson mem-parsing JSON lengkap (author, like, kategori)',
        () {
      final post = Post.fromJson({
        'id': 7,
        'userId': 2,
        'title': 'Judul',
        'content': 'Isi',
        'categories': ['flutter', 'dart'],
        'imageUrl': 'https://example.com/g.jpg',
        'status': 'draft',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
        'author': {
          'id': 2,
          'username': 'sinta',
          'avatarUrl': 'https://example.com/a.png',
        },
        'likesCount': '12',
        'isLiked': true,
      });

      expect(post.categories, ['flutter', 'dart']);
      expect(post.hasImage, isTrue);
      expect(post.status, 'draft');
      expect(post.author?.username, 'sinta');
      expect(post.author?.hasAvatar, isTrue);
      expect(post.likesCount, 12);
      expect(post.isLiked, isTrue);
    });

    test('Post.fromJson memberi nilai default untuk field yang hilang', () {
      final post = Post.fromJson({});

      expect(post.id, isNull);
      expect(post.userId, 0);
      expect(post.title, '');
      expect(post.content, '');
      expect(post.status, 'published');
      expect(post.author, isNull);
      expect(post.displayName, 'Unknown');
      expect(post.hasCategories, isFalse);
    });

    test('Post.asInt converts various types', () {
      expect(Post.asInt(5), 5);
      expect(Post.asInt('10'), 10);
      expect(Post.asInt(3.14), 3);
      expect(Post.asInt(null), 0);
      expect(Post.asInt('bukan angka'), 0);
    });

    test('Post hashtagsText & hasCategories', () {
      final post = Post(
        userId: 1,
        title: 'Test',
        content: 'Content',
        status: 'published',
        createdAt: '',
        updatedAt: '',
        categories: ['Flutter', 'Dart'],
      );
      expect(post.hashtagsText, '#Flutter #Dart');
      expect(post.hasCategories, isTrue);
    });

    test('Post hasImage returns correct boolean', () {
      final postWithImage = Post(
        userId: 1,
        title: 'Test',
        content: 'Content',
        status: 'published',
        createdAt: '',
        updatedAt: '',
        imageUrl: 'https://example.com/image.jpg',
      );
      expect(postWithImage.hasImage, true);

      final postWithoutImage = Post(
        userId: 1,
        title: 'Test',
        content: 'Content',
        status: 'published',
        createdAt: '',
        updatedAt: '',
      );
      expect(postWithoutImage.hasImage, false);
    });

    test('contentWithoutHashtags membuang hashtag dan spasi ganda', () {
      final post = Post(
        userId: 1,
        title: 'T',
        content: 'Cek ini #flutter dan  #dart   ya',
        status: 'published',
        createdAt: '',
        updatedAt: '',
      );

      expect(post.contentWithoutHashtags, 'Cek ini dan ya');
    });

    test('copyWithLike mengganti status suka tanpa mengubah field lain', () {
      final original = Post(
        id: 1,
        userId: 2,
        title: 'Judul',
        content: 'Isi',
        status: 'published',
        createdAt: 'a',
        updatedAt: 'b',
        likesCount: 0,
        isLiked: false,
      );

      final updated = original.copyWithLike(liked: true, count: 3);

      expect(updated.isLiked, isTrue);
      expect(updated.likesCount, 3);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(original.isLiked, isFalse);
    });
  });

  group('LikeResult model', () {
    test('parses JSON correctly', () {
      final result = LikeResult.fromJson({
        'postId': 1,
        'liked': true,
        'likesCount': 5,
      });
      expect(result.postId, 1);
      expect(result.liked, true);
      expect(result.likesCount, 5);
    });
  });

  group('Comment model', () {
    test('fromJson mem-parsing data lengkap', () {
      final comment = Comment.fromJson({
        'id': 11,
        'postId': 1,
        'userId': 2,
        'comment': 'Halo',
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-01T00:00:00Z',
        'user': {'id': 2, 'username': 'sinta'},
      });

      expect(comment.id, 11);
      expect(comment.postId, 1);
      expect(comment.comment, 'Halo');
      expect(comment.user?.username, 'sinta');
    });

    test('fromJson memberi default untuk data kosong', () {
      final comment = Comment.fromJson({});

      expect(comment.id, 0);
      expect(comment.postId, 0);
      expect(comment.comment, '');
      expect(comment.user, isNull);
    });
  });
}
