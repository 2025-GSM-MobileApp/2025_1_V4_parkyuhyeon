import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

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

class CurrentIndexClass extends ChangeNotifier {
  static final CurrentIndexClass _currentIndexClass = CurrentIndexClass._init();

  CurrentIndexClass._init();

  factory CurrentIndexClass() => _currentIndexClass;

  static int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

Future<bool> showAlarmInsertDialog(BuildContext context) async {
  var selectedAlarm = 1;
  TextEditingController hours = TextEditingController();
  TextEditingController mins = TextEditingController();
  bool connect = false;
  await showDialog(
    context: context,
    builder:
        (builder) => StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add alarm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: CircleAvatar(
                            backgroundColor:
                                selectedAlarm == 0 ? Colors.black : lightGrey,
                            radius: 30,
                            child: SvgPicture.asset(
                              'assets/icon/food-dinner-svgrepo-com.svg',
                              color:
                                  selectedAlarm == 0
                                      ? Colors.white
                                      : Colors.black,
                              width: 30,
                            ),
                          ),
                          onPressed: () => setState(() => selectedAlarm = 0),
                        ),
                        IconButton(
                          onPressed: () => setState(() => selectedAlarm = 1),
                          icon: CircleAvatar(
                            backgroundColor:
                                selectedAlarm == 1 ? Colors.black : lightGrey,
                            radius: 30,
                            child: SvgPicture.asset(
                              'assets/icon/water_drop_FILL0_wght400_GRAD0_opsz24.svg',
                              color:
                                  selectedAlarm == 1
                                      ? Colors.white
                                      : Colors.black,
                              width: 30,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => selectedAlarm = 2),
                          icon: CircleAvatar(
                            backgroundColor:
                                selectedAlarm == 2 ? Colors.black : lightGrey,
                            radius: 30,
                            child: Icon(
                              Icons.more_horiz,
                              color:
                                  selectedAlarm == 2
                                      ? Colors.white
                                      : Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        spacing: 20,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: hours,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],

                              keyboardType: TextInputType.numberWithOptions(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                focusColor: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            'hours',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: mins,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                              keyboardType: TextInputType.numberWithOptions(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                focusColor: Colors.black,
                              ),
                            ),
                          ),

                          Text(
                            'mins',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(color: Colors.black, width: 1),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (hours.text == "" || mins.text == "") {
                                dialog(
                                  '죄송합니다! 시와 분이 들어있지 않습니다! 확인해주세요!',
                                  context,
                                );
                              } else {
                                bool postConnect = await postAlarm(
                                  selectedAlarm,
                                  int.parse(hours.text),
                                  int.parse(mins.text),
                                  context,
                                );
                                connect = postConnect;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(color: Colors.black, width: 1),
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
  );

  return connect;
}

Future<bool> postAlarm(
  int index,
  int hour,
  int mins,
  BuildContext context,
) async {
  CurrentIndexClass currentIndexClass = CurrentIndexClass();
  final response = await post(
    Uri.parse('$baseurl/alarm'),
    headers: {
      'Authorization': ' Bearer $token',
      'Content-Type': 'application/json;charset=UTF-8',
    },
    body: jsonEncode({
      'alarmKndCd':
          index == 0
              ? "F"
              : index == 1
              ? "W"
              : "E",
      'hour': hour,
      'mnt': mins,
    }),
  );
  final result = jsonDecode(response.body);
  log(result.toString());
  if (result['success']) {
    Navigator.pop(context);
    return true;
  }
  return false;
}
