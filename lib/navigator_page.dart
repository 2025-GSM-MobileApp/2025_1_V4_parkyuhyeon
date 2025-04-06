import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:module_a_002/alarm.dart';
import 'package:module_a_002/home_page.dart';
import 'package:module_a_002/signin.dart';
import 'package:module_a_002/tuils.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  final CurrentIndexClass currentIndex = CurrentIndexClass();

  void signOut() async {
    final response = await get(
      Uri.parse('$baseurl/authenticate/signout'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => SignIn()),
        (_) => false,
      );
    }
  }

  @override
  void initState() {
    currentIndex.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Home(),
      Alarm(),
      Center(
        child: Text(
          'Wortout',
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.w600),
        ),
      ),
      Center(
        child: Text(
          'My Page',
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.w600),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('MY Health DATA'),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            color: lightBlack,
            iconColor: Colors.white,
            itemBuilder:
                (builder) => [
                  PopupMenuItem(
                    onTap: () => signOut(),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: pages[currentIndex.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex.currentIndex,
        onTap: (index) => currentIndex.setCurrentIndex(index),
        backgroundColor: lightBlack,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            backgroundColor: lightBlack,
            icon: SvgPicture.asset(
              'assets/icon/home-1-svgrepo-com.svg',
              width: 30,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlack,
            icon: SvgPicture.asset(
              'assets/icon/alarm-clock-svgrepo-com.svg',
              color: Colors.white,
              width: 30,
            ),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlack,
            icon: SvgPicture.asset(
              'assets/icon/run-on-treadmill-exercise-work-out-run-svgrepo-com.svg',
              color: Colors.white,
              width: 30,
            ),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlack,
            icon: SvgPicture.asset(
              'assets/icon/user-svgrepo-com.svg',
              color: Colors.white,
              width: 30,
            ),
            label: 'My Page',
          ),
        ],
      ),
    );
  }
}
