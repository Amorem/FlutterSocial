import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../pages/home.dart';
import 'custom_image.dart';
import 'progress.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  PostWidget(this.post);

  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.document(post.ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {},
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(post.location),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {},
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(post.mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () {},
              child:
                  Icon(Icons.favorite_border, size: 28.0, color: Colors.pink),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.chat, size: 28.0, color: Colors.blue[900]),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '${post.getLikeCount(post.likes)} likes',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '${post.username}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(post.description),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
