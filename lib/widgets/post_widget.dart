import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../pages/comments.dart';
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
  String currentUserId = currentUser?.id;
  int likeCount;
  bool isLiked;
  Map likes;
  bool showHeart = false;

  void initState() {
    super.initState();
    likeCount = widget.post.getLikeCount(widget.post.likes);
    likes = widget.post.likes;
    isLiked = (likes[currentUserId] == true);
  }

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
      removeLikeToActivityFeed();
    } else if (!isLiked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': true,
      });
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = (currentUserId != widget.post.ownerId);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.ownerId)
          .collection('feedItems')
          .document(widget.post.postId)
          .setData({
        "type": 'like',
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": timestamp
      });
    }
  }

  removeLikeToActivityFeed() {
    bool isNotPostOwner = (currentUserId != widget.post.ownerId);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.ownerId)
          .collection('feedItems')
          .document(widget.post.postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
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
          bool isPostOwner = currentUserId == widget.post.ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: widget.post.ownerId),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(widget.post.location),
            trailing: isPostOwner
                ? IconButton(
                    onPressed: () => handleDeletePost(context),
                    icon: Icon(Icons.more_vert),
                  )
                : Text(''),
          );
        });
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) => SimpleDialog(
        title: Text("Remove this post ?"),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              deletePost();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          )
        ],
      ),
    );
  }

  // To delete a post, ownerId and currentUserId must be equal.
  deletePost() async {
    // delete post itself
    postsRef
        .document(widget.post.ownerId)
        .collection('userPosts')
        .document(widget.post.postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // delete uploaded image from the post
    storageRef.child('post_${widget.post.postId}.jpg').delete();

    // delete all activity field notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(widget.post.ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: widget.post.postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(widget.post.postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(widget.post.mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 0.2, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.red,
                    ),
                  ),
                )
              : Text('')
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
              onTap: () => showComments(context,
                  postId: widget.post.postId,
                  ownerId: widget.post.ownerId,
                  mediaUrl: widget.post.mediaUrl),
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

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
        postId: postId, postOwnerId: ownerId, postMediaUrl: mediaUrl);
  }));
}
