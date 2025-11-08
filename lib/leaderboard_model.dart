// lib/leaderboard_model.dart

class LeaderboardEntry {
  int? id;

  int rank;
  String name;
  int score;
  String imageUrl;
  String region;

  LeaderboardEntry({
    this.id,
    required this.rank,
    required this.name,
    required this.score,
    required this.imageUrl,
    required this.region,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'rank': rank,
    'name': name,
    'score': score,
    'imageUrl': imageUrl,
    'region': region,
  };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> m) => LeaderboardEntry(
    id: m['id'] as int?,
    rank: m['rank'] as int,
    name: m['name'] as String,
    score: m['score'] as int,
    imageUrl: m['imageUrl'] as String,
    region: m['region'] as String,
  );
}
