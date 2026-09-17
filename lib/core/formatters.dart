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
