import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/post_service.dart';

/// TextField dengan autocomplete hashtag.
///
/// Saat user ngetik `#` diikuti huruf, widget cari kategori
/// yang cocok dari BE lalu tampilkan sebagai saran di bawah input.
class HashtagAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const HashtagAutocompleteField({
    super.key,
    required this.controller,
    this.hintText = 'Tulis caption...',
    this.helperText,
    this.minLines = 3,
    this.maxLines = 5,
    this.enabled = true,
  });

  @override
  State<HashtagAutocompleteField> createState() =>
      _HashtagAutocompleteFieldState();
}

class _HashtagAutocompleteFieldState extends State<HashtagAutocompleteField> {
  final PostService _postService = PostService();

  List<String> _suggestions = [];
  String? _currentPrefix;
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    // Kalau kursor gak di akhir, skip
    if (!selection.isValid || selection.baseOffset != text.length) {
      _hideSuggestions();
      return;
    }

    // Regex: cari `#` diikuti word chars, di akhir string
    final match = RegExp(r'#(\w*)$').firstMatch(text);

    if (match == null) {
      _hideSuggestions();
      return;
    }

    final prefix = match.group(1) ?? '';
    _currentPrefix = prefix;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _search(prefix);
    });
  }

  Future<void> _search(String prefix) async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final results = await _postService.searchCategories(prefix);
      if (!mounted) return;

      // Buang yang persis sama dengan prefix
      final filtered = results
          .where((r) => r.toLowerCase() != prefix.toLowerCase())
          .toList();

      setState(() {
        _suggestions = filtered;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  void _hideSuggestions() {
    if (_suggestions.isEmpty && !_isSearching) return;
    if (!mounted) return;
    setState(() {
      _suggestions = [];
      _currentPrefix = null;
      _isSearching = false;
    });
  }

  void _applySuggestion(String tag) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    final beforeCursor = text.substring(0, selection.baseOffset);
    final match = RegExp(r'#(\w*)$').firstMatch(beforeCursor);
    if (match == null) return;

    final start = match.start;
    final end = match.end;

    // Ganti `#prefix` → `#tag ` (kasih spasi di akhir)
    final newText = text.replaceRange(start, end, '#$tag ');
    final newOffset = start + tag.length + 2;

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );

    setState(() {
      _suggestions = [];
      _currentPrefix = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _suggestions.isNotEmpty || _isSearching;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            helperStyle: const TextStyle(color: AppColors.textMuted),
          ),
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        if (showSuggestions) _buildSuggestionBox(),
      ],
    );
  }

  Widget _buildSuggestionBox() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _isSearching && _suggestions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Text(
                    'Saran hashtag',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ..._suggestions.map((tag) {
                  return InkWell(
                    onTap: () => _applySuggestion(tag),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tag_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                children: [
                                  if (_currentPrefix != null &&
                                      _currentPrefix!.isNotEmpty)
                                    TextSpan(text: _currentPrefix),
                                  TextSpan(
                                    text: tag.substring(
                                      _currentPrefix?.length ?? 0,
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}