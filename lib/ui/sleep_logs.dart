import 'package:flutter/material.dart';

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
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= 10) {
          // fetch 10 more from the DB??
        }

        return _buildRow(10);
    });
  }

  Widget _buildRow(int index) {
    return ListTile(
      title: Text("1st Jan 2019"),
      onTap: () => setState(() => {

      })
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: <Widget>[
          IconButton(
            icon:
                Icon(Icons.airline_seat_individual_suite, color: Colors.white),
            onPressed: _pushSleepTracker,
          )
        ]),
        body: _buildSleepLogs());
  }
}
