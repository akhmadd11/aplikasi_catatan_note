import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:aplikasi_catatan_note/utils/constants.dart';

/// Singleton helper for SQLite database access.
///
/// Manages database creation, table setup, and default data insertion.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  /// Returns the database instance, creating it if necessary.
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database file and creates tables.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConfig.databaseName);

    return openDatabase(
      path,
      version: DbConfig.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${DbConfig.tableCategories} (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            name       TEXT    NOT NULL UNIQUE,
            icon_code  INTEGER NOT NULL DEFAULT 983231,
            color_hex  TEXT    NOT NULL DEFAULT '#FFC107',
            created_at TEXT    NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ${DbConfig.tableNotes} (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT    NOT NULL,
            content     TEXT    NOT NULL DEFAULT '',
            category_id INTEGER,
            is_pinned   INTEGER NOT NULL DEFAULT 0,
            created_at  TEXT    NOT NULL,
            updated_at  TEXT    NOT NULL,
            FOREIGN KEY (category_id) REFERENCES ${DbConfig.tableCategories}(id) ON DELETE SET NULL
          )
        ''');

        await _insertDefaultCategories(db);
      },
    );
  }

  /// Inserts the three default categories on first database creation.
  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    for (final category in DefaultCategories.data) {
      await db.insert(DbConfig.tableCategories, {
        'name': category['name'],
        'icon_code': category['icon_code'],
        'color_hex': category['color_hex'],
        'created_at': now,
      });
    }
  }
}
