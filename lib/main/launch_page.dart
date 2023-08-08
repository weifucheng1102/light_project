import 'dart:async';

import 'package:ali_iot_plugin/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/nav_key.dart';

import '../config/get_box.dart';
import '../login/login.dart';
import 'navigation_page.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({Key? key}) : super(key: key);

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  Timer? _timer;

  ///倒计时5s
  int countTime = 3;
  @override
  void initState() {
    super.initState();
    //开始倒计时
    startCountDown();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  startCountDown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      countTime--;
      if (countTime == 0) {
        gotoNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/launch_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Positioned(
              //   right: 30.w,
              //   top: 30.w,
              //   child: GestureDetector(
              //     onTap: () {
              //       gotoNextPage();
              //     },
              //     child: Container(
              //       width: 110.w,
              //       height: 48.w,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(24.w),
              //         color: Colors.white.withOpacity(0.4),
              //       ),
              //       alignment: Alignment.center,
              //       child: Text(
              //         '跳过',
              //         style: TextStyle(
              //           fontSize: 28.sp,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                bottom: 93.w,
                child: Image.asset(
                  'images/launch_logo.png',
                  width: 270.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  gotoNextPage() async {
    bool? isLogin = await CommonAPI.isLogin;

    NavKey.navKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              (getBox.read('token') == null || isLogin == null || !isLogin
                  ? Login()
                  : NavigationPage()),
        ),
        (route) => route == null);
  }
}
