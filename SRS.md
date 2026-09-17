# KATA — Aplikasi Blog Berbasis Mobile

> **"Setiap kata berarti."**

Dokumen ini merupakan **Software Requirements Specification (SRS)** untuk proyek **KATA** — aplikasi blog berbasis mobile yang dibangun sebagai bagian dari Assessment Sumatif Tengah Semester mata pelajaran Mapil Pilihan, Kompetensi Keahlian Rekayasa Perangkat Lunak, SMK Taruna Bhakti.

> **Kedudukan dokumen:** SRS lengkap (BAB I–V beserta use case/activity/class diagram, ERD, kontrak REST API, dan lampiran bukti) ada di **`srs2.md`** pada root project. Berkas ini adalah ringkasan dari sisi aplikasi mobile; bila ada perbedaan, `srs2.md` yang berlaku karena disusun langsung dari implementasi terakhir.

---

## 📋 Informasi Proyek

| Item | Keterangan |
|---|---|
| **Nama Sistem** | KATA |
| **Jenis** | Aplikasi Blog Berbasis Mobile |
| **Platform** | Android (Flutter) |
| **Backend** | Node.js + Express + TypeScript |
| **Database** | MySQL 8.x |
| **Image Storage** | Cloudinary |
| **Manajemen Proyek** | Trello (Agile/Scrum) |
| **Version Control** | GitHub (Git Flow) |
| **Tahun Pelajaran** | 2026/2027 |

**Disusun oleh:**
- Nama: [Nama Lu]
- Kelas: XI RPL [X]
- NIS: [NIS Lu]

---

## 📖 Daftar Isi

- [BAB I — Pendahuluan](#bab-i--pendahuluan)
- [BAB II — Metode Pengembangan](#bab-ii--metode-pengembangan)
- [BAB III — Analisis Kebutuhan Sistem](#bab-iii--analisis-kebutuhan-sistem)
- [BAB IV — Development](#bab-iv--development)
- [BAB V — Penutup](#bab-v--penutup)

---

# BAB I — PENDAHULUAN

## 1.1 Latar Belakang

Perkembangan teknologi informasi di era digital telah mengubah cara masyarakat dalam berbagi informasi dan berkomunikasi. Media sosial dan platform blogging menjadi sarana utama bagi pengguna untuk menuangkan ide, pengalaman, serta karya dalam bentuk tulisan dan gambar. Namun, sebagian besar platform yang ada saat ini memiliki antarmuka yang kompleks dan berat, sehingga kurang efisien untuk kebutuhan berbagi konten sederhana.

Di sisi lain, pembelajaran Rekayasa Perangkat Lunak (RPL) di tingkat SMK menuntut siswa untuk mampu membangun aplikasi secara *end-to-end*, mulai dari perancangan basis data, pembuatan REST API, hingga pengembangan aplikasi mobile. Selain itu, kompetensi *version control* menggunakan GitHub dan penyusunan dokumen perancangan sistem (SRS) juga menjadi bagian penting yang harus dikuasai siswa.

Proyek **"KATA"** hadir sebagai aplikasi blog sederhana berbasis mobile yang mengusung konsep berbagi artikel dengan dukungan **hashtag/kategori**, **komentar**, dan **avatar pengguna**. Nama **KATA** dipilih karena merepresentasikan unit terkecil dari bahasa yang menjadi fondasi setiap ekspresi manusia — setiap ide besar dimulai dari satu kata.

## 1.2 Rumusan Masalah

1. Bagaimana merancang sistem aplikasi blog berbasis mobile yang dapat menampilkan, membuat, mengedit, dan menghapus artikel?
2. Bagaimana merancang REST API sebagai penghubung antara aplikasi mobile dengan basis data?
3. Bagaimana menerapkan sistem kategori/hashtag pada artikel agar pengguna dapat mengelompokkan dan mencari artikel berdasarkan topik?
4. Bagaimana merancang struktur basis data yang efisien dengan menerapkan relasi antar tabel (*foreign key*)?
5. Bagaimana menerapkan *version control* GitHub dengan *branching* yang terstruktur dalam pengembangan proyek?

## 1.3 Tujuan Penulisan Dokumen

1. Mendokumentasikan kebutuhan fungsional dan non-fungsional sistem aplikasi blog **KATA**.
2. Menjadi acuan teknis dalam proses pengembangan aplikasi.
3. Menjadi bukti tertulis dari proses analisis kebutuhan sebelum tahap implementasi.
4. Menjadi sarana komunikasi antar *stakeholder* terkait fitur dan batasan sistem.
5. Memenuhi salah satu syarat penilaian Assessment Sumatif Tengah Semester mata pelajaran Mapil Pilihan.

---

# BAB II — METODE PENGEMBANGAN

## 2.1 Metode Pengembangan

Metode pengembangan yang digunakan dalam proyek **KATA** adalah **Agile Development** dengan pendekatan **Scrum** sederhana. Alasan pemilihan metode ini:

> **Catatan:** rincian metode dan jadwal yang dipakai pada implementasi terakhir (sprint harian 8 hari, 7–14 September 2026) ada di **`srs2.md` Bab II**. Bagian di bawah ini adalah catatan perencanaan awal beserta papan pengelolaan tugasnya.

| Alasan | Penjelasan |
|---|---|
| **Fleksibel terhadap perubahan** | Kebutuhan sistem dapat berubah seiring proses pengembangan tanpa harus mengulang dari awal |
| **Iteratif & inkremental** | Sistem dibangun secara bertahap dalam siklus pendek (*sprint*) |
| **Cocok untuk tim kecil** | Proyek dikerjakan secara individu, sehingga Scrum sederhana lebih efisien |
| **Fokus pada *deliverable*** | Setiap sprint menghasilkan fitur yang berfungsi |

## 2.2 Manajemen Proyek dengan Trello

Jadwal pengembangan proyek **KATA** disusun dan dikelola menggunakan **Trello** sebagai *project management board*. Trello dipilih karena:

- **Visual & intuitif** — cocok untuk proyek individu dengan siklus pendek
- **Mendukung metode Agile/Scrum** — board, list, dan card merepresentasikan sprint, task, dan sub-task
- **Kolaborasi real-time** — bisa diakses dari web & mobile
- **Gratis & ringan** — gak butuh setup kompleks

### Struktur Board Trello

Board **"KATA — Blog App Development"** terdiri dari 5 list:

| List | Fungsi |
|---|---|
| **📋 Backlog** | Semua task yang belum dikerjakan |
| **📝 To Do** | Task yang siap dikerjakan di sprint aktif |
| **⚙️ In Progress** | Task yang sedang dikerjakan |
| **🧪 Testing** | Task yang selesai coding, lagi di-test |
| **✅ Done** | Task yang udah selesai & stabil |

### Pembagian Sprint

Setiap sprint direpresentasikan sebagai label warna di Trello:

| Sprint | Fokus | Hari |
|---|---|---|
| 🟦 Sprint 1 | Setup project + Auth | Hari 1-2 |
| 🟩 Sprint 2 | CRUD Post (BE + FE) | Hari 3-4 |
| 🟪 Sprint 3 | Kategori & Hashtag | Hari 5 |
| 🟫 Sprint 4 | Komentar | Hari 6 |
| 🟦 Sprint 5 | Avatar + Polish UI | Hari 7 |
| 🟥 Sprint 6 | Testing & Dokumentasi | Hari 8 |

### Aturan Penggunaan Trello

| Aturan | Deskripsi |
|---|---|
| **1 card = 1 task** | Setiap card merepresentasikan task kecil yang bisa diselesaikan dalam <4 jam |
| **WIP Limit** | Maksimal 3 card di list "In Progress" biar fokus |
| **Due Date** | Setiap card dikasih due date sesuai sprint |
| **Checklist** | Task besar di-breakdown jadi checklist di dalam card |
| **Label Warna** | Label warna merepresentasikan sprint |
| **Move on Done** | Card dipindah ke "Done" setelah lulus testing |

> **📸 Screenshot Trello board** tersedia di [Lampiran](#lampiran)

---

# BAB III — ANALISIS KEBUTUHAN SISTEM

## 3.1 Nama Sistem

| Item | Keterangan |
|---|---|
| **Nama Sistem** | KATA |
| **Jenis Aplikasi** | Aplikasi Blog Berbasis Mobile |
| **Platform** | Android (Flutter) |
| **Tagline** | *"Setiap kata berarti."* |

**Filosofi nama:** "KATA" dipilih karena merupakan **unit terkecil dari bahasa** yang menjadi fondasi setiap ekspresi manusia. Setiap ide besar, cerita panjang, dan gagasan besar selalu dimulai dari satu kata. Aplikasi ini menjadi wadah bagi pengguna untuk menuangkan kata-kata mereka menjadi karya yang bermakna.

### Kesesuaian dengan Kriteria Ujian

Sistem **KATA** dirancang untuk memenuhi seluruh kriteria wajib ujian ATS KOKE (REST API + CRUD + struktur database minimal 2 tabel) sekaligus menambahkan fitur inovasi di atas standar minimal, seperti autentikasi JWT, sistem hashtag dengan autocomplete, upload gambar ke Cloudinary, dan fitur komentar interaktif.

## 3.2 Latar Belakang Sistem

Sistem **KATA** dibangun sebagai jawaban atas kebutuhan akan platform blogging yang ringan dan mudah digunakan di perangkat mobile. Sistem ini menyediakan fitur-fitur utama:

- **Berbagi artikel** dengan gambar dan teks
- **Pengelompokan artikel** menggunakan hashtag/kategori
- **Interaksi sosial** melalui komentar
- **Personalisasi** melalui avatar pengguna
- **Keamanan** melalui autentikasi JWT

Arsitektur sistem:

- **Client (Mobile)** — UI/UX dan interaksi user
- **Server (REST API)** — logika bisnis dan keamanan
- **Database** — menyimpan data persisten
- **Cloud Storage (Cloudinary)** — menyimpan gambar

## 3.3 Ruang Lingkup

### Deskripsi Sistem

**KATA** memungkinkan pengguna untuk:

1. Melihat daftar artikel dari semua pengguna (tanpa perlu login)
2. Membuat, mengedit, dan menghapus artikel miliknya sendiri
3. Berinteraksi melalui komentar
4. Mencari artikel berdasarkan kategori/hashtag
5. Mengganti avatar profil

### Manfaat Sistem

| Manfaat | Penjelasan |
|---|---|
| **Bagi pengguna umum** | Sarana berbagi pengalaman/tulisan secara cepat & ringan |
| **Bagi developer** | Referensi implementasi arsitektur client-server modern |
| **Bagi institusi pendidikan** | Media pembelajaran integrasi REST API + Mobile + Database |
| **Bagi evaluator** | Contoh proyek end-to-end yang dapat diuji secara langsung |

## 3.4 Kebutuhan Fungsional

### 3.4.1 Fitur Utama

| Kode | Fitur | Deskripsi | Kategori |
|---|---|---|---|
| **F-01** | Registrasi Akun | Daftar dengan username, email, password | 🚀 Inovasi |
| **F-02** | Login | Login pakai email & password, dapat JWT | 🚀 Inovasi |
| **F-03** | Persist Session | Sesi tetap aktif meski app ditutup | 🚀 Inovasi |
| **F-04** | Logout | Keluar dari sesi aktif | 🚀 Inovasi |
| **F-05** | Lihat Daftar Artikel | Semua artikel (publik) | ✅ Wajib |
| **F-06** | Lihat Detail Artikel | Isi artikel lengkap + komentar | ✅ Wajib |
| **F-07** | Membuat Artikel | Buat artikel dengan/tanpa gambar | ✅ Wajib |
| **F-08** | Mengedit Artikel | Edit artikel sendiri | ✅ Wajib |
| **F-09** | Menghapus Artikel | Hapus artikel sendiri | ✅ Wajib |
| **F-10** | Kategori/Hashtag | Multi-hashtag per post | ✅ Wajib |
| **F-11** | Autocomplete Hashtag | Saran hashtag saat ngetik `#` | 🚀 Inovasi |
| **F-12** | Trending Hashtag | Hashtag populer | 🚀 Inovasi |
| **F-13** | Filter by Kategori | List post berdasarkan hashtag | 🚀 Inovasi |
| **F-14** | Komentar | Post & list komentar | 🚀 Inovasi |
| **F-15** | Hapus Komentar | Owner bisa hapus komentar | 🚀 Inovasi |
| **F-16** | Ganti Avatar | Upload foto profil ke Cloudinary | 🚀 Inovasi |
| **F-17** | Suka Artikel | Suka/batal suka, tersimpan di tabel `likes` | 🚀 Inovasi |
| **F-18** | Pencarian | Cari tulisan & topik dengan ketikan (debounce 300 ms); pencarian tulisan disaring **di server** lewat `GET /posts?q=` | 🚀 Inovasi |
| **F-19** | Edit Profil | Ubah foto, username, dan email | 🚀 Inovasi |
| **F-20** | Pengaturan Akun | Ganti password, logout, hapus akun, info versi | 🚀 Inovasi |
| **F-21** | Feed per Topik | Filter feed berdasarkan hashtag populer | 🚀 Inovasi |

### 3.4.2 Karakteristik Pengguna

| Tipe User | Deskripsi | Hak Akses |
|---|---|---|
| **Guest** | Belum login | Lihat daftar & detail artikel |
| **User** | Sudah login | Guest + CRUD artikel sendiri + komentar + ganti avatar |
| **Admin** *(future)* | Role khusus | Semua fitur user + moderasi |

### 3.4.3 Kamus Data

#### Tabel `users`

| Field | Tipe | Keterangan |
|---|---|---|
| id | INT (PK) | Auto increment |
| username | VARCHAR(50) | Nama unik pengguna |
| email | VARCHAR(100) | Unik, format email valid |
| password | VARCHAR(255) | Hash bcrypt |
| role | ENUM('user','admin') | Default: user |
| avatar_url | TEXT | URL gambar dari Cloudinary |
| avatar_public_id | VARCHAR(255) | ID gambar di Cloudinary |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto on update |

#### Tabel `posts`

| Field | Tipe | Keterangan |
|---|---|---|
| id | INT (PK) | Auto increment |
| user_id | INT (FK) | → users.id (CASCADE) |
| title | VARCHAR(255) | Judul artikel |
| content | TEXT | Isi artikel (termasuk hashtag) |
| categories | JSON | Array hashtag: `["kuliner","jakarta"]` |
| image_url | TEXT | URL gambar (nullable) |
| image_public_id | VARCHAR(255) | ID gambar (nullable) |
| status | ENUM | 'published', 'delete' |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto on update |

#### Tabel `categories`

| Field | Tipe | Keterangan |
|---|---|---|
| id | INT (PK) | Auto increment |
| name | VARCHAR(100) | Unik, lowercase tanpa `#` |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto on update |

#### Tabel `comments`

| Field | Tipe | Keterangan |
|---|---|---|
| id | INT (PK) | Auto increment |
| post_id | INT (FK) | → posts.id (CASCADE) |
| user_id | INT (FK) | → users.id (CASCADE) |
| comment | TEXT | Isi komentar |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto on update |

### 3.4.4 User Interface

Struktur navigasi aplikasi:

```
HomeScreen (Shell)
├── Bottom navigation: Beranda — tombol + bulat — Profil
├── Layar 1: Beranda
│   ├── Baris filter topik (Semua + hashtag populer dari /categories/trending)
│   ├── Feed artikel (baris linimasa: avatar + @username + waktu + caption + gambar)
│   └── Tarik ke bawah untuk memuat ulang
├── Tombol + (bukan tab)
│   └── Membuka layar Tulis secara penuh: pilih gambar, caption dengan
│       autocomplete hashtag, counter karakter, tombol Batal / Posting
└── Layar 2: Profil
    ├── Header: avatar (diketuk → bottom sheet ganti/hapus foto), username,
    │   email, tombol Edit profil & Pengaturan
    └── Tab Tulisan / Disukai / Disimpan (Disimpan belum tersedia)

PostDetailScreen
├── Baris akun (@username + waktu)
├── Gambar (kalau ada)
├── Judul + caption (hashtag bisa diketuk)
├── Action Row (Komentar, Suka, Simpan, Bagikan)
└── Comments Section
    ├── List Komentar (baris list, bukan kartu)
    └── Input Komentar bergaya pill
```

### 3.4.5 Interaksi Antar Modul

```
┌──────────────┐      HTTP      ┌──────────────┐     Query     ┌──────────────┐
│   FLUTTER    │ ─────────────► │  EXPRESS API │ ────────────► │    MySQL     │
│   (Client)   │ ◄───────────── │   (Server)   │ ◄──────────── │  (Database)  │
└──────────────┘     JSON       └──────┬───────┘               └──────────────┘
                                       │
                                       │ Upload
                                       ▼
                                ┌──────────────┐
                                │  CLOUDINARY  │
                                │ (Image Store)│
                                └──────────────┘
```

### 3.4.6 Alur Bisnis

**Alur Create Post:**

```
User isi caption + pilih gambar → FE parse hashtag → kirim multipart ke BE
→ BE upload gambar ke Cloudinary → BE upsert hashtag ke tabel categories
→ BE insert post ke DB → BE return post + author → FE refresh list
```

**Alur Autocomplete Hashtag:**

```
User ngetik "#kul" → FE debounce 250ms → GET /categories/search?q=kul
→ BE query LIKE 'kul%' → FE tampilkan dropdown saran → user tap saran
→ FE replace "#kul" jadi "#kuliner "
```

## 3.5 Kebutuhan Non-Fungsional

### 3.5.1 Kebutuhan Produk

| Aspek | Requirement |
|---|---|
| **Performance** | Response time API < 500ms |
| **Reliability** | Menangani minimal 50 concurrent user |
| **Usability** | UI intuitif, dark theme, navigasi max 3 tap |
| **Scalability** | Backend scalable (stateless JWT) |
| **Portability** | Android 6.0+ |

### 3.5.2 Kebutuhan Organisasi

| Aspek | Requirement |
|---|---|
| **Version Control** | Git + GitHub dengan branching strategy |
| **Documentation** | Setiap endpoint API & fitur didokumentasikan |
| **Code Standard** | Style guide TypeScript & Dart |
| **Deployment** | Backend dapat dijalankan di VPS |

### 3.5.3 Kebutuhan Eksternal

| Aspek | Requirement |
|---|---|
| **Regulasi** | Tidak menyimpan data sensitif plaintext |
| **Keamanan** | Password bcrypt, JWT expired 7 hari |
| **Pihak Ketiga** | Cloudinary untuk image storage |
| **Interoperabilitas** | Response JSON standar |

## 3.6 Batasan Sistem

| Kategori | Batasan |
|---|---|
| **Teknologi** | Node.js + Express + TypeScript + Drizzle ORM |
| **Database** | MySQL 8.x |
| **Platform** | Android (Flutter 3.x) |
| **Storage** | Cloudinary (max 5MB per file) |
| **Autentikasi** | JWT, expired 7 hari |
| **Jaringan** | Butuh internet untuk akses API & Cloudinary |

---

# BAB IV — DEVELOPMENT

## 4.1 Desain Sistem

### 4.1.1 Use Case Diagram

**Aktor:**

- **Guest** — pengguna yang belum login
- **User** — pengguna yang sudah login

**Use Case:**

| Aktor | Use Case | Kategori |
|---|---|---|
| Guest | Lihat Daftar Artikel | ✅ Wajib |
| Guest | Lihat Detail Artikel | ✅ Wajib |
| Guest | Register | 🚀 Inovasi |
| Guest | Login | 🚀 Inovasi |
| User | Buat Artikel | ✅ Wajib |
| User | Edit Artikel | ✅ Wajib |
| User | Hapus Artikel | ✅ Wajib |
| User | Komentar | 🚀 Inovasi |
| User | Ganti Avatar | 🚀 Inovasi |
| User | Logout | 🚀 Inovasi |

### 4.1.2 Activity Diagram

**Create Post:**

```
[Start] → User menekan tombol + di nav bar → Pilih gambar (opsional)
→ Input caption + hashtag → Tap Posting
→ [Decision: Ada gambar?]
   ├─ Ya → Upload ke Cloudinary → dapat URL
   └─ Tidak → skip
→ BE parse hashtag dari caption
→ BE upsert hashtag ke tabel categories
→ BE insert post ke DB
→ FE refresh list → [End]
```

**Autocomplete Hashtag:**

```
[Start] → User ngetik "#" di caption
→ FE deteksi pattern #\w+
→ [Decision: Ada karakter setelah #?]
   ├─ Ya → Debounce 250ms → Query BE
   └─ Tidak → skip
→ BE return saran (LIKE 'prefix%')
→ [Decision: Ada hasil?]
   ├─ Ya → Tampilkan dropdown → User tap → Replace caption
   └─ Tidak → Sembunyikan dropdown
→ [End]
```

### 4.1.3 Class Diagram

**Model Domain (Frontend):**

```
┌──────────────┐         ┌─────────────────┐
│     User     │         │      Post       │
├──────────────┤         ├─────────────────┤
│ id: int      │         │ id: int         │
│ username:str │         │ userId: int     │
│ email: str   │         │ title: str      │
│ role: str    │         │ content: str    │
│ avatarUrl:str│         │ categories: List│
│ token: str   │         │ imageUrl: str   │
├──────────────┤         │ status: str     │
│ initial(): str│        │ author: Author  │
└──────────────┘         ├─────────────────┤
                         │ hasImage(): bool│
┌──────────────┐         │ hasCategories() │
│ UserSummary  │◄────────│ contentWithout..│
├──────────────┤         └─────────────────┘
│ id: int      │                  │
│ username: str│                  │ 1..*
│ avatarUrl:str│                  ▼
└──────────────┘         ┌─────────────────┐
                         │    Comment      │
                         ├─────────────────┤
                         │ id: int         │
                         │ postId: int     │
                         │ userId: int     │
                         │ comment: str    │
                         │ user:UserSummary│
                         └─────────────────┘
```

**Skema Database (ERD):**

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────┐
│    users     │       │      posts       │       │  comments    │
├──────────────┤       ├──────────────────┤       ├──────────────┤
│ id (PK)      │◄──┐   │ id (PK)          │◄──┐   │ id (PK)      │
│ username     │   │   │ user_id (FK)     │   │   │ post_id (FK) │
│ email        │   └───│ title            │   └───│ user_id (FK) │
│ password     │       │ content          │       │ comment      │
│ role         │       │ categories(JSON) │       │ created_at   │
│ avatar_url   │       │ image_url        │       │ updated_at   │
│ avatar_pub_id│       │ image_public_id  │       └──────────────┘
│ created_at   │       │ status           │              ▲
│ updated_at   │       │ created_at       │              │
└──────────────┘       │ updated_at       │              │
       ▲               └──────────────────┘              │
       │                                                   │
       │               ┌──────────────────┐               │
       │               │   categories     │               │
       │               ├──────────────────┤               │
       │               │ id (PK)          │               │
       │               │ name (UNIQUE)    │               │
       │               │ created_at       │               │
       └───────────────│ updated_at       │               │
        (logis via JSON)└─────────────────┘               │
                                                           │
       ┌───────────────────────────────────────────────────┘
       │  Relasi Foreign Key (CASCADE):
       │  • posts.user_id      → users.id
       │  • comments.post_id   → posts.id
       │  • comments.user_id   → users.id
       │  • likes.post_id      → posts.id
       │  • likes.user_id      → users.id
       │    (tabel `likes` punya UNIQUE (post_id, user_id))
       └─
```

## 4.2 Struktur Repository dan Branching GitHub

### 4.2.1 Struktur Repository

```
kata-blog-app/
├── README.md                        # Halaman masuk repository
├── code.md                          # Isi lengkap seluruh source code
├── srs2.md                          # Dokumen SRS lengkap (BAB I–V)
├── pushgithub-server.md             # Panduan push repositori server
├── pushgithub-client.md             # Panduan push repositori client
├── tools/
│   ├── build_docs.js                # Generator dokumentasi
│   └── check_push_plan.js           # Pemeriksa cakupan berkas pada panduan push
├── server/                          # Backend (Express + TS) → repositori `kata-server`
│   ├── .env.example                 # Contoh isi .env tanpa kredensial
│   ├── db/
│   │   ├── schema.sql               # DDL: buat database + 5 tabel
│   │   ├── inspect.sql              # Query pemeriksa struktur database
│   │   ├── report.js                # Pencetak struktur database
│   │   └── schema-report.md         # Hasil query pada database berjalan
│   ├── src/
│   │   ├── config/
│   │   │   ├── cloudinary.ts
│   │   │   ├── db.ts
│   │   │   └── schema.ts
│   │   ├── controllers/
│   │   │   ├── auth/
│   │   │   ├── categories/
│   │   │   ├── comments/
│   │   │   └── middleware/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── utils/
│   │   ├── validations/
│   │   └── index.ts
│   ├── drizzle.config.ts
│   ├── package.json
│   └── tsconfig.json
│
├── client/                          # Aplikasi mobile (Flutter)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── api_client.dart
│   │   │   ├── constants.dart
│   │   │   ├── formatters.dart
│   │   │   ├── photo_picker.dart
│   │   │   ├── theme.dart
│   │   │   └── ui_feedback.dart
│   │   ├── models/
│   │   │   ├── comment_model.dart
│   │   │   ├── post_model.dart
│   │   │   └── user_model.dart
│   │   ├── screens/
│   │   │   ├── category_posts_screen.dart
│   │   │   ├── create_post_screen.dart
│   │   │   ├── edit_post_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── post_detail_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── post_service.dart
│   │   │   └── user_service.dart
│   │   ├── widgets/
│   │   │   ├── avatar_options_sheet.dart
│   │   │   ├── bottom_nav_bar.dart
│   │   │   ├── hashtag_autocomplete_field.dart
│   │   │   ├── hashtag_text.dart
│   │   │   ├── like_action.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── post_card.dart
│   │   │   ├── state_views.dart
│   │   │   └── user_avatar.dart
│   │   ├── routes.dart
│   │   └── main.dart
│   └── pubspec.yaml
```

### 4.2.2 Branching Strategy

Menggunakan **Git Flow** yang disederhanakan:

| Branch | Fungsi |
|---|---|
| `main` | Production-ready, stable |
| `dev` | Integrasi fitur |
| `feature/*` | Pengembangan fitur spesifik |

**Alur Branching:**

```
main          ●────────●───────────────●───────►
              │        ▲               ▲
              │        │               │
dev           ●───●────●───●───●───────●───────►
                  │    ▲       ▲
                  │    │       │
feature/auth      ●────┘       │
                               │
feature/post-crud              ●────►
```

**Contoh alur kerja:**

1. `git checkout dev` → `git checkout -b feature/auth`
2. Develop fitur auth → commit berkala
3. `git push origin feature/auth`
4. Buka Pull Request ke `dev`
5. Setelah review, merge ke `dev`
6. Setelah semua fitur stabil, merge `dev` → `main`

**Konvensi Commit:**

- `feat: tambah fitur login` — fitur baru
- `fix: perbaiki bug upload avatar` — perbaikan bug
- `docs: update README` — dokumentasi
- `refactor: rapihin kode post service` — refactor
- `style: perbaiki indentasi` — styling

**Branch yang diterapkan:**

| Branch | Isi |
|---|---|
| `main` | Versi stable |
| `dev` | Integrasi semua fitur |
| `feature/auth` | Register, login, JWT, middleware |
| `feature/post-crud` | CRUD post, upload gambar |
| `feature/categories` | Autocomplete hashtag, trending |
| `feature/comments` | CRUD komentar |
| `feature/avatar` | Upload & ganti avatar |
| `feature/ui-polish` | Dark theme, bottom bar, styling |

---

# BAB V — PENUTUP

## 5.1 Kesimpulan

Berdasarkan perancangan sistem yang telah dijabarkan, dapat disimpulkan:

1. Sistem aplikasi blog **KATA** dirancang untuk memenuhi kebutuhan berbagi artikel berbasis mobile dengan fitur CRUD lengkap, kategori/hashtag, komentar, dan personalisasi avatar.
2. Arsitektur sistem menggunakan pendekatan **client-server** dengan **REST API** sebagai jembatan antara aplikasi Flutter dengan database MySQL.
3. Struktur basis data terdiri dari **5 tabel** (users, posts, categories, comments, likes) dengan relasi *foreign key* yang menerapkan **CASCADE**.
4. Metode pengembangan yang digunakan adalah **Agile (Scrum sederhana)** karena fleksibel dan cocok untuk tim kecil.
5. Sistem dikelola menggunakan **GitHub dengan branching strategy** (main, dev, feature/*) dan **Trello** sebagai project management board.
6. Sistem ini tidak hanya memenuhi kriteria wajib ujian, tetapi juga menghadirkan **fitur inovasi** di atas standar minimal: autentikasi JWT dengan persist session, suka (like) yang tersimpan di database, pencarian tulisan & topik, edit profil & pengaturan akun, autocomplete hashtag, upload gambar/avatar via Cloudinary, komentar interaktif, dan UI/UX modern bertema monokrom.

## 5.2 Saran

Untuk pengembangan selanjutnya, beberapa hal yang dapat ditambahkan:

- **Pagination / infinite scroll** — feed saat ini memuat satu halaman (`limit` maksimum 50 dari server)
- **Indeks FULLTEXT** — pencarian `?q=` masih memakai `LIKE`; kalau jumlah artikel membesar, tambahkan indeks FULLTEXT pada `title` dan `content`
- **Simpan (bookmark) artikel** — tab **Disimpan** pada profil belum aktif karena belum ada tabelnya
- **Ikuti penulis (follow)** — tombol **Ikuti** baru menampilkan keterangan belum tersedia
- **Notifikasi** — pemberitahuan saat artikel yang ditulis mendapat komentar baru
- **Hapus komentar dari client** — endpoint `DELETE /comments/:id` sudah tersedia di server, tetapi belum ada tombolnya di aplikasi
- **Dark/Light Mode Toggle** — pilihan tema oleh pengguna

---

# Lampiran

## A. Tautan Repository

| Item | Link |
|---|---|
| **GitHub** | `https://github.com/[username]/kata-blog-app` |
| **APK (opsional)** | `[link download]` |
| **Video Demo (opsional)** | `[link video]` |

## B. Dokumentasi Trello

> 📸 *[Screenshot Trello board — semua card di "Done"]*

**Struktur Board:**

| List | Jumlah Card |
|---|---|
| Backlog | [X] |
| To Do | [X] |
| In Progress | [X] |
| Testing | [X] |
| Done | [X] |

## C. Dokumentasi Branching GitHub

> 📸 *[Screenshot branch list]*
> 📸 *[Screenshot Pull Request]*
> 📸 *[Screenshot commit history]*

## D. Screenshot UI

| Halaman | Screenshot |
|---|---|
| Beranda (feed artikel) | *[sisipkan gambar]* |
| Pencarian (topik populer & tulisan) | *[sisipkan gambar]* |
| Detail Artikel | *[sisipkan gambar]* |
| Buat artikel | *[sisipkan gambar]* |
| Edit artikel | *[sisipkan gambar]* |
| Profil (tab Tulisan / Disukai) | *[sisipkan gambar]* |
| Edit profil | *[sisipkan gambar]* |
| Pengaturan | *[sisipkan gambar]* |
| Komentar | *[sisipkan gambar]* |
| Filter topik | *[sisipkan gambar]* |

## E. API Endpoint Documentation

| Method | Endpoint | Deskripsi |
|---|---|---|
| POST | `/api/v1/auth/register` | Register |
| POST | `/api/v1/auth/login` | Login |
| POST | `/api/v1/auth/logout` | Logout (butuh token) |
| GET | `/api/v1/posts` | List post |
| GET | `/api/v1/posts/:id` | Detail post |
| POST | `/api/v1/posts` | Buat post |
| PUT | `/api/v1/posts/:id` | Edit post |
| DELETE | `/api/v1/posts/:id` | Hapus post |
| GET | `/api/v1/categories/search?q=` | Autocomplete |
| GET | `/api/v1/categories/trending` | Trending |
| GET | `/api/v1/categories/:name/posts` | Post by kategori |
| GET | `/api/v1/posts/:id/comments` | List komentar |
| POST | `/api/v1/posts/:id/comments` | Kirim komentar |
| DELETE | `/api/v1/comments/:id` | Hapus komentar |
| POST | `/api/v1/posts/:id/like` | Suka / batal suka |
| GET | `/api/v1/likes/me` | Artikel yang disukai |
| GET | `/api/v1/users/me` | Data user login |
| PUT | `/api/v1/users/me` | Ubah username & email |
| PUT | `/api/v1/users/me/password` | Ganti password |
| PUT | `/api/v1/users/avatar` | Ganti avatar |
| DELETE | `/api/v1/users/me/avatar` | Hapus avatar |
| DELETE | `/api/v1/users/me` | Hapus akun |

## F. Cara Menjalankan Project

### Backend

```bash
cd server
npm install
# Setup .env (lihat di bawah)
mysql -u root -p < db/schema.sql   # buat database + tabel (setara npx drizzle-kit push)
npm run dev
# Server jalan di http://localhost:3006
```

**File `.env`:**

```env
PORT=3006
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=blog_app
JWT_SECRET=isi_dengan_48_karakter_acak

CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx
```

Buat database beserta tabelnya dengan menjalankan `server/db/schema.sql`:

```bash
mysql -u root -p < server/db/schema.sql
mysql -u root -p blog_app < server/db/inspect.sql   # opsional: cek struktur
```

### Frontend

```bash
cd client
flutter pub get
flutter run
```

**Catatan Base URL** (di `lib/core/constants.dart`):

| Platform | URL |
|---|---|
| Android emulator | `http://10.0.2.2:3006` |
| iOS simulator | `http://localhost:3006` |
| Device fisik | `http://<IP_LAPTOP>:3006` |

---

## 📄 Lisensi

Project ini dibuat untuk keperluan **Assessment Sumatif Tengah Semester** mata pelajaran Mapil Pilihan, Kompetensi Keahlian Rekayasa Perangkat Lunak, SMK Taruna Bhakti, Tahun Pelajaran 2026/2027.

---

**— SELESAI —**

*Dokumen ini disusun sebagai bagian dari Assessment Sumatif Tengah Semester mata pelajaran Mapil Pilihan, Kompetensi Keahlian Rekayasa Perangkat Lunak, SMK Taruna Bhakti, Tahun Pelajaran 2026/2027.*