import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sleepyroom/models/sleep_log.dart';
import 'package:sleepyroom/models/snapshot.dart';
import 'package:sleepyroom/ui/helpers.dart';

enum Status { Initialised, Recording, Stopped }

class SleepTracker extends StatefulWidget {
  _SleepTrackerState createState() => _SleepTrackerState();
}

const initialTitleText = "Tap to start!";
const initialBodyText = "Don't forget to turn this off when you wake up!";

const recordingTitleText = "Tap to finish!";
const recordingBodyText = "";

const finalTitleText = "Recording complete!";
const finalBodyText = "";

class _SleepTrackerState extends State<SleepTracker> {
  Status status;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);

  FlutterSound _flutterSound;
  StreamSubscription<double> _dbPeakSubscription;
  SleepLog _currentSleepLog;
  String titleText;
  String bodyText;

  @override
  void initState() {
    super.initState();
    titleText = initialTitleText;
    bodyText = initialBodyText;

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

    var updateIntervalInSecs = 1.0;
    _flutterSound.setDbLevelEnabled(true);
    _flutterSound.setDbPeakLevelUpdate(updateIntervalInSecs);
  }

  void _startRecording() async {
    // note to self: make a PR for flutter_sound to fix their example code
    String path = await _flutterSound.startRecorder(null);
    print('recording to: $path');

    _currentSleepLog = await SleepLog.withoutId(startDate: DateTime.now());
    _currentSleepLog.insert();

    setState(() {
      status = Status.Recording;
      _buttonIcon = _getPlayerIcon(status);
      _dbPeakSubscription =
          _flutterSound.onRecorderDbPeakChanged.listen((value) async {
        var _dbLevel = value;
        var _timestamp = DateTime.now();

        Snapshot snapshot = await Snapshot.withoutId(
            timestamp: _timestamp,
            lightScore: -1,
            noiseScore: _dbLevel.toInt());

        print(snapshot);
        var snapshotId = await snapshot.insert();

        print("Created snapshot with ID: $snapshotId at $_dbLevel DB");
      });
    });
  }

  void _stopRecording() async {
    // Get snapshots for the sleep log
    _currentSleepLog.endDate = DateTime.now();
    var snapshots = await Snapshot.getAllFor(_currentSleepLog);

    // Calculate scores
    _currentSleepLog.lightScore = -1;
    _currentSleepLog.noiseScore =
        snapshots.fold(0, (total, snapshot) => total + snapshot.noiseScore);

    // Save the scores
    await _currentSleepLog.update();

    String result = await _flutterSound.stopRecorder();
    print("Stopped recording: $result");

    if (_dbPeakSubscription != null) {
      _dbPeakSubscription.cancel();
    }

    setState(() {
      status = Status.Stopped;
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
    if (_flutterSound.isRecording) {
      _flutterSound.stopRecorder();
    }
    super.dispose();
  }

  void _clickHandler() async {
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
          setState(() {
            status = Status.Initialised;
//            _flutterSound = new FlutterSound();
//            _buttonIcon = _getPlayerIcon(status);
          });
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
          titleText = initialTitleText;
          bodyText = initialBodyText;
          return empty();
        }
      case Status.Recording:
        {
          titleText = recordingTitleText;
          bodyText = recordingBodyText;
          return Icon(Icons.stop);
        }
      case Status.Stopped:
        {
          titleText = finalTitleText;
          bodyText = finalBodyText;
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
        body: SizedBox.expand(
          child: new Material(
              color: Colors.deepPurple,
              child: new InkWell(
                onTap: () {
                  _clickHandler();
                },
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(titleText != null ? titleText : "",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      new Text(bodyText != null ? bodyText : "",
                          style:
                              new TextStyle(color: Colors.white, fontSize: 16)),
                      _buttonIcon
                    ]),
              )),
        ));
  }
}
