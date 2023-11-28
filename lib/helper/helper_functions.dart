import 'package:flutter/material.dart';


Future screenPush(BuildContext context, Widget widget) async {
  return await Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

Future getValueAfterScreenPush(BuildContext context, Widget widget) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );
}

Future screenPushRep(BuildContext context, Widget widget) {
  return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget), (Route<dynamic> route) => false);
}

void showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
  ));
}
