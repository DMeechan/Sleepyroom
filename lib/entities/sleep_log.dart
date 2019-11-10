import 'package:sleepyroom/datebase_helper.dart';
import 'package:sleepyroom/utils/timestamps.dart';
import 'package:sqflite/sqflite.dart';

class SleepLog {
  final int id;
  final DateTime startDate;
  DateTime endDate;
  int lightScore;
  int noiseScore;

  // Database table and column names
  static final String table = "sleepLog";
  static final String columnId = "id";
  static final String columnStartDate = "startDate";
  static final String columnEndDate = "endDate";
  static final String columnLightScore = "lightScore";
  static final String columnNoiseScore = "noiseScore";

  SleepLog(this.id, this.startDate);
  SleepLog.complete(
      {this.id,
      this.startDate,
      this.endDate,
      this.lightScore,
      this.noiseScore});

  Future<List<SleepLog>> getAll() async {
    final db = await DatabaseHelper().db;

    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      var map = maps[i];
      return fromMap(map);
    });
  }

  Future<SleepLog> get(int id) async {
    final db = await DatabaseHelper().db;

    List<Map> result = await db.query(table,
        columns: [
          columnId,
          columnStartDate,
          columnEndDate,
          columnLightScore,
          columnNoiseScore
        ],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return fromMap(result.first);
    }

    return null;
  }

  Future<int> insert() async {
    final db = await DatabaseHelper().db;

    var result = await db.insert(table, this.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return result;
  }

  Future<int> update() async {
    final db = await DatabaseHelper().db;

    var result = await db
        .update(table, this.toMap(), where: '$columnId = ?', whereArgs: [id]);

    return result;
  }

  Future<int> delete() async {
    final db = await DatabaseHelper().db;

    var result = db.delete(table, where: '$columnId = ?', whereArgs: [this.id]);

    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'lightScore': lightScore,
      'noiseScore': noiseScore
    };
  }

  SleepLog fromMap(Map<String, dynamic> map) {
    return SleepLog.complete(
      id: map['id'],
      startDate: fromEpoch(map['startDate']),
      endDate: fromEpoch(map['endDate']), // need to null check here
      lightScore: map['lightScore'],
      noiseScore: map['noiseScore'],
    );
  }

  @override
  String toString() {
    return "SleepLog { id: $id, startDate: $startDate, endDate: $endDate, lightScore: $lightScore, noiseScore: $noiseScore }";
  }
}
