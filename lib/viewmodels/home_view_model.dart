import 'package:flutter/foundation.dart' hide Category;

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';

/// ViewModel for the home screen.
///
/// Manages the list of notes with support for category filtering,
/// live search, pin toggling, and note deletion. Injects both
/// [NoteRepository] and [CategoryRepository] via constructor.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required NoteRepository noteRepository,
    required CategoryRepository categoryRepository,
  })  : _noteRepo = noteRepository,
        _categoryRepo = categoryRepository;

  final NoteRepository _noteRepo;
  final CategoryRepository _categoryRepo;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  /// `null` means "All categories".
  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Loads notes based on the current [selectedCategoryId] and [searchQuery].
  ///
  /// Decision matrix:
  /// - category + search → [NoteRepository.searchNotesByCategory]
  /// - search only       → [NoteRepository.searchNotes]
  /// - category only     → [NoteRepository.getNotesByCategory]
  /// - neither           → [NoteRepository.getAllNotes]
  Future<void> loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasSearch = _searchQuery.isNotEmpty;
      final hasCategory = _selectedCategoryId != null;

      if (hasSearch && hasCategory) {
        _notes = await _noteRepo.searchNotesByCategory(
          _searchQuery,
          _selectedCategoryId!,
        );
      } else if (hasSearch) {
        _notes = await _noteRepo.searchNotes(_searchQuery);
      } else if (hasCategory) {
        _notes = await _noteRepo.getNotesByCategory(_selectedCategoryId!);
      } else {
        _notes = await _noteRepo.getAllNotes();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat catatan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads all available categories for the filter chips.
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

  /// Selects a category filter and reloads notes.
  ///
  /// Pass `null` to clear the filter (show all notes).
  Future<void> selectCategory(int? id) async {
    _selectedCategoryId = id;
    notifyListeners();
    await loadNotes();
  }

  /// Updates the search query and reloads notes.
  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();
    await loadNotes();
  }

  /// Toggles the pin state of a note and reloads the list.
  Future<void> toggleNotePin(int noteId, bool currentPinState) async {
    _errorMessage = null;

    try {
      await _noteRepo.togglePin(noteId, !currentPinState);
      await loadNotes();
    } catch (e) {
      _errorMessage = 'Gagal mengubah pin: $e';
      notifyListeners();
    }
  }

  /// Deletes a note by [id] and reloads the list.
  Future<void> deleteNote(int id) async {
    _errorMessage = null;

    try {
      await _noteRepo.deleteNote(id);
      await loadNotes();
    } catch (e) {
      _errorMessage = 'Gagal menghapus catatan: $e';
      notifyListeners();
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
