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
