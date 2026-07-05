import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aplikasi_catatan_note/utils/constants.dart';

/// A dark-themed search bar widget with rounded borders,
/// search icon prefix, and a clear button that appears
/// when text is entered.
///
/// Debouncing is NOT handled here — the parent ViewModel
/// should debounce the [onChanged] callback.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hintText = 'Cari catatan...',
  });

  /// Called whenever the search text changes.
  final ValueChanged<String> onChanged;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClear) {
      setState(() {
        _showClear = hasText;
      });
    }
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 22,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white10,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
