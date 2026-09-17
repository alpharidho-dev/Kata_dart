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
