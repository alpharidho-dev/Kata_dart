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

```
