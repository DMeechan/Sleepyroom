import 'package:flutter/material.dart';

class SleepTracker extends StatefulWidget {
  _SleepTrackerState createState() => _SleepTrackerState();
}

class _SleepTrackerState extends State<SleepTracker> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Track your sleep environment")),
        body: new Center(
            child: new Material(
                color: Colors.deepPurple,
                child: new InkWell(
                  onTap: () => print("TAP: Starting tracker..."),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text("Tap to start!",
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        new Text(
                            "Don't forget to turn this off when you wake up!",
                            style: new TextStyle(
                                color: Colors.white, fontSize: 16))
                      ]),
                ))));
  }
}
