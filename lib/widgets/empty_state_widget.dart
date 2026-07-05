import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A centered empty state widget displayed when there is
/// no data to show (e.g., no notes, no search results).
///
/// Uses a [const] constructor for optimal performance.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.note_add_outlined,
  });

  /// The message displayed below the icon.
  final String message;

  /// The icon displayed above the message. Defaults to [Icons.note_add_outlined].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
