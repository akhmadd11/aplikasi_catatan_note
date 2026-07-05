import 'package:flutter/foundation.dart' hide Category;

import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';

/// ViewModel for the category manager screen.
///
/// Provides full CRUD operations for [Category] entities, with loading
/// state and error handling via [errorMessage].
class CategoryManagerViewModel extends ChangeNotifier {
  CategoryManagerViewModel({
    required CategoryRepository categoryRepository,
  }) : _categoryRepo = categoryRepository;

  final CategoryRepository _categoryRepo;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Loads all categories from the repository.
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryRepo.getAllCategories();
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new category and reloads the list. Returns `true` on success.
  Future<bool> addCategory(
    String name,
    int iconCode,
    String colorHex,
  ) async {
    _errorMessage = null;

    try {
      final category = Category(
        name: name,
        iconCode: iconCode,
        colorHex: colorHex,
        createdAt: DateTime.now(),
      );
      await _categoryRepo.insertCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah kategori: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing category and reloads the list. Returns `true` on success.
  Future<bool> updateCategory(
    int id,
    String name,
    int iconCode,
    String colorHex,
  ) async {
    _errorMessage = null;

    try {
      final existing = await _categoryRepo.getCategoryById(id);
      if (existing == null) {
        _errorMessage = 'Kategori tidak ditemukan';
        notifyListeners();
        return false;
      }
      final updated = existing.copyWith(
        name: name,
        iconCode: iconCode,
        colorHex: colorHex,
      );
      await _categoryRepo.updateCategory(updated);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui kategori: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a category by [id] and reloads the list. Returns `true` on success.
  Future<bool> deleteCategory(int id) async {
    _errorMessage = null;

    try {
      await _categoryRepo.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus kategori: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
