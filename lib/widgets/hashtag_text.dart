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
