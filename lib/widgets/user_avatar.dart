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
