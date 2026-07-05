import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/viewmodels/home_view_model.dart';
import 'package:aplikasi_catatan_note/repositories/note_repository.dart';
import 'package:aplikasi_catatan_note/repositories/category_repository.dart';
import 'package:aplikasi_catatan_note/widgets/note_card.dart';
import 'package:aplikasi_catatan_note/widgets/search_bar_widget.dart';
import 'package:aplikasi_catatan_note/widgets/category_chip.dart';
import 'package:aplikasi_catatan_note/widgets/empty_state_widget.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  Timer? _debounceTimer;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      noteRepository: NoteRepository(),
      categoryRepository: CategoryRepository(),
    );
    _viewModel.loadNotes();
    _viewModel.loadCategories();
    _viewModel.addListener(_onViewModelChanged);
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

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _viewModel.updateSearchQuery(query);
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _debounceTimer?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Kelola Kategori',
            onPressed: () {
              context.push('/categories').then((_) {
                _viewModel.loadNotes();
                _viewModel.loadCategories();
              });
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBarWidget(
                  onChanged: _onSearchChanged,
                ),
              ),

              // Category Filter Chips
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _viewModel.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CategoryChip(
                          label: 'Semua',
                          color: AppColors.secondary,
                          isSelected: _viewModel.selectedCategoryId == null,
                          onTap: () => _viewModel.selectCategory(null),
                        ),
                      );
                    }
                    final category = _viewModel.categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CategoryChip(
                        label: category.name,
                        color: Color(
                          int.parse(
                            category.colorHex.replaceFirst('#', '0xFF'),
                          ),
                        ),
                        isSelected:
                            _viewModel.selectedCategoryId == category.id,
                        onTap: () => _viewModel.selectCategory(category.id),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/note/new').then((_) {
            _viewModel.loadNotes();
            _viewModel.loadCategories();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final notes = _viewModel.notes;
    if (notes.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.note_add_outlined,
        message: 'Belum ada catatan\nTap tombol + untuk membuat catatan baru',
      );
    }

    final pinnedNotes = notes.where((n) => n.isPinned).toList();
    final unpinnedNotes = notes.where((n) => !n.isPinned).toList();

    // Build a flat list with section headers
    final List<_ListItem> items = [];

    if (pinnedNotes.isNotEmpty) {
      items.add(const _ListItem.header('Disematkan'));
      for (final note in pinnedNotes) {
        items.add(_ListItem.note(note));
      }
    }

    if (unpinnedNotes.isNotEmpty) {
      items.add(const _ListItem.header('Catatan'));
      for (final note in unpinnedNotes) {
        items.add(_ListItem.note(note));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              children: [
                if (item.headerTitle == 'Disematkan')
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.push_pin,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ),
                Text(
                  item.headerTitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }

        final note = item.noteData!;
        // Find matching category for the note
        final category = note.categoryId != null
            ? _viewModel.categories
                .where((c) => c.id == note.categoryId)
                .firstOrNull
            : null;

        return NoteCard(
          note: note,
          category: category,
          onTap: () {
            context.push('/note/${note.id}').then((_) {
              _viewModel.loadNotes();
              _viewModel.loadCategories();
            });
          },
          onPinToggle: () {
            _viewModel.toggleNotePin(note.id!, !note.isPinned);
          },
        );
      },
    );
  }
}

/// Helper class to represent items in the flat list (headers + notes).
class _ListItem {
  final bool isHeader;
  final String? headerTitle;
  final Note? noteData;

  const _ListItem.header(this.headerTitle)
      : isHeader = true,
        noteData = null;

  const _ListItem.note(this.noteData)
      : isHeader = false,
        headerTitle = null;
}
