import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:module_a_002/tuils.dart';

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  bool isLoading = true;
  var alarmList;

  void getAlarm() async {
    final response = await get(
      Uri.parse('$baseurl/alarm'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      setState(() {
        alarmList = result['list'];
        isLoading = false;
      });
    }
  }

  void isOnAlarm(bool isOn, int index) async {
    final response = await put(
      Uri.parse('$baseurl/alarm/$index/${isOn ? "Y" : "N"}'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      getAlarm();
    }
  }

  Widget alarmItem(String knd, int hours, int mnts, bool isOn, int index) =>
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 20,

              children: [
                knd == "F"
                    ? CircleAvatar(
                      backgroundColor: white,
                      radius: 30,
                      child: SvgPicture.asset(
                        'assets/icon/food-dinner-svgrepo-com.svg',
                        color: Colors.black,
                        width: 30,
                      ),
                    )
                    : knd == "W"
                    ? CircleAvatar(
                      backgroundColor: white,
                      radius: 30,
                      child: SvgPicture.asset(
                        'assets/icon/water_drop_FILL0_wght400_GRAD0_opsz24.svg',
                        color: Colors.black,
                        width: 30,
                      ),
                    )
                    : CircleAvatar(
                      backgroundColor: white,
                      radius: 30,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                Text(
                  '$hours : $mnts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Switch(
              value: isOn,
              onChanged: (value) {
                isOnAlarm(value, index);
              },
              thumbIcon: WidgetStatePropertyAll(
                Icon(Icons.circle, color: Colors.white),
              ),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: lightGrey,
              activeTrackColor: Colors.black,
              activeColor: Colors.white,
            ),
          ],
        ),
      );

  @override
  void initState() {
    getAlarm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? circleIndicator()
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      Text(
                        'Alarms',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: black,
                        ),
                      ),
                      Column(
                        spacing: 20,
                        children: List.generate(
                          alarmList.length,
                          (index) => alarmItem(
                            alarmList[index]['alarmKndCd'],
                            alarmList[index]['hour'],
                            alarmList[index]['mnt'],
                            alarmList[index]['useYn'] == "N" ? false : true,
                            alarmList[index]['alarmUid'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton: IconButton(
        onPressed: ()=> showAlarmInsertDialog(context),
        icon: CircleAvatar(
          backgroundColor: black,
          radius: 30,
          child: Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
