import 'package:flutter/material.dart';
import 'package:sleepyroom/datebase_helper.dart';
import 'package:sleepyroom/entities/snapshot.dart';

import 'pages/sleep_tracker.dart';
import 'pages/sleep_logs.dart';

void main() async {
  await DatabaseHelper().db;
  return runApp(MyApp());
}

void testSnapshots() async {
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
