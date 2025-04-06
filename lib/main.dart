import 'package:flutter/material.dart';
import 'package:module_a_002/splash.dart';
import 'package:module_a_002/tuils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:Colors.white,
        fontFamily: 'NotoSans',
        appBarTheme: AppBarTheme(

          color: lightBlack,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: Splash(),
    );
  }
}
