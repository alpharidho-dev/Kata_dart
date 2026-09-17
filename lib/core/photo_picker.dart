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
