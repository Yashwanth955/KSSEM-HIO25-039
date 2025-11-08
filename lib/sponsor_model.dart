class Sponsor {
  int? id;
  String name;
  String focusSport; // e.g., "Football", "Athletics"
  String type; // "Mentor" or "Sponsor"
  String? contactEmail;

  Sponsor({
    this.id,
    required this.name,
    required this.focusSport,
    required this.type,
    this.contactEmail,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'focusSport': focusSport,
    'type': type,
    'contactEmail': contactEmail,
  };

  factory Sponsor.fromMap(Map<String, dynamic> m) => Sponsor(
    id: m['id'] as int?,
    name: m['name'] as String,
    focusSport: m['focusSport'] as String,
    type: m['type'] as String,
    contactEmail: m['contactEmail'] as String?,
  );
}
