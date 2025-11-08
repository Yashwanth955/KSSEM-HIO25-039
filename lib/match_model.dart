// lib/match_model.dart

class Match {
  int? id;
  String sponsorName;
  String athleteName;
  String matchReason; // e.g., "High performance in Sprinting"
  DateTime dateMatched;

  Match({
    this.id,
    required this.sponsorName,
    required this.athleteName,
    required this.matchReason,
    required this.dateMatched,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sponsorName': sponsorName,
    'athleteName': athleteName,
    'matchReason': matchReason,
    'dateMatched': dateMatched.toIso8601String(),
  };

  factory Match.fromMap(Map<String, dynamic> m) => Match(
    id: m['id'] as int?,
    sponsorName: m['sponsorName'] as String,
    athleteName: m['athleteName'] as String,
    matchReason: m['matchReason'] as String,
    dateMatched: DateTime.parse(m['dateMatched'] as String),
  );
}
