import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Social',
      debugShowCheckedModeBanner: false,
      home: Text("Hello World"),
    );
  }
}
