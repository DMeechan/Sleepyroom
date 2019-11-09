import 'package:flutter/material.dart';

import 'pages/sleep_tracker.dart';
import 'pages/sleep_logs.dart';

void main() => runApp(MyApp());

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
