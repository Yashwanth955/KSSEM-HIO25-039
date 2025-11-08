// lib/database_seeder.dart
import 'isar_service.dart';
import 'package:sqflite/sqflite.dart';
import 'user_model.dart';
import 'test_result.dart';
import 'badge_model.dart';
import 'leaderboard_model.dart';
import 'sponsor_model.dart';
import 'util/log.dart';

class DatabaseSeeder {
  static Future<void> seed() async {
    final isarService = IsarService();
    final db = await isarService.db;

    // Check if the database is already seeded to prevent re-seeding
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM user_profiles',
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) {
      // Already seeded
      logDebug('Database already seeded. Skipping.');
      return;
    }
    logDebug('Seeding database with prototype data...');

    // 1. Create Sample User Profile
    final user = UserProfile(
      firebaseUid:
          'REPLACE_WITH_YOUR_FIREBASE_UID', // IMPORTANT: replace this when using
      name: 'Yashwanth',
      email: 'athlete@example.com',
      age: 20,
      sport: 'Athletics',
      height: 180,
      weight: 75,
      mobileNumber: '9876543210',
      coachName: 'Ravi Kumar',
      coachPhoneNumber: '+919988776655',
      coachWhatsappNumber: '919988776655',
      isCoachUser: false,
      createdAt: DateTime.now(),
      location: 'Bangalore, India',
    );

    final now = DateTime.now();
    final results = [
      TestResult(
        id: null,
        testTitle: 'Push-up Test',
        resultValue: '22 Reps',
        date: now.subtract(const Duration(days: 10)),
      ),
      TestResult(
        id: null,
        testTitle: 'Push-up Test',
        resultValue: '25 Reps',
        date: now.subtract(const Duration(days: 5)),
      ),
      TestResult(
        id: null,
        testTitle: 'Push-up Test',
        resultValue: '30 Reps',
        date: now.subtract(const Duration(days: 2)),
      ),
      TestResult(
        id: null,
        testTitle: 'Standing Broad Jump',
        resultValue: '2.1m',
        date: now.subtract(const Duration(days: 6)),
      ),
      TestResult(
        id: null,
        testTitle: 'Squat Test',
        resultValue: '40 Reps',
        date: now.subtract(const Duration(days: 4)),
      ),
      TestResult(
        id: null,
        testTitle: 'Sit-up Test',
        resultValue: '35 Reps',
        date: now.subtract(const Duration(days: 3)),
      ),
      TestResult(
        id: null,
        testTitle: '1.6km Run Test',
        resultValue: '5:45 min',
        date: now.subtract(const Duration(days: 1)),
      ),
    ];

    final badges = [
      Badge(
        id: null,
        name: 'Core Strength Pro 💪',
        description: 'Completed 5 core strength tests',
        imageUrl: 'https://i.imgur.com/bT6R022.png',
        isEarned: true,
      ),
      Badge(
        id: null,
        name: 'Stamina Star 🔥',
        description: 'Achieved top 10% in stamina tests',
        imageUrl: 'https://i.imgur.com/k2p8J5F.png',
        isEarned: true,
      ),
      Badge(
        id: null,
        name: 'Speed Demon 🏃',
        description: 'Achieve top speed in sprint tests',
        imageUrl: 'https://i.imgur.com/bT6R022.png',
        isEarned: false,
      ),
    ];

    final leaderboard = [
      LeaderboardEntry(
        id: null,
        rank: 1,
        name: 'Arjun Sharma',
        score: 95,
        imageUrl: 'https://i.pravatar.cc/150?img=1',
        region: 'India',
      ),
      LeaderboardEntry(
        id: null,
        rank: 2,
        name: 'Priya Patel',
        score: 92,
        imageUrl: 'https://i.pravatar.cc/150?img=2',
        region: 'India',
      ),
      LeaderboardEntry(
        id: null,
        rank: 3,
        name: 'Yashwanth',
        score: 89,
        imageUrl: 'https://i.pravatar.cc/150?img=12',
        region: 'India',
      ),
    ];

    final sponsors = [
      Sponsor(
        id: null,
        name: 'National Athletics Foundation',
        focusSport: 'Athletics',
        type: 'Sponsor',
        contactEmail: 'contact@naf.org',
      ),
      Sponsor(
        id: null,
        name: 'Pro Fitness Mentors',
        focusSport: 'Athletics',
        type: 'Mentor',
        contactEmail: 'mentors@profitness.com',
      ),
    ];

    // Use a batch to insert everything
    final batch = db.batch();
    batch.insert(
      'user_profiles',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final r in results) {
      batch.insert(
        'test_results',
        r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final b in badges) {
      batch.insert(
        'badges',
        b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final l in leaderboard) {
      batch.insert(
        'leaderboard',
        l.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final s in sponsors) {
      batch.insert(
        'sponsors',
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    logDebug('Database seeded successfully!');
  }
}
