import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';

/// ViewModel for the note detail screen.
///
/// Loads a single [Note] along with its resolved [Category], and provides
/// actions for toggling pin state, deleting, and exporting the note.
class NoteDetailViewModel extends ChangeNotifier {
  NoteDetailViewModel({
    required NoteRepository noteRepository,
    required CategoryRepository categoryRepository,
  })  : _noteRepo = noteRepository,
        _categoryRepo = categoryRepository;

  final NoteRepository _noteRepo;
  final CategoryRepository _categoryRepo;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  Note? _note;
  Note? get note => _note;

  /// The resolved category for the current note (if any).
  Category? _category;
  Category? get category => _category;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Loads a note by [id] and resolves its category (if `categoryId != null`).
  Future<void> loadNote(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _note = await _noteRepo.getNoteById(id);

      if (_note?.categoryId != null) {
        _category = await _categoryRepo.getCategoryById(_note!.categoryId!);
      } else {
        _category = null;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat catatan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles the pin state of the current note and reloads it.
  Future<void> togglePin() async {
    if (_note == null) return;

    _errorMessage = null;

    try {
      await _noteRepo.togglePin(_note!.id!, !_note!.isPinned);
      await loadNote(_note!.id!);
    } catch (e) {
      _errorMessage = 'Gagal mengubah pin: $e';
      notifyListeners();
    }
  }

  /// Deletes the current note. Returns `true` on success.
  Future<bool> deleteNote() async {
    if (_note == null) return false;

    _errorMessage = null;

    try {
      await _noteRepo.deleteNote(_note!.id!);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus catatan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Exports the current note to a temporary file and returns the file path.
  ///
  /// [format] must be either `'md'` or `'txt'`.
  /// - For `.md`, the raw Markdown content is written as-is.
  /// - For `.txt`, basic Markdown syntax is stripped for plain-text output.
  ///
  /// The filename is derived from the note title.
  Future<String> exportNote(String format) async {
    if (_note == null) {
      throw StateError('No note loaded to export');
    }

    try {
      final dir = await getTemporaryDirectory();
      final sanitizedTitle =
          _note!.title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final fileName =
          sanitizedTitle.isEmpty ? 'catatan' : sanitizedTitle;
      final file = File('${dir.path}/$fileName.$format');

      String fileContent;

      if (format == 'txt') {
        // Strip common Markdown syntax for plain-text export.
        fileContent = _stripMarkdown(_note!.content);
      } else {
        // .md — include title as heading + raw content.
        fileContent = '# ${_note!.title}\n\n${_note!.content}';
      }

      await file.writeAsString(fileContent);

      return file.path;
    } catch (e) {
      _errorMessage = 'Gagal mengekspor catatan: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Strips basic Markdown syntax for a plain-text representation.
  String _stripMarkdown(String markdown) {
    var text = markdown;

    // Remove headings (# ... ######)
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove bold / italic markers
    text = text.replaceAll(RegExp(r'\*{1,3}'), '');
    text = text.replaceAll(RegExp(r'_{1,3}'), '');

    // Remove strikethrough
    text = text.replaceAll(RegExp(r'~~'), '');

    // Remove inline code backticks
    text = text.replaceAll(RegExp(r'`'), '');

    // Convert Markdown links [text](url) → text
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');

    // Convert Markdown images ![alt](url) → alt
    text = text.replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), r'$1');

    // Remove horizontal rules
    text = text.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');

    // Convert checkbox markers
    text = text.replaceAll(RegExp(r'- \[x\]'), '☑');
    text = text.replaceAll(RegExp(r'- \[ \]'), '☐');

    return text.trim();
  }
}
