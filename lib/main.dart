import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print('Timestamps enabled in snapshots\n');
  }, onError: (_) {
    print('Error enabling timestamp in snapshots\n');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Social',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primarySwatch: Colors.deepPurple, accentColor: Colors.teal),
      home: Home(),
    );
  }
}
