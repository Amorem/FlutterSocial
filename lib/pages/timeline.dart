import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/header.dart';
import '../widgets/progress.dart';

final CollectionReference usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    getUserById();
    super.initState();
  }

  getUsers() async {
    QuerySnapshot snapshot = await usersRef.getDocuments();
    snapshot.documents.forEach((DocumentSnapshot doc) {
      print(doc.data);
    });
  }

  getUserById() async {
    final String id = 'cRsyLyqKIGm1F20cWINX';

    DocumentSnapshot doc = await usersRef.document(id).get();
    print('User $id ${doc.data}');
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: linearProgress(),
    );
  }
}
