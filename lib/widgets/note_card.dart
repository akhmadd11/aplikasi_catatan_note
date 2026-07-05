import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';
import 'package:aplikasi_catatan_note/utils/date_formatter.dart';

/// A glassmorphism-styled card widget that displays a note summary
/// in list views. Shows title, content preview, category chip,
/// smart date, and pin status.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.category,
    required this.onTap,
    required this.onPinToggle,
  });

  /// The note data to display.
  final Note note;

  /// Optional category associated with this note.
  final Category? category;

  /// Callback when the card is tapped (navigate to detail).
  final VoidCallback onTap;

  /// Callback when the pin icon is toggled.
  final VoidCallback onPinToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with pin icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Animated pin icon
                  GestureDetector(
                    onTap: onPinToggle,
                    child: AnimatedOpacity(
                      opacity: note.isPinned ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 20,
                        color: note.isPinned
                            ? AppColors.secondary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Content preview
              Text(
                note.contentPreview,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Bottom row: category chip + date
              Row(
                children: [
                  // Category chip (if exists)
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            category!.colorHex.replaceFirst('#', '0xFF'),
                          ),
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PredefinedIcons.getIconData(category!.iconCode),
                            size: 12,
                            color: Color(
                              int.parse(
                                category!.colorHex.replaceFirst('#', '0xFF'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Color(
                                int.parse(
                                  category!.colorHex
                                      .replaceFirst('#', '0xFF'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),

                  // Smart date
                  Text(
                    DateFormatter.formatSmartDate(note.updatedAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
