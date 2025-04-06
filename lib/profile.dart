import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:module_a_002/signin.dart';
import 'package:module_a_002/tuils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  String? sex;
  final TextEditingController username = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController birthday = TextEditingController();
  final TextEditingController targetStep = TextEditingController();
  final TextEditingController targetWater = TextEditingController();

  void getProfile() async {
    final response = await get(
      Uri.parse('$baseurl/profile'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      setState(() {
        username.text = result['mberNm'];
        sex = result['sexdstn'];
        birthday.text = result['brthdy'];
        height.text = result['physical']['height'].toString();
        weight.text = result['physical']['weight'].toString();
        targetStep.text = result['target']['step'].toString();
        targetWater.text = result['target']['water'].toString();
        isLoading = false;
      });
    } else {
      dialog('프로필을 불러오는중 오류가 발생했습니다!', context);
    }
  }

  void postProfile() async {
    final response = await put(
      Uri.parse('$baseurl/profile'),
      headers: {
        'Authorization': ' Bearer $token',
        'Content-Type': ' application/json',
      },
      body: jsonEncode({
        "mberNm": username.text,
        "sexdstn": sex,
        "height": double.parse(height.text),
        "weight": double.parse(weight.text),
        "brthdy": birthday.text,
        "stepTarget": int.parse(targetStep.text),
        "waterTarget": int.parse(targetWater.text),
      }),
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => SignIn()),
        (_) => false,
      );
    } else {
      dialog('프로필 업데이트중 오류가 발생했습니다!', context);
    }
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Target'),
        leading: BackButton(color: Colors.white),
      ),
      body:
          isLoading
              ? circleIndicator()
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi ${username.text}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: black,
                            ),
                          ),
                          Text(
                            'Profile,',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: black,
                            ),
                          ),
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: lightGrey,
                                    foregroundColor: Colors.white,

                                    elevation: 0,
                                    side: BorderSide(
                                      color:
                                          sex == 'M'
                                              ? grey
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.all(16),
                                  ),
                                  onPressed: () => setState(() => sex = "M"),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.man,
                                        color: sex == "M" ? black : grey,
                                        size: 100,
                                      ),
                                      Text(
                                        'Male',
                                        style: TextStyle(
                                          color: sex == "M" ? black : grey,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: lightGrey,

                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                      color:
                                          sex == "F"
                                              ? grey
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.all(16),
                                  ),
                                  onPressed: () => setState(() => sex = "F"),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.woman,
                                        color: sex == "F" ? black : grey,
                                        size: 100,
                                      ),
                                      Text(
                                        'Female',
                                        style: TextStyle(
                                          color: sex == "F" ? black : grey,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: username,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(Icons.person, size: 30, color: grey),
                                hintText:
                                    username.text == ""
                                        ? 'username'
                                        : username.text,
                                hintStyle: TextStyle(
                                  fontSize: 15,

                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: height,
                              decoration: InputDecoration(
                                suffixIconConstraints: BoxConstraints(
                                  minHeight: 10,
                                  minWidth: 10,
                                ),
                                suffixIcon: Text(
                                  'Cm',
                                  style: TextStyle(color: grey),
                                ),

                                border: InputBorder.none,
                                icon: SvgPicture.asset(
                                  'assets/icon/height-svgrepo-com.svg',
                                  width: 30,
                                  color: grey,
                                ),
                                hintText:
                                    height.text == "" ? '00.0' : height.text,
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: weight,
                              decoration: InputDecoration(
                                suffixIconConstraints: BoxConstraints(
                                  minHeight: 10,
                                  minWidth: 10,
                                ),
                                suffixIcon: Text(
                                  'Kg',
                                  style: TextStyle(color: grey),
                                ),
                                border: InputBorder.none,
                                icon: SvgPicture.asset(
                                  'assets/icon/weight-svgrepo-com.svg',
                                  width: 30,
                                  color: grey,
                                ),
                                hintText:
                                    weight.text == "" ? '00.0' : weight.text,
                                hintStyle: TextStyle(
                                  fontSize: 15,

                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: birthday,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: SvgPicture.asset(
                                  'assets/icon/cake-svgrepo-com.svg',
                                  width: 30,
                                  color: grey,
                                ),
                                hintText:
                                    birthday.text == ""
                                        ? 'YYYY.MM.DD'
                                        : birthday.text,

                                hintStyle: TextStyle(
                                  fontSize: 15,

                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Target,',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: black,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: targetStep,
                              decoration: InputDecoration(
                                suffixIconConstraints: BoxConstraints(
                                  minHeight: 10,
                                  minWidth: 10,
                                ),
                                suffixIcon: Text(
                                  'Steps',
                                  style: TextStyle(color: grey),
                                ),

                                border: InputBorder.none,
                                icon: SvgPicture.asset(
                                  'assets/icon/footprint_FILL0_wght400_GRAD0_opsz24.svg',
                                  width: 30,
                                  color: grey,
                                ),
                                hintText:
                                    targetStep.text == ""
                                        ? '0.00'
                                        : targetStep.text,
                                hintStyle: TextStyle(
                                  fontSize: 15,

                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lightGrey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: targetWater,
                              decoration: InputDecoration(
                                suffixIconConstraints: BoxConstraints(
                                  minHeight: 10,
                                  minWidth: 10,
                                ),
                                suffixIcon: Text(
                                  'ml',
                                  style: TextStyle(color: grey),
                                ),

                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.water_drop_outlined,
                                  size: 30,
                                  color: grey,
                                ),
                                hintText:
                                    targetWater.text == ""
                                        ? '0.00'
                                        : targetWater.text,
                                hintStyle: TextStyle(
                                  fontSize: 15,

                                  color: grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: lightBlack,
                              ),
                              onPressed: () => postProfile(),
                              child: Text(
                                'Complete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
