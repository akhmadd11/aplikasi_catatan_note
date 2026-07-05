import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/viewmodels/note_detail_view_model.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';
import 'package:aplikasi_catatan_note/utils/date_formatter.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final int noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final NoteDetailViewModel _viewModel;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _viewModel = NoteDetailViewModel(
      noteRepository: NoteRepository(),
      categoryRepository: CategoryRepository(),
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadNote(widget.noteId);
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    
    final error = _viewModel.errorMessage;
    if (error != null && error != _lastError) {
      _lastError = error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () => _viewModel.clearError(),
          ),
        ),
      );
    } else if (error == null) {
      _lastError = null;
    }
  }

  Future<void> _togglePin() async {
    await _viewModel.togglePin();
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus Catatan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan ini? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _viewModel.deleteNote();
      if (success && mounted) {
        context.pop();
      }
    }
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ekspor Catatan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: AppColors.secondary,
                  ),
                  title: Text(
                    'Ekspor sebagai Markdown (.md)',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Menyimpan format Markdown asli',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _exportNote('md');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.text_snippet_outlined,
                    color: AppColors.secondary,
                  ),
                  title: Text(
                    'Ekspor sebagai Teks (.txt)',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Menghapus format Markdown',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _exportNote('txt');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportNote(String format) async {
    try {
      final filePath = await _viewModel.exportNote(format);
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: _viewModel.note?.title ?? 'Catatan',
      );
    } catch (_) {
      // Error is handled by the ViewModel listener via errorMessage
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final note = _viewModel.note;
          if (note == null) {
            return Center(
              child: Text(
                'Catatan tidak ditemukan',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip + pin badge
                _buildHeader(note),

                const SizedBox(height: 16),

                // Title
                Text(
                  note.title,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Date info
                _buildDateInfo(note),

                const SizedBox(height: 20),

                // Glassmorphism content card with Markdown
                _buildContentCard(note),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Text(
            _viewModel.note?.title ?? 'Detail Catatan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      actions: [
        // Pin toggle
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final isPinned = _viewModel.note?.isPinned ?? false;
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  key: ValueKey(isPinned),
                  color: isPinned ? AppColors.secondary : Colors.grey,
                ),
              ),
              tooltip: isPinned ? 'Lepas Pin' : 'Sematkan',
              onPressed: _viewModel.note != null ? _togglePin : null,
            );
          },
        ),

        // Edit button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit',
          onPressed: () {
            context
                .push('/note/${widget.noteId}/edit')
                .then((_) => _viewModel.loadNote(widget.noteId));
          },
        ),

        // Export button
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Ekspor',
          onPressed: _showExportSheet,
        ),

        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outlined),
          tooltip: 'Hapus',
          onPressed: _deleteNote,
        ),
      ],
    );
  }

  Widget _buildHeader(Note note) {
    final category = _viewModel.category;

    return Row(
      children: [
        if (category != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color(
                int.parse(
                  category.colorHex.replaceFirst('#', '0xFF'),
                ),
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PredefinedIcons.getIconData(category.iconCode),
                  size: 14,
                  color: Color(
                    int.parse(
                      category.colorHex.replaceFirst('#', '0xFF'),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(
                      int.parse(
                        category.colorHex.replaceFirst('#', '0xFF'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (note.isPinned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.push_pin,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Disematkan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDateInfo(Note note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.white38,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Dibuat: ${DateFormatter.formatSmartDate(note.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 16,
            color: Colors.white12,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_calendar_outlined,
                    size: 14,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Diubah: ${DateFormatter.formatSmartDate(note.updatedAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Note note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: note.content.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Tidak ada konten',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : MarkdownBody(
              data: note.content,
              selectable: true,
              styleSheet: _markdownStyleSheet(),
            ),
    );
  }

  /// Markdown style matching NoteEditorScreen preview.
  MarkdownStyleSheet _markdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        height: 1.6,
      ),
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      h4: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      h5: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      h6: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      code: TextStyle(
        color: AppColors.secondary,
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      listBullet: const TextStyle(
        color: Colors.white70,
      ),
      blockquoteDecoration: BoxDecoration(
        border: const Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      a: const TextStyle(
        color: AppColors.secondary,
        decoration: TextDecoration.underline,
      ),
      strong: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      em: const TextStyle(
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      ),
      tableHead: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      tableBody: const TextStyle(
        color: Colors.white70,
      ),
      tableBorder: TableBorder.all(
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }
}
