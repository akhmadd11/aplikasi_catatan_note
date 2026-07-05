import 'package:aplikasi_catatan_note/database/database_helper.dart';
import 'package:aplikasi_catatan_note/models/note.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';

/// Default ordering: pinned notes first, then most recently updated.
const String _defaultOrder = 'is_pinned DESC, updated_at DESC';

/// Repository for note CRUD, search, and pin operations.
///
/// Stateless — every call queries SQLite directly via [DatabaseHelper].
class NoteRepository {
  /// Returns all notes ordered by pin status then update date.
  Future<List<Note>> getAllNotes() async {
    final db = await DatabaseHelper.instance.getDatabase();
    final maps = await db.query(
      DbConfig.tableNotes,
      orderBy: _defaultOrder,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Returns a single note by [id], or `null` if not found.
  Future<Note?> getNoteById(int id) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final maps = await db.query(
      DbConfig.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Returns notes belonging to a specific [categoryId],
  /// ordered by pin status then update date.
  Future<List<Note>> getNotesByCategory(int categoryId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final maps = await db.query(
      DbConfig.tableNotes,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: _defaultOrder,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Searches notes by [query] across title and content using SQL `LIKE`.
  /// Results are ordered by pin status then update date.
  Future<List<Note>> searchNotes(String query) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final wildcard = '%$query%';
    final maps = await db.query(
      DbConfig.tableNotes,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: [wildcard, wildcard],
      orderBy: _defaultOrder,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Searches notes by [query] within a specific [categoryId].
  /// Results are ordered by pin status then update date.
  Future<List<Note>> searchNotesByCategory(
    String query,
    int categoryId,
  ) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final wildcard = '%$query%';
    final maps = await db.query(
      DbConfig.tableNotes,
      where: 'category_id = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [categoryId, wildcard, wildcard],
      orderBy: _defaultOrder,
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Inserts a new note and returns the auto-generated row id.
  Future<int> insertNote(Note note) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.insert(DbConfig.tableNotes, note.toMap());
  }

  /// Updates an existing note and returns the number of affected rows.
  Future<int> updateNote(Note note) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.update(
      DbConfig.tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Deletes a note by [id] and returns the number of affected rows.
  Future<int> deleteNote(int id) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.delete(
      DbConfig.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles the pin state of a note by [id].
  ///
  /// Sets `is_pinned` to 1 if [isPinned] is `true`, 0 otherwise.
  /// Also updates `updated_at` to the current timestamp.
  Future<int> togglePin(int id, bool isPinned) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.update(
      DbConfig.tableNotes,
      {
        'is_pinned': isPinned ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
