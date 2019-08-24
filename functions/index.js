const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    console.log("Follower Created", snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1. Create followed users posts
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    // 2. Create following user's timeline
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    // 3. Get the followed users posts
    const querySnapshot = await followedUserPostsRef.get();
    console.log("QuerySnapshot", querySnapshot.size);

    // 4. Add each user post to following user's timeline
    querySnapshot.forEach(doc => {
      if (doc.exist) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // get all the followers from the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");
    const querySnapshot = await userFollowersRef.get();

    // add new post to each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUdpated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");
    const querySnapshot = await userFollowersRef.get();
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUdpated);
          }
        });
    });
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");
    const querySnapshot = await userFollowersRef.get();
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete(postUdpated);
          }
        });
    });
  });

exports.onCreateActivityFeedItem = functions.firestore
  .document("/feed/{userId}/feedItems/{activityFeedItem}")
  .onCreate(async (snapshot, context) => {
    console.log("Activity Feed Item created", snapshot.data());

    // get user connected to the feed
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();

    // check if they have a notification token
    const androidNotificationToken = doc.data().androidNotificationToken;
    if (androidNotificationToken) {
      // send notification
      sendNotification(androidNotificationToken, snapshot.data());
    } else {
      console.log("No token for user, cannot send notification");
    }

    function sendNotification(androidNotificationToken, activityFeedItem) {
      let body;
      switch (activityFeedItem.type) {
        case "comment":
          body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
          break;

        case "like":
          body = `${activityFeedItem.username} liked your post`;
          break;

        case "follow":
          body = `${activityFeedItem.username} started following you`;
          break;

        default:
          break;
      }

      // create message for pusn notification
      const message = {
        notification: {
          body
        },
        token: androidNotificationToken,
        data: { recipient: userId }
      };

      // send message with admin.messaging
      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log("Successsfully sent message", response);
        })
        .catch(error => console.log("Error sending notification", error));
    }
  });
