class ItemModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor: dari Supabase map / Factory constructor: from Supabase map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  // Konversi ke map untuk insert ke Supabase / Convert to map for inserting into Supabase
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'category': category,
    };
  }

  // Konversi ke map untuk update ke Supabase / Convert to map for updating in Supabase
  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // CopyWith untuk update immutable / CopyWith for immutable update
  ItemModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? category,
  }) {
    return ItemModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Getter untuk format tanggal / Formatted date getter
  String get formattedDate {
    final d = createdAt;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
