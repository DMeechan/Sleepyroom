import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sleepyroom/models/snapshot.dart';
import 'package:sleepyroom/ui/helpers.dart';

enum Status { Initialised, Recording, Stopped }

class SleepTracker extends StatefulWidget {
  _SleepTrackerState createState() => _SleepTrackerState();
}

class _SleepTrackerState extends State<SleepTracker> {
  Status status;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);

  FlutterSound _flutterSound;
  StreamSubscription<double> _dbPeakSubscription;
  DateTime _timestamp;
  double _dbLevel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
  }

  void _prepare() {
    setState(() {
      status = Status.Initialised;
      _flutterSound = new FlutterSound();
      _buttonIcon = _getPlayerIcon(status);
    });

    var updateIntervalInSecs = 0.3;
    _flutterSound.setDbLevelEnabled(true);
    _flutterSound.setDbPeakLevelUpdate(updateIntervalInSecs);
  }

  void _startRecording() async {
    // note to self: make a PR for flutter_sound to fix their example code
    String path = await _flutterSound.startRecorder(null);
    print('recording to: $path');

    setState(() {
      status = Status.Recording;
      _buttonIcon = _getPlayerIcon(status);
      _dbPeakSubscription =
          _flutterSound.onRecorderDbPeakChanged.listen((value) async {
            this._dbLevel = value;
            this._timestamp = DateTime.now();

            Snapshot snapshot = await Snapshot.withoutId(
                timestamp: _timestamp,
                lightScore: -1,
                noiseScore: _dbLevel.toInt());

            print(snapshot);
            var itemsCreated = await snapshot.insert();

            print("Created snapshots: $itemsCreated");
            print(this._dbLevel);
          });
    });
  }

  void _stopRecording() async {
    String result = await _flutterSound.stopRecorder();
    print("Stopped recording: $result");

    if (_dbPeakSubscription != null) {
      _dbPeakSubscription.cancel();
    }

    setState(() {
      status = Status.Stopped;
      _dbLevel = null;
      _dbPeakSubscription = null;
      _buttonIcon = _getPlayerIcon(status);
    });
  }

  void _startPlayback() async {
    var path = await _flutterSound.startPlayer(null);
    print('startPlayer: $path');

    _flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        DateTime date =
        new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        print(date);
      }
    });
  }

  @override
  void dispose() {
    _flutterSound.stopRecorder();
    super.dispose();
  }

  void _opt() async {
    switch (status) {
      case Status.Initialised:
        {
          _startRecording();
          break;
        }
      case Status.Recording:
        {
          _stopRecording();
          break;
        }
      case Status.Stopped:
        {
          _prepare();
          break;
        }

      default:
        break;
    }

    setState(() {
      _buttonIcon = _getPlayerIcon(status);
    });
  }

  Widget _getPlayerIcon(Status status) {
    switch (status) {
      case Status.Initialised:
        {
          return empty();
        }
      case Status.Recording:
        {
          return Icon(Icons.stop);
        }
      case Status.Stopped:
        {
          return Icon(Icons.check);
        }
      default:
        return Icon(Icons.do_not_disturb_on);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Track your sleep environment")),
        body: new Center(
            child: new Material(
                color: Colors.deepPurple,
                child: new InkWell(
                  onTap: () {
                    print("TAP: Starting tracker...");
                    _opt();
                  },
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
                                color: Colors.white, fontSize: 16)),
                        _buttonIcon
                      ]),
                ))));
  }
}
