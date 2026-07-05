import 'package:flutter/foundation.dart' hide Category;

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';

/// ViewModel for the note editor screen.
///
/// Supports both **creating** a new note and **editing** an existing one.
/// When [existingNote] is `null`, the editor is in "create" mode.
class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required NoteRepository noteRepository,
    required CategoryRepository categoryRepository,
  })  : _noteRepo = noteRepository,
        _categoryRepo = categoryRepository;

  final NoteRepository _noteRepo;
  final CategoryRepository _categoryRepo;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// The note being edited, or `null` when creating a new note.
  Note? _existingNote;
  Note? get existingNote => _existingNote;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isPreviewMode = false;
  bool get isPreviewMode => _isPreviewMode;

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Loads all categories for the category dropdown / picker.
  Future<void> loadCategories() async {
    _errorMessage = null;

    try {
      _categories = await _categoryRepo.getAllCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  /// Loads an existing note for editing by [id].
  ///
  /// Sets [existingNote] and [selectedCategoryId] from the loaded data.
  Future<void> loadNote(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _existingNote = await _noteRepo.getNoteById(id);
      _selectedCategoryId = _existingNote?.categoryId;
    } catch (e) {
      _errorMessage = 'Gagal memuat catatan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a category for the current note.
  void selectCategory(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  /// Toggles between edit mode and Markdown preview mode.
  void togglePreviewMode() {
    _isPreviewMode = !_isPreviewMode;
    notifyListeners();
  }

  /// Saves the note (create or update) and returns `true` on success.
  ///
  /// If [existingNote] is `null`, a new note is created with both `createdAt`
  /// and `updatedAt` set to now. Otherwise, only `updatedAt` is refreshed.
  Future<bool> saveNote(String title, String content) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      if (_existingNote == null) {
        // --- Create ---
        final newNote = Note(
          title: title,
          content: content,
          categoryId: _selectedCategoryId,
          isPinned: false,
          createdAt: now,
          updatedAt: now,
        );
        await _noteRepo.insertNote(newNote);
      } else {
        // --- Update ---
        final updatedNote = _existingNote!.copyWith(
          title: title,
          content: content,
          categoryId: () => _selectedCategoryId,
          updatedAt: now,
        );
        await _noteRepo.updateNote(updatedNote);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan catatan: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
