import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:module_a_002/navigator_page.dart';
import 'package:module_a_002/signup.dart';
import 'package:module_a_002/tuils.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String? checkString() {
    if (username.text.isEmpty) {
      return '죄송합니다! 사용자 이름은 필수입니다!';
    }
    if (username.text.length < 4) {
      return '죄송합니다! 사용자 이름은 4자 이상입니다!';
    }
    if (username.text.contains(' ')) {
      return '죄송합니다! 사용자 이름에 공백은 사용 불가합니다!';
    }
    if (password.text.isEmpty) {
      return '죄송합니다! 비밀번호는 필수입니다!';
    }
    if (password.text.length < 4) {
      return '죄송합니다! 비밀번호는 4자 이상입니다!';
    } else {
      return null;
    }
  }

  void signin() async {
    String? responseString = checkString();
    if (responseString == null) {
      final response = await post(
        Uri.parse('$baseurl/authenticate/signin'),
        headers: {'Content-Type': ' application/json'},
        body: jsonEncode({
          "mberId": username.text,
          "mberPassword": password.text,
        }),
      );
      final result = jsonDecode(response.body);
      log(result.toString());
      if (result['success']) {
        setState(() {
          token = result['tkn'];
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => NavigatorPage()),
          (_) => false,
        );
      } else {
        dialog('로그인중 오류가 발생했습니다!', context);
      }
    } else {
      dialog(responseString, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('My Health DATA', style: TextStyle(fontSize: 30)),
        backgroundColor: black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/logo_symbol/symbol.svg'),
                  Text(
                    'Please enter your information.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                      controller: username,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.person, size: 30, color: grey),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                      onPressed: () => signin(),
                      child: Text(
                        'Sign In',
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
                        backgroundColor: Colors.black,
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (builder) => SignUp()),
                          ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
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
                            '죄송합니다! 지원하지 않는 기능입니다!\n업데이트 하고 다시 돌아오겠습니다!',
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
