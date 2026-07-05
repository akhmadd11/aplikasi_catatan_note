import 'package:flutter/material.dart';

/// Database configuration constants.
abstract final class DbConfig {
  static const String databaseName = 'notes_app.db';
  static const int databaseVersion = 1;
  static const String tableCategories = 'categories';
  static const String tableNotes = 'notes';
}

/// App color palette — dark theme.
abstract final class AppColors {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color primary = Color(0xFFE94560);
  static const Color secondary = Color(0xFFFFC107);
}

/// Default category data inserted on first app launch.
///
/// Each map contains [name], [iconCode] (Material icon codePoint),
/// and [colorHex].
abstract final class DefaultCategories {
  static const List<Map<String, dynamic>> data = [
    {
      'name': 'Kuliah',
      'icon_code': 0xe559, // Icons.school
      'color_hex': '#4FC3F7',
    },
    {
      'name': 'Pribadi',
      'icon_code': 0xe491, // Icons.person
      'color_hex': '#E94560',
    },
    {
      'name': 'Belanja',
      'icon_code': 0xe59c, // Icons.shopping_cart
      'color_hex': '#FFC107',
    },
  ];
}

/// Predefined Material icons for the category icon picker.
///
/// Each entry maps a display label to its codePoint so a
/// `Icon(IconData(codePoint, fontFamily: 'MaterialIcons'))` can render it.
abstract final class PredefinedIcons {
  static const List<Map<String, dynamic>> icons = [
    {'label': 'Folder', 'codePoint': 0xe2c7}, // Icons.folder
    {'label': 'School', 'codePoint': 0xe559}, // Icons.school
    {'label': 'Person', 'codePoint': 0xe491}, // Icons.person
    {'label': 'Shopping Cart', 'codePoint': 0xe59c}, // Icons.shopping_cart
    {'label': 'Work', 'codePoint': 0xe943}, // Icons.work
    {'label': 'Favorite', 'codePoint': 0xe25b}, // Icons.favorite
    {'label': 'Star', 'codePoint': 0xe5f9}, // Icons.star
    {'label': 'Home', 'codePoint': 0xe318}, // Icons.home
    {'label': 'Music', 'codePoint': 0xe405}, // Icons.music_note
    {'label': 'Sports', 'codePoint': 0xe5e1}, // Icons.sports_soccer
    {'label': 'Code', 'codePoint': 0xe86f}, // Icons.code
    {'label': 'Travel', 'codePoint': 0xe1d7}, // Icons.flight
  ];

  /// Returns the corresponding [IconData] constant to prevent icon tree shaking errors.
  static IconData getIconData(int codePoint) {
    switch (codePoint) {
      case 0xe2c7: return Icons.folder;
      case 0xe559: return Icons.school;
      case 0xe491: return Icons.person;
      case 0xe59c: return Icons.shopping_cart;
      case 0xe943: return Icons.work;
      case 0xe25b: return Icons.favorite;
      case 0xe5f9: return Icons.star;
      case 0xe318: return Icons.home;
      case 0xe405: return Icons.music_note;
      case 0xe5e1: return Icons.sports_soccer;
      case 0xe86f: return Icons.code;
      case 0xe1d7: return Icons.flight;
      default: return Icons.folder;
    }
  }
}

/// Predefined hex color strings for the category color picker.
abstract final class PredefinedColors {
  static const List<String> colors = [
    '#E94560', // Rose
    '#FFC107', // Amber
    '#4FC3F7', // Light Blue
    '#66BB6A', // Green
    '#AB47BC', // Purple
    '#FF7043', // Deep Orange
    '#26C6DA', // Cyan
    '#EC407A', // Pink
  ];
}
