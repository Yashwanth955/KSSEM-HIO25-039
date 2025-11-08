// lib/data/app_database.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Future<Database>? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'sadhak.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Create a table per model
        await db.execute('''
          CREATE TABLE user_profiles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebaseUid TEXT UNIQUE,
            name TEXT,
            email TEXT,
            mobileNumber TEXT,
            age INTEGER,
            sport TEXT,
            height REAL,
            weight REAL,
            profilePhotoPath TEXT,
            gender TEXT,
            coachName TEXT,
            coachPhoneNumber TEXT,
            coachWhatsappNumber TEXT,
            isCoachUser INTEGER,
            assignedAthleteIds TEXT,
            createdAt TEXT,
            location TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE test_results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            testTitle TEXT,
            resultValue TEXT,
            date TEXT,
            videoPath TEXT,
            wrongRepCount INTEGER,
            formCorrect INTEGER,
            feedback TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE badges(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            imageUrl TEXT,
            isEarned INTEGER
          );
        ''');

        await db.execute('''
          CREATE TABLE leaderboard(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rank INTEGER,
            name TEXT,
            score INTEGER,
            imageUrl TEXT,
            region TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE matches(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sponsorName TEXT,
            athleteName TEXT,
            matchReason TEXT,
            dateMatched TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE sponsors(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            focusSport TEXT,
            type TEXT,
            contactEmail TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE athlete_reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            athleteUid TEXT,
            testTitle TEXT,
            headline TEXT,
            resultValue TEXT,
            generatedAt TEXT,
            pdfPath TEXT,
            uploadedUrl TEXT,
            synced INTEGER,
            tags TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create athlete_reports table if upgrading from v1
          await db.execute('''
            CREATE TABLE IF NOT EXISTS athlete_reports(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              athleteUid TEXT,
              testTitle TEXT,
              headline TEXT,
              resultValue TEXT,
              generatedAt TEXT,
              pdfPath TEXT,
              uploadedUrl TEXT,
              synced INTEGER,
              tags TEXT
            );
          ''');
        }
      },
    );
  }

  // Generic helpers per table
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, orderBy: orderBy);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}
