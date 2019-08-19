import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String photoUrl;
  final String bio;

  User(
      {this.id,
      this.username,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        username: doc['username'],
        email: doc['email'],
        displayName: doc['displayName'],
        photoUrl: doc['photoUrl'],
        bio: doc['bio']);
  }
}
