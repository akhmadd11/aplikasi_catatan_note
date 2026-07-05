/// Category model representing a note folder/category.
///
/// Maps directly to the `categories` table in SQLite.
class Category {
  const Category({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final int iconCode;
  final String colorHex;
  final DateTime createdAt;

  /// Creates a [Category] from a SQLite row map.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts this [Category] to a map for SQLite insertion/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [Category] with the given fields replaced.
  Category copyWith({
    int? id,
    String? name,
    int? iconCode,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, iconCode: $iconCode, '
        'colorHex: $colorHex, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.iconCode == iconCode &&
        other.colorHex == colorHex &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, iconCode, colorHex, createdAt);
  }
}
