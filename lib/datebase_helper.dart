import 'dart:async';
import 'package:path/path.dart';
import 'package:sleepyroom/entities/sleep_log.dart';
import 'package:sleepyroom/entities/snapshot.dart';
import 'package:sqflite/sqflite.dart';

// Source: https://grokonez.com/flutter/flutter-sqlite-example-crud-sqflite-example
class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;
  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }

    return _db;
  }

  _onCreate(Database db, int newVersion) async {
    await db.execute(createSnapshotTable());
    await db.execute(createSleepLogTable());
  }

  /// // Open a connection to the database and score a reference
  _initDb() async {
    final String dbName = "sleepyroom_database.db";

    final String path = join(await getDatabasesPath(), dbName);
    final Future<Database> dbConnection =
        openDatabase(path, onCreate: _onCreate, version: 1);

    return dbConnection;
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

  /// Source: https://alvinalexander.com/index.php/flutter/using-sqlite-datetime-field-flutter-dart
  String createSnapshotTable() {
    final String table = Snapshot.table;
    final columnId = Snapshot.columnId;
    final columnTimestamp = Snapshot.columnTimestamp;
    final columnLightScore = Snapshot.columnLightScore;
    final columnNoiseScore = Snapshot.columnNoiseScore;

    return """CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnTimestamp INTEGER UNIQUE DEFAULT (cast(strftime('%s','now') * 1000 as int)) NOT NULL,
      $columnLightScore INTEGER NOT NULL,
      $columnNoiseScore INTEGER NOT NULL
    )""";
  }

  String createSleepLogTable() {
    final table = SleepLog.table;
    final columnId = SleepLog.columnId;
    final columnStartDate = SleepLog.columnStartDate;
    final columnEndDate = SleepLog.columnEndDate;
    final columnLightScore = SleepLog.columnLightScore;
    final columnNoiseScore = SleepLog.columnNoiseScore;

    return """CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnStartDate INTEGER UNIQUE DEFAULT (cast(strftime('%s','now') * 1000 as int)) NOT NULL,
      $columnEndDate INTEGER UNIQUE,
      $columnLightScore INTEGER,
      $columnNoiseScore INTEGER
     )""";
  }
}
