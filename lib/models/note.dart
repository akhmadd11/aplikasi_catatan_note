/// Note model representing a single note/catatan.
///
/// Maps directly to the `notes` table in SQLite.
class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final int? categoryId;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a [Note] from a SQLite row map.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      categoryId: map['category_id'] as int?,
      isPinned: (map['is_pinned'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts this [Note] to a map for SQLite insertion/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'is_pinned': isPinned ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [Note] with the given fields replaced.
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? Function()? categoryId,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a plain-text preview of the content with markdown stripped.
  ///
  /// Removes common markdown syntax (headers, bold, italic, links, images,
  /// code blocks, checkboxes, horizontal rules) and returns the first 100
  /// characters.
  String get contentPreview {
    String stripped = content
        // Remove code blocks (``` ... ```)
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        // Remove inline code
        .replaceAll(RegExp(r'`[^`]*`'), '')
        // Remove images ![alt](url)
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '')
        // Remove links [text](url) → keep text
        .replaceAllMapped(
          RegExp(r'\[([^\]]*)\]\([^)]*\)'),
          (match) => match.group(1) ?? '',
        )
        // Remove headings (# ## ### etc.)
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        // Remove bold/italic markers
        .replaceAll(RegExp(r'\*{1,3}'), '')
        .replaceAll(RegExp(r'_{1,3}'), '')
        // Remove strikethrough
        .replaceAll(RegExp(r'~~'), '')
        // Remove blockquotes
        .replaceAll(RegExp(r'^>\s+', multiLine: true), '')
        // Remove unordered list markers
        .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '')
        // Remove ordered list markers
        .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '')
        // Remove checkboxes
        .replaceAll(RegExp(r'\[[ xX]\]\s*'), '')
        // Remove horizontal rules
        .replaceAll(RegExp(r'^---+$', multiLine: true), '')
        // Collapse whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (stripped.length <= 100) return stripped;
    return '${stripped.substring(0, 100)}...';
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, categoryId: $categoryId, '
        'isPinned: $isPinned, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.categoryId == categoryId &&
        other.isPinned == isPinned &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      categoryId,
      isPinned,
      createdAt,
      updatedAt,
    );
  }
}
