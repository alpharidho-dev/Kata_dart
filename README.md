# KATA — Client (Flutter)

Aplikasi mobile KATA. Semua tampilan ditulis dengan Flutter dan seluruh data diambil dari REST API server KATA — tidak ada satu pun data contoh yang ditanam di dalam aplikasi.

> **Berkas ini adalah README repositori client.** Seluruh path di dalamnya ditulis relatif terhadap root repositori ini, jadi perintah dan tautannya tetap benar baik dibaca dari repositori client yang berdiri sendiri maupun dari monorepo KATA.

## Ringkasan teknis

| Bagian | Keterangan |
| :--- | :--- |
| Bahasa | Dart (SDK `^3.12.2`) |
| Framework | Flutter, Material 3, tema gelap monokrom |
| HTTP | paket `http` lewat kelas tunggal `ApiClient` |
| Sesi | JWT di `flutter_secure_storage`; username/avatar di `shared_preferences` |
| Gambar | `cached_network_image` (feed & avatar), `image_picker` (unggah) |
| Font | `google_fonts` (Inter) |
| Navigasi | navbar bawah sendiri (`bottom_nav_bar.dart`), bukan tab dari paket |

### Dependensi runtime

Dibaca langsung dari `pubspec.yaml`, jadi tabel ini selalu ikut berubah kalau dependensinya diubah.

| Paket | Versi | Fungsi di aplikasi |
| :--- | :--- | :--- |
| `cupertino_icons` | `^1.0.8` | Ikon gaya iOS |
| `http` | `^1.6.0` | Semua panggilan REST API |
| `http_parser` | `^4.1.2` | Menyusun `MediaType` untuk request multipart |
| `image_picker` | `^1.2.3` | Memilih gambar dari galeri (`core/photo_picker.dart`) |
| `flutter_spinkit` | `^5.2.0` | Indikator loading (`widgets/loading_indicator.dart`) |
| `google_fonts` | `^6.0.0` | Font Inter |
| `shared_preferences` | `^2.5.5` | Menyimpan id/username/avatar agar tidak perlu login ulang |
| `cached_network_image` | `^4.0.0` | Gambar feed & avatar dibaca dari cache lokal |
| `flutter_secure_storage` | `^11.1.1` | Menyimpan token JWT (Keychain/Keystore) |
| `like_button` | `^2.1.0` | Animasi tombol suka (`widgets/like_action.dart`) |

## Struktur folder

```text
kata-client/  (root repositori ini)
├── pubspec.yaml                        # Dependency Flutter + nama paket `kata`
├── pubspec.lock                        # Versi dependency yang terkunci
├── analysis_options.yaml               # Aturan lint Dart
├── .gitignore                          # Berkas yang tidak ikut di-commit
├── .metadata                           # Penanda versi tooling Flutter
├── README.md                           # Dokumen ini
├── SRS.md                              # Ringkasan kebutuhan sisi aplikasi mobile
├── flutter_01.png                      # Tangkapan layar aplikasi (lampiran SRS)
├── test/                               # Folder pengujian Flutter (masih kosong)
├── android/                            # Proyek Android (namespace com.example.kata)
├── ios/ macos/ linux/ windows/ web/     # Platform target lainnya
└── lib/
    ├── main.dart                       # Entry point + ApiClient.init()
    ├── routes.dart                     # Nama rute (login, register, home)
    ├── core/
    │   ├── api_client.dart             # HTTP + penyimpanan sesi
    │   ├── constants.dart              # Alamat endpoint
    │   ├── theme.dart                  # Palet & ThemeData
    │   ├── formatters.dart             # formatRelativeTime()
    │   ├── photo_picker.dart           # Pemilih foto galeri
    │   └── ui_feedback.dart            # Snackbar & dialog konfirmasi
    ├── models/
    │   ├── user_model.dart             # User, UserSummary
    │   ├── post_model.dart             # Post, LikeResult
    │   └── comment_model.dart          # Comment
    ├── services/
    │   ├── auth_service.dart           # login, register, logout
    │   ├── post_service.dart           # artikel, like, topik, komentar
    │   └── user_service.dart           # profil, avatar, password
    ├── screens/
    │   ├── home_screen.dart            # Kerangka nav bar + feed
    │   ├── search_screen.dart          # Pencarian tulisan & topik
    │   ├── category_posts_screen.dart  # Artikel per topik
    │   ├── create_post_screen.dart     # Layar buat postingan (tombol +)
    │   ├── edit_post_screen.dart       # Sunting artikel
    │   ├── post_detail_screen.dart     # Detail + komentar
    │   ├── profile_screen.dart         # Profil + tab Tulisan/Disukai/Disimpan
    │   ├── edit_profile_screen.dart    # Foto, username, email
    │   ├── settings_screen.dart        # Password, sesi, info aplikasi
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── widgets/
        ├── bottom_nav_bar.dart         # Beranda, +, Profil
        ├── post_card.dart              # Satu baris artikel di linimasa
        ├── state_views.dart            # EmptyStateView, ErrorStateView
        ├── avatar_options_sheet.dart   # Ganti/hapus foto profil
        ├── hashtag_text.dart           # Caption dengan hashtag bisa diketuk
        ├── hashtag_autocomplete_field.dart
        ├── like_action.dart            # Tombol suka (tersambung API)
        ├── user_avatar.dart
        └── loading_indicator.dart
```

## Cara menjalankan

```bash
# dijalankan dari root repositori ini
flutter pub get
flutter run          # pilih device, atau: flutter run -d chrome
```

Alamat API diatur di `lib/core/constants.dart` (`ApiConstants.baseUrl`, default `http://localhost:3006`). Jalankan dulu server-nya supaya feed tidak berhenti di tampilan error.

## Pemetaan layar ke endpoint

| Layar / aksi | Endpoint |
| :--- | :--- |
| Login & daftar | `POST /api/v1/auth/login`, `POST /api/v1/auth/register` |
| Feed | `GET /api/v1/posts?page=&limit=` |
| Pencarian tulisan (judul, isi, penulis, hashtag) | `GET /api/v1/posts?q=` |
| Pencarian & topik populer | `GET /api/v1/categories/search`, `GET /api/v1/categories/trending` |
| Artikel per topik | `GET /api/v1/categories/:name/posts` |
| Detail, edit, hapus artikel | `GET/PUT/DELETE /api/v1/posts/:id` |
| Buat artikel (multipart) | `POST /api/v1/posts` |
| Suka / batal suka | `POST /api/v1/posts/:id/like`, `GET /api/v1/likes/me` |
| Komentar | `GET/POST /api/v1/posts/:id/comments`, `DELETE /api/v1/comments/:id` |
| Profil | `GET/PUT/DELETE /api/v1/users/me`, `PUT /api/v1/users/avatar` |

## Fitur yang belum didukung backend

Supaya tidak ada data palsu di layar, aksi berikut hanya memunculkan pesan bahwa fitur belum tersedia (`showNotAvailable` di `lib/core/ui_feedback.dart`):

| Aksi | Alasan |
| :--- | :--- |
| Simpan artikel (bookmark) & tab **Disimpan** | belum ada tabelnya di database |
| Mengikuti akun | belum ada tabel relasi follow |
| Bagikan artikel | belum ada mekanisme berbagi/tautan publik |
| Menu `...` pada kartu artikel | belum ada aksi tambahan di baliknya |
| Jumlah dilihat, bio, pengikut/mengikuti, centang biru | kolomnya tidak ada di tabel `users`/`posts` |

## Source code

Berikut isi asli 36 file Dart/konfigurasi pada folder ini, dikutip apa adanya. Folder platform (`android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`) tidak dikutip karena isinya boilerplate `flutter create` yang tidak diubah; `pubspec.lock` juga dilewati (isinya hash dependency).

### `pubspec.yaml`

```yaml
name: kata
description: "KATA — aplikasi blog berbasis mobile (Flutter)."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.12.2

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  http: ^1.6.0
  http_parser: ^4.1.2
  image_picker: ^1.2.3
  flutter_spinkit: ^5.2.0
  google_fonts: ^6.0.0
  shared_preferences: ^2.5.5
  cached_network_image: ^4.0.0
  flutter_secure_storage: ^11.1.1
  like_button: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```

### `analysis_options.yaml`

```yaml
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options
```

### `lib/core/api_client.dart`

```dart
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
        await http.get(uri, headers: _headers(withToken: withToken));
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String url, {
    Object? body,
    bool withToken = true,
  }) async {
    final response = await http.post(
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
    final response = await http.put(
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
    final response = await http.delete(
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

    final streamedResponse = await request.send();
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
```

### `lib/core/constants.dart`

```dart
/// Kumpulan alamat endpoint REST API dan nama header yang dipakai client.
///
/// Semua alamat ditulis di satu tempat supaya perubahan base URL atau versi
/// API tidak perlu diburu ke seluruh aplikasi.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:3006';

  // Auth
  static const String loginEndpoint = '$baseUrl/api/v1/auth/login';
  static const String registerEndpoint = '$baseUrl/api/v1/auth/register';
  static const String logoutEndpoint = '$baseUrl/api/v1/auth/logout';

  // Posts
  static const String postsEndpoint = '$baseUrl/api/v1/posts';
  static String likePostEndpoint(int postId) =>
      '$baseUrl/api/v1/posts/$postId/like';

  // Likes
  static const String myLikesEndpoint = '$baseUrl/api/v1/likes/me';

  // Users
  static const String meEndpoint = '$baseUrl/api/v1/users/me';
  static const String avatarEndpoint = '$baseUrl/api/v1/users/avatar';
  static const String changePasswordEndpoint =
      '$baseUrl/api/v1/users/me/password';
  static const String deleteAvatarEndpoint = '$baseUrl/api/v1/users/me/avatar';

  // Categories
  static const String categoriesSearchEndpoint = '$baseUrl/api/v1/categories/search';
  static const String categoriesTrendingEndpoint = '$baseUrl/api/v1/categories/trending';
  static String categoryPostsEndpoint(String categoryName) =>
      '$baseUrl/api/v1/categories/$categoryName/posts';

  // Comments
  static String postCommentsEndpoint(int postId) => '$baseUrl/api/v1/posts/$postId/comments';
  static String deleteCommentEndpoint(int commentId) => '$baseUrl/api/v1/comments/$commentId';

  // Header
  static const String contentTypeHeader = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
}
```

### `lib/core/formatters.dart`

```dart
/// Pemformat waktu yang dipakai bersama oleh kartu feed, halaman detail,
/// dan daftar komentar.
///
/// Dipisah dari layer widget supaya aturan tampilannya cuma ada di satu tempat
/// dan bisa diuji tanpa membangun UI.
String formatRelativeTime(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '';

  try {
    final date = DateTime.parse(isoString).toLocal();
    final diff = DateTime.now().difference(date);

    if (diff.isNegative) return 'baru saja';
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit';
    if (diff.inDays < 1) return '${diff.inHours} jam';
    if (diff.inDays < 7) return '${diff.inDays} hari';
    return '${date.day}/${date.month}/${date.year}';
  } catch (_) {
    // Tanggal dari server tidak terduga: tampilkan apa adanya daripada gagal.
    return isoString;
  }
}
```

### `lib/core/photo_picker.dart`

```dart
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Foto yang dipilih pengguna dari galeri.
///
/// Isinya sudah dibaca menjadi byte supaya bisa langsung dikirim sebagai
/// multipart tanpa perlu menyentuh file lagi di layer UI.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Membuka galeri untuk memilih satu foto.
///
/// Mengembalikan `null` kalau pengguna membatalkan pilihan, jadi pemanggil
/// cukup berhenti tanpa perlu menangani error khusus.
Future<PickedPhoto?> pickPhotoFromGallery({
  double? maxWidth,
  double? maxHeight,
  int imageQuality = 85,
}) async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    imageQuality: imageQuality,
  );
  if (picked == null) return null;

  return PickedPhoto(
    bytes: await picked.readAsBytes(),
    fileName: picked.name,
  );
}
```

### `lib/core/theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet monokrom (hitam–putih) untuk seluruh aplikasi:
/// latar hitam pekat, aksen putih, dan informasi kedua memakai abu-abu.
///
/// Catatan: tidak ada warna "semantik" (merah/hijau) di sini. Status penting
/// dibedakan lewat kontras (putih vs abu-abu), bukan lewat warna, supaya
/// tampilan tetap konsisten hitam-putih di seluruh aplikasi.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000); // hitam pekat
  static const Color surface = Color(0xFF0A0A0A); // bidang mengapung / sheet
  static const Color surfaceLight = Color(0xFF16181C); // input, chip, thumbnail
  static const Color border = Color(0xFF2F3336); // garis pemisah tipis

  /// Aksen utama = putih. Dipakai untuk tombol, hashtag, dan penanda aktif.
  static const Color primary = Color(0xFFFFFFFF);

  /// Teks di atas bidang putih (mis. label tombol) harus hitam agar terbaca.
  static const Color onPrimary = Color(0xFF000000);

  static const Color textPrimary = Color(0xFFE7E9EA); // teks utama
  static const Color textSecondary = Color(0xFF71767B); // teks kedua & ikon diam
  static const Color textMuted = Color(0xFF536471); // paling redup (timestamp)

  /// Warna untuk keadaan gagal. Tetap tanpa hue supaya seluruh aplikasi
  /// monokrom — pembedaannya lewat ikon dan teks, bukan warna.
  static const Color warning = Color(0xFFBDBDBD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.primary,
          onSecondary: AppColors.onPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.warning,
        ),

        // Typography
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),

        // Dialog (konfirmasi hapus, dsb.)
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),

        // Elevated Button — bidang putih, teks hitam
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.surfaceLight,
            disabledForegroundColor: AppColors.textMuted,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Tombol garis — garis & teks putih di atas hitam
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
        ),

        // Snackbar — bidang terang dengan teks hitam supaya kontras.
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: const TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
          actionTextColor: AppColors.onPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // Progress indicator mengikuti aksen putih
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.6,
          space: 0,
        ),

        // Nav bar & baris atas ikut hitam pekat supaya tampak menyatu.
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
        ),
      );
}
```

### `lib/core/ui_feedback.dart`

```dart
import 'package:flutter/material.dart';

/// Fitur yang belum ada di backend (follow, simpan postingan, dsb.) tidak
/// dibuatkan versi palsu di UI. Kalau diketuk, aplikasi cuma memberi tahu
/// bahwa fitur itu belum tersedia — jadi tidak ada data yang terlihat
/// tersimpan padahal tidak ada tabelnya.
void showNotAvailable(BuildContext context, String feature) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$feature belum tersedia di versi ini')),
    );
}

/// Dialog konfirmasi untuk aksi yang sulit dibatalkan (hapus, logout).
///
/// Aksi destruktif dibedakan lewat teks tebal, bukan warna merah, supaya tema
/// aplikasi tetap hitam-putih. Mengembalikan `true` bila pengguna menyetujui.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
```

### `lib/main.dart`

```dart
import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Memuat sesi yang tersimpan (token di secure storage, data akun di prefs)
  // sebelum UI pertama dibangun, supaya status login sudah benar sejak awal.
  await ApiClient.init();
  runApp(const KataApp());
}

/// Akar aplikasi: hanya menyiapkan tema dan daftar rute.
class KataApp extends StatelessWidget {
  const KataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KATA',
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### `lib/models/comment_model.dart`

```dart
import 'user_model.dart';

/// Satu komentar pada sebuah artikel (tabel `comments`).
///
/// Ditulis di file terpisah supaya tiap model punya satu file sendiri:
/// `user_model.dart`, `post_model.dart`, `comment_model.dart`.
class Comment {
  final int id;
  final int postId;
  final int userId;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final UserSummary? user;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      userId: json['userId'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['user'] is Map<String, dynamic>
          ? UserSummary.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
```

### `lib/models/post_model.dart`

```dart
import 'user_model.dart';

/// Artikel (tabel `posts`) beserta data ringkas penulisnya.
class Post {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final List<String>? categories;
  final String? imageUrl;
  final String? imagePublicId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final UserSummary? author;

  /// Jumlah suka artikel ini.
  final int likesCount;

  /// True bila artikel ini sudah disukai pengguna yang sedang login.
  final bool isLiked;

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.categories,
    this.imageUrl,
    this.imagePublicId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      categories: (json['categories'] as List?)?.cast<String>(),
      imageUrl: json['imageUrl'],
      imagePublicId: json['imagePublicId'],
      status: json['status'] ?? 'published',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      author: json['author'] is Map<String, dynamic>
          ? UserSummary.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      likesCount: asInt(json['likesCount']),
      isLiked: json['isLiked'] == true,
    );
  }

  /// Konversi angka dari API yang bisa datang sebagai int, num, atau string.
  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  /// Salinan post dengan status suka terbaru.
  /// Model sengaja dibuat immutable supaya perubahan data lewat satu jalur ini.
  Post copyWithLike({required bool liked, required int count}) {
    return Post(
      id: id,
      userId: userId,
      title: title,
      content: content,
      categories: categories,
      imageUrl: imageUrl,
      imagePublicId: imagePublicId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author,
      likesCount: count,
      isLiked: liked,
    );
  }

  String get hashtagsText => (categories ?? []).map((t) => '#$t').join(' ');

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasCategories => categories != null && categories!.isNotEmpty;

  /// Caption tanpa hashtag — dipakai di tempat yang tidak muat menampilkan
  /// seluruh teks (mis. thumbnail di grid profil).
  String get contentWithoutHashtags {
    final stripped = content
        .replaceAll(RegExp(r'#\w+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped;
  }

  /// Nama yang ditampilkan sebagai identitas penulis di kartu: nama akun.
  String get displayName => author?.username ?? 'Unknown';
}

/// Hasil pemanggilan endpoint like.
class LikeResult {
  final int postId;
  final bool liked;
  final int likesCount;

  LikeResult({
    required this.postId,
    required this.liked,
    required this.likesCount,
  });

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      postId: Post.asInt(json['postId']),
      liked: json['liked'] == true,
      likesCount: Post.asInt(json['likesCount']),
    );
  }
}
```

### `lib/models/user_model.dart`

```dart
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
```

### `lib/routes.dart`

```dart
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

/// Nama rute halaman yang dipakai bersama dan pembuat rutenya.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
```

### `lib/screens/category_posts_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'post_detail_screen.dart';

/// Daftar artikel yang memakai satu hashtag/topik tertentu.
///
/// Dipakai dari chip topik di feed, halaman trending, dan hashtag yang
/// diketuk di dalam caption.
class CategoryPostsScreen extends StatefulWidget {
  final String category;
  const CategoryPostsScreen({super.key, required this.category});

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _postService.getPostsByCategory(widget.category);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat: $e';
        _isLoading = false;
      });
    }
  }

  /// Perbarui satu artikel setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _posts = _posts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();
    });
  }

  Future<void> _openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (result != null && mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.category}'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Memuat...');
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorStateView(message: _errorMessage!, onRetry: _load),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: EmptyStateView(
          icon: Icons.tag_rounded,
          title: 'Belum ada tulisan di #${widget.category}',
          subtitle: 'Jadi yang pertama menulis soal topik ini.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        // PostCard sudah punya padding horizontalnya sendiri, jadi daftar ini
        // tidak boleh menambah lagi — kalau tidak, isinya menjorok ke kanan.
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _posts.length,
        // Baris artikel yang sama dengan feed: nama akun, caption (hashtag
        // putih tebal), gambar, lalu tombol suka yang tersambung ke database.
        itemBuilder: (context, index) => PostCard(
          post: _posts[index],
          onTap: () => _openDetail(_posts[index]),
          onTagTap: _openCategory,
          onPostChanged: _onPostChanged,
        ),
      ),
    );
  }

  /// Buka hashtag lain dari dalam caption (mis. #kuliner → #jakarta).
  void _openCategory(String tag) {
    if (tag == widget.category) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }
}
```

### `lib/screens/create_post_screen.dart`

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_autocomplete_field.dart';
import '../widgets/user_avatar.dart';

/// Layar buat postingan — dibuka dari tombol "+" di nav bar, bukan sebagai tab.
///
/// Susunannya: batal di kiri, tombol Posting di kanan, isi tulisan sebagai
/// fokus utama, dan toolbar kecil di bawah untuk lampiran gambar + sisa
/// karakter.
///
/// Nilai balik `Navigator.pop(true)` menandakan postingan berhasil dibuat,
/// supaya pemanggil (feed) tahu harus memuat ulang.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const int _maxChars = 1000;

  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();

  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _captionController.removeListener(_onTextChanged);
    _captionController.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  int get _length => _captionController.text.trim().length;

  bool get _canPost => _length > 0 && _length <= _maxChars && !_isLoading;

  // =========================
  // GAMBAR (opsional)
  // =========================
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
    });
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  // =========================
  // SIMPAN
  // =========================
  Future<void> _submit() async {
    if (!ApiClient.isLoggedIn) {
      _showSnack('Login dulu untuk membuat postingan');
      return;
    }

    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      _showSnack('Tulisan tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _postService.createPost(
        caption: caption,
        userId: ApiClient.userId ?? 1,
        fileBytes: _imageBytes,
        fileName: _imageName,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Gagal memposting: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxChars - _length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text(
            'Batal',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _canPost ? _submit : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Posting'),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl: ApiClient.avatarUrl,
                    username: ApiClient.username ?? '?',
                    size: 42,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HashtagAutocompleteField(
                          controller: _captionController,
                          hintText: 'Lagi mikirin apa?',
                          helperText: 'Ketik # untuk lihat saran topik',
                          minLines: 6,
                          maxLines: 10,
                          enabled: !_isLoading,
                        ),
                        if (_imageBytes != null) ...[
                          const SizedBox(height: 12),
                          _buildImagePreview(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomToolbar(remaining),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Semantics(
            button: true,
            label: 'Hapus gambar',
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.6),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(int remaining) {
    final progress = (_length / _maxChars).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
              color: AppColors.primary,
              tooltip: _imageBytes == null ? 'Tambah gambar' : 'Ganti gambar',
            ),
            const Spacer(),
            if (remaining < 200)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '$remaining',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.4,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining < 0 ? AppColors.textMuted : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
```

### `lib/screens/edit_post_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_autocomplete_field.dart';

/// Menyunting artikel yang sudah ada. Mengembalikan artikel hasil perubahan
/// lewat `Navigator.pop` supaya halaman detail bisa langsung memperbarui diri.
class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final PostService _postService = PostService();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.length < 3) {
      _showSnack('Judul minimal 3 karakter');
      return;
    }
    if (content.length < 10) {
      _showSnack('Konten minimal 10 karakter');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await _postService.updatePost(
        postId: widget.post.id!,
        title: title,
        content: content,
      );
      if (!mounted) return;
      _showSnack('Postingan berhasil diupdate');
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Gagal: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Postingan'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Judul',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                hintText: 'Judul postingan',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 20),

            const Text(
              'Konten',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            HashtagAutocompleteField(
              controller: _contentController,
              hintText: 'Tulis konten... #kuliner #jakarta',
              helperText: 'Ketik # untuk lihat saran hashtag',
              minLines: 6,
              maxLines: 10,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor:
                    _isSaving ? AppColors.surfaceLight : AppColors.primary,
              ),
              // Tombol memakai bidang putih, jadi isinya harus hitam.
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Menyimpan...',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                      ],
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimary,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### `lib/screens/edit_profile_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/photo_picker.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/avatar_options_sheet.dart';
import '../widgets/user_avatar.dart';

/// Halaman menyunting profil: foto, username, dan email.
///
/// Sengaja dipisah dari halaman Pengaturan. Pengaturan mengurus hal akun yang
/// sifatnya teknis (password, sesi, hapus akun), sedangkan halaman ini murni
/// data profil yang tampil ke orang lain.
///
/// Mengembalikan [User] terbaru lewat `Navigator.pop` bila ada perubahan.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.user});

  final User? user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  late User? _user;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _usernameController =
        TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================
  // FOTO PROFIL
  // =========================
  /// Avatar diketuk → muncul pilihan ganti / hapus foto.
  Future<void> _onAvatarTap() async {
    if (_isBusy) return;

    await showAvatarOptionsSheet(
      context,
      onChangePhoto: _changePhoto,
      onRemovePhoto: (_user?.hasAvatar ?? false) ? _removeAvatar : null,
    );
  }

  Future<void> _changePhoto() async {
    final photo = await pickPhotoFromGallery(maxWidth: 512, maxHeight: 512);
    if (photo == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated =
          await _userService.updateAvatar(photo.bytes, photo.fileName);
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Foto profil diperbarui');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal mengunggah foto: $e');
    }
  }

  Future<void> _removeAvatar() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus foto profil?',
      message: 'Avatar akan kembali memakai inisial username.',
      confirmLabel: 'Hapus',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated = await _userService.deleteAvatar();
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Foto profil dihapus');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal menghapus foto: $e');
    }
  }

  // =========================
  // SIMPAN
  // =========================
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isBusy = true);
    try {
      final updated = await _userService.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
      );
      await ApiClient.updateProfileCache(newUsername: updated.username);
      if (!mounted) return;
      setState(() {
        _user = updated;
        _isBusy = false;
      });
      _showSnack('Profil diperbarui');
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal memperbarui profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit profil'),
        actions: [
          TextButton(
            onPressed: _isBusy ? null : _save,
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
        bottom: _isBusy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                ),
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _onAvatarTap,
                  child: Stack(
                    children: [
                      UserAvatar(
                        imageUrl: user?.avatarUrl ?? ApiClient.avatarUrl,
                        username: user?.username ?? ApiClient.username ?? '?',
                        size: 96,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.6,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ketuk foto untuk mengganti atau menghapusnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _usernameController,
                enabled: !_isBusy,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Username wajib diisi';
                  if (text.length < 3) return 'Username minimal 3 karakter';
                  if (text.length > 50) return 'Username maksimal 50 karakter';
                  // Pola sama dengan validasi di server.
                  if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(text)) {
                    return 'Hanya huruf, angka, titik, _ dan -';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_isBusy,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isBusy ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Simpan perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### `lib/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/post_model.dart';
import '../routes.dart';
import '../services/post_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'category_posts_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Kerangka utama aplikasi.
///
/// Nav bar bawah cuma punya 3 item: Beranda, tombol "+" di tengah, dan Profil.
/// Tombol "+" bukan tab — dia membuka layar buat postingan sebagai halaman
/// baru (nav bar ikut tertutup), jadi isi tab tetap cuma dua.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();

  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  int _currentIndex = 0;

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Topik yang muncul di baris filter feed (dari /categories/trending).
  List<String> _topics = [];
  String? _activeTag; // null = semua topik

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadTopics();
  }

  // =========================
  // DATA
  // =========================
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // `isLiked` per artikel sudah dikirim server (middleware optionalAuth),
      // jadi feed hanya butuh satu request untuk tahu status suka semuanya.
      final posts = await _postService.getPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat postingan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTopics() async {
    try {
      final data = await _postService.getTrendingCategories();
      if (!mounted) return;
      setState(() {
        _topics = data
            .map((c) => c['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .take(10)
            .toList();
      });
    } catch (_) {
      // Filter topik bersifat opsional: kalau gagal, feed tetap tampil semua.
    }
  }

  Future<void> _refreshPosts() async {
    await Future.wait([_loadPosts(), _loadTopics()]);
  }

  List<Post> get _visiblePosts {
    if (_activeTag == null) return _posts;
    final tag = _activeTag!.toLowerCase();
    return _posts
        .where((post) =>
            (post.categories ?? []).any((c) => c.toLowerCase() == tag))
        .toList();
  }

  /// Ganti satu artikel di daftar setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _posts = _posts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();
    });
  }

  // =========================
  // NAVIGASI
  // =========================
  Future<void> _onTabChanged(int index) async {
    if (index == 1 && !ApiClient.isLoggedIn) {
      final loggedIn = await Navigator.pushNamed(context, AppRoutes.login);
      if (!mounted) return;
      if (loggedIn != true) return;
    }

    setState(() => _currentIndex = index);
    if (index == 1) _profileKey.currentState?.reload();
  }

  void _onLoggedOut() {
    setState(() => _currentIndex = 0);
    _loadPosts();
  }

  /// Tombol "+": buka layar buat postingan sebagai halaman penuh.
  Future<void> _openCompose() async {
    if (!ApiClient.isLoggedIn) {
      final loggedIn = await Navigator.pushNamed(context, AppRoutes.login);
      if (!mounted || loggedIn != true) return;
    }

    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(),
        fullscreenDialog: true,
      ),
    );

    if (posted == true && mounted) {
      setState(() => _currentIndex = 0);
      await _loadPosts();
      _profileKey.currentState?.reload();
    }
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }

  Future<void> _openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (result != null && mounted) _loadPosts();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Judul mengikuti tab yang sedang dibuka, bukan nama aplikasi terus.
        title: _currentIndex == 0
            ? const Text(
                'KATA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: AppColors.primary,
                ),
              )
            : const Text('Profil'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _openSearch,
              tooltip: 'Cari',
            ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadPosts,
              tooltip: 'Refresh',
            ),
        ],
        bottom: _currentIndex == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(54),
                child: _TopicFilterBar(
                  topics: _topics,
                  activeTag: _activeTag,
                  onSelected: (tag) => setState(() => _activeTag = tag),
                ),
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFeedTab(),
          ProfileScreen(
            key: _profileKey,
            onLoggedOut: _onLoggedOut,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: _onTabChanged,
        onComposePressed: _openCompose,
      ),
    );
  }

  // =========================
  // FEED
  // =========================
  Widget _buildFeedTab() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Memuat postingan...');
    }

    if (_errorMessage != null) {
      return Center(
        child: ErrorStateView(
          message: _errorMessage!,
          onRetry: _loadPosts,
        ),
      );
    }

    final posts = _visiblePosts;

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: posts.isEmpty
          ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _activeTag == null
                        ? const EmptyStateView(
                            icon: Icons.photo_library_outlined,
                            title: 'Belum ada postingan',
                            subtitle: 'Tap tombol + untuk mulai menulis.',
                          )
                        : EmptyStateView(
                            icon: Icons.tag_rounded,
                            title: 'Belum ada tulisan di topik ini',
                            subtitle:
                                'Jadi yang pertama menulis soal #${_activeTag!}.',
                          ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(
                post: posts[index],
                onTap: () => _openDetail(posts[index]),
                onTagTap: _openCategory,
                onPostChanged: _onPostChanged,
              ),
            ),
    );
  }
}

/// Baris filter topik di bawah AppBar: "Semua" + hashtag yang sedang tren.
class _TopicFilterBar extends StatelessWidget {
  const _TopicFilterBar({
    required this.topics,
    required this.activeTag,
    required this.onSelected,
  });

  final List<String> topics;
  final String? activeTag;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: topics.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TopicChip(
              label: 'Semua',
              selected: activeTag == null,
              onTap: () => onSelected(null),
            );
          }
          final tag = topics[index - 1];
          return _TopicChip(
            label: '#$tag',
            selected: activeTag?.toLowerCase() == tag.toLowerCase(),
            onTap: () => onSelected(tag),
          );
        },
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
```

### `lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../routes.dart';
import '../services/auth_service.dart';

/// Halaman masuk. Mengembalikan `true` lewat `Navigator.pop` bila berhasil,
/// supaya pemanggil tahu sesi sudah aktif.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      // Halaman pemanggil menunggu nilai `true` sebagai tanda berhasil login.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    }
  }

  Future<void> _goToRegister() async {
    await Navigator.pushNamed(context, AppRoutes.register);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol kembali dibiarkan otomatis supaya pengguna bisa membatalkan.
      appBar: AppBar(
        title: const Text('Masuk'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke KATA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gunakan email dan password akunmu.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Format email salah';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (v.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol masuk. Saat memproses, tombol tetap putih supaya
                // spinner hitam di atasnya masih terbaca.
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    disabledBackgroundColor:
                        _isLoading ? AppColors.primary : AppColors.surfaceLight,
                    disabledForegroundColor:
                        _isLoading ? AppColors.onPrimary : AppColors.textMuted,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Memuat...',
                              style: TextStyle(color: AppColors.onPrimary),
                            ),
                          ],
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 12),

                // Tautan ke halaman pendaftaran
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _goToRegister,
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### `lib/screens/post_detail_screen.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/hashtag_text.dart';
import '../widgets/like_action.dart';
import '../widgets/user_avatar.dart';
import 'category_posts_screen.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Post _post;
  bool _isDeleting = false;
  bool _isLoadingComments = true;
  bool _isSendingComment = false;

  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isOwner {
    if (ApiClient.userId == null) return false;
    return _post.userId == ApiClient.userId;
  }

  bool get _canComment => ApiClient.isLoggedIn;

  // =========================
  // LIKE
  // =========================
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() => _post = updated);
  }

  // =========================
  // COMMENTS
  // =========================
  Future<void> _loadComments() async {
    if (_post.id == null) return;
    setState(() => _isLoadingComments = true);
    try {
      final list = await _postService.getComments(_post.id!);
      if (!mounted) return;
      setState(() {
        _comments = list;
        _isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    if (!_canComment) {
      _showSnack('Login dulu untuk berkomentar');
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) {
      _showSnack('Komentar gak boleh kosong');
      return;
    }

    setState(() => _isSendingComment = true);
    try {
      final newComment = await _postService.createComment(
        postId: _post.id!,
        userId: ApiClient.userId!,
        comment: text,
      );
      if (!mounted) return;
      setState(() {
        _comments.insert(0, newComment);
        _isSendingComment = false;
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _showSnack('Komentar terkirim');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingComment = false);
      _showSnack('Gagal kirim komentar: $e');
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus komentar?',
      confirmLabel: 'Hapus',
    );

    if (confirm != true) return;

    try {
      await _postService.deleteComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
      });
      _showSnack('Komentar dihapus');
    } catch (e) {
      _showSnack('Gagal hapus: $e');
    }
  }

  // =========================
  // EDIT / DELETE POST
  // =========================
  Future<void> _openEdit() async {
    final result = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => EditPostScreen(post: _post)),
    );
    if (result != null && mounted) {
      setState(() => _post = result);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus postingan?',
      message: 'Postingan ini akan dihapus permanen.',
      confirmLabel: 'Hapus',
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _postService.deletePost(_post.id!);
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
      _showSnack('Postingan berhasil dihapus');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showSnack('Gagal menghapus: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }

  void _scrollToComments() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postingan'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
        actions: [
          if (_isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit',
              onPressed: _isDeleting ? null : _openEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Hapus',
              onPressed: _isDeleting ? null : _confirmDelete,
            ),
          ],
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostContent(),
                        const Divider(height: 1, color: AppColors.border),
                        _buildCommentsSection(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _buildCommentInput(),
              ],
            ),
    );
  }

  // =========================
  // POST CONTENT
  // =========================
  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris akun: @username, waktu, dan tombol Ikuti di kanan.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: _post.author?.avatarUrl,
                username: _post.displayName,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '@${_post.displayName} · ${formatRelativeTime(_post.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Tidak ada tombol Ikuti di artikel sendiri.
              if (!_isOwner)
                OutlinedButton(
                  onPressed: () => showNotAvailable(context, 'Mengikuti akun'),
                  child: const Text('Ikuti'),
                ),
            ],
          ),
        ),

        // Isi tulisan; hashtag jadi teks putih tebal yang bisa diketuk.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: HashtagText(
            text: _post.content,
            fontSize: 16.5,
            color: AppColors.textPrimary,
            onTagTap: _openCategory,
          ),
        ),

        // Gambar — dibulatkan dan diberi jarak, konsisten dengan kartu feed.
        if (_post.hasImage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: _post.imageUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, _) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Topik yang menempel di artikel (kolom `categories`).
        if (_post.hasCategories)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _post.categories!
                  .map(
                    (tag) => _TagChip(
                      label: tag,
                      onTap: () => _openCategory(tag),
                    ),
                  )
                  .toList(),
            ),
          ),

        // Action row
        _buildActionRow(),
      ],
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          _DetailAction(
            icon: Icons.mode_comment_outlined,
            label: _comments.isEmpty ? null : '${_comments.length}',
            tooltip: 'Komentar',
            onTap: _scrollToComments,
          ),
          const SizedBox(width: 20),
          LikeAction(
            post: _post,
            onPostChanged: _onPostChanged,
            iconSize: 20,
          ),
          const Spacer(),
          _DetailAction(
            icon: Icons.bookmark_border_rounded,
            tooltip: 'Simpan',
            onTap: () => showNotAvailable(context, 'Menyimpan postingan'),
          ),
          const SizedBox(width: 10),
          _DetailAction(
            icon: Icons.ios_share_rounded,
            tooltip: 'Bagikan',
            onTap: () => showNotAvailable(context, 'Membagikan postingan'),
          ),
        ],
      ),
    );
  }

  // =========================
  // COMMENTS SECTION
  // =========================
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (!_isLoadingComments && _comments.isNotEmpty)
                Text(
                  '${_comments.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (_isLoadingComments)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
        else if (_comments.isEmpty)
          _buildEmptyComments()
        else
          Column(
            children:
                _comments.map((c) => _buildCommentItem(c)).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyComments() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 36,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada komentar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final user = comment.user;
    final canDelete = ApiClient.userId != null &&
        (comment.userId == ApiClient.userId ||
            _post.userId == ApiClient.userId);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: user?.avatarUrl,
            username: user?.username ?? '?',
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.username ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatRelativeTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                HashtagText(
                  text: comment.comment,
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                  onTagTap: _openCategory,
                ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              onPressed: () => _deleteComment(comment),
              icon: const Icon(Icons.more_horiz_rounded, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Hapus',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    if (!_canComment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Login dulu untuk berkomentar',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result =
                      await Navigator.pushNamed(context, '/login');
                  if (result == true && mounted) setState(() {});
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !_isSendingComment,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendComment(),
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSendingComment
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Semantics(
                    button: true,
                    label: 'Kirim komentar',
                    child: GestureDetector(
                      onTap: _sendComment,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Ikon aksi di bawah artikel pada halaman detail.
class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.tooltip,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip topik (hashtag) yang bisa diketuk menuju daftar artikel topik itu.
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '#$label',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
```

### `lib/screens/profile_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/photo_picker.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/avatar_options_sheet.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import '../widgets/user_avatar.dart';
import 'category_posts_screen.dart';
import 'edit_profile_screen.dart';
import 'post_detail_screen.dart';
import 'settings_screen.dart';

/// Tab profil: header akun, lalu tiga tab (Tulisan / Disukai / Disimpan)
/// dan daftar artikel dalam bentuk linimasa — bukan grid.
///
/// Catatan: tabel `bookmark` belum ada di database, jadi tab **Disimpan** cuma
/// memberi tahu bahwa fiturnya belum tersedia dan tidak menampilkan data palsu.
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLoggedOut;

  const ProfileScreen({super.key, this.onLoggedOut});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  static const int _tabPosts = 0;
  static const int _tabLiked = 1;
  static const int _tabSaved = 2;

  int _tab = _tabPosts;

  bool _isLoadingPosts = false;
  bool _isUploadingPhoto = false;
  List<Post> _allPosts = [];
  Set<int> _likedPostIds = {};
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    reload();
    ApiClient.authNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    ApiClient.authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      _allPosts = [];
      _likedPostIds = {};
      _currentUser = null;
      _tab = _tabPosts;
    });
    reload();
  }

  Future<void> reload() async {
    await Future.wait([_loadCurrentUser(), _loadPosts()]);
  }

  // =========================
  // DATA
  // =========================
  Future<void> _loadCurrentUser() async {
    if (!ApiClient.isLoggedIn) return;
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() => _currentUser = user);
      // Sync ke cache juga
      await ApiClient.updateAvatarCache(user.avatarUrl);
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> _loadPosts() async {
    if (!ApiClient.isLoggedIn) {
      if (mounted) {
        setState(() {
          _allPosts = [];
          _likedPostIds = {};
          _isLoadingPosts = false;
        });
      }
      return;
    }

    setState(() => _isLoadingPosts = true);
    try {
      // Dua request: daftar artikel + id artikel yang disukai (endpoint
      // /likes/me). `isLiked` di feed hanya berlaku untuk artikel di halaman
      // itu, jadi id-nya diambil terpisah supaya tab Disukai akurat.
      final results = await Future.wait([
        _postService.getPosts(),
        _postService.getMyLikedPostIds(),
      ]);

      final posts = results[0] as List<Post>;
      final likedIds = results[1] as Set<int>;

      if (!mounted) return;
      setState(() {
        _allPosts = posts;
        _likedPostIds = likedIds;
        _isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPosts = false);
    }
  }

  List<Post> get _visiblePosts {
    switch (_tab) {
      case _tabLiked:
        return _allPosts
            .where((p) => p.id != null && _likedPostIds.contains(p.id))
            .toList();
      case _tabPosts:
      default:
        if (ApiClient.userId == null) return const [];
        return _allPosts.where((p) => p.userId == ApiClient.userId).toList();
    }
  }

  /// Ganti satu artikel di daftar setelah status sukanya berubah.
  void _onPostChanged(Post updated) {
    if (!mounted) return;
    setState(() {
      _allPosts = _allPosts
          .map((post) => post.id == updated.id ? updated : post)
          .toList();

      final id = updated.id;
      if (id != null) {
        if (updated.isLiked) {
          _likedPostIds.add(id);
        } else {
          _likedPostIds.remove(id);
        }
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // =========================
  // FOTO PROFIL
  // =========================
  /// Avatar diketuk → muncul pilihan ganti / hapus foto.
  Future<void> _onAvatarTap() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }
    if (_isUploadingPhoto) return;

    final hasPhoto = _currentUser?.hasAvatar ??
        (ApiClient.avatarUrl?.isNotEmpty ?? false);

    await showAvatarOptionsSheet(
      context,
      onChangePhoto: _changePhoto,
      onRemovePhoto: hasPhoto ? _removePhoto : null,
    );
  }

  Future<void> _changePhoto() async {
    final photo = await pickPhotoFromGallery(maxWidth: 512, maxHeight: 512);
    if (photo == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final updated =
          await _userService.updateAvatar(photo.bytes, photo.fileName);
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _currentUser = updated;
        _isUploadingPhoto = false;
      });
      _showSnack('Foto profil diperbarui');
      await _loadPosts();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Gagal mengunggah foto: $e');
    }
  }

  Future<void> _removePhoto() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus foto profil?',
      message: 'Avatar akan kembali memakai inisial username.',
      confirmLabel: 'Hapus',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final updated = await _userService.deleteAvatar();
      await ApiClient.updateAvatarCache(updated.avatarUrl);
      if (!mounted) return;
      setState(() {
        _currentUser = updated;
        _isUploadingPhoto = false;
      });
      _showSnack('Foto profil dihapus');
      await _loadPosts();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      _showSnack('Gagal menghapus foto: $e');
    }
  }

  // =========================
  // EDIT PROFIL & PENGATURAN
  // =========================
  /// Menyunting data profil (foto, username, email).
  Future<void> _openEditProfile() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }

    final updated = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _currentUser),
      ),
    );

    if (!mounted) return;
    if (updated != null) setState(() => _currentUser = updated);
    await reload();
  }

  /// Pengaturan akun: password, sesi, dan info aplikasi.
  Future<void> _openSettings() async {
    if (!ApiClient.isLoggedIn) {
      await _goToLogin();
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(user: _currentUser),
      ),
    );

    if (!mounted) return;

    if (result == 'logout') {
      _showSnack('Berhasil logout');
      widget.onLoggedOut?.call();
    } else if (result == 'deleted') {
      _showSnack('Akun berhasil dihapus');
      widget.onLoggedOut?.call();
    } else {
      await reload();
    }
  }

  Future<void> _goToLogin() async {
    await Navigator.pushNamed(context, AppRoutes.login);
  }

  Future<void> _openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (result != null && mounted) _loadPosts();
  }

  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPostsScreen(category: tag),
      ),
    );
  }

  void _onTabSelected(int index) {
    // Tab Disimpan belum punya tabelnya, jadi tidak pernah jadi tab aktif.
    if (index == _tabSaved) return;
    setState(() => _tab = index);
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ApiClient.authNotifier,
      builder: (context, isLoggedIn, _) {
        return ValueListenableBuilder<int>(
          valueListenable: ApiClient.profileNotifier,
          builder: (context, _, _) {
            if (!isLoggedIn) return _buildLoggedOut();

            final posts = _visiblePosts;

            return RefreshIndicator(
              onRefresh: reload,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ProfileTabBarDelegate(
                      activeIndex: _tab,
                      onChanged: _onTabSelected,
                      onUnavailable: (label) => showNotAvailable(context, label),
                    ),
                  ),
                  if (_isLoadingPosts)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (posts.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyTab(_tab == _tabLiked),
                    )
                  else
                    SliverList.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onTap: () => _openDetail(post),
                          onTagTap: _openCategory,
                          onPostChanged: _onPostChanged,
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoggedOut() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Padding horizontal 16 supaya sejajar dengan header profil dan feed.
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      children: [
        Center(
          child: UserAvatar(
            imageUrl: null,
            username: 'Tamu',
            size: 96,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '@tamu',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Login untuk menulis, menyukai, dan berkomentar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _goToLogin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Login'),
        ),
      ],
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    final user = _currentUser;
    final username = user?.username ?? ApiClient.username ?? 'Pengguna';
    final email = user?.email;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _onAvatarTap,
                child: Stack(
                  children: [
                    UserAvatar(
                      imageUrl: user?.avatarUrl ?? ApiClient.avatarUrl,
                      username: username,
                      size: 84,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.border, width: 0.6),
                        ),
                        child: _isUploadingPhoto
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _openSettings,
                tooltip: 'Pengaturan',
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '@$username',
            style:
                const TextStyle(fontSize: 14.5, color: AppColors.textSecondary),
          ),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _openEditProfile,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
            ),
            child: const Text('Edit profil'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(bool isLikedTab) {
    return EmptyStateView(
      icon: isLikedTab ? Icons.favorite_border_rounded : Icons.edit_note_rounded,
      title: isLikedTab
          ? 'Belum ada postingan yang kamu sukai'
          : 'Belum ada tulisan',
      subtitle: isLikedTab
          ? 'Tap ikon hati di postingan untuk melihatnya di sini.'
          : 'Tap tombol + untuk menulis yang pertama.',
    );
  }
}

/// Tab bar lengket (pinned) dengan garis penanda di bawah tab aktif.
class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  _ProfileTabBarDelegate({
    required this.activeIndex,
    required this.onChanged,
    required this.onUnavailable,
  });

  final int activeIndex;
  final ValueChanged<int> onChanged;

  /// Dipanggil untuk tab yang belum punya dukungan backend (Disimpan).
  final ValueChanged<String> onUnavailable;

  static const List<String> _labels = ['Tulisan', 'Disukai', 'Disimpan'];
  static const int _unavailableIndex = 2;

  @override
  double get minExtent => 49;

  @override
  double get maxExtent => 49;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_labels.length, (index) {
                final active = index == activeIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => index == _unavailableIndex
                        ? onUnavailable(_labels[index])
                        : onChanged(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            color: active
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: active ? 44 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 0.6),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarDelegate oldDelegate) =>
      oldDelegate.activeIndex != activeIndex;
}
```

### `lib/screens/register_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';

/// Halaman pendaftaran akun baru.
///
/// Kalau server langsung mengembalikan token, sesi ikut aktif dan halaman
/// pemanggil menerima `true` lewat `Navigator.pop`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      // Halaman pemanggil menunggu nilai `true` sebagai tanda berhasil daftar.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tombol kembali dibiarkan otomatis supaya pengguna bisa membatalkan.
      appBar: AppBar(
        title: const Text('Daftar'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.6),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Buat akun KATA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cukup username, email, dan password.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Nama akun
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'username',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    if (v.trim().length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!v.contains('@')) return 'Format email salah';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    // Aturan ini disamakan dengan validasi server (Zod).
                    if (v.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                      return 'Password harus memuat huruf';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(v)) {
                      return 'Password harus memuat angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol daftar. Saat memproses, tombol tetap putih supaya
                // spinner hitam di atasnya masih terbaca.
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    disabledBackgroundColor:
                        _isLoading ? AppColors.primary : AppColors.surfaceLight,
                    disabledForegroundColor:
                        _isLoading ? AppColors.onPrimary : AppColors.textMuted,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Memuat...',
                              style: TextStyle(color: AppColors.onPrimary),
                            ),
                          ],
                        )
                      : const Text('Daftar'),
                ),
                const SizedBox(height: 12),

                // Tautan balik ke halaman masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### `lib/screens/search_screen.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/state_views.dart';
import 'category_posts_screen.dart';
import 'post_detail_screen.dart';

/// Halaman pencarian: ketik kata kunci, hasilnya langsung tersaring.
///
/// Dua jenis hasil ditampilkan sekaligus:
/// - **topik** — dari `GET /categories/search?q=`
/// - **tulisan** — dari `GET /posts?q=`, disaring di server pada judul, isi,
///   nama penulis, dan hashtag di dalam caption
///
/// Karena penyaringan terjadi di server, hasilnya menjangkau seluruh artikel di
/// database — bukan hanya yang sedang tampil di layar. Selama kolom pencarian
/// masih kosong, halaman ini menampilkan topik populer sebagai titik awal.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Batas maksimum `limit` yang diterima server.
  static const int _resultLimit = 50;

  final PostService _postService = PostService();
  final TextEditingController _queryController = TextEditingController();

  Timer? _debounce;

  List<Map<String, dynamic>> _trending = [];
  List<String> _topicResults = [];
  List<Post> _postResults = [];

  bool _isLoadingTopics = true;
  bool _isSearching = false;
  String? _loadError;
  String? _searchError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  // =========================
  // DATA
  // =========================
  /// Topik populer sebagai titik awal sebelum pengguna mengetik apa pun.
  Future<void> _loadTrending() async {
    setState(() {
      _isLoadingTopics = true;
      _loadError = null;
    });

    try {
      final trending = await _postService.getTrendingCategories();
      if (!mounted) return;
      setState(() {
        _trending = trending;
        _isLoadingTopics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat data: $e';
        _isLoadingTopics = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    setState(() => _query = query);

    // Setiap ketukan membatalkan permintaan yang tertunda, jadi server hanya
    // menerima kata kunci yang benar-benar ditinggalkan pengguna.
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _topicResults = [];
        _postResults = [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await Future.wait([
        _postService.searchCategories(query),
        _postService.getPosts(limit: _resultLimit, query: query),
      ]);

      // Kalau pengguna sudah mengetik kata kunci lain, hasil ini sudah tidak
      // relevan — dibuang supaya tidak menimpa hasil yang lebih baru.
      if (!mounted || query != _query) return;

      setState(() {
        _topicResults = results[0] as List<String>;
        _postResults = results[1] as List<Post>;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted || query != _query) return;
      setState(() {
        _topicResults = [];
        _postResults = [];
        _searchError = 'Gagal mencari: $e';
        _isSearching = false;
      });
    }
  }

  void _clearQuery() {
    _queryController.clear();
    _onQueryChanged('');
  }

  // =========================
  // NAVIGASI
  // =========================
  void _openCategory(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPostsScreen(category: tag)),
    );
  }

  Future<void> _openDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          style: const TextStyle(fontSize: 15.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceLight,
            hintText: 'Cari tulisan atau topik',
            hintStyle: const TextStyle(
              fontSize: 15.5,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: _clearQuery,
                    tooltip: 'Bersihkan',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.6, color: AppColors.border),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      if (_isLoadingTopics) {
        return const LoadingIndicator(message: 'Memuat...');
      }

      if (_loadError != null) {
        return Center(
          child: ErrorStateView(message: _loadError!, onRetry: _loadTrending),
        );
      }

      return _buildTrendingList();
    }

    if (_searchError != null) {
      return Center(
        child: ErrorStateView(
          message: _searchError!,
          onRetry: () => _runSearch(_query),
        ),
      );
    }

    // Masih menunggu jawaban server dan belum ada hasil lama untuk ditampilkan.
    if (_isSearching && _postResults.isEmpty && _topicResults.isEmpty) {
      return const LoadingIndicator(message: 'Mencari...');
    }

    final hasNoResult = _postResults.isEmpty && _topicResults.isEmpty;

    if (hasNoResult && _isSearching) {
      return const LoadingIndicator(message: 'Mencari...');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (_topicResults.isNotEmpty) ...[
          const _SectionLabel('Topik'),
          ..._topicResults.map(
            (tag) => _TopicRow(name: tag, onTap: () => _openCategory(tag)),
          ),
        ],
        if (_postResults.isNotEmpty) ...[
          const _SectionLabel('Tulisan'),
          ..._postResults.map(
            (post) => PostCard(
              post: post,
              onTap: () => _openDetail(post),
              onTagTap: _openCategory,
            ),
          ),
        ],
        if (hasNoResult)
          Center(
            child: EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'Tidak ada hasil untuk "$_query"',
              subtitle: 'Coba kata kunci lain, atau cek ejaannya.',
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingList() {
    if (_trending.isEmpty) {
      return const Center(
        child: EmptyStateView(
          icon: Icons.search_rounded,
          title: 'Cari tulisan atau topik',
          subtitle: 'Ketik kata kunci di kolom atas untuk mulai mencari.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _SectionLabel('Topik populer'),
        ..._trending.map((category) {
          final name = category['name']?.toString() ?? '';
          final count = Post.asInt(category['post_count']);
          if (name.isEmpty) return const SizedBox.shrink();

          return _TopicRow(
            name: name,
            postCount: count,
            onTap: () => _openCategory(name),
          );
        }),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Satu baris topik: #nama + jumlah tulisan.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.name, required this.onTap, this.postCount});

  final String name;
  final VoidCallback onTap;
  final int? postCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#$name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (postCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$postCount tulisan',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
```

### `lib/screens/settings_screen.dart`

```dart
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

/// Halaman pengaturan akun (dibuka dari ikon gerigi di tab Profil).
///
/// Isinya hal-hal teknis akun — ganti password, sesi, dan info aplikasi.
/// Penyuntingan data profil (foto, username, email) ada di halaman terpisah,
/// `EditProfileScreen`.
///
/// Barisnya ditulis sendiri di file ini, bukan memakai paket pihak ketiga,
/// supaya gaya daftarnya sama dengan layar lain (garis pemisah tipis, tanpa
/// warna aksen selain putih).
///
/// Nilai kembalian (`Navigator.pop`):
/// - `'logout'`  → pengguna keluar, halaman pemanggil mereset state.
/// - `'deleted'` → akun dihapus permanen.
/// - `null`      → tidak ada perubahan sesi.
class SettingsScreen extends StatefulWidget {
  final User? user;

  const SettingsScreen({super.key, this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _appVersion = '1.0.0';

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  late User? _user;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!ApiClient.isLoggedIn) return;
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() => _user = user);
      await ApiClient.updateAvatarCache(user.avatarUrl);
    } catch (_) {
      // Gagal memuat profil tidak menghalangi halaman pengaturan tampil.
    }
  }

  // =========================
  // GANTI PASSWORD
  // =========================
  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password lama'),
                validator: (value) => (value ?? '').isEmpty
                    ? 'Password lama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password baru'),
                validator: (value) {
                  final text = value ?? '';
                  if (text.length < 8) return 'Minimal 8 karakter';
                  if (!RegExp(r'[A-Za-z]').hasMatch(text)) {
                    return 'Harus memuat huruf';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(text)) {
                    return 'Harus memuat angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Ulangi password baru'),
                validator: (value) => value != newController.text
                    ? 'Konfirmasi tidak sama'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (submitted != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await _userService.changePassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Password berhasil diganti');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal mengganti password: $e');
    } finally {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  // =========================
  // LOGOUT & HAPUS AKUN
  // =========================
  /// Menyunting data profil; daftar di halaman ini ikut disegarkan setelahnya.
  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _user),
      ),
    );

    if (!mounted) return;
    if (updated != null) setState(() => _user = updated);
  }

  Future<void> _logout() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Logout?',
      message: 'Kamu akan keluar dari akun ini.',
      confirmLabel: 'Logout',
    );
    if (confirm != true || !mounted) return;

    setState(() => _isBusy = true);
    await _authService.logout();
    if (!mounted) return;
    Navigator.pop(context, 'logout');
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus akun permanen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seluruh artikel, komentar, dan foto profilmu akan dihapus dan '
              'tidak bisa dikembalikan. Masukkan password untuk melanjutkan.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Hapus akun',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      await _userService.deleteAccount(passwordController.text);
      await ApiClient.clearAuth();
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showSnack('Gagal menghapus akun: $e');
    } finally {
      passwordController.dispose();
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'KATA',
      applicationVersion: _appVersion,
      applicationIcon: const Icon(
        Icons.article_rounded,
        size: 40,
        color: AppColors.textPrimary,
      ),
      children: const [
        Text(
          'Aplikasi blog sederhana: menulis, menyukai, dan mengomentari '
          'artikel. Dibangun dengan Flutter (client) dan Express + MySQL '
          '(REST API).',
        ),
      ],
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        bottom: _isBusy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                ),
              )
            : null,
      ),
      body: _buildList(user),
    );
  }

  // =========================
  // DAFTAR PENGATURAN
  // =========================
  Widget _buildList(User? user) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _buildIdentityRow(user),
        const _SectionLabel('Keamanan'),
        _SettingRow(
          icon: Icons.lock_outline_rounded,
          title: 'Ganti password',
          subtitle: 'Wajib memasukkan password lama',
          onTap: _isBusy ? null : _changePassword,
        ),
        const _SectionLabel('Aplikasi'),
        _SettingRow(
          icon: Icons.info_outline_rounded,
          title: 'Tentang aplikasi',
          onTap: _showAbout,
        ),
        const _SettingRow(
          icon: Icons.numbers_rounded,
          title: 'Versi',
          value: _appVersion,
        ),
        const _SectionLabel('Sesi'),
        _SettingRow(
          icon: Icons.logout_rounded,
          title: 'Logout',
          onTap: _isBusy ? null : _logout,
        ),
        _SettingRow(
          icon: Icons.delete_forever_outlined,
          title: 'Hapus akun',
          subtitle: 'Permanen, tidak bisa dibatalkan',
          onTap: _isBusy ? null : _deleteAccount,
        ),
      ],
    );
  }

  /// Identitas akun sekaligus jalan pintas ke halaman edit profil.
  Widget _buildIdentityRow(User? user) {
    return InkWell(
      onTap: _openEditProfile,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: user?.avatarUrl,
              username: user?.username ?? '?',
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.username ?? 'Belum login',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul kelompok baris pengaturan.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Satu baris pengaturan: ikon, judul, penjelasan opsional, dan nilai di kanan.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
```

### `lib/services/auth_service.dart`

```dart
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

    return User.fromJson({...userJson, 'token': ?token});
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
```

### `lib/services/post_service.dart`

```dart
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// Semua panggilan API seputar artikel: feed, detail, suka, topik, dan
/// komentar.
///
/// Tidak menyimpan state apa pun — hasilnya dikembalikan ke pemanggil supaya
/// tiap halaman bebas mengatur tampilannya sendiri.
class PostService {
  final ApiClient _apiClient = ApiClient.instance;

  // =========================
  // GET ALL POSTS
  // =========================
  /// Daftar artikel terbaru, atau hasil pencarian bila [query] diisi.
  ///
  /// [limit] bersifat opsional dan dibatasi server (maksimum 50).
  /// [query] dikirim sebagai `?q=` dan disaring **di server** — server mencari
  /// pada judul, isi, dan nama penulis, sehingga hasilnya menjangkau seluruh
  /// artikel di database, bukan hanya yang sedang tampil di layar.
  Future<List<Post>> getPosts({int? limit, String? query}) async {
    final keyword = query?.trim() ?? '';
    final queryParams = <String, String>{
      if (limit != null) 'limit': '$limit',
      if (keyword.isNotEmpty) 'q': keyword,
    };

    final response = await _apiClient.get(
      ApiConstants.postsEndpoint,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> postsJson =
        jsonResponse['data']?['posts'] ?? jsonResponse['posts'] ?? [];
    return postsJson.map((json) => Post.fromJson(json)).toList();
  }

  // =========================
  // GET POST DETAIL
  // =========================
  Future<Post> getPostById(int id) async {
    final response =
        await _apiClient.get('${ApiConstants.postsEndpoint}/$id');
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // LIKE — TOGGLE
  // =========================
  /// Suka / batal suka satu artikel.
  ///
  /// Server yang menentukan status akhir (toggle), jadi client tidak perlu
  /// mengirim status yang diinginkan — cukup memakai nilai yang dikembalikan.
  Future<LikeResult> toggleLike(int postId) async {
    final response =
        await _apiClient.post(ApiConstants.likePostEndpoint(postId));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return LikeResult.fromJson(jsonResponse['data'] ?? jsonResponse);
  }

  // =========================
  // LIKE — POST YANG SAYA SUKAI
  // =========================
  /// Daftar id artikel yang disukai pengguna yang sedang login.
  Future<Set<int>> getMyLikedPostIds() async {
    final response = await _apiClient.get(ApiConstants.myLikesEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> ids = jsonResponse['data']?['postIds'] ?? [];
    return ids.map(Post.asInt).where((id) => id > 0).toSet();
  }

  // =========================
  // CREATE POST (gambar opsional)
  // =========================
  Future<Post> createPost({
    required String caption,
    int userId = 1,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final cleanCaption = caption.trim();
    final title =
        cleanCaption.length >= 3 ? cleanCaption : 'Postingan baru';
    final content = cleanCaption.length >= 10
        ? cleanCaption
        : '${cleanCaption.isEmpty ? "Postingan" : cleanCaption} dari aplikasi';

    final fields = {
      'userId': userId.toString(),
      'title': title,
      'content': content,
    };

    final List<http.MultipartFile> files = [];
    if (fileBytes != null && fileName != null) {
      files.add(
        http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await _apiClient.postMultipart(
      ApiConstants.postsEndpoint,
      fields: fields,
      files: files.isEmpty ? null : files,
    );

    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // UPDATE POST
  // =========================
  Future<Post> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.postsEndpoint}/$postId',
      body: {'title': title, 'content': content},
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Post.fromJson(jsonResponse['data']?['post'] ?? jsonResponse);
  }

  // =========================
  // DELETE POST
  // =========================
  Future<void> deletePost(int postId) async {
    await _apiClient.delete('${ApiConstants.postsEndpoint}/$postId');
  }

  // =========================
  // CATEGORIES — AUTOCOMPLETE
  // =========================
  Future<List<String>> searchCategories(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _apiClient.get(
      ApiConstants.categoriesSearchEndpoint,
      queryParams: {'q': query.trim().toLowerCase()},
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['categories'] ?? [];
    return data.map<String>((c) => c['name'] as String).toList();
  }

  // =========================
  // CATEGORIES — TRENDING
  // =========================
  Future<List<Map<String, dynamic>>> getTrendingCategories() async {
    final response =
        await _apiClient.get(ApiConstants.categoriesTrendingEndpoint);
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['categories'] ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  // =========================
  // CATEGORIES — POSTS BY CATEGORY
  // =========================
  Future<List<Post>> getPostsByCategory(String name) async {
    final response =
        await _apiClient.get(ApiConstants.categoryPostsEndpoint(name));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['posts'] ?? [];
    return data.map((json) => Post.fromJson(json)).toList();
  }

  // =========================
  // COMMENTS — GET BY POST
  // =========================
  Future<List<Comment>> getComments(int postId) async {
    final response =
        await _apiClient.get(ApiConstants.postCommentsEndpoint(postId));
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    final List<dynamic> data = jsonResponse['data']?['comments'] ?? [];
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  // =========================
  // COMMENTS — CREATE
  // =========================
  Future<Comment> createComment({
    required int postId,
    required int userId,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.postCommentsEndpoint(postId),
      body: {
        'userId': userId,
        'comment': comment,
      },
    );
    final Map<String, dynamic> jsonResponse =
        response is Map<String, dynamic> ? response : {};
    return Comment.fromJson(jsonResponse['data']?['comment'] ?? jsonResponse);
  }

  // =========================
  // COMMENTS — DELETE
  // =========================
  Future<void> deleteComment(int commentId) async {
    await _apiClient.delete(ApiConstants.deleteCommentEndpoint(commentId));
  }
}
```

### `lib/services/user_service.dart`

```dart
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
```

### `lib/widgets/avatar_options_sheet.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Pilihan aksi untuk foto profil, muncul dari bawah saat avatar diketuk.
///
/// Isinya sengaja cuma soal foto — mengganti dan menghapus. Penyuntingan data
/// lain (username, email) tetap lewat tombol "Edit profil" di halaman profil.
Future<void> showAvatarOptionsSheet(
  BuildContext context, {
  required VoidCallback onChangePhoto,
  VoidCallback? onRemovePhoto,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            _SheetAction(
              icon: Icons.image_outlined,
              label: 'Ganti foto',
              onTap: () {
                Navigator.pop(sheetContext);
                onChangePhoto();
              },
            ),
            if (onRemovePhoto != null)
              _SheetAction(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus foto',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onRemovePhoto();
                },
              ),
            const Divider(height: 0.6),
            _SheetAction(
              icon: Icons.close_rounded,
              label: 'Batal',
              onTap: () => Navigator.pop(sheetContext),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### `lib/widgets/bottom_nav_bar.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Nav bar bawah aplikasi: Beranda di kiri, tombol "+" bulat di tengah, dan
/// Profil di kanan.
///
/// Tombol "+" bukan tab — dia membuka layar buat postingan, jadi index yang
/// dikirim ke [onItemSelected] cuma 0 (beranda) dan 1 (profil).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onComposePressed,
    this.height = 64,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onComposePressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                isActive: selectedIndex == 0,
                onTap: () => onItemSelected(0),
                label: 'Beranda',
              ),
            ),
            _ComposeButton(onPressed: onComposePressed),
            Expanded(
              child: _NavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                isActive: selectedIndex == 1,
                onTap: () => onItemSelected(1),
                label: 'Profil',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu ikon tab. Saat aktif, ikon berganti ke versi solid dan diberi latar
/// lingkaran tipis plus bayangan halus sebagai penanda posisi.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : const [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey<bool>(isActive),
                size: 26,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                shadows: isActive
                    ? [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeButton extends StatefulWidget {
  const _ComposeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_ComposeButton> createState() => _ComposeButtonState();
}

class _ComposeButtonState extends State<_ComposeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buat postingan',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1,
          duration: const Duration(milliseconds: 140),
          child: Container(
            width: 54,
            height: 54,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.onPrimary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
```

### `lib/widgets/hashtag_autocomplete_field.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/post_service.dart';

/// TextField dengan autocomplete hashtag.
///
/// Saat user ngetik `#` diikuti huruf, widget cari kategori
/// yang cocok dari BE lalu tampilkan sebagai saran di bawah input.
class HashtagAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const HashtagAutocompleteField({
    super.key,
    required this.controller,
    this.hintText = 'Tulis caption...',
    this.helperText,
    this.minLines = 3,
    this.maxLines = 5,
    this.enabled = true,
  });

  @override
  State<HashtagAutocompleteField> createState() =>
      _HashtagAutocompleteFieldState();
}

class _HashtagAutocompleteFieldState extends State<HashtagAutocompleteField> {
  final PostService _postService = PostService();

  List<String> _suggestions = [];
  String? _currentPrefix;
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    // Kalau kursor gak di akhir, skip
    if (!selection.isValid || selection.baseOffset != text.length) {
      _hideSuggestions();
      return;
    }

    // Regex: cari `#` diikuti word chars, di akhir string
    final match = RegExp(r'#(\w*)$').firstMatch(text);

    if (match == null) {
      _hideSuggestions();
      return;
    }

    final prefix = match.group(1) ?? '';
    _currentPrefix = prefix;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _search(prefix);
    });
  }

  Future<void> _search(String prefix) async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final results = await _postService.searchCategories(prefix);
      if (!mounted) return;

      // Buang yang persis sama dengan prefix
      final filtered = results
          .where((r) => r.toLowerCase() != prefix.toLowerCase())
          .toList();

      setState(() {
        _suggestions = filtered;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  void _hideSuggestions() {
    if (_suggestions.isEmpty && !_isSearching) return;
    if (!mounted) return;
    setState(() {
      _suggestions = [];
      _currentPrefix = null;
      _isSearching = false;
    });
  }

  void _applySuggestion(String tag) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    final beforeCursor = text.substring(0, selection.baseOffset);
    final match = RegExp(r'#(\w*)$').firstMatch(beforeCursor);
    if (match == null) return;

    final start = match.start;
    final end = match.end;

    // Ganti `#prefix` → `#tag ` (kasih spasi di akhir)
    final newText = text.replaceRange(start, end, '#$tag ');
    final newOffset = start + tag.length + 2;

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );

    setState(() {
      _suggestions = [];
      _currentPrefix = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _suggestions.isNotEmpty || _isSearching;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            helperStyle: const TextStyle(color: AppColors.textMuted),
          ),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        if (showSuggestions) _buildSuggestionBox(),
      ],
    );
  }

  Widget _buildSuggestionBox() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _isSearching && _suggestions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Text(
                    'Saran hashtag',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ..._suggestions.map((tag) {
                  return InkWell(
                    onTap: () => _applySuggestion(tag),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tag_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                children: [
                                  if (_currentPrefix != null &&
                                      _currentPrefix!.isNotEmpty)
                                    TextSpan(text: _currentPrefix),
                                  TextSpan(
                                    text: tag.substring(
                                      _currentPrefix?.length ?? 0,
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
```

### `lib/widgets/hashtag_text.dart`

```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Menampilkan teks (caption) dengan hashtag sebagai tulisan yang bisa
/// diketuk — tetap berupa teks biasa, bukan bubble/chip.
///
/// Dipakai di kartu feed dan halaman detail supaya tampilan caption konsisten.
class HashtagText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final int? maxLines;
  final Color? hashtagColor;
  final void Function(String tag)? onTagTap;

  const HashtagText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = AppColors.textPrimary,
    this.maxLines,
    this.hashtagColor,
    this.onTagTap,
  });

  @override
  State<HashtagText> createState() => _HashtagTextState();
}

class _HashtagTextState extends State<HashtagText> {
  final List<TapGestureRecognizer> _recognizers = [];

  static final RegExp _hashtagPattern = RegExp(r'#(\w+)');

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  /// Recognizer adalah objek native yang harus dibebaskan. Karena span dibuat
  /// ulang tiap rebuild (teksnya bisa berubah), yang lama dibuang lebih dulu.
  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final tagColor = widget.hashtagColor ?? AppColors.primary;
    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final match in _hashtagPattern.allMatches(widget.text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: widget.text.substring(lastIndex, match.start)));
      }

      final tag = match.group(1) ?? '';
      final label = widget.text.substring(match.start, match.end);

      TapGestureRecognizer? recognizer;
      if (widget.onTagTap != null) {
        recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onTagTap!(tag);
        _recognizers.add(recognizer);
      }

      spans.add(
        TextSpan(
          text: label,
          recognizer: recognizer,
          style: TextStyle(
            color: tagColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(lastIndex)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.color,
          height: 1.45,
        ),
        children: spans,
      ),
      maxLines: widget.maxLines,
      overflow: widget.maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );
  }
}
```

### `lib/widgets/like_action.dart`

```dart
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../models/post_model.dart';
import '../routes.dart';
import '../services/post_service.dart';

/// Tombol suka dengan animasi hati yang tersambung ke database.
///
/// Alur: ketuk → server membalik status di tabel `likes` → nilai final dari
/// server dipakai untuk memperbarui tampilan. Kalau gagal, tampilan tidak
/// berubah (dikembalikan `null` ke LikeButton) sehingga UI tidak pernah
/// menampilkan status yang tidak tersimpan di database.
class LikeAction extends StatefulWidget {
  final Post post;
  final ValueChanged<Post>? onPostChanged;
  final double iconSize;
  final Color? labelColor;

  const LikeAction({
    super.key,
    required this.post,
    this.onPostChanged,
    this.iconSize = 22,
    this.labelColor,
  });

  @override
  State<LikeAction> createState() => _LikeActionState();
}

class _LikeActionState extends State<LikeAction> {
  final PostService _postService = PostService();

  Future<bool?> _handleTap(bool isLiked) async {
    final postId = widget.post.id;
    if (postId == null) return null;

    if (!ApiClient.isLoggedIn) {
      _showMessage(
        'Login dulu untuk menyukai postingan',
        action: SnackBarAction(
          label: 'Login',
          textColor: AppColors.primary,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.login),
        ),
      );
      return null;
    }

    try {
      final result = await _postService.toggleLike(postId);
      widget.onPostChanged?.call(
        widget.post.copyWithLike(
          liked: result.liked,
          count: result.likesCount,
        ),
      );
      return result.liked;
    } catch (e) {
      _showMessage('Gagal menyukai postingan: $e');
      return null;
    }
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLiked;
    final labelColor = widget.labelColor ?? AppColors.textSecondary;

    return LikeButton(
      size: widget.iconSize,
      isLiked: isLiked,
      likeCount: widget.post.likesCount,
      countPostion: CountPostion.right,
      // Semua warna di bawah ini monokrom: putih saat disukai, abu-abu saat
      // belum — konsisten dengan tema hitam-putih aplikasi.
      bubblesColor: const BubblesColor(
        dotPrimaryColor: AppColors.textPrimary,
        dotSecondaryColor: AppColors.textSecondary,
      ),
      circleColor: const CircleColor(
        start: AppColors.textPrimary,
        end: AppColors.textSecondary,
      ),
      likeBuilder: (liked) => Icon(
        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.iconSize,
        color: liked ? AppColors.textPrimary : labelColor,
      ),
      countBuilder: (count, liked, text) => Text(
        count == null || count == 0 ? 'Suka' : text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: liked ? AppColors.textPrimary : labelColor,
        ),
      ),
      onTap: _handleTap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }
}
```

### `lib/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../core/theme.dart';

/// Widget loading reusable untuk dipakai di semua screen.
class LoadingIndicator extends StatelessWidget {
  final String message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message = 'Memuat...',
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const SpinKitFadingCircle(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
```

### `lib/widgets/post_card.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../core/ui_feedback.dart';
import '../models/post_model.dart';
import 'hashtag_text.dart';
import 'like_action.dart';
import 'user_avatar.dart';

/// Satu baris artikel di linimasa feed:
/// avatar, baris akun (@username · waktu), isi tulisan, gambar opsional,
/// lalu baris aksi.
///
/// Tiap artikel tidak dibungkus kotak ber-border — pemisahnya cukup garis
/// tipis di bawah, jadi feed terasa lebih ringan dan tidak seperti daftar kartu.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final void Function(String tag) onTagTap;
  final ValueChanged<Post>? onPostChanged;
  final int commentCount;
  final bool showCommentCount;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onTagTap,
    this.onPostChanged,
    this.commentCount = 0,
    this.showCommentCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              imageUrl: post.author?.avatarUrl,
              username: post.displayName,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              // Isi tulisan diberi jarak 12 dari tepi kanan; tombol titik tiga
              // ditaruh di luar kolom ini supaya bisa mepet ke tepi.
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountRow(),
                    if (post.content.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      HashtagText(
                        text: post.content,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                        maxLines: 6,
                        onTagTap: onTagTap,
                      ),
                    ],
                    if (post.hasImage) ...[
                      const SizedBox(height: 10),
                      _buildImage(),
                    ],
                    const SizedBox(height: 4),
                    _buildActionRow(context),
                  ],
                ),
              ),
            ),
            _buildMoreButton(context),
          ],
        ),
      ),
    );
  }

  // =========================
  // BARIS AKUN
  // =========================
  Widget _buildAccountRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            post.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text('·', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        Text(
          formatRelativeTime(post.createdAt),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Tombol "..." di pojok kanan atas kartu.
  Widget _buildMoreButton(BuildContext context) {
    return InkWell(
      onTap: () => showNotAvailable(context, 'Menu postingan'),
      borderRadius: BorderRadius.circular(999),
      child: const Padding(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Icon(
          Icons.more_horiz,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // =========================
  // GAMBAR
  // =========================
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: post.imageUrl!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) => Container(
            color: AppColors.surfaceLight,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          errorWidget: (_, _, _) => Container(
            color: AppColors.surfaceLight,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // BARIS AKSI
  // =========================
  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        _CardAction(
          icon: Icons.mode_comment_outlined,
          label: showCommentCount && commentCount > 0 ? '$commentCount' : null,
          tooltip: 'Komentar',
          onTap: onTap,
        ),
        const SizedBox(width: 24),
        LikeAction(post: post, onPostChanged: onPostChanged),
        const Spacer(),
        _CardAction(
          icon: Icons.bookmark_border_rounded,
          tooltip: 'Simpan',
          onTap: () => showNotAvailable(context, 'Menyimpan postingan'),
        ),
        const SizedBox(width: 12),
        _CardAction(
          icon: Icons.ios_share_rounded,
          tooltip: 'Bagikan',
          onTap: () => showNotAvailable(context, 'Membagikan postingan'),
        ),
      ],
    );
  }
}

/// Ikon aksi kecil di bawah artikel (komentar, simpan, bagikan).
class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.tooltip,
    this.label,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### `lib/widgets/state_views.dart`

```dart
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Tampilan saat sebuah daftar berhasil dimuat tapi belum ada isinya.
///
/// Dipakai bersama supaya ukuran ikon, jarak, dan gaya teksnya sama di semua
/// halaman — sebelumnya tiap layar menulis ulang blok ini dengan angka yang
/// berbeda-beda.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan saat pemuatan data gagal, lengkap dengan tombol coba lagi.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }
}
```

### `lib/widgets/user_avatar.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Avatar pengguna.
///
/// Memakai [CachedNetworkImage] supaya gambar yang sama (mis. foto profil yang
/// muncul di banyak kartu) hanya diunduh sekali lalu dibaca dari cache lokal —
/// ini yang membuat feed terasa ringan dan hemat kuota.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double size;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.username,
    this.size = 38,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get _initial =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: size,
              height: size,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, _) => _buildInitial(),
              errorWidget: (_, _, _) => _buildInitial(),
            )
          : _buildInitial(),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
```
