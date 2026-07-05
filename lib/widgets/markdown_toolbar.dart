import 'package:flutter/material.dart';

import 'package:aplikasi_catatan_note/utils/constants.dart';

/// A horizontal scrollable toolbar providing markdown formatting
/// buttons for the note editor.
///
/// This is a [StatelessWidget] — the [TextEditingController] is
/// owned by the parent editor screen and passed in.
///
/// Supported formats: Bold, Italic, Heading, Bullet List,
/// Checkbox, Code Block.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
  });

  /// The text editing controller from the editor's content field.
  final TextEditingController controller;

  /// Inserts markdown syntax around the current selection or at
  /// cursor position.
  ///
  /// If text is selected, wraps it with [before] and [after].
  /// If no text is selected, inserts [before] + [after] and
  /// places the cursor between them.
  void _insertMarkdown(String before, String after) {
    final text = controller.text;
    final selection = controller.selection;

    // Guard against invalid selection
    if (!selection.isValid) return;

    final start = selection.start;
    final end = selection.end;

    if (selection.isCollapsed) {
      // No selection — insert markers and place cursor between them
      final newText = text.substring(0, start) +
          before +
          after +
          text.substring(start);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: start + before.length,
        ),
      );
    } else {
      // Text selected — wrap selection with markers
      final selectedText = text.substring(start, end);
      final newText = text.substring(0, start) +
          before +
          selectedText +
          after +
          text.substring(end);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: start + before.length + selectedText.length + after.length,
        ),
      );
    }
  }

  /// Inserts a line-level markdown prefix (e.g., `# `, `- `).
  ///
  /// Inserts [prefix] at the beginning of the current line.
  void _insertLinePrefix(String prefix) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) return;

    final start = selection.start;

    // Find the beginning of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final newText =
        text.substring(0, lineStart) + prefix + text.substring(lineStart);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + prefix.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold',
              onPressed: () => _insertMarkdown('**', '**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic',
              onPressed: () => _insertMarkdown('*', '*'),
            ),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading',
              onPressed: () => _insertLinePrefix('# '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet List',
              onPressed: () => _insertLinePrefix('- '),
            ),
            _ToolbarButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Checkbox',
              onPressed: () => _insertLinePrefix('- [ ] '),
            ),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Code',
              onPressed: () => _insertMarkdown('```\n', '\n```'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal toolbar icon button with consistent styling.
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        color: Colors.grey[300],
        splashRadius: 20,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}
