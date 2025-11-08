// lib/user_model.dart

import 'dart:convert';

class UserProfile {
  int? id;

  String firebaseUid;

  String? name;
  String? email;
  String? mobileNumber;
  int? age;
  String? sport;
  double? height; // in cm
  double? weight; // in kg
  String? profilePhotoPath;
  String? gender; // ADDED

  // --- Coach Fields ---
  String? coachName;
  String? coachPhoneNumber;
  String? coachWhatsappNumber;
  bool isCoachUser;

  // --- Common Fields ---
  List<String> assignedAthleteIds; // Non-nullable field
  DateTime? createdAt;
  String? location;

  UserProfile({
    this.id,
    required this.firebaseUid,
    this.name,
    this.email,
    this.mobileNumber,
    this.age,
    this.sport,
    this.height,
    this.weight,
    this.profilePhotoPath,
    this.gender, // ADDED
    this.coachName,
    this.coachPhoneNumber,
    this.coachWhatsappNumber,
    this.isCoachUser = false,
    this.assignedAthleteIds = const [],
    this.createdAt,
    this.location,
  });

  UserProfile copyWith({
    int? id,
    String? firebaseUid,
    String? name,
    String? email,
    String? mobileNumber,
    int? age,
    String? sport,
    double? height,
    double? weight,
    String? profilePhotoPath,
    String? gender, // ADDED
    String? coachName,
    String? coachPhoneNumber,
    String? coachWhatsappNumber,
    bool? isCoachUser,
    List<String>? assignedAthleteIds,
    DateTime? createdAt,
    String? location,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      age: age ?? this.age,
      sport: sport ?? this.sport,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      gender: gender ?? this.gender, // ADDED
      coachName: coachName ?? this.coachName,
      coachPhoneNumber: coachPhoneNumber ?? this.coachPhoneNumber,
      coachWhatsappNumber: coachWhatsappNumber ?? this.coachWhatsappNumber,
      isCoachUser: isCoachUser ?? this.isCoachUser,
      assignedAthleteIds: assignedAthleteIds ?? this.assignedAthleteIds,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'firebaseUid': firebaseUid,
    'name': name,
    'email': email,
    'mobileNumber': mobileNumber,
    'age': age,
    'sport': sport,
    'height': height,
    'weight': weight,
    'profilePhotoPath': profilePhotoPath,
    'gender': gender,
    'coachName': coachName,
    'coachPhoneNumber': coachPhoneNumber,
    'coachWhatsappNumber': coachWhatsappNumber,
    'isCoachUser': isCoachUser ? 1 : 0,
    'assignedAthleteIds': jsonEncode(assignedAthleteIds),
    'createdAt': createdAt?.toIso8601String(),
    'location': location,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as int?,
    firebaseUid: map['firebaseUid'] as String,
    name: map['name'] as String?,
    email: map['email'] as String?,
    mobileNumber: map['mobileNumber'] as String?,
    age: map['age'] as int?,
    sport: map['sport'] as String?,
    height: map['height'] is num ? (map['height'] as num).toDouble() : null,
    weight: map['weight'] is num ? (map['weight'] as num).toDouble() : null,
    profilePhotoPath: map['profilePhotoPath'] as String?,
    gender: map['gender'] as String?,
    coachName: map['coachName'] as String?,
    coachPhoneNumber: map['coachPhoneNumber'] as String?,
    coachWhatsappNumber: map['coachWhatsappNumber'] as String?,
    isCoachUser: (map['isCoachUser'] as int?) == 1,
    assignedAthleteIds: map['assignedAthleteIds'] != null
        ? List<String>.from(jsonDecode(map['assignedAthleteIds'] as String))
        : <String>[],
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'] as String)
        : null,
    location: map['location'] as String?,
  );

  // ADDED toJson for debugging and potential API use
  Map<String, dynamic> toJson() => toMap();
}
