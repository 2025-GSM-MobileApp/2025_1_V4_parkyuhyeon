import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:module_a_002/tuils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController waterAnimation = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 800),
  );
  final CurrentIndexClass currentIndexClass = CurrentIndexClass();
  Timer? timer;
  bool isLoading = true;
  String username = '';
  String sex = '';
  double height = 182.5;
  double weight = 80.5;
  double bmi = 0;
  List foodList = [];
  int todayStep = 0;
  int targetStep = 5000;
  int lastHeart = 0;
  int minHeartRate = 200;
  int maxHeartRate = 0;
  int todayWater = 0;
  int targetWater = 5000;
  int selectFoodDate = 0;
  File? image;

  void getMyInfo() async {
    final response = await get(
      Uri.parse('$baseurl/home'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      setState(() {
        username = result['mberNm'];
        sex = result['sexdstn'];
        height = result['physical']['height'];
        weight = result['physical']['weight'];
        bmi = double.parse(
          (weight / ((height / 100) * (height / 100))).toStringAsFixed(2),
        );
        todayStep = result['today']['step'];
        targetStep = result['target']['step'];
        todayWater = result['today']['water'];
        targetWater = result['target']['water'];
        foodList = result['today']['foodList'];

        lastHeart = result['today']['lastHeart'] ?? 0;
        for (int i = 0; i < result['today']['heartList'].length; i++) {
          if (result['today']['heartList'][i]['heartRate'] < minHeartRate) {
            minHeartRate = result['today']['heartList'][i]['heartRate'];
          }
          if (result['today']['heartList'][i]['heartRate'] > maxHeartRate) {
            maxHeartRate = result['today']['heartList'][i]['heartRate'];
          }
        }
        waterAnimation.animateTo(
          todayWater / targetWater,
          curve: Curves.easeInCirc,
        );
        isLoading = false;
      });
    }
  }

  void postStep() async {
    var randomValue = math.Random().nextInt(10);
    final response = await post(
      Uri.parse('$baseurl/step'),
      headers: {
        'Authorization': ' Bearer $token',
        'Content-Type': ' application/json',
      },
      body: jsonEncode({"stepCount": randomValue}),
    );
  }

  void postHeartRate() async {
    final response = await post(
      Uri.parse('$baseurl/heart'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      getMyInfo();
    }
  }

  void postWater(int ml) async {
    final response = await post(
      Uri.parse('$baseurl/water'),
      headers: {
        'Authorization': ' Bearer $token',
        'Content-Type': ' application/json',
      },
      body: jsonEncode({"water": ml}),
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      getMyInfo();
    }
  }

  void deleteImage(int index) async {
    final response = await delete(
      Uri.parse('$baseurl/food/$index'),
      headers: {'Authorization': ' Bearer $token'},
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      getMyInfo();
    }
  }

  void postFoodImage() async {
    final request = MultipartRequest('POST', Uri.parse('$baseurl/food'));
    request.headers.addAll({
      'Authorization': ' Bearer $token',
      'Content-Type': ' multipart/form-data',
    });
    request.fields.addAll({
      'foodKndCd':
          selectFoodDate == 0
              ? "B"
              : selectFoodDate == 1
              ? "L"
              : "D",
    });
    request.files.add(await MultipartFile.fromPath('file', image!.path));
    final response = await request.send();

    final result = jsonDecode(await response.stream.bytesToString());
    log(result.toString());
    if (result['success']) {
      getMyInfo();
      image = null;
      Navigator.pop(context);
    }
  }

  void showImageDialog() {
    showDialog(
      context: context,
      builder:
          (builder) => Align(
            alignment: Alignment(0.6, 0.2),
            heightFactor: 1,
            child: Container(
              width: 150,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showFoodImageDialog();
                    },
                    child: Text(
                      'Add food image',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    height: 2,
                    width: double.infinity,
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      bool result = await showAlarmInsertDialog(context);
                      if (result) {
                        setState(() {
                          currentIndexClass.setCurrentIndex(1);
                        });
                        setState(() {});
                      }
                    },
                    child: Text(
                      'Add alarm',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void showAlarmDialog() {
    showDialog(
      context: context,
      builder:
          (builder) => Align(
            alignment: Alignment(0.6, 0.6),
            heightFactor: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  bool result = await showAlarmInsertDialog(context);
                  if (result) {
                    setState(() {
                      currentIndexClass.setCurrentIndex(1);
                    });
                    setState(() {});
                  }
                },
                child: Text('Add alarm', style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
    );
  }

  void showFoodImageDialog() => showDialog(
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
                      'Add food image',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectFoodDate = 0);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 30),
                              padding: EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(color: Colors.black, width: 1),
                              backgroundColor:
                                  selectFoodDate == 0
                                      ? Colors.black
                                      : Colors.white,
                            ),
                            child: Text(
                              'Breakfast',
                              style: TextStyle(
                                color:
                                    selectFoodDate == 0
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectFoodDate = 1);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 30),

                              padding: EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(color: Colors.black, width: 1),
                              backgroundColor:
                                  selectFoodDate == 1
                                      ? Colors.black
                                      : Colors.white,
                            ),
                            child: Text(
                              'Launch',
                              style: TextStyle(
                                color:
                                    selectFoodDate == 1
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectFoodDate = 2);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100, 30),

                              padding: EdgeInsets.symmetric(vertical: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(color: Colors.black, width: 1),
                              backgroundColor:
                                  selectFoodDate == 2
                                      ? Colors.black
                                      : Colors.white,
                            ),
                            child: Text(
                              'Dinner',
                              style: TextStyle(
                                color:
                                    selectFoodDate == 2
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        XFile? result = await pickGallertOrImage();
                        if (result != null) {
                          setState(() => image = File(result.path));
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child:
                            image == null
                                ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 60),
                                  child: Icon(Icons.image_outlined),
                                )
                                : Image.file(image!),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Please select an image area.\nYou can use the gallery or camera.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              image = null;
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
                            onPressed: () {
                              if (image == null) {
                                dialog('죄송합니다! 이미지가 없습니다!', context);
                              } else {
                                postFoodImage();
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

  Future<XFile?> pickGallertOrImage() async {
    XFile? resultImage;

    await showDialog(
      context: context,
      builder:
          (builder) => Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? result = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        resultImage = result;
                        if (resultImage != null) {
                          Navigator.pop(context);
                        }
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
                        'Gallery',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? result = await imagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        resultImage = result;
                        if (resultImage != null) {
                          Navigator.pop(context);
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
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    return resultImage;
  }

  @override
  void initState() {
    waterAnimation.forward();
    getMyInfo();
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      postStep();
      getMyInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    waterAnimation.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? circleIndicator()
        : Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    'Hello $username,',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(sex == 'M' ? Icons.man : Icons.woman, size: 80),
                        Expanded(
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        height.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Cm',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    color: Colors.grey,
                                    width: 2,
                                    height: 50,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        weight.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Kg',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    color: Colors.grey,
                                    width: 2,
                                    height: 50,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        bmi.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'bmi',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  Container(height: 42),
                                  Container(
                                    width: 250,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.green,
                                          Colors.yellow,
                                          Colors.orange,
                                          Colors.red,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: (bmi / 50) * 250,
                                    child: Container(
                                      color: Colors.white,
                                      width: 2,
                                      height: 15,
                                    ),
                                  ),
                                  Positioned(
                                    left: (bmi / 50) * 250 - 24,
                                    top: 22,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Transform.rotate(
                                          angle: 4,
                                          child: Container(
                                            width: 10,
                                            height: 5,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            bmi.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todayStep.toString(),
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '/$targetStep Steps',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Container(height: 50),
                            Container(
                              width: 200,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: math.min(
                                (todayStep / targetStep) * 200,
                                200,
                              ),
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: (todayStep / targetStep) * 200,
                              child: Container(
                                color: Colors.white,
                                width: 2,
                                height: 15,
                              ),
                            ),
                            Positioned(
                              left: (todayStep / targetStep) * 200 - 25,
                              top: 0,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Transform.rotate(
                                    angle: 4,
                                    child: Container(
                                      width: 10,
                                      height: 5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${((todayStep / targetStep) * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Heart Rate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 10,

                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: SvgPicture.asset(
                                'assets/icon/heart-rate-svgrepo-com.svg',
                                width: 30,
                              ),
                            ),
                            Column(
                              spacing: 10,
                              children: [
                                Text(
                                  '$lastHeart bpm',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      postHeartRate();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      backgroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      'Measure',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(height: 70),
                            Positioned(
                              left: 0,
                              top: 40,
                              child: Text(
                                '0',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Positioned(
                              left: 120,
                              top: 40,
                              child: Text(
                                '200',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      (minHeartRate == 200 ? 0 : minHeartRate)
                                          .toDouble(),
                                ),
                                Container(
                                  width:
                                      ((maxHeartRate - minHeartRate < 0
                                              ? 0
                                              : maxHeartRate - minHeartRate) /
                                          200) *
                                      150,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),

                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            Positioned(
                              left:
                                  ((maxHeartRate - minHeartRate < 0
                                              ? 0
                                              : maxHeartRate - minHeartRate) /
                                          200) *
                                      150 -
                                  50,
                              top: 0,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Transform.rotate(
                                    angle: 4,
                                    child: Container(
                                      width: 10,
                                      height: 5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$minHeartRate ~ $maxHeartRate',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Foods',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: SvgPicture.asset(
                            'assets/icon/food-dinner-svgrepo-com.svg',
                            width: 30,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                foodList.length > 5 ? 5 : foodList.length,
                                (index) => Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.network(
                                        'http://api.db.pe.kr:51091/resource/images/food/${foodList[index]['maskNm']}',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      child: GestureDetector(
                                        onTap: () {
                                          deleteImage(
                                            foodList[index]['foodUid'],
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 6,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.close,
                                            color: grey,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => showImageDialog(),
                          icon: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Water',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              child: SvgPicture.asset(
                                'assets/icon/food-dinner-svgrepo-com.svg',
                                width: 30,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: [
                                    Text(
                                      '$todayWater',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '/ $targetWater ml',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          postWater(100);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Text(
                                          '+ 100ml',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          postWater(250);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Text(
                                          '+ 250ml',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Positioned(
                                    left: 3,
                                    child: AnimatedBuilder(
                                      builder: (context, child) {
                                        return Container(
                                          width: 40,
                                          height: waterAnimation.value * 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                      animation: waterAnimation,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/icon/cup-svgrepo-com.svg',
                                    height: 60,
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Transform.rotate(
                                  angle: 4,
                                  child: Container(
                                    width: 10,
                                    height: 5,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(2),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${((todayWater / targetWater) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => showAlarmDialog(),
                          child: Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
