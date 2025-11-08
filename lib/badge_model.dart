// lib/badge_model.dart

class Badge {
  int? id;

  String name;
  String description;
  String imageUrl;
  bool isEarned;

  Badge({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isEarned = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'isEarned': isEarned ? 1 : 0,
  };

  factory Badge.fromMap(Map<String, dynamic> m) => Badge(
    id: m['id'] as int?,
    name: m['name'] as String,
    description: m['description'] as String,
    imageUrl: m['imageUrl'] as String,
    isEarned: (m['isEarned'] as int?) == 1,
  );
}
