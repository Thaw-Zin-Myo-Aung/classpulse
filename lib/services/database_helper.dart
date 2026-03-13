import 'package:classpulse/models/check_in_record.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('classpulse.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checkins (
        id               TEXT PRIMARY KEY,
        studentId        TEXT NOT NULL,
        sessionId        TEXT NOT NULL,
        checkInTime      TEXT NOT NULL,
        checkInLat       REAL NOT NULL,
        checkInLng       REAL NOT NULL,
        previousTopic    TEXT NOT NULL,
        expectedTopic    TEXT NOT NULL,
        moodBefore       INTEGER NOT NULL,
        status           TEXT NOT NULL DEFAULT 'checked_in',
        checkOutTime     TEXT,
        checkOutLat      REAL,
        checkOutLng      REAL,
        learningSummary  TEXT,
        classFeedback    TEXT
      )
    ''');
  }

  Future<void> insertRecord(CheckInRecord record) async {
    final db = await database;
    await db.insert(
      'checkins',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRecord(CheckInRecord record) async {
    final db = await database;
    await db.update(
      'checkins',
      record.toJson(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<List<CheckInRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('checkins', orderBy: 'checkInTime DESC');
    return maps.map((m) => CheckInRecord.fromJson(m)).toList();
  }
}

