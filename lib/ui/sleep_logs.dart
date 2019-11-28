import 'package:flutter/material.dart';
import 'package:sleepyroom/models/sleep_log.dart';
import 'package:sleepyroom/ui/helpers.dart';
import 'package:sleepyroom/utils/timestamps.dart';

class SleepLogs extends StatefulWidget {
  SleepLogs({Key key, this.title}) : super(key: key);
  final String title;

  _SleepLogsState createState() => _SleepLogsState();
}

class _SleepLogsState extends State<SleepLogs> {
  void _pushSleepTracker() {
    Navigator.pushNamed(context, "/sleepTracker");
  }

  /// Summary contains average sleep score over last 7 days and any recommendations
  Widget _buildSummary() {
    return null;
  }

  /// Show list of every sleep log recorded: date, light score, sound score
  Widget _buildSleepLogs() {
    return FutureBuilder<List<SleepLog>>(
        future: SleepLog.getAll(),
        builder:
            (BuildContext context, AsyncSnapshot<List<SleepLog>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount:
                    snapshot.data.length * 2 - 1, // add space for dividers
                itemBuilder: (context, i) {
                  if (i.isOdd) return Divider();

                  final position = i ~/ 2;
                  final dataIndex = snapshot.data.length -
                      position -
                      1; // render data in reverse order

                  return _buildRow(snapshot.data[dataIndex]);
                });
          } else {
            return loading();
          }
        });
  }

  Widget _buildRow(SleepLog sleepLog) {
    final start = toWeekday(sleepLog.startDate.weekday) +
        " at " +
        sleepLog.startDate.hour.toString() +
        ":" +
        sleepLog.startDate.minute.toString();

    return ListTile(
        title: Text(start), trailing: Text(sleepLog.noiseScore.toString()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.deepPurpleAccent,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.airline_seat_individual_suite,
                    color: Colors.white),
                onPressed: _pushSleepTracker,
              )
            ]),
        body: _buildSleepLogs());
  }
}
