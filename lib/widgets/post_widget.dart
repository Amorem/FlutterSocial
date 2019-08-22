import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../pages/home.dart';
import 'custom_image.dart';
import 'progress.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget(this.post);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  void initState() {
    super.initState();
    likeCount = widget.post.getLikeCount(widget.post.likes);
    likes = widget.post.likes;
    isLiked = (likes[currentUserId] == true);
  }

  final String currentUserId = currentUser?.id;
  int likeCount;
  bool isLiked;
  Map likes;

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': false,
      });
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!isLiked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': true,
      });
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.document(widget.post.ownerId).get(),
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
            subtitle: Text(widget.post.location),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(widget.post.mediaUrl),
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
              onTap: handleLikePost,
              child: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0, color: Colors.pink),
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
                '$likeCount likes',
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
                '${widget.post.username}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(widget.post.description),
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
