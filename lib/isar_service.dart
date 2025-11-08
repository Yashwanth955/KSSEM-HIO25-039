// lib/isar_service.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'data/app_database.dart';
import 'test_result.dart';
import 'user_model.dart';
import 'badge_model.dart';
import 'leaderboard_model.dart';
import 'match_model.dart';
import 'sponsor_model.dart';

class IsarService {
  // Keep the same singleton API so app imports don't need changing
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal() {
    db = AppDatabase.instance.database;
  }

  late Future<Database> db;

  // --- Seeding & Test Utilities ---
  Future<void> createDummyUser() async {
    final database = await db;
    final existing = await database.query(
      'user_profiles',
      where: 'firebaseUid = ?',
      whereArgs: ['dummyUser123'],
    );
    if (existing.isNotEmpty) return;

    final profile = UserProfile(
      firebaseUid: 'dummyUser123',
      name: 'Alex Rider',
      email: 'alex.rider@example.com',
      mobileNumber: '9876543210',
      age: 28,
      sport: 'Triathlon',
      height: 175.0,
      weight: 70.0,
      profilePhotoPath: null,
      coachName: 'Ms. Jones',
      coachPhoneNumber: '0123456789',
      coachWhatsappNumber: '0123456789',
    );

    await database.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> seedDatabase() async {
    // Optional: implement seeding logic if desired
  }

  // --- User Profile Methods ---
  Future<void> saveUserProfile(UserProfile newUserProfile) async {
    final database = await db;
    await database.insert(
      'user_profiles',
      newUserProfile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final database = await db;
    final rows = await database.query(
      'user_profiles',
      where: 'firebaseUid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<UserProfile?> getUserProfileByFirebaseUid(String firebaseUid) =>
      getUserProfile(firebaseUid);
  Future<UserProfile?> getUserProfileById(String userId) =>
      getUserProfile(userId);

  Future<UserProfile?> getCurrentUserProfile() async {
    final database = await db;
    final rows = await database.query('user_profiles', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  // --- Test Result Methods ---
  Future<void> saveTestResult(TestResult newResult) async {
    final database = await db;
    await database.insert(
      'test_results',
      newResult.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TestResult>> getAllTestResults() async {
    final database = await db;
    final rows = await database.query('test_results');
    return rows.map((r) => TestResult.fromMap(r)).toList();
  }

  // --- Badge Methods ---
  Future<List<Badge>> getEarnedBadges() async {
    final database = await db;
    final rows = await database.query(
      'badges',
      where: 'isEarned = ?',
      whereArgs: [1],
    );
    return rows.map((r) => Badge.fromMap(r)).toList();
  }

  Future<List<Badge>> getUnearnedBadges() async {
    final database = await db;
    final rows = await database.query(
      'badges',
      where: 'isEarned = ?',
      whereArgs: [0],
    );
    return rows.map((r) => Badge.fromMap(r)).toList();
  }

  // --- Leaderboard Methods ---
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final database = await db;
    final rows = await database.query('leaderboard', orderBy: 'rank ASC');
    return rows.map((r) => LeaderboardEntry.fromMap(r)).toList();
  }

  // --- Matching / Sponsors ---
  Future<List<Sponsor>> getAllSponsors() async {
    final database = await db;
    final rows = await database.query('sponsors');
    return rows.map((r) => Sponsor.fromMap(r)).toList();
  }

  Future<void> saveMatches(List<Match> matches) async {
    final database = await db;
    final batch = database.batch();
    for (final m in matches) {
      batch.insert(
        'matches',
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Match>> getMatches() async {
    final database = await db;
    final rows = await database.query('matches');
    return rows.map((r) => Match.fromMap(r)).toList();
  }
}
