import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/custom_image.dart';

import '../models/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
