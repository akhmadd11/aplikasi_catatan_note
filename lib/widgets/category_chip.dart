import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A compact category filter chip with animated selection state.
///
/// When [isSelected] is true, the chip fills with [color] and
/// displays white text. When false, it shows an outlined border
/// with colored text.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  /// Display label for the category.
  final String label;

  /// Category color used for fill/border/text.
  final Color color;

  /// Whether this chip is currently selected.
  final bool isSelected;

  /// Callback when the chip is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
