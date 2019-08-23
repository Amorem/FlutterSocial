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
