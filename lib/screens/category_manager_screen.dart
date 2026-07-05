import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aplikasi_catatan_note/viewmodels/category_manager_view_model.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';
import 'package:aplikasi_catatan_note/widgets/empty_state_widget.dart';
import 'package:aplikasi_catatan_note/models/category.dart' as model;

/// Screen for full CRUD management of note categories.
///
/// Displays a list of categories with options to add, edit, and delete.
/// Uses [CategoryManagerViewModel] for state management via
/// [ListenableBuilder].
class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  late final CategoryManagerViewModel _viewModel;
  String? _lastError;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _viewModel = CategoryManagerViewModel(
      categoryRepository: CategoryRepository(),
    );
    _viewModel.loadCategories();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Error listener
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Parses a hex color string (e.g. '#E94560') into a [Color].
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  /// Opens the add / edit dialog. When [category] is provided the dialog
  /// pre-populates the fields for editing.
  Future<void> _showCategoryDialog({model.Category? category}) async {
    final isEditing = category != null;

    final nameController = TextEditingController(
      text: isEditing ? category.name : '',
    );
    final nameFocusNode = FocusNode();

    int selectedIconCode = isEditing
        ? category.iconCode
        : PredefinedIcons.icons.first['codePoint'] as int;

    String selectedColorHex = isEditing
        ? category.colorHex
        : PredefinedColors.colors.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isEditing ? 'Edit Kategori' : 'Tambah Kategori',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // — Name field —
                    TextField(
                      controller: nameController,
                      focusNode: nameFocusNode,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // — Icon picker label —
                    Text(
                      'Pilih Ikon',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // — Icon picker grid (4 × 3) —
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: PredefinedIcons.icons.length,
                      itemBuilder: (_, index) {
                        final iconData = PredefinedIcons.icons[index];
                        final codePoint = iconData['codePoint'] as int;
                        final isSelected = codePoint == selectedIconCode;
                        final selectedColor = _hexToColor(selectedColorHex);

                        return Tooltip(
                          message: iconData['label'] as String,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setDialogState(
                                () => selectedIconCode = codePoint,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: 0.15)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : Colors.grey[800]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                PredefinedIcons.getIconData(codePoint),
                                color: isSelected
                                    ? selectedColor
                                    : Colors.grey[400],
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // — Color picker label —
                    Text(
                      'Pilih Warna',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // — Color picker row —
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: PredefinedColors.colors.map((hex) {
                        final color = _hexToColor(hex);
                        final isSelected = hex == selectedColorHex;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(
                              () => selectedColorHex = hex,
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Nama kategori tidak boleh kosong',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    bool success;
                    if (isEditing) {
                      success = await _viewModel.updateCategory(
                        category.id!,
                        name,
                        selectedIconCode,
                        selectedColorHex,
                      );
                    } else {
                      success = await _viewModel.addCategory(
                        name,
                        selectedIconCode,
                        selectedColorHex,
                      );
                    }

                    if (success && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameFocusNode.dispose();
    nameController.dispose();
  }

  /// Shows a confirmation dialog before deleting a category.
  Future<void> _showDeleteDialog(model.Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus kategori ${category.name}?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Catatan yang menggunakan kategori ini akan menjadi '
            'tidak berkategori.',
            style: GoogleFonts.poppins(
              color: Colors.grey[300],
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _viewModel.deleteCategory(category.id!);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Kategori',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = _viewModel.categories;

    if (categories.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_off_outlined,
        message: 'Belum ada kategori.\nTap tombol + untuk menambahkan.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = _hexToColor(category.colorHex);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PredefinedIcons.getIconData(category.iconCode),
                  color: color,
                  size: 24,
                ),
              ),
              title: Text(
                category.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color indicator
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: Colors.grey[400],
                    tooltip: 'Edit',
                    onPressed: () =>
                        _showCategoryDialog(category: category),
                  ),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.primary,
                    tooltip: 'Hapus',
                    onPressed: () => _showDeleteDialog(category),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
