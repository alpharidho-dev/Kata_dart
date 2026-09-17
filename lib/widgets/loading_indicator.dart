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