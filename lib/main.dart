import 'package:flutter/material.dart';
import 'package:sleepyroom/datebase_helper.dart';
import 'package:sleepyroom/models/sleep_log.dart';
import 'package:sleepyroom/models/snapshot.dart';

import 'ui/sleep_tracker.dart';
import 'ui/sleep_logs.dart';

void main() async {
  await DatabaseHelper().db;
  await testSleepLogs();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sleepyroom',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
        ),
        home: SleepLogs(title: "Sleepyroom"),
        routes: <String, WidgetBuilder>{
          '/sleepTracker': (BuildContext context) => SleepTracker()
        });
  }
}

// Two pages:
// - sleep logs
// - sleep tracker


/*
TEST DATABASE STUFFS
 */

Future<void> testSnapshots() async {
  var snap1 = new Snapshot(
      id: 1, timestamp: DateTime.now(), lightScore: 10, noiseScore: 50);

  var snap2 = new Snapshot(
      id: 2,
      timestamp: DateTime.now().add(Duration(seconds: 5)),
      lightScore: 20,
      noiseScore: 30);

  var snap3 = new Snapshot(
      id: 3,
      timestamp: DateTime.now().add(Duration(seconds: 10)),
      lightScore: 30,
      noiseScore: 50);

  await snap1.insert();
  await snap2.insert();
  await snap3.insert();

  var snaps = await Snapshot().getAll();
  print(snaps);

  print(await Snapshot().get(1));
  print(await Snapshot().get(2));
  print(await Snapshot().get(3));
  await snap2.delete();
  print(await Snapshot().get(2));
  print(await Snapshot().getAll());
}

Future<void> testSleepLogs() async {
  var now = DateTime.now();

  var log1 = new SleepLog.complete(
      id: 1,
      startDate: now,
      endDate: now.add(new Duration(hours: 8)),
      lightScore: 35,
      noiseScore: 60);

  var log2 = new SleepLog.complete(
      id: 2,
      startDate: now.add(new Duration(days: 1)),
      endDate: now.add(new Duration(days: 1, hours: 8)),
      lightScore: 35,
      noiseScore: 60);

  var log3 = new SleepLog(3, now.add(new Duration(days: 2)));

  await log1.insert();
  await log2.insert();
  await log3.insert();

  print(await SleepLog.getAll());

  log3.finish(
      endDate: now.add(new Duration(days: 2, hours: 8)),
      lightScore: 99,
      noiseScore: 5);
  log3.update();

  print(await SleepLog.get(3));

  log2.delete();
  print(await SleepLog.getAll());
}