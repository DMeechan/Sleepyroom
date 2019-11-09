import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Connection {
  /// // Open a connection to the database and score a reference
  open() async {
    final String dbName = "sleepyroom_database.db";
    final String createDbSql =
        "CREATE TABLE snapshots(id INTEGER PRIMARY KEY, lightScore INTEGER, noiseScore INTEGER, timestamp INTEGER";

    final String path = join(await getDatabasesPath(), dbName);
    final Future<Database> dbConnection =
        openDatabase(path, onCreate: (db, version) {
      return db.execute(createDbSql);
    }, version: 1);

    return dbConnection;
  }
}
