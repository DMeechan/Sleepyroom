import 'package:flutter/material.dart';

Widget loading() {
  return Center(child: CircularProgressIndicator(backgroundColor: Colors.deepPurpleAccent));
}

// Source: https://stackoverflow.com/a/55796929/4752388
Widget empty() {
  return SizedBox.shrink();
}