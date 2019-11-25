import 'package:sleepyroom/datebase_helper.dart';
import 'package:sleepyroom/utils/timestamps.dart';
import 'package:sqflite/sqflite.dart';

class Snapshot {
  final int id;
  final DateTime timestamp;
  final int lightScore;
  final int noiseScore;

  // Database table and column names
  static final String table = "snapshot";
  static final String columnId = "id";
  static final String columnTimestamp = "timestamp";
  static final String columnLightScore = "lightScore";
  static final String columnNoiseScore = "noiseScore";

  Snapshot({this.id, this.timestamp, this.lightScore, this.noiseScore});

  static Future<Snapshot> withoutId({timestamp, lightScore, noiseScore}) async {
    final Database db = await DatabaseHelper().db;
    List<Map> latestSnapshots = await db.query(table,
        columns: [columnId], orderBy: "$columnId DESC", limit: 1);

    print("latestSnapshots");
    print(latestSnapshots);
    int latestId = latestSnapshots.length > 0 ? latestSnapshots.first['id'] : 0;
    return new Snapshot(
        id: latestId + 1,
        timestamp: timestamp,
        lightScore: lightScore,
        noiseScore: noiseScore);
  }

  Future<List<Snapshot>> getAll() async {
    final Database db = await DatabaseHelper().db;

    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      var map = maps[i];
      return fromMap(map);
    });
  }

  Future<Snapshot> get(int id) async {
    final Database db = await DatabaseHelper().db;

    List<Map> result = await db.query(table,
        columns: [
          columnId,
          columnTimestamp,
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
    final Database db = await DatabaseHelper().db;

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

  // Keys must correspond to names of columns in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': toEpoch(timestamp),
      'lightScore': lightScore,
      'noiseScore': noiseScore
    };
  }

  // TODO: this should probs be Snapshot.fromMap to be a constructor
  Snapshot fromMap(Map<String, dynamic> map) {
    return Snapshot(
      id: map['id'],
      timestamp: fromEpoch(map['timestamp']),
      lightScore: map['lightScore'],
      noiseScore: map['noiseScore'],
    );
  }

  @override
  String toString() {
    return "Snapshot { id: $id, timestamp: $timestamp, lightScore: $lightScore, noiseScore: $noiseScore }";
  }
}
