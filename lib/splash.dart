import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:module_a_002/signin.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late final AnimationController logoAnimationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 800),
  );
  late final AnimationController textAnimationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 800),
  );

  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 300),
      () => logoAnimationController.forward(),
    );
    Future.delayed(
      Duration(milliseconds: 800),
      () => textAnimationController.forward(),
    );
    Future.delayed(
      Duration(seconds: 2),
      () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => SignIn()),
        (_) => false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    logoAnimationController.dispose();
    textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: logoAnimationController,
              child: SlideTransition(
                position: logoAnimationController.drive(
                  Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero),
                ),
                child: SvgPicture.asset('assets/logo_symbol/symbol.svg'),
              ),
            ),
            FadeTransition(
              opacity: textAnimationController,
              child: Text(
                'My Health DATA',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
