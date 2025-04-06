import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:module_a_002/profile.dart';
import 'package:module_a_002/signin.dart';
import 'package:module_a_002/tuils.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController userId = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  String? checkString() {
    if (username.text.isEmpty) {
      return '죄송합니다! 사용자 이름은 필수입니다!';
    }
    if (username.text.isEmpty) {
      return '죄송합니다! 사용자 아이디는 필수입니다!';
    }
    if (password.text.isEmpty) {
      return '죄송합니다! 비밀번호는 필수입니다!';
    }
    if (password.text.length < 4) {
      return '죄송합니다! 비밀번호는 4자 이상입니다!';
    }
    if (confirmPassword.text.isEmpty) {
      return '죄송합니다! 비밀번호 확인은 필수입니다!';
    }
    if (confirmPassword.text.length < 4) {
      return '죄송합니다! 비밀번호 확인은 4자 이상입니다!';
    }
    if (confirmPassword.text != password.text) {
      return '죄송합니다! 비밀번호가 일치하지않습니다!';
    } else {
      return null;
    }
  }

  void signup() async {
    String? responseString = checkString();
    if (responseString == null) {
      final response = await post(
        Uri.parse('$baseurl/authenticate/signup'),
        body: {
          "mberId": userId.text,
          "mberPassword": password.text,
          "mberNm": username.text,
        },
      );
      final result = jsonDecode(response.body);
      log(result.toString());
      if (result['success']) {
        signin();
      } else {
        dialog('회원가입 중 오류가 발생했습니다!', context);
      }
    } else {
      dialog(responseString, context);
    }
  }

  void signin() async {
    final response = await post(
      Uri.parse('$baseurl/authenticate/signin'),
      headers: {'Content-Type': ' application/json'},
      body: jsonEncode({"mberId": userId.text, "mberPassword": password.text}),
    );
    final result = jsonDecode(response.body);
    log(result.toString());
    if (result['success']) {
      setState(() {
        token = result['tkn'];
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => Profile()),
        (_) => false,
      );
    } else {
      dialog('로그인중 오류가 발생했습니다!', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your information,',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: userId,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.person, size: 30, color: grey),
                        hintText: 'UserID',
                        hintStyle: TextStyle(
                          fontSize: 15,

                          color: grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: username,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.badge, size: 30, color: grey),
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: password,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.lock, size: 30, color: grey),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontSize: 15,

                          color: grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: confirmPassword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.lock_reset, size: 30, color: grey),
                        hintText: 'Confirm Password',
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
                      onPressed: () => signup(),
                      child: Text(
                        'Sign Up',
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
            Container(
              color: lightGrey,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                spacing: 20,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      onPressed:
                          () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (builder) => SignIn()),
                            (_) => false,
                          ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      onPressed:
                          () => dialog(
                            '죄송합니다! 지원하지 않는 기능입니다! 업데이트 하고 다시 돌아오겠습니다!ㅂㅈ',
                            context,
                          ),
                      child: Text(
                        'Password Reset',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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
