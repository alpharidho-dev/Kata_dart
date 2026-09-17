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
