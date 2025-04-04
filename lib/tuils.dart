import 'package:flutter/material.dart';

final String baseurl = 'http://api.db.pe.kr:51091/api';

String token = '';

final Color white = Colors.white;
final Color black = Colors.black;
final Color lightBlack = Color(0xff272727);
final Color grey = Colors.grey;
final Color lightGrey = Color(0xffe4e4e4);

void dialog(String content, BuildContext context) {
  showDialog(
    context: context,
    builder:
        (builder) => AlertDialog(
          title: Text('Error!'),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인했습니다!'),
            ),
          ],
        ),
  );
}

Widget circleIndicator() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}
