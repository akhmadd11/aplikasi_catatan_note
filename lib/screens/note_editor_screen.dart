import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:aplikasi_catatan_note/viewmodels/note_editor_view_model.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';
import 'package:aplikasi_catatan_note/widgets/markdown_toolbar.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final int? noteId;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final NoteEditorViewModel _viewModel;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _lastError;

  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _viewModel = NoteEditorViewModel(
      noteRepository: NoteRepository(),
      categoryRepository: CategoryRepository(),
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadCategories();

    if (_isEditing) {
      _viewModel.loadNote(widget.noteId!).then((_) {
        final note = _viewModel.existingNote;
        if (note != null) {
          _titleController.text = note.title;
          _contentController.text = note.content;
        }
      });
    }
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
        ),
      );
    } else if (error == null) {
      _lastError = null;
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul catatan tidak boleh kosong'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final content = _contentController.text;
    final success = await _viewModel.saveNote(title, content);
    if (success && mounted) {
      context.pop();
    }
  }

  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Catatan' : 'Catatan Baru'),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  _viewModel.isPreviewMode
                      ? Icons.edit_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: _viewModel.isPreviewMode
                    ? 'Mode Edit'
                    : 'Mode Preview',
                onPressed: () => _viewModel.togglePreviewMode(),
              );
            },
          ),
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return IconButton(
                icon: _viewModel.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                tooltip: 'Simpan',
                onPressed: _viewModel.isSaving ? null : _saveNote,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Title field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Judul catatan',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  maxLines: 1,
                ),
              ),

              // Category dropdown
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DropdownButtonFormField<int?>(
                  // ignore: deprecated_member_use
                  value: _viewModel.selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: Colors.white),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tanpa Kategori'),
                    ),
                    ..._viewModel.categories.map((category) {
                      return DropdownMenuItem<int?>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(
                              PredefinedIcons.getIconData(category.iconCode),
                              size: 18,
                              color: Color(
                                int.parse(
                                  category.colorHex
                                      .replaceFirst('#', '0xFF'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => _viewModel.selectCategory(value),
                ),
              ),

              const Divider(height: 1, color: Colors.white12),

              // Content area: preview or edit
              if (_viewModel.isPreviewMode)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _contentController.text.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada konten untuk ditampilkan',
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : Markdown(
                            data: _contentController.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
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
                              code: TextStyle(
                                color: AppColors.secondary,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.05),
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
                            ),
                          ),
                  ),
                )
              else ...[
                // Markdown Toolbar
                MarkdownToolbar(controller: _contentController),

                // Content text field
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tulis catatan dengan Markdown...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
