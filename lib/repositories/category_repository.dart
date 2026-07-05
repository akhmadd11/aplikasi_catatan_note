import 'package:aplikasi_catatan_note/database/database_helper.dart';
import 'package:aplikasi_catatan_note/models/category.dart';
import 'package:aplikasi_catatan_note/utils/constants.dart';

/// Repository for category CRUD operations.
///
/// Stateless — every call queries SQLite directly via [DatabaseHelper].
class CategoryRepository {
  /// Returns all categories ordered by creation date.
  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper.instance.getDatabase();
    final maps = await db.query(
      DbConfig.tableCategories,
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Returns a single category by [id], or `null` if not found.
  Future<Category?> getCategoryById(int id) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final maps = await db.query(
      DbConfig.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Inserts a new category and returns the auto-generated row id.
  Future<int> insertCategory(Category category) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.insert(DbConfig.tableCategories, category.toMap());
  }

  /// Updates an existing category and returns the number of affected rows.
  Future<int> updateCategory(Category category) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.update(
      DbConfig.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Deletes a category by [id] and returns the number of affected rows.
  ///
  /// Related notes will have their `category_id` set to `NULL`
  /// automatically via the `ON DELETE SET NULL` foreign key constraint.
  Future<int> deleteCategory(int id) async {
    final db = await DatabaseHelper.instance.getDatabase();
    return db.delete(
      DbConfig.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
