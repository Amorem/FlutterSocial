import 'package:flutter/material.dart';

AppBar header(BuildContext context,
    {bool isAppTitle = false, String titleText}) {
  return AppBar(
    title: Text(
      isAppTitle ? 'Flutter Social' : titleText,
      style: TextStyle(
          color: Colors.white,
          fontFamily: isAppTitle ? 'Signatra' : "",
          fontSize: isAppTitle ? 50.0 : 22.0),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
